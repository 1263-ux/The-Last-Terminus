# Acceptance report — Case 3 Round 1, desk lamp (v01)

Asset: anglepoise desk lamp from board 02 (main scene, top centre),
4 parts (base, arm, shade, bulb), ≤3,000 faces, GLB target.
Modules: text-to-blender (orchestrator) + blender-modeler /
hard-surface (parametric). Execution: headless Blender CLI 4.5.16
LTS ONLY (`blender -b --python`); the persistent MCP Blender was NOT
touched (owned by the v07 head rebuild).

## Round 1 — whitebox

- Reference lock: board 02 viewed directly; lamp crop
  (`/tmp/case3_lamp.png`, board x540–830 y0–320) as primary,
  bottom-right mood panels as cross-check (dome-shade desk lamp).
  Reading: classic anglepoise — heavy round base with domed step,
  two parallel brass bars per arm segment, round disc joints at
  base / elbow / shade, large dome/bell shade (dark bronze outside,
  warm glowing interior, bright bulb disc inside the rim), opening
  facing down toward the town. Proportions recorded in
  `manifest.json`: total height ~2.83 (towers over the 2.75-high
  Case 2 shopfront, as the board lamp towers over the town); shade
  rim Ø 1.5; base Ø 1.1; arm reach base joint (0,0,0.30) -> elbow
  (0.55,0,1.55) -> shade joint (1.18,0,2.72); shade tilt 30 deg so
  the opening faces down and +X. Backs, undersides, arm
  cross-section, bulb shape and the 30 deg tilt are `inferred`
  (see manifest) — never presented as reproduction.
- Validation gates: no numeric front-mask IoU can be computed
  honestly from this painterly source (same finding as Case 2 —
  the board is a painterly illustration, not a line template).
  `silhouette_validator.py` was NOT run (running it on a hand-drawn
  mask would fabricate a number). Substitute: front-overlay visual
  check (`renders/front_overlay_reference.png`, side-by-side
  composite of the board lamp crop and the fresh final-front
  render, visual only, no numeric claim) plus independent review.
- Build: parametric script `scripts/build_lamp.py` (one function
  per part; shade is a custom revolved closed profile, 14 points x
  48 segments, with separate outer/inner material slots). Whitebox
  clay only (`CLAY_whitebox`, 0.62 gray, via material override in
  the render script).
- Geometry (evaluated mesh, `checks.json`): total **1,320/3,000
  faces** (base 240, arm 198, shade 672, bulb 210); all parts 0
  non-manifold, 0 boundary edges; bbox 2.6895 x 1.5 x 2.83
  (matches the manifest target 2.69 x 1.5 x 2.83); exactly 4 parts,
  no unexpected objects.
- In-round fixes (both caught by the builder's own probes before
  any render):
  1. Bulb sat at the shade joint instead of hanging inside the
     shade: `join_objects` leaves the origin at the active
     object's (sphere) centre, so setting the joined object's
     location to the shade joint put the bulb sphere at the joint,
     up inside the neck (vertex probe: bulb z max 2.89, centre
     (1.18,0,2.72)). Fix: translate the joined mesh down 0.42 in
     local space (`obj.data.transform`) before placing it at the
     joint. Re-probe: bulb centre at shade-local (0,0,-0.42),
     visible inside the shade in whitebox-bottom and
     final-iso-shade.
  2. Bbox overstated by `bound_box` corners: the first check said
     bbox Z 3.095, but the true vertex max is 2.818 (the local
     AABB corners of a rotated object stick out beyond the mesh).
     Fix: `scripts/check_geometry.py` now measures the bbox from
     actual evaluated-mesh vertices (note left in the script for
     the next case — Case 2's bound_box method only worked because
     its parts are axis-aligned). Manifest target corrected to
     2.69 x 1.5 x 2.83.
  3. Cosmetic: the joined arm inherited the first bar's transform
     (location + -66 deg rotation) as its object transform; baked
     into the mesh with `transform_apply` so the arm object is
     identity (shade/bulb keep their tilt transforms deliberately).
