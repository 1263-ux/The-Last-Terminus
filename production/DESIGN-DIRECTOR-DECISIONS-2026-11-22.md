# Design Director Decisions｜2026-11-22

> Scope: current three-world production, based on PR #10/#11/#12 and Day-3 evidence.
> Authority: design direction and acceptance criteria. This file does not convert unverified editor behavior into fact.

## 1. Product direction — CONFIRMED
Keep the three-world journey:
1. Train Hub / The Last Terminus — connective spine and emotional frame.
2. Desk World: Under the Desk — intimate micro-scale exploration; signature verb: reinterpret and repurpose familiar objects.
3. Floating Garden — vertical spatial discovery; signature verb: observe, infer, and discover a route.

World distinction:
- Desk: object-use transformation, near-field detail, tactile warmth.
- Garden: vertical layers, inverted greenhouse, route discovery and vista.
- Train/Terminus: travel, transition, anticipation and final release.
No fourth playable world in the one-week scope. Cloud-sea Terminus remains primarily an exhibition/ending space.

## 2. Editor constraints — current production assumptions
Based on A/B independent runtime inspection:
- Player is a script-driven NetworkActor with isKinematic=true and velocity=(0,0,0).
- Ordinary scene meshes / rigidbody colliders cannot be assumed to block horizontal player movement.
- Trigger + bound Lua + controlled state transition / Teleport has working evidence in C and A probes.
- B CLI-created trigger has no script list; this does not prove editor-bound scripts cannot work. C bound-Lua trigger proves the GUI/project-side binding route is viable in at least one project/version.

Production rule: never design a critical gate around a wall physically stopping the player. Use explicit trigger/state logic and verify in the actual player camera. Geometry remains visual and may provide walkable surfaces only where real walking tests prove it.

## 3. Decision B — Desk World / ruler puzzle
### 3.1 Preserve the signature idea
Keep the ruler as the key object and preserve the fantasy: a familiar ruler is reinterpreted as a bridge/ramp that changes how the miniature explorer reaches the pencil-case town.

### 3.2 Change implementation, not fantasy
C4 “vertical wall physically blocks the player” is NOT APPROVED. It relies on collision response that current evidence says is unavailable.
Replace it with a state-gated route:
- State 0: ruler is in resting position; target route is visually incomplete or destination/route is not yet activated.
- Player approaches an interaction zone and activates it through a bound Trigger/Lua interaction.
- State 1: resting ruler representation is hidden; ramp/bridge representation is shown; route cue and destination state update.
- A gate trigger controls progression. Before activation, entering the locked zone returns the player to a safe point or leaves the destination inactive. After activation, route trigger allows progression.
- Player must see the changed route and traverse it in a real continuous player run. A logic flag flipping is insufficient.
Do not use a fake invisible wall as the primary explanation. The player should understand locked/unlocked state from visible affordances. Avoid repeated teleporting without feedback.

### 3.3 Fallback order
1. Preferred: bound Lua trigger + REST/RAMP visual state swap + route state gate.
2. If trigger binding is unreliable: explicit interaction prompt/button supported by the editor, bound to the same state machine.
3. If player-camera geometry fails in Preview: test Published/non-Preview before changing the world.
4. If Published player camera also cannot render scene assets: stop world expansion and present a minimal reproducible project. R1 (editor-viewport/logic-only presentation) is a competition-risk fallback, not approved as target experience.
C4 remains a whitebox candidate until the full see → understand → activate → see change → traverse → arrive loop is visible and playable.

## 4. Decision C — Floating Garden / vista acceptance
Keep Plan C: entry island → broken bridge / route clue → roots descent → inverted greenhouse roof → crown vista.

### 4.1 Vista framing rule
Withdraw the requirement that approach path and next destination must appear in the same static camera frame.
New acceptance:
- On arrival at the crown, the next destination / horizon reward is visible in the default arrival view.
- With normal player look input, the player can identify the route they came from within 3 seconds of intentionally looking back.
- No forced camera cut, forced yaw, or scripted camera takeover is required.
- If the editor does not provide usable free-look, design a physical viewing position / short turn-around path that reveals the route without camera scripting.
This is an acceptance rule, not a claim C has passed. It requires a real GUI playtest.

### 4.2 Keep route discovery meaningful
- Entry view must show the greenhouse as a legible target.
- Broken bridge communicates “straight path unavailable” without relying on physical collision.
- Roots are visually and spatially legible as an alternate route.
- Inverted greenhouse retains structural cues: upward-facing drainage/eaves, exposed base flanges, downward-facing skylight.
- Fall recovery remains available, but the first route should be discoverable without repeated accidental falls.
C-G1 remains REVISE until blind route discovery and vista criterion are tested.

## 5. Decision A — Train Hub and Terminus
- Keep A Hub and cloud-sea terminus as public integration spine.
- Hub is the safe return point; every world can be entered and left without completing its puzzle.
- Use trigger + Lua transitions only after real runtime verification; use separated Entry/Exit anchors with cooldown and safe spawn zones.
- The 115m terminus route is not accepted as fully walkable: A must complete the full route, not extrapolate from the first two arches.
- Terminus remains primarily exhibition/ending in one-week scope. Prioritize silhouette, route clarity, vista, audio and memorable arrival over extra mechanics.

## 6. Visual production / Tripo gate
No mass asset generation until:
- B proves player-camera visibility in Preview and Published (or isolates exact limitation).
- B ruler state-gated loop is visible and traversable.
- C route and vista criterion are tested with real player input.
- A publishes shared GLB import recipe and known constraints.

After that:
- Total design owner supplies Tripo-generated hero assets and style reference.
- B/C prepare Asset Cards and placement requirements, but do not independently invent hero asset style.
- Use GLB as exchange format; include textures and ASSET-MANIFEST.csv.
- Test one representative Tripo export before generating the full set.
- Based on C T-19 evidence, prioritize geometry/material separation; do not spend generation budget on normal/ORM maps until support is proven. Confirm actual Tripo texture container format.

## 7. Sound direction
Use existing/licensed sound sources and editor-supported playback; do not build a custom audio system before verifying the editor.
- Hub: warm mechanical ambience, soft rail/engine rhythm, departure/arrival motif.
- Desk: close tactile foley (paper, wood, pencil, cup resonance), warm restrained music.
- Garden: airy wind, distant glass/leaf resonance, sparse melodic texture.
- Terminus: reduce rhythm, open ambience, resolve the travel motif.
A probes import/playback/loop/volume/triggered cue once. C identifies cue points, not unsupported audio assumptions. All tracks require clear usage rights and local asset files or stable references.

## 8. One-week scope lock
Must deliver: one integrated Hub + two playable worlds + one exhibition/ending space; one complete signature interaction in Desk; one complete route-discovery experience in Garden; one connected journey with entry/exit and return; consistent visual language, readable lighting, intentional ambience/music; at least one independent playtest per playable world.

Explicitly out of scope: true physics-based movable objects; arbitrary gravity direction; large open-world streaming; complex NPC simulation/economy; multiplayer puzzle synchronization unless already proven; batch-generated decorative assets before hero assets and camera tests pass.

## 9. Gate ownership
- A owns shared editor/asset/integration evidence.
- B owns Desk world and its playable loop.
- C owns Garden world and its playable loop.
- Design director owns concept changes, scope, art approval and final Gate.
- A member self-review is not final approval.
- Every Gate uses PASS / FAIL / NOT TESTED / INCONCLUSIVE and links direct evidence.

## 10. Immediate next actions
See production/prompts/DAY-03-REVISION-AND-DAY-04-ENTRY-GATE.md.