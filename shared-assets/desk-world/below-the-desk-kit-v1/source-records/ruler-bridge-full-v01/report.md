# ruler-bridge-full — v01 report (builder, round 1)

## What was built

Full ruler bridge, 8.0 units long (80 cm at 1 cm = 0.1 units), same
cross-section as the case-3 bridge-end (plank 0.9 wide, 0.12 thick,
top z 1.20). Six parts, exactly per manifest:

- `SM_bridge_ruler` — plank + 160 cm tick boxes (80 per row,
  x −3.95..+3.95 step 0.1; short 0.06 / 5-cm 0.10 / 10-cm 0.16).
- `SM_bridge_numerals` — thin plate (8.0 × 0.9 × 0.002, top z 1.202)
  carrying the generated numeral texture.
- `SM_bridge_post_l` / `SM_bridge_post_r` — trestles at x ±3.4 (2 legs
  + crossbar + top beam each, mirroring case-3).
- `SM_bridge_bracket_l` / `SM_bridge_bracket_r` — 2 iron straps + 4
  bolt discs at each end (straps at |x| 3.70 / 3.94, mirroring
  case-3's 0.30 / 0.06 inboard of the end).

Span derivation (recorded in the manifest, not invented silently):
case-3's 4.0 segment ends at mid-span, so the full bridge is 2 × 4.0
= 8.0. Corroborated by the board: projected ruler length ~803 px vs
projected width at mid-span ~57 px; correcting the width for top-face
foreshortening (view elevation ~35°, sin ~0.57) gives a length/width
ratio ~8.5, i.e. ~7.7 units — consistent with 8.0 within
painterly-perspective error. The board's numerals are painterly and
were NOT used as the length authority.

## Numerals — TEXTURE route (a), succeeded

- `numeral_strip.png`, 2048×256, generated inside the build script
  with a 5×7 bitmap font (no external downloads, $0). Digits
  10, 20, 30, 40, 50, 60, 70 at every 10 cm, centre line, digit
  height 0.30 units. Plate top-face UVs set explicitly from vertex
  positions (u=(x+4)/8, v=(y+0.45)/0.9).
- Legibility proof: `final-top-closeup.png` shows 30 / 40 / 50
  clearly readable, upright, increasing left → right;
  `final-top.png` shows all seven numerals identifiable.
- The GEOMETRY route (b) was not needed.
- Real defect found and fixed during the round: Blender's
  generated-image pixel buffer does NOT survive `save()` /
  `save_render()` / `pack()` in this headless build — the written PNG
  came out all black even though `img.pixels` read back correctly in
  memory, and a render from a reopened `.blend` sampled black
  (diagnosed with `/tmp/px_test*.py`). Fix: the PNG is written with
  a pure-Python encoder inside the build script, then loaded with
  `bpy.data.images.load()` as a file-backed image; that renders
  correctly and packs correctly. First final render (black plate)
  was discarded and re-rendered after the fix.

## Geometry checks (final `.blend`, `checks.json`)

- Total faces **1,384** / budget 8,000. Per part: ruler 986,
  numerals 6, post_l 104, post_r 104, bracket_l 92, bracket_r 92.
- Bbox **8.0 × 0.99 × 1.245** — exact match to the expected bbox.
- All parts manifold, 0 non-manifold edges, 0 boundary edges.
- No unexpected mesh objects.

## Renders

- `renders/`: 8 whitebox views + 10 final views (the 8 standard
  views plus `final-top-closeup` and `final-iso-end`), all fresh
  from the final `.blend`, plus `front_overlay_reference.png`
  (board ruler crop left, final-top right, visual only, no numeric
  claim).
- What the fresh renders show (builder's own read): top — warm
  light-brown plank, dark tick rows along both edges with the 10-cm
  ticks clearly longer, seven centre-line numerals, dark-iron straps
  with bolt heads at both ends; iso-fr — the whole bridge reads at a
  glance, both trestles under the ends with crossbars visible;
  iso-end — straps wrap the plank end, bolts read as small discs,
  trestle below with crossbar. The plate colour matches the plank
  wood; no visible seam around the numeral plate.

## Export

- `ruler-bridge-full.glb`, **198,832 bytes**, selection-only export
  of exactly the 6 parts.
- GLB byte/JSON validation (`scripts/validate_glb.py`): PASS —
  magic `glTF`, version 2, declared length 198,832 == file size,
  6 meshes (the 6 SM_* names), 5 materials (the 5 MAT_* names),
  26 accessors, 27 bufferViews, 6 nodes, 1 image, 1 texture.
  roughnessFactor AND metallicFactor present on all 5 materials.
  `MAT_ruler_numerals` carries `baseColorTexture` index 0. No
  unexpected names in the GLB JSON.
- Blender re-import (clean scene): exactly 6 mesh objects with the
  correct names and material slots. Triangulated face counts:
  ruler 1964, numerals 12, post_l 176, post_r 176, bracket_l 248,
  bracket_r 248 (total 2,824).
- Three.js validation (fresh `npm install three@0.160.0` in
  `/tmp/batch2-three-check`, script kept as
  `scripts/three_check.mjs`): GLTFLoader LOADED OK — 7 meshes
  (ruler splits per material slot), 5,416 vertices, 2,824 triangles
  (matches the re-import triangulated total exactly); all 6 scene
  children present with the right names.
- Texture caveat (honest limit): headless Node's GLTFLoader could
  NOT decode the embedded PNG (`Couldn't load texture` for the
  blob: URL; `createImageBitmap` in Node does not fetch blob: URLs),
  so `MAT_ruler_numerals map=none` in that check. The embedded image
  itself was extracted from the GLB and verified independently:
  valid 2048×256 PNG, digits 30/40/50 readable in the extracted
  bytes. In-browser decoding is the normal path and is NOT verified
  here — recorded as a known limit, not as a pass.

## Known issues (for the reviewer, all non-blocking unless the reviewer says otherwise)

1. The `0` glyph in the 5×7 font carries a diagonal stroke (the
   classic 5×7 zero with a slash) — reads as 0 at render scale but
   looks slightly odd in the extreme close-up.
2. The numerals are a clean pixel font; the board's digits are
   painterly/hand-drawn. The model does not reproduce the board's
   hand-drawn wobble — by design, since a printed ruler is the
   reference intent.
3. Tick tops sit 0.006 proud of the numeral plate (tops z 1.208)
   rather than engraved — reads fine at render scale, same as
   case-3.
4. Post placement (±3.4, 0.6 inboard) mirrors case-3; the board is
   asymmetric (left post reads ~1.6 inboard, right ~0.9). Recorded
   as inferred in the manifest.
5. The numeral plate is a separate 0.002-thick object, not the plank
   top face itself — no visible seam in any render, but it is a
   second object in the manifest.

## Builder's top-3 problems (own read, for the reviewer)

1. Numeral font: the `0` glyph's diagonal slash is the weakest
   letterform; at small render scales it is fine, but a cleaner
   zero would read better in close-ups.
2. The bridge is a clean, regular object — the board's ruler has
   worn edges, slight warp and wood grain the model does not have
   (flat Principled colours, no grain; grain would need a texture
   the budget and the scalar-roughness rule currently exclude).
3. The trestle crossbar is edge-on in the front view (reads as a
   thin line) — it is visible in iso views, but the front view
   alone under-sells the trestle construction.

## Review (independent, binding): PENDING.

## State: v01 stays IN_PROGRESS (only the coordinator flips to ACCEPTED after final review).
