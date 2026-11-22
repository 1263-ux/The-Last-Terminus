# DAY 03 REVISION → DAY 04 ENTRY GATE

This is a focused revision round, not a new multi-day mega-prompt. Read production/DESIGN-DIRECTOR-DECISIONS-2026-11-22.md first. Continue on the existing member branch; preserve all work. Do not reset/rebase destructively.

## Shared rules
- No batch Tripo production yet.
- Do not rely on scene mesh collision to block the script-driven NetworkActor.
- Separate data/render/runtime evidence.
- A must correct contradictory collision conclusions before PR review.
- A/B/C post handoffs in existing PR threads, with report path + commit SHA.
- GUI-only tasks must be done by a human member and marked NOT TESTED until evidence exists.

## A — Integration / technical owner
1. Correct reports/day-03/A/COLLISION-MATRIX.md: remove stale rows claiming P3 PASS / GLB blocks player. State current root cause consistently: NetworkActor kinematic, transform-driven movement; ordinary scene colliders do not stop horizontal movement. Preserve historical false-positive as superseded observation.
2. Reconcile BLOCKERS.md, DAY3-SUMMARY.md, WORLD-INTERFACE-CONTRACT.md and HANDOFF.md. No contradictory PASS/FAIL claims.
3. Deliver a minimal bound-trigger WPRE and cross-member import request. A same-machine proof is not cross-member.
4. Complete Hub-to-Terminus full 115m route with real player input; record elapsed time, failures and arrival view.
5. Probe audio import/playback/loop/volume/trigger once; report supported formats and exact GUI/CLI workflow. If unavailable, mark NOT TESTED and give fallback.
6. Update PR #12 with corrected reports and remaining NOT TESTED list.

## B — Desk World owner
1. Do not build a physical blocking wall. C4 vertical wall is rejected as a physical gate.
2. Preserve ruler repurposing. Implement state-gated version: REST visual → player activates bound interaction → REST hidden / RAMP visible → route state changes → player traverses route → arrives at pencil-case town.
3. C Trigger+Lua is evidence bound scripts can work. B CLI-only empty script list does not prove GUI-bound scripts fail. Ask C for exact binding recipe and reproduce in Desk project. If GUI is required, member B performs it.
4. Critical GUI test: compare (a) GUI-created Cube, (b) imported GLB, (c) existing C4 assets from player third-person camera in Preview and Published/non-Preview. Record editor version/project, same camera position, screenshots/video.
5. If player-camera rendering works in Published, use it as target runtime and document Preview limitation. If it fails in both, create a minimal reproducible project and stop expanding until understood.
6. C4 gate remains REVISE until complete player-visible interaction loop is proven. Logic-only PASS does not pass world Gate.
7. Update PR #10 with evidence and revised capability matrix.

## C — Floating Garden owner
1. Keep Plan C; do not expand map.
2. Apply vista acceptance: default arrival view shows next destination; after normal free-look input, approach path can be identified within 3 seconds. Same-frame view of both is no longer required.
3. Human GUI test: verify free-look works. If unavailable, propose a physical turnaround platform/path; do not script forced camera yaw.
4. Run at least two uninvolved-player route discovery tests. Record time-to-discover roots, wrong turns, falls, help requests and completion. If unavailable, mark NOT TESTED and provide honest internal dry run separately.
5. Verify full Backup Cue timing at 45 seconds, one-shot/debounce and fall-recovery after restart.
6. Provide exact world-space Entry/Exit, spawn yaw, safe-zone and return target. Use runtime-measured positions, not source Three.js coordinates.
7. Update PR #11 and QA-AUDIT with evidence; do not claim Gate PASS.

## Cross-team
- B consumes C bound Lua Trigger recipe and reports whether it works in Desk project.
- C consumes A shared probe assets and reports actual cross-member import result.
- A receives B/C exact Entry/Exit fields and records integration status.
- Each handoff includes commit SHA, project/editor version, file path and evidence.
- If a dependency blocks, isolate it and continue independent work.

## Day 04 entry criteria
Day 04 may begin one representative hero asset and style/audio proof only when:
1. B player-camera rendering status is known in Preview and Published.
2. B ruler state change is visible and player-traversable, or design director explicitly approves fallback.
3. C arrival vista rule is verified; route blind test is either passed or scheduled with named testers.
4. A shared GLB import constraints and asset package manifest are stable.
5. One actual Tripo export has been imported and inspected, including texture container format.

Do not interpret Day 04 entry as permission for mass asset production. One representative hero asset first, then review before batch.

## Reporting
Write to reports/day-03/A/REVISION.md, reports/day-03/B/REVISION.md, reports/day-03/C/REVISION.md. Update existing evidence indexes. Commit and push on existing feature branches. Keep PRs open for review.