# Acceptance report — Case 2, run new-v1, version v02 (roof v02 round)

Asset: modular shopfront from the pencil-box town on board 02 (red-white
striped awning, arched door, warm window, sign board), 6 parts, ≤8,000
faces, GLB target. Base: v01 ACCEPTED 2026-11-15 ~10:36 CST.
Modules: reference-to-3d + blender-modeling (RobLe3). Execution: headless
Blender CLI 4.5.16 LTS ONLY (`blender -b --python`); the persistent MCP
Blender was NOT touched (owned by v07 head rebuild).

## What changed — roof trim ONLY (user-approved roof v02, 2026-11-15)

- Why: the v01 brass cap read as a flat gold slab dominating iso views,
  while board 02 shows a red pitched tile roof. The row-wide note (batch-2
  compare.md) recorded the same observation for buildings B/C; v02 is the
  shopfront's answer, scoped to this asset only.
- Reference: board 02 town-strip house (bottom environment panel, viewed
  directly): red pitched tile roof with horizontal tile courses stepping
  down toward the eaves, plus a ridge cap. The flat cap itself stays —
  the v01 module scope (no pitched roof) is unchanged; only the cap's
  surface treatment changes.
- Recolour: whole trim (cap + fascia) in MAT_awning_red (0.72, 0.10,
  0.09) — the in-house red-tile colour (building D's gable), reused, no
  new material. GLB material count stays 7.
- Tile rows: 10 half-round ribs (r 0.06) running along X across the cap
  top, spaced 0.21 in Y — the board's horizontal tile courses flattened
  onto the cap. Each rib is a full 16-segment cylinder (length 3.98,
  0.02 short of the cap width so no coplanar end faces) whose lower half
  is embedded in the cap and unioned EXACT into one solid; only the
  upper half protrudes. Upper rib faces smooth-shaded (68 faces, world
  z 2.7227–2.7477); valley floor and slab/fascia faces flat-shaded.
- Envelope binding: cap slab thinned 0.15 → 0.09 (z 2.60–2.69); rib
  crests rise exactly 0.06 to z 2.75, the v01 cap top. No vertex exceeds
  z 2.75. Trim bbox z 2.60–2.75, y −1.05..1.08, x −2.0..2.0 — identical
  to v01; overall bbox unchanged [4.0, 3.1063, 2.75].
- Fascia geometry UNCHANGED (4.0 x 0.06 x 0.15, y 1.05, z 2.675);
  only its material changes brass → red.
- Bevel discipline (Round 1 lesson): cap slab and fascia beveled
  individually BEFORE the union (`bevel_and_apply`, 0.02); the joined
  trim carries NO post-join bevel. Ribs need none (already round).

## Identity check — everything else byte-for-byte identical

Diff of `checks.json` v02 vs v01 (evaluated mesh, per part):

| Part | v01 faces | v02 faces | non-manifold / boundary |
|---|---|---|---|
| SM_shopfront_box | 54 | 54 | 0 / 0 |
| SM_awning | 264 | 264 | 0 / 0 |
| SM_door | 365 | 365 | 0 / 0 |
| SM_window | 463 | 463 | 0 / 0 |
| SM_sign_board | 78 | 78 | 0 / 0 |
| SM_roof_trim | 52 | 180 (+128, the ribs) | 0 / 0 |
| **Total** | **1276** | **1404 / 8000** | all manifold |

- Bbox identical: [4.0, 3.1063, 2.75], bbox_ok true. Exactly 6 parts,
  no unexpected objects.
- `manifest.json` diff vs v01: identical outside the `roof_trim` entry
  (plus `version: v02` / `based_on` markers) — verified by scripted
  comparison.
- Material values in the GLB are identical to v01 for all 7 materials
  (red base [0.477, 0.01, 0.0085], roughness 0.70; brass still present,
  used by door/window/sign; window emissive [1, 0.3424, 0.0331] +
  KHR_materials_emissive_strength 2).

## In-round fix — smooth-shading threshold in local space (builder-caught)

- First build: the rib smooth-shading post-process tested
  `poly.center.z` (LOCAL space; object origin z 2.645) against the
  world-space threshold 2.695, so 0 of 180 faces were smoothed — the
  ribs would have rendered faceted. Caught by a probe before any
  render (TRIM smooth faces: 0 of 180). Fix: use
  `obj.matrix_world @ poly.center` and exclude the fascia top face
  (`0.3 < normal.z < 0.995`). Rebuilt, re-probed: 68 rib faces smooth
  (world z 2.7227–2.7477), face counts unchanged (1404). The defect
  never reached a render.

## Renders — 16 fresh views, Cycles CPU 16 samples, 512×512

- Whitebox (8, true clay via material override — the v01 script only
  tinted a clay material if one existed, which would have rendered the
  v02 .blend in colour; the override is in-session only, never saved):
  whitebox-front, -back, -left, -right, -top, -bottom, -iso-fr,
  -iso-bl.
- Final (8): final-front, -back, -left, -right, -top, -iso-fr,
  -iso-bk, -roof-closeup (steep iso on the cap, ortho 4.4). No bottom
  view (nothing changed there) and no iso-awning (the change is the
  roof, not the awning) — the v02 set replaces the v01 final set.
- What the renders show (builder's own read):
  - final-roof-closeup: 10 red half-round ribs read rib by rib across
    the whole cap, with shadowed valleys between them — tile courses,
    not a flat red slab. The red matches the awning red.
  - final-top: the 10 courses read across the full cap; scalloped
    awning behind, unchanged.
  - final-iso-fr / -iso-bk: the roof reads red-tiled from both iso
    angles; the gold-slab dominance is gone. Door, window, sign,
    awning read exactly as in v01.
  - final-front: the fascia is now a thin red band under the cap
    (was brass/gold); everything below it is v01-identical.
  - whitebox-top: the 10 ribs read in pure clay — the tile rows are
    geometry, not a material trick.
- Lighting: same 3-sun pattern as v01 (key 2.5, fill 0.9, rim 1.2),
  plain light-gray world (0.85 @ 0.7), no filters, no bloom.

## Export + validation

- Export: `versions/v02/shopfront.glb`, **245,576 bytes** (v01: 220,152),
  selection-only export of exactly the 6 parts.
- GLB byte/JSON validation (`scripts/validate_glb.py`): PASS — magic
  `glTF`, version 2, declared length == file size, 6 meshes (the 6 SM_*
  names), 7 materials (the 7 MAT_* names), 40 accessors, 40 bufferViews,
  6 nodes, 0 images, 0 textures. roughnessFactor AND metallicFactor
  present on all 7 materials; emissiveFactor + emissiveStrength 2 on
  MAT_window_glow. No unexpected names in the GLB JSON.
- Blender re-import: exactly 6 mesh objects with the correct names and
  material slots (box [teal], awning [red, white], door [wood, brass],
  window [glow, brass], sign [cream, brass], trim [red] — trim is now
  red-only). Triangulated face counts: box 108, awning 1232, door 1192,
  window 1216, sign 132, trim 620 (v01 trim: 88).
- Post-triangulation weld audit (`scripts/check_weld.py`,
  `checks_weld.json`): re-imported GLB, weld 1e-5, recount — ALL 6 parts
  CLOSED, 0 boundary / 0 non-manifold edges after weld. Trim faces
  620 → 616 after weld (4 degenerate faces collapse at rib/slab seams
  — the same benign phenomenon as batch-2; not an error). No-weld
  recount was not used (meaningless — GLB splits verts at seams).
- Three.js validation (fresh `npm install three@0.160.0` in
  /tmp/case2-v02-three-check): GLTFLoader LOADED OK — 10 meshes
  (multi-material meshes split per slot), 6,518 vertices, 4,500
  triangles. Cross-check: re-import triangulated total
  108+1232+1192+1216+132+620 = 4,500 = Three.js tri count. Window glow
  emissive ff9e33; all other materials emissive 000000. Trim is a
  single mesh, MAT_awning_red only.

## Known issues (for the reviewer, all non-blocking unless the reviewer says otherwise)

1. The ribs are uniform half-round courses, not individual tiles: there
   is no per-tile segmentation along X (no vertical joints between
   tiles in a course). The board's roof shows tile edges; at this
   module's scale the courses read correctly in iso, but a closer
   inspection could ask for staggered tile joints. If the reviewer
   wants them, that is a v03 geometry change (staggering would also
   break the single-cylinder-per-course construction).
2. The cap is still flat, not pitched: the ribs sit on a flat cap, so
   from a low front angle the roof reads as a ribbed slab rather than
   a pitched roof — the v01 module scope (flat trim cap), unchanged
   by design. A pitched roof is a different asset (cf. building D's
   gable prism), not a v02 defect.
3. The red fascia band is thin (0.15 high) and, from the front, reads
   as a red stripe rather than a roof edge — same thinness as the v01
   brass band, only the colour changed.
4. v01 known issues carry over unchanged: sign thin (0.26); door top in
   awning shadow; brass flat, no brushed variation; emissive pane flat
   warm peach with no bloom in stills.

## Review (independent, binding): PENDING.

- State: v02 stays IN_PROGRESS (only the coordinator flips to ACCEPTED
  after reading the renders and the independent review). v01 files were
  not modified (verified: v01 mtimes/hashes untouched — v02 was built
  alongside, never in place).
