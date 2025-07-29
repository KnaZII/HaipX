#include "Player.hpp"

#include <algorithm>
#define GLM_ENABLE_EXPERIMENTAL
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <utility>

#include "content/ContentReport.hpp"
#include "items/Inventory.hpp"
#include "Entities.hpp"
#include "rigging.hpp"
#include "physics/Hitbox.hpp"
#include "physics/PhysicsSolver.hpp"
#include "voxels/Chunks.hpp"
#include "window/Camera.hpp"
#include "world/Level.hpp"
#include "data/dv_util.hpp"
#include "debug/Logger.hpp"
#include "logic/scripting/lua/lua_engine.hpp"

static debug::Logger logger("player");

constexpr float CROUCH_SPEED_MUL = 0.35f;
constexpr float RUN_SPEED_MUL = 1.5f;
constexpr float PLAYER_GROUND_DAMPING = 10.0f;
constexpr float PLAYER_AIR_DAMPING = 8.0f;
constexpr float FLIGHT_SPEED_MUL = 4.0f;
constexpr float CHEAT_SPEED_MUL = 5.0f;
constexpr float JUMP_FORCE = 8.0f;
constexpr int SPAWN_ATTEMPTS_PER_UPDATE = 64;

Player::Player(
    Level& level,
    int64_t id,
    const std::string& name,
    glm::vec3 position,
    float speed,
    std::shared_ptr<Inventory> inv,
    entityid_t eid
)
    : level(level),
      id(id),
      name(name),
      speed(speed),
      chosenSlot(0),
      position(position),
      inventory(std::move(inv)),
      eid(eid),
      chunks(std::make_unique<Chunks>(
          3, 3, 0, 0, level.events.get(), *level.content.getIndices()
      )),
      fpCamera(level.getCamera("core:first-person")),
      spCamera(level.getCamera("core:third-person-front")),
      tpCamera(level.getCamera("core:third-person-back")),
      currentCamera(fpCamera) {
    fpCamera->setFov(glm::radians(90.0f));
    spCamera->setFov(glm::radians(90.0f));
    tpCamera->setFov(glm::radians(90.0f));
}

Player::~Player() = default;

void Player::updateEntity() {
    if (eid == ENTITY_AUTO) {
        const auto& defaults = level.content.getDefaults();
        const auto& defName = defaults["player-entity"].asString();
        if (!defName.empty()) {
            auto& def = level.content.entities.require(defName);
            eid = level.entities->spawn(def, getPosition());
            if (auto entity = level.entities->get(eid)) {
                entity->setPlayer(id);
            }
        }
    } else if (auto entity = level.entities->get(eid)) {
        position = entity->getTransform().pos;
        if (auto entity = level.entities->get(eid)) {
            entity->setPlayer(id);
        }
    } else if (chunks->getChunkByVoxel(position) && eid != ENTITY_NONE) {
        logger.error() << "player entity despawned or deleted; "
                          "will be respawned";
        eid = ENTITY_AUTO;
    }
    auto hitbox = getHitbox();
    if (hitbox == nullptr) {
        return;
    }
    hitbox->linearDamping = PLAYER_GROUND_DAMPING;
    hitbox->verticalDamping = flight;
    hitbox->gravityScale = flight ? 0.0f : 1.0f;
    if (flight || !hitbox->grounded) {
        hitbox->linearDamping = PLAYER_AIR_DAMPING;
    }
    hitbox->type = noclip ? BodyType::KINEMATIC : BodyType::DYNAMIC;
}

Hitbox* Player::getHitbox() {
    if (auto entity = level.entities->get(eid)) {
        return &entity->getRigidbody().hitbox;
    }
    return nullptr;
}

void Player::updateInput(PlayerInput& input, float delta) {
    auto hitbox = getHitbox();
    if (hitbox == nullptr) {
        return;
    }
    bool crouch = input.shift && hitbox->grounded && !input.sprint;
    float speed = this->speed;
    if (flight) {
        speed *= FLIGHT_SPEED_MUL;
    }
    if (input.cheat) {
        speed *= CHEAT_SPEED_MUL;
    }

    hitbox->crouching = crouch;
    if (crouch) {
        speed *= CROUCH_SPEED_MUL;
    } else if (input.sprint) {
        speed *= RUN_SPEED_MUL;
    }

    glm::vec3 dir(0, 0, 0);
    if (input.moveForward) {
        dir += fpCamera->dir;
    }
    if (input.moveBack) {
        dir -= fpCamera->dir;
    }
    if (input.moveRight) {
        dir += fpCamera->right;
    }
    if (input.moveLeft) {
        dir -= fpCamera->right;
    }
    if (glm::length(dir) > 0.0f) {
        dir = glm::normalize(dir);
        hitbox->velocity += dir * speed * delta * 9.0f;
    }
    if (flight) {
        if (input.jump) {
            hitbox->velocity.y += speed * delta * 9;
        }
        if (input.shift) {
            hitbox->velocity.y -= speed * delta * 9;
        }
    }
    if (input.jump && hitbox->grounded) {
        hitbox->velocity.y = JUMP_FORCE;
    }
}

