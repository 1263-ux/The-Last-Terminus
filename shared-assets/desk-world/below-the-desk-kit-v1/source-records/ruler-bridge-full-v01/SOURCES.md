# SOURCES.md — ruler-bridge-full v01

## Reference

- `BelowTheDesk_Muse_Handoff_v0.2/06_REFERENCE_LIBRARY/images/reference_board_02_character_material_environment.png`
  — board 02, main scene ruler bridge (board x~430–1300, y~400–560).
  Crops examined during the build: `/tmp/ruler_span.png`,
  `/tmp/ruler_numerals.png`, `/tmp/ruler_mid.png` (ephemeral, not kept).
- Consistency baseline: case-3 bridge-end manifest
  (`ab/case-3-small-scene/runs/new-v1/assets/ruler-bridge-end/versions/v01/manifest.json`)
  — plank cross-section, tick geometry, materials, bracket/post
  construction. No geometry or code copied verbatim; the build script
  was rewritten for the 8.0 span with parametrised posts/brackets.
- Game constants (read-only, for proportion context):
  `web/src/state.js` — RULER_LEN = 340, RULER_VIS_W = 115,
  RULER_W = 60. Not used as a scale authority (game units are
  arbitrary vs model units); recorded for traceability only.

## External assets

None. All geometry is procedural (Blender Python); the numeral
texture is generated inside the build script (5×7 bitmap font,
pure-Python PNG encoder). No downloads, no accounts, $0 spent.

## Skills / process sources

- `~/workspace/custom-skills/blender-production/SKILL.md` (dispatch:
  mandatory closed loop, version-gated state, three-round rule,
  lock files).
- Case-3 generic scripts (`ab/case-3-small-scene/runs/new-v1/scripts/`):
  `render.py`, `check_geometry.py`, `export_glb.py`,
  `reimport_glb.py` copied unchanged; `validate_glb.py` adapted
  (expects exactly 1 image / 1 texture, checks `baseColorTexture`
  on `MAT_ruler_numerals`); `three_check.mjs` new (Node GLTFLoader
  load, `self` polyfill for Node).
- Vendored capability modules used as reference only (no code
  copied): blender-modeler, blender-materials, blender-export,
  blender-uv-texturing.
