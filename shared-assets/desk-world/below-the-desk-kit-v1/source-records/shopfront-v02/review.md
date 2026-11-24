# Independent review — Case 2 shopfront v02 (roof v02 round)

Reviewer: independent reviewer (did NOT build this round). Binding verdict below.
Date: 2026-11-15. Reviewed against the v02 files in this directory, the v01
accepted run in `../v01/`, and board 02
(`reference_board_02_character_material_environment.png`, bottom-middle panel:
pencil-box town house with a red pitched tile roof).

Method: read `report.md`, `manifest.json`, `checks.json`, `checks_weld.json`;
looked at all 16 fresh v02 renders (8 whitebox + 8 final) myself; diffed
`checks.json` and `manifest.json` v01→v02 by script; re-ran GLB byte/JSON
validation by hand; re-imported `shopfront.glb` in headless Blender 4.5.16,
re-ran the weld audit (remove_doubles 1e-5) and measured per-part bboxes
myself; pixel-diffed v01 vs v02 `final-front`, `final-iso-fr`, `final-top`.

## Top 3 problems found

1. **No per-tile segmentation along X.** The 10 ribs are continuous
   half-round courses with no vertical joints between tiles in a course.
   Board 02's roof shows individual tile edges; at close range (final-
   roof-closeup) the roof reads as unbroken parallel ridges. At this
   module's scale the courses still read as tile courses in every view,
   and the builder disclosed this as known issue 1 — so it is a real
   fidelity gap, but not a blocking one. Staggered tile joints would be
   a v03 geometry change (and would break the one-cylinder-per-course
   construction).
2. **The cap is still flat, not pitched.** From a low front angle the roof
   reads as a ribbed slab rather than a pitched roof. Disclosed as known
   issue 2 and unchanged by design — the v01 module scope is a flat
   trim cap, and a pitched roof is a different asset (cf. building D's
   gable prism). Not blocking for this round.
3. **Uniform colour/roughness across all ribs.** Every rib is the same
   MAT_awning_red at scalar roughness 0.7, so at close range the roof
   reads slightly like corrugated sheet rather than handmade tiles —
   there is no per-tile tonal variation. This is polish, not a defect:
   the courses, shadowed valleys, and red all read correctly, and the
   material discipline (scalar roughness, no new material) is the
   established one. A possible v03 consideration only.

No blocking issue. The builder's claims held up under re-verification
(see "Overclaim check" below).

## Per-check verdicts