void Player::updateSelectedEntity() {
    selectedEid = selection.entity;
}

void Player::postUpdate() {
    auto entity = level.entities->get(eid);
    if (!entity.has_value()) {
        return;
    }
    auto& hitbox = entity->getRigidbody().hitbox;
    position = hitbox.position;

    if (flight && hitbox.grounded && !noclip) {
        flight = false;
    }
    if (spawnpoint.y <= 0.1) {
        for (int i = 0; i < SPAWN_ATTEMPTS_PER_UPDATE; i++) {
            attemptToFindSpawnpoint();
        }
    }

    // TODO: ERASE & FORGET
    auto& skeleton = entity->getSkeleton();
    skeleton.visible = currentCamera != fpCamera;
}

void Player::teleport(glm::vec3 position) {
    this->position = position;

    if (auto entity = level.entities->get(eid)) {
        entity->getRigidbody().hitbox.position = position;
        entity->getTransform().setPos(position);
        entity->setInterpolatedPosition(position);
    }
}

void Player::attemptToFindSpawnpoint() {
    glm::vec3 newpos(
        position.x + (rand() % 200 - 100),
        rand() % 80 + 100,
        position.z + (rand() % 200 - 100)
    );
    while (newpos.y > 0 &&
           !chunks->isObstacleBlock(newpos.x, newpos.y - 2, newpos.z)) {
        newpos.y--;
    }

    voxel* headvox = chunks->get(newpos.x, newpos.y + 1, newpos.z);
    if (chunks->isObstacleBlock(newpos.x, newpos.y, newpos.z) ||
        headvox == nullptr || headvox->id != 0) {
        return;
    }
    spawnpoint = newpos + glm::vec3(0.5f, 0.0f, 0.5f);
    teleport(spawnpoint);
}

void Player::setChosenSlot(int index) {
    chosenSlot = index;
}

int Player::getChosenSlot() const {
    return chosenSlot;
}

float Player::getSpeed() const {
    return speed;
}

bool Player::isSuspended() const {
    return suspended;
}

void Player::setSuspended(bool flag) {
    suspended = flag;
}

bool Player::isFlight() const {
    return flight;
}

void Player::setFlight(bool flag) {
    this->flight = flag;
}

bool Player::isNoclip() const {
    return noclip;
}

void Player::setNoclip(bool flag) {
    this->noclip = flag;
}

bool Player::isInfiniteItems() const {
    return infiniteItems;
}

void Player::setInfiniteItems(bool flag) {
    infiniteItems = flag;
}

bool Player::isInstantDestruction() const {
    return instantDestruction;
}

void Player::setInstantDestruction(bool flag) {
    instantDestruction = flag;
}

bool Player::isLoadingChunks() const {
    return loadingChunks;
}

void Player::setLoadingChunks(bool flag) {
    loadingChunks = flag;
}

entityid_t Player::getEntity() const {
    return eid;
}

void Player::setEntity(entityid_t eid) {
    this->eid = eid;
}

// Survival system implementation
void Player::setHealth(float value) {
    health = std::clamp(value, 0.0f, maxHealth);
}

void Player::setMaxHealth(float value) {
    maxHealth = std::max(1.0f, value);
    health = std::min(health, maxHealth);
}

void Player::setHunger(float value) {
    hunger = std::clamp(value, 0.0f, maxHunger);
}

void Player::setMaxHunger(float value) {
    maxHunger = std::max(1.0f, value);
    hunger = std::min(hunger, maxHunger);
}

void Player::setSurvivalMode(bool mode) {
    survivalMode = mode;
    if (!survivalMode) {
        // В креативном режиме восстанавливаем здоровье и голод
        health = maxHealth;
        hunger = maxHunger;
    }
}

void Player::updateSurvival(float delta) {
    if (!survivalMode) {
        return;
    }
    
    // Система голода
    hungerTimer += delta;
    if (hungerTimer >= 4.0f) { // Каждые 4 секунды
        hungerTimer = 0.0f;
        if (hunger > 0) {
            hunger = std::max(0.0f, hunger - 0.5f);
        }
    }
    
    // Система регенерации здоровья
    if (hunger >= 18.0f) { // Если голод больше 18, регенерируем здоровье
        healthRegenTimer += delta;
        if (healthRegenTimer >= 4.0f) { // Каждые 4 секунды
            healthRegenTimer = 0.0f;
            if (health < maxHealth) {
                health = std::min(maxHealth, health + 1.0f);
            }
        }
    } else {
        healthRegenTimer = 0.0f;
    }
    
    // Урон от голода
    if (hunger <= 0) {
        healthRegenTimer += delta;
        if (healthRegenTimer >= 4.0f) { // Каждые 4 секунды
            healthRegenTimer = 0.0f;
            if (health > 0) {
                health = std::max(0.0f, health - 1.0f);
            }
        }
    }
}

// Block breaking system implementation
void Player::startBreaking(glm::ivec3 pos, float time) {
    if (breakingBlock != pos) {
        breakingBlock = pos;
        breakingProgress = 0.0f;
        breakingTime = time;
        isBreaking = true;
    }
}

