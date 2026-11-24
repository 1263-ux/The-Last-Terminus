# cup-harbor — v03 INDEPENDENT REVIEW (binding)

- Reviewer: independent reviewer (did not build this round). Judged only from the
  fresh v03 renders and files in `versions/v03/` plus the v02 review.
- Renders examined: all 5 fresh files in `renders/` — `final-front.png`,
  `final-pattern-closeup.png`, `final-stairs-closeup.png`, `final-iso-fr.png`,
  `whitebox-front.png`. Every one was looked at.
- Scope: the glyph ONLY. Mirror, sign clearance, pattern and rail were closed in
  v02 and were not re-opened.
- State: **NOT flipped by this review.** `state.json` stays `IN_PROGRESS`; only the
  coordinator flips it after reading the renders itself.

## Verdict: ACCEPTED

**Blocking-issue count: 0** (down from 1 in v02 — the v02 blocker is closed).

The white glyph on the dark sign disc now reads as a cup. In
`final-stairs-closeup.png` it is unmistakably a white cup: tapered body (wider
at the top than the base), a small C-handle loop on the viewer's right, and a
saucer line underneath. In `final-pattern-closeup.png`, seen at an angle, the
tapered body and saucer are still clear and the handle reads as a small loop
on the right — a cup silhouette, not a block. At front distance
(`final-front.png`) it reads as a small white cup shape on the disc, not the
white dash of v02. The v02 direction (tapered body, open-top rim, C-handle
loop on the right, saucer line) is met on all four points; the rim dip is
shallow (see non-blocking note 1) but the taper + handle + saucer together
carry the cup read in every view.

Nothing else moved. `final-iso-fr.png` and `whitebox-front.png` show the same
asset as v02 — handle right, boat left, stairs wrapping the left face, door +
dark sign on the front, tower, awning stall, pier — with only the glyph
changed. The v02 closures (mirror, sign clearance, pattern, rail) are
undisturbed.

## Top 3 problems (all non-blocking)

1. **The open-top rim dip is shallow.** At front distance the cup's top reads
   more as a flat top with a notch than a clearly open mouth; the close-ups
   carry the read. Non-blocking — the taper, handle and saucer already make
   it a cup — but a deeper dip would strengthen the front-distance read.
2. **The handle loop is small and slightly blobby at an angle.** In the
   pattern close-up it reads as a small loop with a visible hole, but it is
   the weakest of the four glyph elements and loses crispness off-axis.
   Non-blocking.
3. **Carried non-blocking note from v02: the main sprig's stem is still
   near-vertical, not the board's bold ~45° diagonal, and its leaves are
   coarse.** Largest remaining fidelity gap after the glyph; the explicit
   span/clearance criteria were already met in v02, so it does not gate
   acceptance.

Carried non-blocking notes, unchanged: the rim deck still reads as a flat
coffee surface filling the whole cup mouth (top and iso views); the door arch
shoulders still show small dark wedges (visible in the stairs close-up); the
saucer stem joins the body base with only a thin overlap (renders joined).

## Numbers audit (verified without re-running the build)

Every number the builder reported checks out; **no number fails to add up.**

- Faces: 896 + 322 + 1,038 + 1,542 + 258 + 245 + 50 = **4,351** / 8,000 budget.
  Per-part counts in `checks.json` agree exactly; every part other than the
  door is identical to v02, door 258 = 230 + 28 as reported.
- Manifold: all 7 parts 0 non-manifold, 0 boundary edges (`checks.json`).
- Bbox: min (−3.0092, −2.1903, 0.0), max (3.95, 2.6215, 4.41) →
  6.9592 × 4.8118 × 4.41, unchanged from v02, matching the report exactly.
- GLB (read directly from the file): 387,724 bytes, glTF 2.0, declared length
  == file size, 7 meshes with exactly the 7 `SM_*` names, 11 materials,
  95 accessors, 96 bufferViews, 7 nodes, 1 image, 1 texture, 24 primitives
  (matching the reported 24 Three.js meshes). Embedded PNG is 1024×1024;
  `cup_pattern.png` on disk is 9,491 bytes, as reported.
- Re-import 8,710 tris (8,610 in v02 + 100): taken from the report, not
  re-run here. The +100 is consistent with the report's own Three.js load
  (8,710 tris, 24 meshes) and plausible for the new glyph — the handle arc
  band and tapered body are n-gon faces that triangulate into several tris
  each — but the re-import itself was not independently re-run, same
  treatment as v02.
- Stray field, carried from v01/v02: `checks.json` still carries
  `case_face_budget: 20000` alongside the operative `face_budget: 8000`.
  Ignore the former.
- Render freshness: all 5 renders timestamped 06:03, after the v03 build;
  fresh for this round.

## Claims audit

**Supported by the renders/files:**
- Glyph reads as a cup in both close-ups and at front distance (taper, handle
  loop, saucer all visible).
- Nothing else moved: iso-fr and whitebox-front match the v02 arrangement.
- All numbers above (faces, bbox, GLB bytes/JSON, primitive count, texture size).

**Not independently verifiable from the renders (taken from checks.json / report, consistent):**
- Per-part manifold counts; the re-import tri count (see above); the exact
  glyph dimensions (0.22 top / 0.15 base / 0.15 tall, handle radii) — nothing
  in the renders contradicts them.

## The PNG-decode limit (carried from v01/v02)

Headless Node could not decode the embedded PNG (same known limit as asset 1:
verified by extraction only — valid 1024×1024 PNG in the GLB — and in-browser
decoding is NOT verified). **This does not block acceptance**, same treatment
as asset 1 and v02, which carries the mandatory integration condition:
**when this GLB is integrated, in-browser texture decoding must be verified,
and if the browser cannot decode the embedded PNG the asset is not shippable.**

## Direction

None needed. The glyph fix is complete and accepted. Optional polish for a
later round (non-blocking, do not gate on them): deepen the rim dip; enlarge
or crisp the handle loop; steepen the main sprig toward the board's ~45°
diagonal; plank lines or a rim gap on the deck disc; clean the door-arch
shoulder wedges.
