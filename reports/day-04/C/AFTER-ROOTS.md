# AFTER scene roots (post-dedup, scene.data 2026-11-24 18:23)

Total nodes: 44 (was 187)

- id=-145304910 name=地图
- id=-235524988 name=出生点 (spawnPointData -> this id)
- id=-640233936 name=garden-whitebox  <-- single remaining, kept

Removed roots (scene remove --request-id c-dedup-20261124, status=committed):
-886474586, 2062724271, -804300076, 625190827

Scene save: request-id c-dedup-save-20261124, status=committed, hasUnsavedChanges=false

## Binding counts across whole scene (persisted)
- backup_cue.lua x1
- fall_respawn.lua x1
- garden_layer_tint.lua x1
- trigger_probe.lua x0 (old probe fully removed)

## Runtime verification (runtimeId dae1c872-df04-4f82-b3c9-030edd077baf)
- previewGameRoot children: Env#-4682, 地图#-4710, 出生点#-4762, garden-whitebox#-4774  => garden=1
- runtime targets: 3 attached bindings only (fall_respawn, backup_cue, garden_layer_tint)
- screenshot: after-dedup.png

## Kept root bindings
- C_TriggerProbe [-1005226548] -> fall_respawn.lua params {RespawnX:0,RespawnY:21,RespawnZ:-8}
- C_BackupCueZone [-578819827] -> backup_cue.lua params {CueAfterSeconds:45,MaxCues:3,LightIntensity:8}
- Model [-1628462626] -> garden_layer_tint.lua
- C_LightProbe present
