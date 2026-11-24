# Independent review — town row assembly v02 (2026-11-15)

Reviewer: independent (did not build this round). Verdict is binding.
Method: read report.md, manifest.json, checks.json, checks_weld.json,
`_build_layout.json`, `SOURCES.md`, the build script's GLB table, and the
v01 assembly for comparison; viewed all six fresh v02 renders myself;
re-imported `town-row.glb` with my own fresh Blender script
(`/tmp/reviewer_weld_audit.py`, not the builder's `weld_audit.py`) and
re-ran the weld audit, bbox, per-asset centres, seating, and face counts;
re-imported the v01 GLB as a control for building-B's centre. Board 02
(bottom-middle panel: red-tile-roof house, striped awnings, warm windows,
clock tower) is the visual standard.

## Binding verdict: ACCEPTED — 0 blocking issues

All three changes under review are verified as built, and every number I
re-measured matches the builder's record. The v01 "flat tan roof slabs
dominate the iso views" problem is gone (v01 iso-fr vs v02 iso-fr compared
directly). No blocking issue found.

## Top 3 problems (all non-blocking, carried/inherited)

1. **Front view still reads slightly flat/washed; windows render pale
   cream rather than warm glow at ortho distance** (carried from v01).
   Emission is present (strength 2.0, verified in the GLB record), so this
   is presentation/lighting, not missing geometry. The red roofline now
   reads across the whole row, which softens it vs v01, but the front is
   still the flattest view.
2. **Tile rows read as continuous ridges (corrugation) at close range,
   not individual overlapping tiles; head-on they are still a thin red
   bar.** Inherited character of the four accepted roof-v02 sub-assets
   (recorded honestly in the B v02 review); the assembly does not change
   it. Largest remaining gap vs the board's overlapping-tile house roof.
   Non-blocking for this envelope-bound round.
3. **D's smooth gable roof reads as a flat, slightly paler red slab next
   to the ridged roofs** — clearest in `final-iso-bk` (far-right end,
   salmon-pink flat slab) and in `final-top` (flat red rectangle vs four
   ridged roofs). The tower's darker-red pyramid sits naturally; D's
   gable is the one roof that does not carry tile courses. Inherited
   from accepted D v01 (8-face gable, unchanged by design), not an
   assembly defect. Same class: **backs are plain teal boxes**, disclosed
   and inherited from the sub-assets as shipped.

## Per-check verdicts

### 1. Part manifest — PASS
44 parts, count and labels exact: 43 sub-asset parts + `SM_row_ground`.
`checks.json` parts_present matches parts_expected exactly, 0 unexpected
mesh objects. Build script's GLB table (read directly from
`build_assembly_row_v02.py`) imports exactly the accepted versions:
shopfront v02, A v02, B v02, C v02, D v01, clock-tower v01 — and all six
sub-asset `state.json` files read ACCEPTED (coordinator-flipped, with
independent reviews on record). Layout centres as claimed (tower
−10.915, shopfront −7.615, A −3.315, B 0.985, C 5.315, D 9.765):
my re-import reproduces the bbox centres for tower/shopfront/A/C/D
exactly; building-B's bbox centre measures 1.0, not 0.985 — but the v01
GLB re-imported as a control measures 1.0 too, so this is B's asymmetric
geometry vs its placement origin (0.015), identical in v01 and v02, not
a layout change. Gaps 0.30 preserved (x-spans match `_build_layout.json`).

### 2. Silhouette / proportion — PASS
Whole row uncropped in final-front, final-iso-fr, final-iso-bk,
final-top, and whitebox-front (the roofline view is a detail crop by
design, ortho 16, central ~16 units; whole-row views exist separately).
My re-import: bbox **[24.13, 3.592, 5.84]**, min **[-12.065, -1.3, 0.0]**,
max **[12.065, 2.292, 5.84]** — exact match to the report. Min z is 0.0
(v01 was −0.06); z_max 5.84 = v01's 5.78 + 0.06 lift. Ground strip
z 0.0 → 0.06, x [−12.065, 12.065]. Every building's z_min measures
0.06 in my audit — all six seated exactly on the strip top, no floating
parts, no part dipping below 0.06, no interpenetration visible in any
render. Row reads as one street frontage with the tower as landmark,
matching the board's pencil-box town.

