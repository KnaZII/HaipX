# 0.28 - 2025.07.18

[Documentation](https://github.com/MihailRis/HaipX-Cpp/tree/release-0.28/doc/en/main-page.md) for 0.28

Table of contents:

- [Added](#added)
    - [Changes](#changes)
    - [Functions](#functions)
- [Fixes](#fixes)

## Added

- advanced graphics mode
- state bits based models
- post-effects
- ui elements:
    - iframe
    - select
    - modelviewer
- vcm models format
- bit.compile
- yaml encoder/decoder
- error handler argument in http.get, http.post
- ui properties:
    - image.region
- rotation profiles:
    - stairs
- libraries
    - gfx.posteffects
    - yaml
- stairs rotation profile
- models editing in console
- syntax highlighting: xml, glsl, vcm
- beginning of projects system

### Changes

- reserved 'project', 'pack', 'packid', 'root' entry points
- Bytearray optimized with FFI
- chunks non-unloading zone limited with circle 

### Functions

- yaml.tostring
- yaml.parse
- gfx.posteffects.index
- gfx.posteffects.set_effect
- gfx.posteffects.get_intensity
- gfx.posteffects.set_intensity
- gfx.posteffects.is_active
- gfx.posteffects.set_params
- gfx.posteffects.set_array
- block.get_variant
- block.set_variant
- bit.compile
- Bytearray_as_string

## Fixes

- fix: "unknown argument --memcheck" in vctest
- fix "upgrade square is not fully inside of area" error
- fix generator area centering
- fix incomplete content reset
- fix stack traces
- fix containers refreshing
- fix toml encoder
- fix InputBindBox
- fix inventory.* functions error messages
- fix: validator not called after backspace
- fix: missing pack.has_indices if content is not loaded
- fix: entities despawn on F5
- bug fix [#549]
- fix player camera zoom with fov-effects disabled
