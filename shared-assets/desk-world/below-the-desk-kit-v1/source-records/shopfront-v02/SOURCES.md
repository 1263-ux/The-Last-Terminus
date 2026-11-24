# Asset source records — Case 2, run new-v1, version v02 (roof v02 round)

- External 3D assets: NONE. All geometry is parametric, built by
  `scripts/build_shopfront_v02.py` from the dimensions in
  `reference_manifest.json` (v02: only `build_roof_trim` differs from
  the v01 script). No Meshy/Tripo generation, no BlenderKit/Poly
  Haven/Sketchfab download.
- External textures: NONE. Materials are Principled BSDF with scalar
  values only (base colours specified in sRGB, converted to linear in
  the build script; scalar roughness and metallic; the window pane's
  warm emission is an Emission Color + Strength scalar, no texture).
  The roof reuses the existing MAT_awning_red (0.72, 0.10, 0.09) —
  no new material was created. GLB carries 0 images / 0 textures
  (verified in `scripts/validate_glb.py`).
- Reference used (not shipped): board 02 `BelowTheDesk_Muse_Handoff_v0.2/06_REFERENCE_LIBRARY/images/reference_board_02_character_material_environment.png` — town-strip house (bottom environment panel) as primary, main-scene pencil-box shopfront as cross-check. The house's red pitched tile roof with horizontal tile courses is the model for the v02 ribs; the flat cap itself (no pitched roof) is the v01 module scope, unchanged. Rear/interior/roof pitch are marked `inferred` in `reference_manifest.json`.
- In-house colour reference: building D's red gable uses MAT_awning_red
  (0.72, 0.10, 0.09) — see batch-2 `scripts/building-d/build_building_d.py`.
- Capability modules used (skills, not shipped assets): `reference-to-3d` (RobLe3, MIT) and `blender-modeling` (RobLe3, MIT) — see `~/workspace/custom-skills/THIRD_PARTY_NOTICES.md` for source, commit, and licence. Execution via headless Blender CLI 4.5.16 LTS only; the persistent MCP Blender was NOT touched.
- No copyrighted material of any kind was used or copied.