### 3. Surface / material — PASS (with the noted non-blocking gaps)
Red tile rows continuous across all six roofs in iso-fr, iso-bk, and
top; teal walls, varied striped awnings, warm windows all read. The
tower roof (MAT_roof_red, a touch darker) does not clash — in iso-fr it
reads as the same red family, slightly deeper. D's gable and the tower
pyramid sit naturally in the row from the front; from the back D's
smooth gable is the one visibly flatter roof (problem 3 above). Front
flatness from v01 is still present but acceptable: the roofline is now
red across the row and the composition reads as the board's town.
12 materials in the re-imported GLB, exactly the manifest's set, no new
material introduced by the roof change.

### 4. Weld audit reproduced independently — PASS
My own script (fresh code, same method: re-import GLB, triangulate,
weld 1e-5, recount): **44/44 parts 0 boundary / 0 non-manifold**,
`all_clean: true`. Tris pre-weld 29,656, post-weld 29,622. Deltas only
`SM_roof_trim` 620 → 616 and `SM_tower_finial` 286 → 256 — exactly as
the builder claimed, degenerate tris collapsing on weld, both parts 0/0
after. **`SM_bldgC_windows_up`: 954 tris, 0/0 — the v01 micro-seam is
fixed** (v01 control in the v01 weld file: 933 faces, 6 boundary / 9
non-manifold after weld). Builder's `checks_weld.json` is corroborated,
not taken on trust.

### 5. Face-count reconciliation — PASS
Source sum 10,328 = 1,404 + 2,152 + 1,527 + 2,297 + 1,459 + 1,489 —
each matches the sub-asset's own `checks.json` total_faces. Per-asset
triangulated counts verified against the sub-assets' own weld audits:
shopfront 4,500 (own audit parts sum 4,500 pre-weld), A 6,084, B 4,872,
C 6,230 (own `checks_weld.json` total_tris_post_weld 6,230); D 4,252
and tower 3,706 match the v01 assembly `checks.json` per-part sums
exactly, part by part. Total 29,650 (v01: 26,331, Δ +3,319) reconciles
to the per-asset deltas (+532 / +784 / +744 / +1,259 / 0 / 0). My
re-import counts 29,656 tris pre-weld = 29,650 + 6, the ground-strip box
(6 quads → 12 tris), same +6 as v01.

### 6. D and tower unchanged; no v01 file modified — PASS
D and tower per-part face counts are identical v01 → v02 for all 15
parts (e.g. `SM_bldgD_roof` 8, `SM_tower_finial` 286). Source GLBs
`building-d v01` (06:12) and `clock-tower v01` (06:15) predate the v01
assembly build; all v01 assembly files carry mtimes 06:25–06:30 UTC,
all v02 files 08:57–08:59 — nothing in v01 was touched by this round.
Renders are fresh: 08:58:48–08:59:06 UTC, after the v02 GLB export at
08:58:14. `state.json` remains `IN_PROGRESS`; not flipped by this
review (coordinator's call).

## Overclaim check
No overclaim found. Every builder claim I tested reproduced exactly:
bbox, min z 0.0, centres (modulo the B origin/bbox-centre distinction,
which is identical in v01), weld 44/44, C windows_up 954 tris 0/0,
roof-trim/finial weld deltas, per-asset tri counts, D/tower unchanged,
material dedup (12 materials, same set as v01). The report's honest
notes (corrugation not individual tiles, plain backs, flat front) match
what the renders show.

## Non-blocking record note (not a defect)
`checks.json` carries two budget figures — `face_budget: 30000`
(`face_budget_ok: true`, 29,650 < 30,000) and `case_face_budget: 20000`.
The manifest states the assembly has no separate face budget, and the
v01 precedent settles it (v01 total 26,331 already exceeded 20,000 and
was ACCEPTED), so this is a leftover field from the asset-level check
script, not a budget breach. Worth cleaning up in the record at the
next round, not a reason to hold acceptance.

## Verdict
**ACCEPTED.** 0 blocking issues. The three changes under review are all
verified: red-tile roofs coherent across the row, ground strip fixed
(min z 0.0, all buildings seated on the strip top), C micro-seam fixed
(0/0 after weld). Carried items for a future round, none blocking:
front-view warmth, individual-tile (not corrugation) roofs, D gable tile
courses, rear detail.
