# Acceptance report — Case 3 Round 1, ground paper sheet (v01)

Asset: the desk-surface paper sheet everything in the scene stands
on, 1 part, ≤100 faces, GLB target. Modules: text-to-blender
(orchestrator) + blender-modeler (parametric). Execution: headless
Blender CLI 4.5.16 LTS ONLY (`blender -b --python`); the persistent
MCP Blender was NOT touched (owned by the v07 head rebuild).

## Round 1 — whitebox + materials + export (single pass)

- Reference lock: board 02 main scene — a large flat sheet of warm
  cream paper on the desk, edges visible at the scene borders.
  No silhouette to validate (a flat sheet has no meaningful
  silhouette against the painterly board); judged by the top view
  + the assembly renders. Dimensions in `manifest.json`: 12.0 x
  8.0 x 0.06, centre (0,0,0.03), top at z 0.06; sized to hold the
  lamp (base at x -3.8), the ruler-bridge end and two 4.0-wide
  buildings with margin in Round 2. Thickness 0.06 and the 0.02
  edge bevel are `inferred` (the board shows the sheet edge-on
  only as a thin line); no folds, no printed lines, no stains
  (deliberately omitted for the sample asset).
- Build: parametric script `scripts/build_paper.py` — a single
  beveled box. Whitebox clay first, then the real material
  (MAT_paper_cream, warm cream (0.93, 0.90, 0.82) sRGB, roughness
  0.9, metallic 0, Principled BSDF, scalar roughness only).
- Geometry (evaluated mesh, `checks.json`): total **26/100 faces**;
  0 non-manifold, 0 boundary edges; bbox 12.0 x 8.0 x 0.06
  (exact); exactly 1 part, no unexpected objects. Case running
  total after this asset + the lamp: **1,346/20,000**.
- Renders: 8 orthographic whitebox views + 8 final views,
  512x512, Cycles CPU 16 samples, no denoising (headless EEVEE
  impossible on this VM, libEGL absent), same 1-sun (whitebox) /
  3-sun (final) pattern as Case 1/2, plain light-gray world.
  `versions/v01/renders/`: whitebox-front/-back/-left/-right/
  -top/-bottom/-iso-fr/-iso-bl, final-* (same 8). What the renders
  show (builder's own read): a flat warm-cream sheet; top view is
  a clean 12 x 8 rectangle; side views are a thin line with the
  0.02 bevel just visible; iso views show the sheet corners and
  the slight bevel edge. Nothing else to see — by design.
- Export: `versions/v01/ground-paper.glb`, **4,568 bytes**,
  selection-only export of the single part.
  GLB byte/JSON validation (`scripts/validate_glb.py`): PASS —
  magic `glTF`, version 2, declared length 4,568 == file size,
  JSON chunk parses, 1 mesh (SM_ground_paper), 1 material
  (MAT_paper_cream), 4 accessors, 4 bufferViews, 1 node, 0 images,
  0 textures. roughnessFactor 0.9 AND metallicFactor 0 present.
  No unexpected names in the GLB JSON.
- Blender re-import (clean scene, objects deleted, never
  factory-reset): exactly 1 mesh object, SM_ground_paper,
  material [MAT_paper_cream], 44 triangulated faces.
- Three.js validation (fresh `npm install three@0.160.0` in
  /tmp/case3-three-check, no game files touched): GLTFLoader
  LOADED OK — 1 mesh, 96 vertices, 44 triangles (matches the
  re-import total); emissive 000000. Not loaded inside the game's
  own artifact (validation level: Blender re-import + GLB
  byte/JSON validation + real Three.js GLTFLoader load, headless
  Node).
- Known issues: none found. The sheet is deliberately plain; any
  printed lines / folds / stains are a Round 2 decision, not a
  defect of this asset.
- Review (independent, binding): PENDING.
- State: v01 stays IN_PROGRESS (only the coordinator flips to
  ACCEPTED after final review).
