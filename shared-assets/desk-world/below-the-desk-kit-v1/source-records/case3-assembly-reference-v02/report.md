# Acceptance report — Case 3 Round 2, full-scene assembly (v02)

Assembly: all five accepted assets together — ground paper, desk
lamp, ruler bridge end, building A, building B — one coherent
corner of the desk world: the bridge leads north into building A's
door under its awning, the two shopfronts form the town row along
the north edge, the lamp stands back-left lighting the corner.
Method: `scripts/build_assembly_v02.py` imports the five shipped
asset GLBs and only positions them; nothing is remodelled.
Modules: text-to-blender (orchestrator) + assembly. Execution:
headless Blender CLI 4.5.16 LTS ONLY (`blender -b --python`); the
persistent MCP Blender was NOT touched (owned by the v07 head
rebuild).

## Round 2 — full scene

- Layout (paper 12 x 8, x -6..6, y -4..4, top z 0.06; recorded in
  `manifest.json`): lamp base centre (-3.8, -2.0, 0.06), rot 0 —
  UNCHANGED from the Round 1 sample. Building A centre (2.6, 2.0,
  0.06), rot Z 180 deg — front faces south, door at world x 2.6.
  Building B centre (-1.8, 2.0, 0.06), rot Z 180 deg — front faces
  south, oculus faces west; 0.4 gap to A. Bridge centre (2.6, -1.5,
  0.06), rot Z +90 deg — plank runs north-south, town end north,
  axis aligned with A's door; trestle at world y -0.1, plank north
  end y 0.5 (0.34 short of A's door front at y 0.84), passing under
  A's awning (bridge top z 1.305, awning bottom z ~1.88); south end
  y -3.5, 0.5 inside the paper edge. The whole layout is `inferred`
  (the board gives no plan-view positions).
- Placement checks (`scripts/check_assembly.py`, `checks.json`):
  exactly the 22 expected meshes, no unexpected objects; all four
  standing assets seated (min z 0.06 == paper top, tolerance
  0.001) and fully inside the paper; all 22 parts 0 non-manifold /
  0 boundary after the weld-at-0.0001 (Round 1 method). Total faces
  **13,804** triangulated (lamp 2,904, paper 44, bridge 1,428, A
  5,300, B 4,128 — per-part counts match the fresh-import probe
  exactly); case budget accounted on SOURCE counts: **5,194 /
  20,000 used, 14,806 left**. Interpenetration: zero cross-asset
  part pairs even have intersecting bboxes (the bridge clears A's
  awning in Z by 0.58 and stops 0.34 short of A's door in Y), so
  the BVH triangle-overlap test had nothing to test and reports 0
  overlapping triangles; no interpenetration by bbox separation.
  Lamp bbox x -4.35..-1.66, y -2.75..-1.25 — shade clear of both
  buildings (1.11 gap in Y to B).
- In-round fix 1 (build script, caught by the builder before any
  render): the first build translated the bridge and buildings but
  NEVER turned them — the ruler still ran east-west and A's awning
  bbox reached x 7.598, outside the paper. Cause: the glTF
  importer stores orientation as a quaternion (`rotation_mode`
  'QUATERNION'); `rotation_euler` reads (0,0,0) and writing it is
  ignored by `matrix_world`. Fix: after each import,
  `view_layer.update()`, read the import rotation from
  `matrix_world`, compose `Rz(theta) @ R_import`, and write it back
  as `rotation_quaternion` (mode stays QUATERNION). This preserves
  the assets' own rotations (shade 30 deg tilt, awning slope) and
  adds the assembly turn. Rebuilt; all bboxes then matched the
  planned layout exactly (bridge ruler x 2.15..3.05, y -3.5..0.5;
  A awning x 0.802..4.398, y -0.09..0.988; door front y 0.84).
  The wrong first build never left the machine (same
  `assembly-final.blend` path, overwritten by the rebuild).
- In-round fix 2 (check script, the assigned budget bug):
  `check_assembly.py` recomputed `case_running_total_faces` from
  `total_faces` (triangulated), which overwrote the source-count
  correction (1,346 used / 18,654 left in Round 1). Fixed: the
  script now carries `SOURCE_FACES` per asset (lamp 1320 + paper
  26 + bridge 702 + A 1823 + B 1323) and reports
  `case_running_total_faces = 5194` from those, with
  `total_faces` (13,804 triangulated) reported separately and
  explicitly NOT the budget number. Re-ran: 5,194 / 20,000,
  14,806 left — verified, not overwritten. The script is also
  generalized to all 22 parts, per-asset seating/inside checks,
  and the cross-asset BVH interpenetration test; default output
  is now `assembly/versions/v02/checks.json` (CHECK_OUT env
  overrides). Round 1's `versions/v01/checks.json` was not touched.
- In-round fix 3 (check script, builder's own arithmetic error):
  the first v02 check run reported `total_faces_ok: false`
  (13,804 vs expected 14,804). Every per-part count matched the
  probe exactly; the error was mine — building A's triangulated
  sum is 5,300, not 6,300 (108+1008+1192+1386+1386+132+88).
  Corrected `EXPECTED_TOTAL_FACES` to 13,804; re-ran:
  `total_faces_ok: true`.
- Fix (a) — lamp overlay regenerated: `scripts/
  regenerate_lamp_overlay.py` rebuilt `assets/desk-lamp/versions/
  v01/renders/front_overlay_reference.png` from the FIXED
  final-front render (smooth dome, sunk disc; md5 changed
  af398ed7… -> 7fe68cf9…, 984x540, same side-by-side format, board
  lamp crop x540-830 y0-320 left). Viewed: the right panel now
  shows the smooth dome with no crown knob and no facet pattern.
  The lamp's own GLB/blend/manifest were not touched.
- Renders: 6 final views, 512x512, Cycles CPU 16 samples, no
  denoising, 3-sun pattern, plain light-gray world, `versions/v02/
  renders/` (cfg `scripts/render_cfg_assembly_v02_final.json`):
  assembly-iso-fr, assembly-iso-bl, assembly-front, assembly-top,
  assembly-detail-junction (bridge end + A's door/awning), 
  assembly-detail-lamp (lamp + building B). What the renders show
  (builder's own read): iso-fr — two red-white striped shopfronts
  side by side, bridge running in from the south edge to A's door,
  lamp back-left, shade toward the town; top — the layout reads
  unambiguously (town row north, bridge N-S at x 2.6, lamp
  south-west, all inside the paper); front — both shopfronts face
  the camera, lamp at left (its shade overlaps B's awning only in
  2D projection — 1.11 gap in Y, verified); iso-bl — building
  backs, B's oculus on its west face, lamp from behind, bridge end
  behind A; detail-junction — bridge tick marks, trestle and
  bracket read, plank ends under the awning just short of A's
  door; detail-lamp — smooth dome, no crown knob, base flush on
  the paper, B's door/window/awning behind. Honest note: in the
  straight front view the bridge reads wood-on-wood against A's
  door (similar browns at 512 px); the junction detail is the
  legible view of the bridge/town meeting.
- Export: `versions/v02/assembly-final.glb`, **776,924 bytes**,
  selection-only export of exactly the 22 parts.
  GLB byte/JSON validation (`scripts/validate_glb.py`): PASS —
  magic `glTF`, version 2, declared length 776,924 == file size,
  JSON chunk parses, 22 meshes (the 22 SM_* names), 22 materials,
  129 accessors, 129 bufferViews, 22 nodes, 0 images, 0 textures.
  roughnessFactor AND metallicFactor present on all 22 materials.
  emissiveFactor present on MAT_bulb_glow: [1, 0.5225, 0.1005],
  plus KHR_materials_emissive_strength with emissiveStrength 3;
  MAT_window_glow (both buildings) also emissive [1, 0.3424,
  0.0331] with emissiveStrength 2 (verified in the GLB JSON and
  in Three.js). No unexpected names in the GLB JSON.
- Blender re-import (clean scene, objects deleted, never
  factory-reset): exactly 22 mesh objects with the correct names
  and material slots; triangulated face counts match the check
  exactly per part (paper 44, lamp 656/492/1344/412, bridge
  1004/176/248, A 108/1008/1192/1386/1386/132/88, B
  108/784/1192/1252/572/132/88).
- Three.js validation (fresh `npm install three@0.160.0` in
  /tmp/case3-three-check-v02, no game files touched): GLTFLoader
  LOADED OK — 35 meshes (multi-material meshes split per slot),
  21,111 vertices, 13,804 triangles (matches the triangulated
  total); bulb emissive ffbf59, emissiveIntensity 3; window glow
  ff9e33, emissiveIntensity 2; all other materials emissive
  000000. Not loaded inside the game's own artifact (validation
  level: Blender re-import + GLB byte/JSON validation + real
  Three.js GLTFLoader load, headless Node).
- Known issues (for the reviewer, all non-blocking unless the
  reviewer says otherwise): (1) building B's 7 materials are
  `.001` duplicates of building A's (MAT_wall_teal.001 etc.) —
  the glTF importer creates separate material datablocks per
  file; values are identical, but the GLB carries 22 materials
  instead of 15. Dedup would mean remapping material slots, which
  is beyond position-only assembly; left for a later round.
  (2) The layout itself is the builder's choice, not a board
  measurement (recorded as `inferred` in the manifest).
  (3) In the straight front render the bridge reads wood-on-wood
  against A's door; the junction detail view is the legible one.
  (4) The lamp's known non-blocking issues carry over from its
  own record (neck socket reads as a circular opening from
  top/left; pin caps read as small dark dots).
- Review (independent, binding): PENDING.
- State: v02 stays IN_PROGRESS (only the coordinator flips to
  ACCEPTED after final review).

## Coordinator sign-off (final) — 2026-11-15 ~11:33 CST

- Final review (independent, binding): ACCEPTED, blocking 0. All 22 meshes present with exact names; placements verified against the renders; per-part face sums reconcile exactly (13,804 triangulated); source-face budget 5,194/20,000; GLB independently parsed by the reviewer (776,924 B, 22 meshes, 22 materials, 13,804 tris from index accessors, bulb + window emissive verified). Coordinator read assembly-iso-fr.png, assembly-front.png and assembly-detail-junction.png myself and agrees: the scene reads as one coherent desk corner — ruler bridge into the pencil-box town, lamp nearby, board-02 palette.
- STATE FLIPPED TO ACCEPTED by the coordinator at ~11:33 CST. Case 3 is complete: all 5 assemblies ACCEPTED + the full-scene assembly ACCEPTED.
- Known remaining issues (non-blocking): bridge nearly illegible in the straight front view (wood-on-wood against A's door; the junction detail is the legible view); lamp shade overlaps B's awning in 2D projection only (real Y gap 1.11); 22 materials in the GLB instead of 15 unique (B's 7 are .001 duplicates of A's — identical values, file-size/cleanliness cost only; dedup needs slot remapping, beyond position-only assembly); building backs are plain flat teal slabs with gold roofs (inferred, board never shows them); 0.34 gap between plank end and door reads as designed.
