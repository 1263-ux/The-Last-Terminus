# SOURCES — town row assembly v02

No external assets. No new geometry except the ground strip (built in
Blender, procedural material). All parts come from the six ACCEPTED
sub-asset GLBs in this workspace:

- Clock tower: `assets-batch-2/town-row-extension/runs/new-v1/assets/clock-tower/versions/v01/clock-tower.glb` (unchanged)
- Shopfront: `ab/case-2-building-part/runs/new-v1/versions/v02/shopfront.glb`
- Building A / B: `ab/case-3-small-scene/runs/new-v1/assets/building-a|building-b/versions/v02/*.glb`
- Building C: `assets-batch-2/town-row-extension/runs/new-v1/assets/building-c/versions/v02/building-c.glb`
- Building D: `assets-batch-2/town-row-extension/runs/new-v1/assets/building-d/versions/v01/building-d.glb` (unchanged)

Visual standard: board 02 reference image
(`BelowTheDesk_Muse_Handoff_v0.2/06_REFERENCE_LIBRARY/images/reference_board_02_character_material_environment.png`).

Cost: $0. No textures, no downloads, no third-party material.
Build script: `assembly/versions/v02/build_assembly_row_v02.py` (adapted
from v01 `runs/new-v1/scripts/build_assembly_row.py`; v01 script and v01
files untouched). Render configs:
`runs/new-v1/scripts/render_cfg_row_v02_final.json` /
`render_cfg_row_v02_whitebox.json` (v01 configs untouched). Weld audit:
`assembly/versions/v02/weld_audit.py` (copy of the building-c v02 audit
script).
