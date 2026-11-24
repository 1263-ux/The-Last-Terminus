# Sources — Case 3 assembly v02 (full scene)

Fully procedural; no external assets. The assembly imports only the
five shipped, accepted asset GLBs and positions them — it remodels
nothing.

- `assets/ground-paper/versions/v01/ground-paper.glb` (ACCEPTED, v01)
- `assets/desk-lamp/versions/v01/desk-lamp.glb` (ACCEPTED, v01, fixed
  version: smooth dome, sunk shade-joint disc, 135,236 B)
- `assets/ruler-bridge-end/versions/v01/ruler-bridge-end.glb`
  (ACCEPTED, v01)
- `assets/building-a/versions/v01/building-a.glb` (ACCEPTED, v01)
- `assets/building-b/versions/v01/building-b.glb` (ACCEPTED, v01)
- Reference: board 02
  (`BelowTheDesk_Muse_Handoff_v0.2/06_REFERENCE_LIBRARY/images/reference_board_02_character_material_environment.png`)
  — composition only (ruler bridge leading into the pencil-box town,
  desk lamp nearby); the board gives no plan-view positions, so the
  layout is the builder's choice, recorded in `manifest.json`.
- Scripts: `scripts/build_assembly_v02.py` (placement source of
  truth), `scripts/check_assembly.py` (fixed budget accounting),
  `scripts/render.py` + `scripts/render_cfg_assembly_v02_final.json`,
  `scripts/export_glb.py`, `scripts/validate_glb.py`,
  `scripts/reimport_glb.py`, `scripts/regenerate_lamp_overlay.py`.
- No textures, no images, no third-party models. All materials are
  procedural Principled BSDF from the asset builds (22 material
  slots in the GLB; building B's 7 materials are `.001` duplicates
  of building A's — the glTF importer creates separate datablocks
  per file; values identical, see report).
