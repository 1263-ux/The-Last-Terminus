# Report — town row assembly v02 (2026-11-15)

Row order (object space, left → right): clock-tower, shopfront, building-a,
building-b, building-c, building-d. Gaps 0.30 between neighbours, measured
from actual evaluated-mesh x-extents. Row 23.83 wide, recentered on x=0
(centres: tower −10.915, shopfront −7.615, A −3.315, B 0.985, C 5.315,
D 9.765) — **identical to v01**: the v02 sub-assets kept the v01
footprints. Fronts face +Y. On screen the order reads right-to-left — the
documented camera-mirror convention, not a defect.

## What changed vs v01

1. **Four roof-v02 sub-assets re-imported.** Shopfront, A, B, C now carry
   red-tile roofs in MAT_awning_red (all four ACCEPTED, 0 blocking). D v01
   (red gable) and the clock tower v01 (red pyramid) are unchanged — and
   they stay consistent with the new roofs: in the renders all six reds
   read as one family (tower roof is MAT_roof_red, a touch darker, as in
   v01; no mismatch found). The v01 "flat tan roof slabs dominate the iso
   views" problem is gone.
2. **Ground strip fix (queued from batch 2).** Slab bottom now at z=0.0
   (v01: top at 0, bottom at −0.06). Slab still 0.06 thick, top at z=+0.06,
   and all six buildings lifted by one uniform +0.06 — every asset's z_min
   was 0.000 before the lift, so every base sits exactly on the strip top,
   no interpenetration. Assembly bbox min z is now 0.0 (was −0.06); bbox
   [24.13, 3.592, 5.84] — same extents as v01, shifted up 0.06.
3. **C micro-seam FIXED.** SM_bldgC_windows_up now welds clean: 954 tris,
   0 boundary / 0 non-manifold after a 1e-5 weld (v01: 6 boundary / 9
   non-manifold). The fix is in the accepted building-c v02, verified
   here by the full-row weld audit.

## Face-count reconciliation

| asset | source (own checks.json) | triangulated (assembly) | v01 triangulated | Δ vs v01 |
|---|---|---|---|---|
| clock-tower v01 | 1,489 | 3,706 | 3,706 | 0 |
| shopfront v02 | 1,404 | 4,500 | 3,968 | +532 |
| building-a v02 | 2,152 | 6,084 | 5,300 | +784 |
| building-b v02 | 1,527 | 4,872 | 4,128 | +744 |
| building-c v02 | 2,297 | 6,230 | 4,971 | +1,259 |
| building-d v01 | 1,459 | 4,252 | 4,252 | 0 |
| ground strip | — | 6 | 6 | 0 |
| **total** | **10,328** | **29,650** | **26,331** | **+3,319** |

Every per-asset triangulated count was verified against that sub-asset's
own weld-audit tri total (shopfront 4,500 / A 6,084 / B 4,872 / C 6,230)
or, for the unchanged v01 assets, the v01 assembly checks.json per-part
sums (D 4,252 / tower 3,706). All six match exactly. No separate face
budget for the assembly.

New geometry: one thin ground strip only (SM_row_ground, 24.13 × 3.59 ×
0.06, bottom z=0, top z=0.06, 0.15 margin, MAT_row_ground warm paper
grey). No sub-asset file touched; the six ACCEPTED GLBs were imported only.

## Builder's read of the renders (all 6 viewed)

- **final-front / whitebox-front:** whole row uncropped; six buildings +
  tower, all seated on the strip, no floating parts, no gaps beyond the
  0.30 spacing. Red roofline now reads across the whole row (thin red
  bars at front).
- **final-iso-fr:** the row reads as one coherent town — continuous red
  tile rows on every roof, teal walls, striped awnings, tower landmark.
  D's red gable and the tower's red pyramid sit naturally with the new
  tile roofs. No mismatch between D/tower and the new roofs.
- **final-iso-bk:** backs are plain teal boxes (as shipped, disclosed);
  red tile roofs read consistently from the back too.
- **final-top:** red roofs across the whole row, tile courses visible,
  awning stripes at the front edge, strip margin visible as paper.
- **final-roofline (new detail view):** tile rows read as red courses
  with ridge lines on shopfront/A/B/C; D's gable at the right edge. At
  this range the rows read as continuous ridges (corrugation), not
  individual overlapping tiles — the accepted v02 sub-assets' character,
  recorded honestly in the B v02 review, not an assembly defect.

## Top 3 problems (builder's list; reviewer rules)

1. **Front view still reads slightly flat/washed** (carried from v01).
   Windows render pale cream rather than warm glow at ortho distance
   (emission verified present, strength 2.0). Presentation only.
2. **Tile rows read as corrugation at close range** (carried from the
   B v02 review). Continuous ridges, not individual overlapping tiles;
   head-on still a thin red bar. Largest remaining gap vs the board,
   non-blocking for this envelope-bound round.
3. **Backs are plain teal boxes** (carried from v01). As shipped in the
   sub-assets; disclosed, inferred.

No blocking issue found by the builder. The two weld deltas
(SM_roof_trim 620→616, SM_tower_finial 286→256) are degenerate tris
collapsing on weld — inherited from the accepted sub-assets (the trim's
delta is reproduced in the shopfront v02's own audit), both parts 0/0
after weld, same class as v01.

## Other notes

- Raw manifold check on imported meshes flags every part — glTF import
  splits vertices. After a 1e-5 weld, **44/44 parts are fully closed**
  (checks_weld.json, all_clean: true).
- First export had 43 materials (one copy of each shared material per
  GLB import) and the build script's stray-name scan found none. Materials
  deduped after verifying identical Principled values (31 removed,
  0 mismatches kept); final GLB: 44 meshes, 12 materials (same set as
  v01 — the v02 roofs use MAT_awning_red, no new material), 0
  images/textures.
- Bbox [24.13, 3.592, 5.84]; Z 5.84 = tower finial 5.78 + 0.06 lift.
- Renders (all whole row, uncropped): final-front, final-iso-fr,
  final-iso-bk, final-top, final-roofline (new detail view, ortho 16) +
  whitebox-front. Ortho 26 front/top, 28 iso.

## What is inferred

Rear faces, interiors (none), row spacing (0.30 gaps), strip size/colour.
Board 02 is the sole visual standard; everything else follows the six
accepted sub-assets as shipped.

## Verification

- checks.json: bbox OK (min z 0.0), 29,650 faces, no unexpected objects.
- GLB byte/JSON validation: PASS.
- Blender re-import: 44 mesh objects, names match.
- Weld audit (checks_weld.json): all_clean true, 44/44 parts 0/0 after
  1e-5 weld; post-weld tri total 29,622 vs 29,656 pre-weld (34 degenerate
  tris collapse: roof trim 4, tower finial 30).
- Three.js 0.160.0 (fresh npm install, /tmp/row-v02-three-check): load OK,
  74 meshes (multi-material split), 29,656 triangles, 44,059 vertices.
  29,656 = 29,650 + 6, exactly the ground-strip box (6 quads in Blender
  → 12 tris) — same +6 as v01.
- state.json left IN_PROGRESS; acceptance is the reviewer's/coordinator's
  call.