void Player::stopBreaking() {
    isBreaking = false;
    breakingProgress = 0.0f;
    breakingBlock = glm::ivec3(-1, -1, -1);
    
    // Убираем трещины
    if (breakingCrackId != -1) {
        auto L = lua::get_main_state();
        if (L && lua::getglobal(L, "blockwraps")) {
            if (lua::getfield(L, "remove", -1)) {
                lua::pushinteger(L, breakingCrackId);
                lua::call(L, 1, 0);
            }
            lua::pop(L); // pop blockwraps
        }
        breakingCrackId = -1;
    }
}

void Player::updateBreaking(float delta) {
    if (!isBreaking || instantDestruction) {
        return;
    }
    
    breakingProgress += delta;
    if (breakingProgress >= breakingTime) {
        // Блок разрушен
        isBreaking = false;
        breakingProgress = 0.0f;
        // Здесь будет вызов разрушения блока
    }
}

entityid_t Player::getSelectedEntity() const {
    return selectedEid;
}

void Player::setName(const std::string& name) {
    this->name = name;
}

const std::string& Player::getName() const {
    return name;
}

const std::shared_ptr<Inventory>& Player::getInventory() const {
    return inventory;
}

void Player::setSpawnPoint(glm::vec3 spawnpoint) {
    this->spawnpoint = spawnpoint;
}

glm::vec3 Player::getSpawnPoint() const {
    return spawnpoint;
}

glm::vec3 Player::getRotation(bool interpolated) const {
    if (interpolated) {
        return rotationInterpolation.getCurrent();
    }
    return rotation;
}

void Player::setRotation(const glm::vec3& rotation) {
    this->rotation = rotation;
    rotationInterpolation.refresh(rotation);
}

dv::value Player::serialize() const {
    auto root = dv::object();

    root["id"] = id;
    root["name"] = name;

    root["position"] = dv::to_value(position);
    root["rotation"] = dv::to_value(rotation);
    root["spawnpoint"] = dv::to_value(spawnpoint);

    root["flight"] = flight;
    root["noclip"] = noclip;
    root["suspended"] = suspended;
    root["infinite-items"] = infiniteItems;
    root["instant-destruction"] = instantDestruction;
    root["loading-chunks"] = loadingChunks;
    root["chosen-slot"] = chosenSlot;
    root["entity"] = eid;
    root["inventory"] = inventory->serialize();
    
    // Survival system serialization
    root["health"] = health;
    root["max-health"] = maxHealth;
    root["hunger"] = hunger;
    root["max-hunger"] = maxHunger;
    root["survival-mode"] = survivalMode;
    auto found =
        std::find(level.cameras.begin(), level.cameras.end(), currentCamera);
    if (found != level.cameras.end()) {
        root["camera"] = level.content.getIndices(ResourceType::CAMERA)
                .getName(found - level.cameras.begin());
    }
    return root;
}

void Player::deserialize(const dv::value& src) {
    src.at("id").get(id);
    src.at("name").get(name);

    const auto& posarr = src["position"];

    dv::get_vec(posarr, position);
    fpCamera->position = position;

    const auto& rotarr = src["rotation"];
    dv::get_vec(rotarr, rotation);

    const auto& sparr = src["spawnpoint"];
    setSpawnPoint(glm::vec3(
        sparr[0].asNumber(), sparr[1].asNumber(), sparr[2].asNumber()));

    flight = src["flight"].asBoolean();
    noclip = src["noclip"].asBoolean();
    src.at("suspended").get(suspended);
    src.at("infinite-items").get(infiniteItems);
    src.at("instant-destruction").get(instantDestruction);
    src.at("loading-chunks").get(loadingChunks);

    setChosenSlot(src["chosen-slot"].asInteger());
    eid = src["entity"].asNumber();
    
    // Survival system deserialization
    if (src.has("health")) {
        health = src["health"].asNumber();
    }
    if (src.has("max-health")) {
        maxHealth = src["max-health"].asNumber();
    }
    if (src.has("hunger")) {
        hunger = src["hunger"].asNumber();
    }
    if (src.has("max-hunger")) {
        maxHunger = src["max-hunger"].asNumber();
    }
    if (src.has("survival-mode")) {
        survivalMode = src["survival-mode"].asBoolean();
    }

    if (src.has("inventory")) {
        getInventory()->deserialize(src["inventory"]);
    }

    if (src.has("camera")) {
        std::string name = src["camera"].asString();
        if (auto camera = level.getCamera(name)) {
            currentCamera = camera;
        }
    }
}

void Player::convert(dv::value& data, const ContentReport* report) {
    if (data.has("players")) {
        auto& players = data["players"];
        for (uint i = 0; i < players.size(); i++) {
            auto& playerData = players[i];
            if (playerData.has("inventory")) {
                Inventory::convert(playerData["inventory"], report);
            }
        }

    } else if (data.has("inventory")){
        Inventory::convert(data["inventory"], report);
    }
}
