# cup-harbor — v03 glyph-only fix (builder report, brief)

## What changed (one local fix only)
- Copied `versions/v02/cup-harbor.blend` to `versions/v03/cup-harbor.blend` (v01/v02 untouched).
- Reshaped ONLY the white glyph on the dark-brown sign disc, inside `SM_harbor_door`,
  same `MAT_cup_ceramic` material, same disc, same position/depth (local Y 0.095–0.145):
  - **Cup body:** tapered prism — 0.22 wide at the top, 0.15 at the base, 0.15 tall,
    with a shallow dip in the top edge (open-top rim).
  - **C-handle loop:** flat band arc on the viewer's right (local −X), outer r 0.062,
    inner r 0.032, ends overlapping the body so it is a loop, not a tab.
  - **Saucer:** thin bar under the body with a small stem up to the body base.
  - Old glyph (10 faces) deleted; two interior dark quads at Y 0.095 that only closed
    the old open-backed glyph were also deleted (invisible inside the disc, behind its
    front face at Y 0.105) plus their orphan edges, so the door stays manifold.
- Nothing else touched: mirror, pattern, stairs, rail, disc, door, cup, pier, tower, boat
  all have identical face counts to v02.

## What the glyph looks like now (fresh v03 renders, looked at)
- `final-stairs-closeup.png`: clearly a white cup — tapered body, handle loop on the
  right, saucer line underneath — on the dark disc above the door.
- `final-pattern-closeup.png`: same cup, seen at an angle; body + saucer clear, handle
  reads as a small loop on the right.
- `final-front.png`: small white cup shape on the disc, readable at front distance.
- `final-iso-fr.png` / `whitebox-front.png`: rest of the asset unchanged, nothing moved.

## Face counts (evaluated, from checks.json)
- cup 896, handle 322, stairs 1038, pier 1542, **door 258 (+28 vs v02)**, tower 245,
  boat 50. **Total 4,351 / 8,000 budget.** All parts 0 non-manifold, 0 boundary edges.
- Bbox unchanged: 6.9592 × 4.8118 × 4.41, min (−3.0092, −2.1903, 0.0), max (3.95, 2.6215, 4.41).
- GLB: 387,724 bytes, glTF 2.0, 7 meshes / 7 nodes / 11 materials / 24 primitives,
  95 accessors, 96 bufferViews, 1 image + 1 texture (1024×1024 pattern, 9,491 bytes).
  Validation PASS. Re-import 8,710 tris. Three.js 0.160.0 load OK: 24 meshes, 8,710 tris.
  Known carried limit (same as v01/v02): headless Node cannot decode the embedded PNG
  blob — verified by extraction only; in-browser decoding must still be verified at
  integration.

## Top-3 problems (builder's own)
1. The open-top dip is shallow — at front distance the rim reads more as a flat top
   with a notch than a clearly open cup mouth; the close-ups carry the read.
2. The handle loop is small relative to the body and, at the pattern-closeup angle,
   reads slightly blobby rather than a crisp C — still a loop with a visible hole.
3. The saucer stem touches the body base with only ~0.003 overlap; it renders joined,
   but the joint is thin.

## Files
- `cup-harbor.blend`, `cup-harbor.glb`, `cup_pattern.png` (copied unchanged from v02),
  `renders/` (5 fresh: final-front, final-pattern-closeup, final-stairs-closeup,
  final-iso-fr, whitebox-front), `checks.json`, `manifest.json`, `SOURCES.md`, `timing.md`.
- $0, no external assets. Headless Blender CLI only; MCP Blender untouched.
