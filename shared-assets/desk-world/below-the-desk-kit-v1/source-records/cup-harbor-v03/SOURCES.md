# SOURCES — cup-harbor v03

- Direction: `versions/v02/review.md` (binding independent review; the only v02 text read).
- Renders examined: `versions/v02/renders/final-pattern-closeup.png` and
  `final-stairs-closeup.png` (glyph as built: white rectangle + tab).
- Starting point: `versions/v02/cup-harbor.blend`, copied untouched to
  `versions/v03/cup-harbor.blend` (v01/v02 never edited).
- Build/reuse: `runs/new-v1/scripts/` — `check_geometry.py`, `export_glb.py`,
  `reimport_glb.py`, `validate_glb.py`, `render.py`, `three_check.mjs`
  (run from `/tmp/batch2-three-check/` so `three` resolves; script itself unmodified).
  Glyph rebuild is a new inline bmesh script (`/tmp/fix_glyph.py`, `/tmp/fix2.py`,
  `/tmp/fix3.py` — not kept in the version dir).
- `cup_pattern.png` copied unchanged from v02 (9,491 bytes).
- No external assets, no downloads, $0. All geometry procedural.
- Blender: headless CLI only (`~/workspace/blender/blender -b --python`); MCP Blender untouched.
