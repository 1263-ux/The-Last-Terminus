# ruler-bridge-full — v01 INDEPENDENT REVIEW

- **Reviewer:** independent reviewer (did not build this round)
- **Date:** 2026-11-15
- **Scope judged:** fresh renders in `versions/v01/renders/` (all 19 files viewed by the reviewer: 8 whitebox + 10 final + `front_overlay_reference.png`), `report.md`, `manifest.json`, `checks.json`, and the GLB file on disk. The `.blend` was NOT opened or modified; `state.json` was NOT flipped.
- **Reference standard:** board 02 main scene only (`reference_board_02_character_material_environment.png`).

## Verdict: ACCEPTED

- **Blocking-issue count: 0.**
- All three explicit acceptance checks pass: (1) part manifest, (2) silhouette/proportion vs the board, (3) surface/material. The numeral-legibility gate in the manifest also passes on its own terms (see §3).
- This is an acceptance of v01 as a ready-for-integration asset, with one **conditional follow-up** (§6): the in-browser texture decode must be confirmed in the live artifact at integration time. That check belongs to integration, not to another modeling round — there is no modeling defect here that a fix round would address.

## Top 3 problems (all non-blocking, ranked)

1. **Slashed-zero glyph.** Every `0` in the numeral texture carries a diagonal stroke, so the bridge reads `1Ø, 2Ø, 3Ø …` in `final-top-closeup.png` and in the overlay composite. The digits stay identifiable as 10/20/30/… — no digit is misreadable as a different digit — so the legibility gate passes, but no real ruler prints a slashed zero and the stroke is plainly visible at every scale where the digits are legible. Cheapest fix in the batch (one glyph in the bitmap font); recommended as a polish pass, not a blocker.
2. **Flat, grain-free wood.** Plank, posts and numeral plate are uniform Principled colours with no grain, wear or edge variation, while the board's ruler shows warm wood grain, worn edges and tonal variation. At game scale the honey colour reads correctly against the board, so this is the main remaining visual gap, not a failure. Grain would need a texture the batch's scalar-roughness rule currently excludes — recorded as a known limitation, deferred, not a fix-round item.
3. **In-browser texture decode never verified.** Headless Node could not decode the embedded PNG (`map=none` in that check), and this very round already produced one black-plate render from a texture-pipeline failure — so the failure mode is demonstrated, not hypothetical. Against that: the GLB is fully conformant (verified below), the embedded PNG is a standard valid 2048×256 PNG, and the Node failure has a documented environment cause (Node `createImageBitmap` does not fetch `blob:` URLs), not a GLB defect. **Judgment: non-blocking for acceptance, mandatory follow-up at integration** — the coordinator must confirm the numerals render in the live in-browser artifact before the asset is called done in-game. The builder was right to record it as a known limit, not a pass.

## 1. Part manifest — PASS