- Renders: 8 orthographic whitebox views, 512x512,
  `versions/v01/renders/`: whitebox-front, -back, -left, -right,
  -top, -bottom, -iso-fr, -iso-bl. Cycles CPU, 16 samples, no
  denoising (headless EEVEE impossible on this VM, libEGL absent).
  Pass took ~21 s.
- What the renders show (builder's own read): front — dome bell
  tilted down-forward, single-bar arm profile (the two bars
  overlap from +Y) with elbow disc, round base with domed step;
  left — the two parallel bars read clearly with the elbow disc
  between them, shade a clean dome from the side; bottom — shade
  interior is a deep dome with the bulb sphere and socket visible
  inside; iso — the whole anglepoise reads at a glance. Known
  issues (for the reviewer, all non-blocking unless the reviewer
  says otherwise): (1) the shade-joint disc pokes slightly through
  the top of the dome, reading as a small knob/cap on the dome
  (visible in front/left/iso) — it is the real hinge knuckle, but
  its intersection seam reads as a dark ring; (2) the joint pins
  read as small dark dots on the discs in front view (the pin end
  caps in shadow); (3) the dome shows faint facet banding in the
  highlight (48 revolve segments x 14 profile points).

## Round 1 — materials / export

- Materials (all Principled BSDF, SCALAR roughness only; palette
  in sRGB as seen on board 02, converted to linear for Blender):

  | Material | sRGB intent | linear (stored / GLB) | metallic | roughness | emission |
  |---|---|---|---|---|---|
  | MAT_brass_dark | (0.45, 0.30, 0.14) | (0.1706, 0.0732, 0.0174) | 0.85 | 0.40 | — |
  | MAT_shade_inner | (0.95, 0.80, 0.55) | (0.89, 0.6038, 0.2633) | 0.20 | 0.50 | — |
  | MAT_bulb_glow | base (0.40, 0.20, 0.05) | (0.1329, 0.0331, 0.0039) | 0 | 0.40 | sRGB (1.0, 0.75, 0.35) -> linear (1.0, 0.5225, 0.1005), strength 3.0 |

  Material slots: shade 2 (brass outside, warm cream inside —
  the revolved profile assigns slots per edge); bulb 2 (glow
  sphere, brass socket); base 1, arm 1 (brass). No external
  textures; fully procedural.
- Geometry (re-run `check_geometry.py`, `checks.json` rewritten):
  total **1,320/3,000 faces**, unchanged by the materials stage;
  all parts 0 non-manifold, 0 boundary edges; bbox 2.6895 x 1.5 x
  2.83, bbox_ok true; exactly 4 parts. Case running total after
  this asset + the paper sheet: **1,346/20,000** (18,654 left for
  the bridge end + buildings A/B — the plan in the manifest
  budgets 5,000 + 5,500 + 5,500 = 16,000 for those, total 17,346).
- Lighting: same 3-sun pattern as Case 1/2 (key 2.5
  front-top-right (-55,0,-35), fill 0.9 front-top-left
  (-40,0,35), rim 1.2 back-top (55,0,-20)), plain light-gray world
  (0.85 @ 0.7), no filters, no bloom. Cycles CPU, 16 samples, no
  denoising.
- Renders: 9 fresh final views, 512x512, 2026-11-15 ~10:43 CST,
  `versions/v01/renders/`: final-front, -back, -left, -right,
  -top, -bottom, -iso-fr, -iso-bl, -iso-shade (closer view up into
  the shade from below-right, target (1.49, 0, 2.18), ortho scale
  1.8 — proves the bulb and cream interior read). All 9 PNGs
  present with new timestamps. Plus `front_overlay_reference.png`
  (side-by-side: board lamp crop left, final-front right, visual
  only, no numeric claim). What the overlay shows: the dome
  silhouette, the arm angle and the base all sit at comparable
  relative proportions to the board lamp; the model is a clean
  anglepoise reading of the painterly original.
- What the fresh renders show (builder's own read): front — warm
  dark-bronze dome, brass arm and base, the shade joint knob on
  the dome top; iso-shade — warm cream interior with the glowing
  bulb disc, the upper arm bars converging at the neck (visible
  inside the opening, as on a real anglepoise); bottom — cream
  interior ring, glowing bulb, base disc; iso-fr — the whole lamp
  reads at a glance in bronze. The bulb reads as a flat warm
  cream disc in the stills (emission verified in the GLB, but with
  no bloom it does not glow on screen) — judge under game lighting
  rather than changing the model (same note as Case 2's window).
- Export: `versions/v01/desk-lamp.glb`, **176,720 bytes**,
  selection-only export of exactly the 4 parts.
  GLB byte/JSON validation (`scripts/validate_glb.py`): PASS —
  magic `glTF`, version 2, declared length 176,720 == file size,
  JSON chunk parses, 4 meshes (the 4 SM_* names), 3 materials (the
  3 MAT_* names), 22 accessors, 22 bufferViews, 4 nodes, 0 images,
  0 textures. roughnessFactor AND metallicFactor present on all 3
  materials (brass 0.40 / 0.85, inner 0.50 / 0.20, bulb 0.40 / 0).
  emissiveFactor present on MAT_bulb_glow: [1, 0.5225, 0.1005],
  plus KHR_materials_emissive_strength with emissiveStrength 3.
  No unexpected names in the GLB JSON.
- Blender re-import (clean scene, objects deleted, never
  factory-reset): exactly 4 mesh objects with the correct names
  and material slots (base [brass], arm [brass], shade [brass,
  inner], bulb [glow, brass]). Triangulated face counts on
  re-import: base 656, arm 492, shade 1344, bulb 412 (higher than
  the Blender quad/ngon counts — glTF triangulates; expected).
- Three.js validation (fresh `npm install three@0.160.0` in
  /tmp/case3-three-check, no game files touched): GLTFLoader
  LOADED OK — 6 meshes (multi-material meshes split per slot:
  shade_1/_2, bulb_1/_2, base, arm), 5,448 vertices, 2,904
  triangles (matches the re-import triangulated total 656+492+
  1344+412 = 2,904); bulb emissive ffbf59, emissiveIntensity 3;
  all other materials emissive 000000. Not loaded inside the
  game's own artifact (validation level: Blender re-import + GLB
  byte/JSON validation + real Three.js GLTFLoader load, headless
  Node).
- Known issues (for the reviewer, all non-blocking unless the
  reviewer says otherwise): (1) shade-joint disc pokes through
  the dome top as a small knob with a dark intersection ring
  (whitebox note 1); (2) pin end caps read as dark dots on the
  joint discs in front view; (3) faint facet banding on the dome
  highlight (48 x 14 revolve); (4) bulb reads flat warm-cream
  with no bloom in the stills (emission verified in the GLB).
- Review (independent, binding): PENDING.
- State: v01 stays IN_PROGRESS (only the coordinator flips to
  ACCEPTED after final review).

## Round 1 fix — local fix only, then back to review (2026-11-15 ~10:55-11:07 CST)

Review verdict addressed: NOT_ACCEPTED, 2 blocking issues. Ground
paper and assembly sample passed; only the lamp was touched, same
version dir v01 (Case 2 fix-round precedent — no v02). Execution:
headless Blender CLI 4.5.16 ONLY; the persistent MCP Blender was
NOT touched (owned by the v07 head rebuild). `writer.lock` created
in this version dir before opening the .blend, removed when done.

### Fix 1 (BLOCKING) — dome flat-shaded / faceted

- Cause (confirmed by the builder viewing Round 1 final-front /
  final-left): the revolved shade was built with `from_pydata`
  with every polygon flat-shaded, so the 48 x 14 quad dome showed
  a strong diamond/checkerboard facet pattern — the dominant
  surface feature of the lamp's largest surface, not the "faint
  banding" the Round 1 report called it.
- Fix in `scripts/build_lamp.py` (`revolve_shade`): smooth-by-angle
  30 deg — all 672 shade polys smooth; an edge stays sharp only
  where the dihedral angle exceeds 30 deg. The dome profile turns
  at most ~22 deg between segments (7.5 deg around the
  circumference), so the whole dome goes smooth; the rim annulus
  (90 deg turns) and the neck-top closing edge (~115 deg) stay
  sharp. Probe on the rebuilt mesh: 672/672 polys smooth, 192
  sharp edges = 4 rings x 48. Profile unchanged. The glTF
  exporter writes split normals from these flags.
- Proof: fresh final-front / final-left / final-iso-fr (see below)
  show a smooth dome with a soft gradient highlight; no facet
  pattern remains anywhere on the dome exterior.

### Fix 2 (BLOCKING) — shade-joint disc poked through the dome crown

- Cause: disc r 0.11 at the joint (1.18,0,2.72), top z 2.83 vs
  dome crown 2.818 — a small knob on the apex with a dark
  intersection ring.
- Fix in `scripts/build_lamp.py` (`build_arm`): disc r 0.11 -> 0.09
  and sunk 0.09 along the shade axis into the neck (new centre
  (1.225,0,2.6421); shade axis in world is (-0.5,0,0.866) under the
  -30 deg Y tilt); the shade pin sank with it. Probe: disc
  neighbourhood max z 2.7321 (was 2.83); disc top sits at axial
  -0.012 (below the neck plane) with max radial 0.09, while the
  inner dome at that height is r ~0.31 — no disc edge breaks the
  dome surface. Arm max z is now 2.7321; the dome crown (2.818)
  is the tallest point of the whole lamp. No neck collar was
  needed; no extra part was added (still exactly 4 parts).
- Follow-on fix found by the builder's own re-render probe (not
  by the reviewer): with the disc sunk, the upper-arm bars' end
  corners poked ~0.03 above the dome's neck silhouette in front
  view (corner at (1.159, 2.765) vs dome edge ~2.72 at that x) —
  a 4-5 px triangular spike on the crown, found by a pixel scan of
  the fresh final-front (topmost-pixel profile) and confirmed in
  the whitebox crop. Fix: upper bars `p1_pullback=0.12` in
  `bar_between` (ends 0.09 before the joint; end centre 0.088
  from the sunk disc centre, r 0.09, so the joint still reads
  connected — the bar ends embed into the disc volume). The spike
  scan on the re-rendered final-front now reports none, and the
  crown profile descends smoothly from the apex.
- Proof: fresh final-front — crown silhouette clean, no knob, no
  spike, no dark ring; fresh final-left — the hinge knuckle now
  sits IN the neck dip (visible through the neck hole as the
  joint, as on a real anglepoise), not through the crown; fresh
  final-iso-fr — dome smooth, two small knuckles in the neck dip,
  crown silhouette continuous.

### Doc fixes

- Manifest "total height ~3.3" corrected to the measured 2.82
  (bbox Z 2.818); `overall_bbox_expected` 2.83 -> 2.82; shade-joint
  and shade-profile dimension text updated to the sunk disc and
  the smooth-by-angle shading.
- Assembly `checks.json` (numbers only, assembly NOT rebuilt):
  `case_running_total_faces` 2948 -> 1346,
  `case_remaining_faces` 17052 -> 18654 (source-count method:
  lamp 1320 + paper 26). `total_faces` 2948 (the assembly scene's
  own triangulated total) is unchanged. Caveat recorded in that
  file: `check_assembly.py` recomputes the case total from
  `total_faces`, so a re-run will overwrite the correction —
  Round 2 must fix the script or re-apply it.

### Shade profile decision (reviewer's non-blocking note)

- The board shade reads as a deeper bell than the model's
  depth/Ø 0.41. Profile LEFT UNCHANGED: deepening the bell would
  move the rim, change the bbox and the bulb's visibility inside
  the shade, and risk the disc fix; the fix round stays scoped to
  the two blocking issues. The current dome already reads as a
  bell in the front overlay vs the board crop.

### Re-render proof (all fresh, Cycles CPU 16 samples, same view
### configs as Round 1 — `/tmp/case3-cfg/lamp_fin.json`,
### `lamp_wb_fix.json`)

- 9/9 final views re-rendered 2026-11-15 11:02-11:04 CST
  (`final-front` … `final-iso-shade`), 3/3 whitebox views
  (`whitebox-front`, `-left`, `-iso-fr`) re-rendered 11:04-11:05
  CST. All 12 PNGs carry fresh timestamps; the other 5 whitebox
  views are unchanged Round 1 renders (silhouette unaffected
  there — the fix only touches the neck region, and the 3
  re-rendered whitebox views cover it).
- What the fresh renders show (builder's own read): front — smooth
  bronze dome, clean crown, arm and base unchanged; left — smooth
  dome, hinge knuckle in the neck dip, two parallel bars with the
  elbow disc; iso-fr — whole lamp reads at a glance, dome smooth;
  iso-shade — warm cream interior with the glowing bulb disc,
  unchanged by the fix. The bulb still reads as a flat warm-cream
  disc with no bloom in the stills (emission verified in the GLB,
  same note as Round 1).

### Re-check / re-export numbers

- Geometry (re-run `check_geometry.py`, `checks.json` rewritten):
  total **1,320/3,000 faces**, unchanged (base 240, arm 198,
  shade 672, bulb 210); all parts 0 non-manifold, 0 boundary
  edges; bbox **2.6895 x 1.5 x 2.818**, bbox_ok true; exactly 4
  parts. Case running total stays **1,346/20,000** (18,654 left).
- Export: `desk-lamp.glb`, **135,236 bytes** (was 176,720 — smooth
  shading merged the shade's split vertices). GLB byte/JSON
  validation (`validate_glb.py`): PASS — magic `glTF`, version 2,
  declared length 135,236 == file size, 4 meshes, 3 materials, 22
  accessors, 22 bufferViews, 4 nodes, 0 images, 0 textures;
  roughnessFactor AND metallicFactor on all 3 materials;
  emissiveFactor on MAT_bulb_glow [1, 0.5225, 0.1005] plus
  KHR_materials_emissive_strength 3.
- Blender re-import: exactly 4 mesh objects with the correct names
  and material slots. Triangulated face counts UNCHANGED from
  Round 1: base 656, arm 492, shade 1344, bulb 412 (total 2,904 —
  smooth shading changes normals, not faces).
- Three.js validation (same /tmp/case3-three-check, three@0.160.0):
  GLTFLoader LOADED OK — 6 meshes, **3,720 vertices** (was 5,448 —
  the shade's split vertices merged under smooth shading:
  shade_1 528 + shade_2 336), **2,904 triangles** (unchanged,
  matches the re-import total); bulb emissive ffbf59,
  emissiveIntensity 3; all other materials emissive 000000.
- Known remaining issues (for the reviewer): (1) pin end caps
  still read as small dark dots on the joint discs in front view
  (unchanged from Round 1); (2) bulb reads flat warm-cream with no
  bloom in the stills (emission verified in the GLB); (3) shade
  depth/Ø 0.41 vs the board's deeper bell — deliberately left
  (see decision above).
- Review (independent, binding): PENDING (second review).
- State: v01 stays IN_PROGRESS (only the coordinator flips to
  ACCEPTED after final review).

## Coordinator sign-off (fix round) — 2026-11-15 ~11:11 CST

- Re-review (independent, binding): ACCEPTED, blocking 0 (was 2). Both blocking issues verified fixed in the fresh renders: dome smooth with a soft gradient highlight in all views; crown silhouette clean, hinge knuckle in the neck dip, no dark ring, no bar-end spike. GLB independently parsed by the reviewer (135,236 B, 4 meshes, 3 materials, emissive + KHR_emissive_strength 3, 2,904 tris).
- Coordinator check: read fresh final-front.png and final-left.png myself. Agrees with the reviewer: the facet pattern is gone and the crown is clean. (The small apex mark in final-left is the neck socket opening with the joint visible through it — the reviewer judged it non-blocking, a real socket, not a gap.)
- Round history: Round 1 lamp 2 blocking (faceted dome, disc through crown) → fix round resolved both, re-review ACCEPTED. Three-round rule never fired.
- STATE FLIPPED TO ACCEPTED by the coordinator at ~11:11 CST. All Round 1 items now accepted: lamp, ground paper, assembly sample. The lamp may enter the Round 2 full scene.
- Known remaining issues (non-blocking): neck socket reads as a prominent circular opening from top/left views — consider a neck collar in a later round; front overlay is stale (still shows the Round 1 render) — regenerate in Round 2; pin end caps read as small dark dots; bulb flat without bloom in stills (emission verified in GLB); shade depth/Ø 0.41 deliberately left (board's deeper bell not pursued).