### (a) Part manifest — PASS
- Exactly 6 parts, labels exact vs v01: `shopfront_box`, `awning`, `door`,
  `window`, `sign_board`, `roof_trim` (present in `checks.json`,
  `manifest.json`, and the GLB's 6 meshes / 6 nodes).
- Scripted manifest diff v01→v02: changes ONLY in the `roof_trim` entry
  (cap 0.15→0.09 thick, centre z 2.675→2.645, tile-ribs entry, material
  brass→MAT_awning_red, fascia material note, envelope entry, v01_note)
  plus `version: v02` / `based_on` markers. Nothing else moved.
- Face counts: box 54, awning 264, door 365, window 463, sign 78 — all
  identical to v01; roof_trim 52→180 (+128, the ribs). Total 1,404 / 8,000
  budget. All parts 0 non-manifold / 0 boundary in `checks.json`.
- Minor documentation nit (non-blocking): `manifest.json`'s `round_2`
  block still carries the v01 numbers (total_faces 1276, export
  220,152 bytes) while the file is version v02 (1,404 faces, 245,576
  bytes). The correct v02 numbers are in `report.md` and `checks.json`;
  the stale block should be corrected in the record, but it is not a
  model defect.

### (b) Silhouette / proportion — PASS
- Overall bbox identical to v01: [4.0, 3.1063, 2.75], min
  [-2.0, -1.05, 0.0], max [2.0, 2.0563, 2.75] — confirmed in
  `checks.json` and by my own re-import measurement.
- Roof envelope: my re-import measured SM_roof_trim bbox z 2.60–2.75,
  y −1.05..1.08, x −2.0..2.0 — exactly as claimed. Rib crests land on
  z 2.75, no vertex exceeds the envelope. The thinned cap (z 2.60–2.69)
  still bears on the wall top (wall top z 2.60), so the Round 1 fix
  (trim bearing on the wall) is preserved.
- Whitebox views confirm the silhouette is unchanged apart from the rib
  relief on the cap: whitebox-top shows the 10 ribs as real geometry in
  clay, and the whitebox iso/front/back/left/right views match v01's
  outline.

### (c) Surface / material — PASS
- The roof READS as a red tile roof, not a flat red slab, in
  final-roof-closeup (10 ribs rib-by-rib with shadowed valleys),
  final-top (10 courses across the full cap), final-iso-fr and
  final-iso-bk (red-tiled from both iso angles), and whitebox-top
  (courses in pure clay — geometry, not a material trick). The gold-slab
  dominance of v01 is gone.
- Red match: the trim is a single GLB primitive carrying MAT_awning_red
  only (verified in the GLB JSON: material index 1, base [0.477, 0.01,
  0.0085], roughness 0.70) — the same material as the awning stripes
  and building D's gable red. In the renders the roof red matches the
  awning red and sits in the same warm-red family as board 02's tile
  roof; the board's roof is a touch more orange-brown in its painterly
  rendering, but the in-house red is the agreed tile colour and the
  match is good.
- Fascia: from the front it reads as a thin red stripe under the cap —
  the builder's note is accurate. This is ACCEPTABLE: it is a fascia
  band, exactly as thin as the v01 brass band (geometry unchanged,
  4.0 x 0.06 x 0.15), and from iso/left views the rib ends read as a
  scalloped tile-roof edge, so the roof edge reads correctly in 3D.
  It is not a problem.
- From the left view the rib ends read as a row of red scallops along
  the top edge — a bonus tile-roof read, not a defect.

## Isolation check — nothing else changed — PASS
- `checks.json` diff: only SM_roof_trim changed (52→180 faces); the
  other five parts are face-identical with 0 non-manifold / 0 boundary.
- Pixel diff v01→v02 final-front: differences confined to the roof band
  (y 100–125, mean abs diff 16.97); sign band mean 0.13, awning-top
  0.21, lower front 0.00 — i.e. noise-level below the roof. Iso-fr and
  top diffs are likewise confined to the roof region. Door, window,
  sign, awning are visually identical to v01 in the renders.
- v01 known issues carry over unchanged, as stated: thin sign (0.26),
  door top in awning shadow, flat brass with no brushed variation,
  emissive pane flat warm peach with no bloom in stills. All visible
  unchanged in the v02 front render. None is a v02 regression.

## Weld / export verification (independently re-run)
- GLB byte/JSON validation (re-run by hand): magic `glTF`, version 2,
  declared length 245,576 == file size; 6 meshes, 7 materials, 6 nodes,
  0 images/textures; trim is one primitive, MAT_awning_red only. PASS.
- Weld audit (re-import + remove_doubles 1e-5, re-run by me): reproduced
  `checks_weld.json` EXACTLY — all 6 parts 0 boundary / 0 non-manifold
  after weld; trim 620→616 faces (the same 4 degenerate faces collapsing
  at rib/slab seams, benign, as in batch-2). Triangulated totals from my
  re-import (108+1232+1192+1216+132+620 = 4,500) match the builder's
  Three.js triangle count, so the Three.js cross-check is arithmetically
  confirmed from my own re-import; I did not re-run the Three.js load
  because the numbers already agree from two independent paths.
- v01 files untouched (v01 mtimes 2026-11-15 02:34–02:36 UTC; v02 built
  alongside, never in place). v01 state remains ACCEPTED.

## Overclaim check
- No overclaim found. The tile reading, the isolation diff, and the
  envelope (trim max z exactly 2.75) all verified against the renders
  and by independent re-measurement. The builder's known-issues list is
  honest and complete for this round; the in-round smooth-shading fix
  is documented and the renders show smooth ribs (no faceting visible
  in the closeup).

## Binding verdict: ACCEPTED (0 blocking issues)

The roof v02 round does what it set out to do: the shopfront's roof now
reads as a red tile roof in every view, within the 2.75 envelope, with
nothing else changed. The three problems above are non-blocking
fidelity/polish notes for a possible v03 (per-tile joints, pitched cap,
tonal variation) — none of them is in this round's scope, and none
fails the explicit check list.

State flip is the coordinator's job; this review does not touch
`state.json`. No builder file was modified; only this `review.md` was added.