- Exactly **6 parts**, labels exactly as in `manifest.json`: `SM_bridge_ruler`, `SM_bridge_numerals`, `SM_bridge_post_l`, `SM_bridge_post_r`, `SM_bridge_bracket_l`, `SM_bridge_bracket_r`. `checks.json` lists the same six as present, zero unexpected mesh objects.
- All six are visible in the renders: plank + tick rows (top/whitebox-top), numeral plate (top — no visible seam, reads as the plank's own printed face), two trestles with legs/crossbar/top beam (iso-fr, iso-bl, left, right, whitebox-left/right), two brackets with straps wrapping top and sides plus bolt discs (iso-end, top, left/right).
- No floating parts, no missing parts, no extra parts in any view.

## 2. Silhouette / proportion vs the board — PASS

- The bridge reads at a glance as the board's ruler bridge: one long wooden plank, cm ticks along both long edges, centre-line numerals, dark metal end brackets, wooden trestle posts under each end. The overlay composite (board crop left, model top right) shows the same object in the same proportions.
- Span 8.0 × width 0.9 (ratio ~8.9) against the board's painterly estimate ~7.7–8.5: consistent within perspective error, and the derivation (2× the case-3 4.0 segment) is documented in the manifest rather than asserted silently.
- Bracket placement (two straps per end, near the ends) and trestle placement (±3.4, 0.6 inboard) match the board's arrangement. The board's trestle spacing is asymmetric (left further inboard than right); the model mirrors case-3 symmetrically. That asymmetry is painterly, the symmetric choice is recorded as inferred in the manifest, and it does not change the silhouette — non-blocking.
- Whitebox iso/front/back confirm the structure with no material or lighting flattery: straight plank, trestles square under the ends, brackets wrapping the ends.

## 3. Numerals — PASS (gate met, with the slashed-zero note)

- `final-top.png`: **all seven numerals 10, 20, 30, 40, 50, 60, 70 are readable**, upright, increasing left → right, evenly spaced every 10 cm on the centre line.
- `final-top-closeup.png`: **30 and 40 are fully and clearly readable**; 50 is cut by the frame edge (close-up framing, not a model defect) and is fully readable in the full top view. The builder's report overstates this slightly — it claims "30 / 40 / 50 clearly readable" in the close-up, but only 30 and 40 are fully in frame. Minor; the gate is satisfied across the two top views together.
- Glyph quality: the 5×7 pixel font is crisp and regular; tick-adjacent digits do not collide with ticks. The only glyph defect is the slashed zero (top problem 1). The board's own digits are painterly and unreadable as a sequence, so the board sets no exact glyph standard; the manifest's "printed ruler" intent is the right call.

## 4. Surface / material — PASS

- Wood colour: warm honey brown, close to the board's ruler wood and to the board's material swatch; post wood is a darker weathered brown as specified; iron brackets are dark, near-black, matching the board's clamps.
- Ticks are clean: two rows, short/5-cm/10-cm lengths clearly differentiated, no ragged edges, no z-fighting, no flicker in any view. Tick tops sit 0.006 proud of the plate as specified and read as printed marks, not as floating geometry.
- No z-fighting, no floating parts, no non-manifold evidence visible in any of the 19 renders. `checks.json` reports 0 non-manifold and 0 boundary edges on every part, consistent with what the renders show.
- Bolt discs read as small discs on the bracket top plates in `final-iso-end.png` (they are near-invisible in the straight top view at 512 px, which is a scale matter, not a defect).
- Flat colours with no grain/wear: noted as top problem 2, non-blocking.
- Underside (final-bottom/whitebox-bottom): plain wood, bracket side plates and bolt backs visible, trestle top beams visible — nothing unexpected, nothing floating.

## 5. Numbers audit (verified by the reviewer from the files, no rebuild)

| Builder claim | Check | Result |
|---|---|---|
| Total faces 1,384 / 8,000 | 986+6+104+104+92+92 = **1,384** ✓; under budget | SUPPORTED |
| Per-part faces (986/6/104/104/92/92) | `checks.json` per-part values match the report exactly | SUPPORTED |
| Bbox 8.0 × 0.99 × 1.245 | bbox_min (−4.0, −0.495, 0.0), bbox_max (4.0, 0.495, 1.245) → differences 8.0 / 0.99 / 1.245 ✓ | SUPPORTED |
| GLB 198,832 B | File on disk is **198,832 bytes**; GLB header magic `glTF`, version 2, declared length 198,832 == file size ✓ | SUPPORTED |
| GLB: 6 meshes, 5 materials, 26 accessors, 27 bufferViews, 1 image, 1 texture | Parsed GLB JSON: meshes are exactly the 6 `SM_*` names; materials exactly the 5 `MAT_*` names; 26 accessors; 27 bufferViews; 1 image; 1 texture ✓ | SUPPORTED |
| `MAT_ruler_numerals` carries baseColorTexture | GLB JSON: `baseColorTexture: {index: 0}` on that material only ✓ | SUPPORTED |
| Embedded image valid 2048×256 PNG | Extracted from the GLB: PNG signature valid, 2048×256 RGB, 4,069 bytes — identical size to `numeral_strip.png` in the version dir ✓ | SUPPORTED |
| Re-import triangulated total 2,824 | 1964+12+176+176+248+248 = **2,824** ✓ | SUPPORTED |
| Three.js load OK, 7 meshes / 5,416 tris 2,824 | Not re-run by the reviewer. 7 meshes is consistent with the ruler splitting per material slot (2 slots) + 5 single-slot objects; 2,824 triangles matches the re-import total exactly. Vertices 5,416 taken on the report's word. | PARTLY VERIFIED (geometry counts cross-check; Three.js run itself not repeated) |
| Texture caveat (Node could not decode; image verified by extraction only) | Consistent with the GLB parse above; the reviewer also verified the embedded PNG independently | SUPPORTED as stated |
| "30/40/50 clearly readable" in the close-up | 30 and 40 fully readable; **50 is half out of frame** in `final-top-closeup.png` | OVERSTATED — 50 is readable only in `final-top.png` |
| `checks.json` "case_face_budget": 20000 vs asset budget 8000 | Not a contradiction: 20,000 is the case-3 scene budget, 8,000 is this asset's budget; the asset is under both | NOTED, not an error |

No number was found that does not add up. The one arithmetic-adjacent flag is the close-up wording above.

## 6. Builder's honest limits — judged

- **In-browser texture decode unverified → non-blocking, mandatory integration follow-up** (top problem 3). The asset itself shows no defect; the verification belongs to the packaging/integration round, where the GLB is actually loaded in the browser. Condition: integration must screenshot the bridge in the live artifact and confirm numerals visible before the asset is called done in-game.
- **Slashed-zero glyph → non-blocking polish** (top problem 1). Legibility gate passes; the fix is a one-glyph font change plus re-render of the top views. Recommend doing it in the next batch pass rather than holding this asset.
- **Flat colours, no grain/wear → non-blocking, deferred.** Within the batch's scalar-roughness rule and the case-3 precedent; the board gap is real but is a texture-scope decision, not a v01 defect.
- **Trestle crossbar edge-on in front view → non-blocking, not a defect.** The crossbar spans Y and the front view looks along Y, so it must read as a thin line; the two legs overlap for the same reason. The crossbar is clearly visible in iso-fr, iso-bl, left, right and both whitebox side views. The board shows the trestle from an angle for the same reason.
- **Symmetric trestle placement vs the board's asymmetry → non-blocking.** Recorded as inferred in the manifest; painterly asymmetry is not a dimension to chase.

## Per-part verdicts

| Part | Verdict | Note |
|---|---|---|
| `SM_bridge_ruler` | ACCEPT | Plank + 160 ticks clean; both edge rows, 10-cm ticks longer; honey wood close to the board; no seam or z-fighting |
| `SM_bridge_numerals` | ACCEPT | Plate invisible as a separate object; 10–70 readable in full top, 30/40 in close-up; slashed zero is the only glyph wart (polish, §6) |
| `SM_bridge_post_l` | ACCEPT | 2 legs + crossbar + top beam, all visible in iso/side views; front-view single-leg read is viewpoint overlap |
| `SM_bridge_post_r` | ACCEPT | Mirror of left; same read |
| `SM_bridge_bracket_l` | ACCEPT | Two straps wrap top and sides; bolt discs visible in iso-end; dark iron matches the board's clamps |
| `SM_bridge_bracket_r` | ACCEPT | Mirror of left; same read |

## Claims audit (builder's claims vs the renders)

**Supported:** 6 parts with exact labels; 1,384 faces / 8,000; bbox 8.0 × 0.99 × 1.245; GLB 198,832 B with 6 meshes / 5 materials / 1 embedded 2048×256 PNG; numerals 10–70 readable in the full top view; straps wrap the plank ends with bolt discs; trestles under both ends with visible crossbars in iso views; no visible seam around the numeral plate; ticks clean with 10-cm ticks longer; all parts manifold; texture caveat stated honestly and not presented as a pass; overlay composite is visual-only with no numeric claim (as stated).

**Contradicted / overstated:** only one — the report's "30 / 40 / 50 clearly readable" for the close-up: 50 is half out of frame in `final-top-closeup.png`. The numerals as a set are still fully readable across the top views, so the gate stands.

**Not verified by this review:** the Three.js run itself (counts cross-checked, run not repeated); in-browser texture decoding (integration follow-up, §6).

## Direction

- **No fix round is required.** v01 is accepted as-is for integration.
- **If the coordinator wants the polish pass** (one round, small): replace the slashed `0` with a plain `0` in the bitmap font, regenerate `numeral_strip.png`, re-export, and re-render `final-top.png` + `final-top-closeup.png` for a fresh legibility check. Do not touch geometry, placement, or materials in that pass.
- **At integration (mandatory):** load `ruler-bridge-full.glb` in the live in-browser artifact and screenshot the bridge from the game's bridge-crossing camera; confirm the numerals decode and read. If the texture fails there, the asset comes back — that would be a real blocking defect, not a Node artifact.
- **Do not** chase the board's trestle asymmetry, add grain, or re-derive the span in a further round; all three are recorded, reasoned, and within tolerance for this asset.

## Deliverables present

`.blend` (697,838 B), build/export scripts under the run's `scripts/`, `ruler-bridge-full.glb`, 19 fresh renders, `report.md`, `manifest.json`, `checks.json`, `numeral_strip.png`, `SOURCES.md`, `timing.md`. All six qualified-asset deliverables are present. `state.json` remains `IN_PROGRESS` — the coordinator flips it after reading the renders.
