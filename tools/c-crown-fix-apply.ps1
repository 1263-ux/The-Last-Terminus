<#
C garden — crown entry fix A' apply script (POST-APPROVAL ONLY)

Why this exists:
  The crown vista is unreachable on foot because the intended return corridor
  (VistaReturn, world x 118.5-121.5) is blocked by
    1) a 0.7 m gap at z 139.5-140.2, and
    2) VistaRail_Back (z=139.5, spans x 115.9-124.1, top 76.56).
  Fix A' = split the back rail into two 2.4 m segments (3.4 m gap over the corridor)
  + add VistaCorridorFill (3.0 x 0.30 x 1.2, top 26.0 local).
  Runtime simulation already proved this works (issue #23 comment 7154792871).

Safety:
  - dry-run by default; pass -Execute to actually change anything
  - refuses to run unless the patch applies cleanly and a backup is made
  - does not touch scene.data until the prefab rebuild + validate + build succeed

Usage:
  pwsh tools/c-crown-fix-apply.ps1                 # dry run: prints every step
  pwsh tools/c-crown-fix-apply.ps1 -Execute        # really apply (needs approval)
#>
param(
  [switch]$Execute,
  [string]$ProjectRoot = "C:\Users\LENOVO\AppData\Roaming\AI World Creator\projects\project-8e9f55c1-590c-4ffa-9dc7-403b8759d19a",
  [string]$WorkspaceId = "workspace_ihycinrp",
  [string]$PrefabId = "garden-whitebox",
  [string]$SessionFile = "D:\wow-land\competition\session-c2.json",
  [string]$BackupDir = "D:\wow-land\competition\backup-garden-whitebox-prefix",
  [string]$OldGardenRootId = "-640233936",
  [string]$Uri = ""
)

$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent $PSScriptRoot
$patch = Join-Path $repo "reports\day-04\C\crown-fix-A-prime.patch"
$prefabRoot = Join-Path $ProjectRoot "ai-sessions\$WorkspaceId\wprefabs\$PrefabId"

function Step([string]$title) {
  Write-Host ""
  Write-Host "=== $title" -ForegroundColor Cyan
}
function Run([string]$cmd) {
  Write-Host "  > $cmd" -ForegroundColor DarkGray
  if (-not $Execute) { return }
  Invoke-Expression $cmd
  if ($LASTEXITCODE -ne 0) { throw "command failed ($LASTEXITCODE): $cmd" }
}

Write-Host "C crown fix A' - mode: $(if ($Execute) { 'EXECUTE' } else { 'DRY-RUN' })" -ForegroundColor Yellow
Write-Host "  repo       : $repo"
Write-Host "  prefabRoot : $prefabRoot"
Write-Host "  patch      : $patch"

Step "0. preconditions"
if (-not (Test-Path $patch)) { throw "patch not found: $patch" }
if (-not (Test-Path $prefabRoot)) { throw "prefab workspace not found: $prefabRoot" }
Run "git -C '$prefabRoot' apply --check '$patch'"
Write-Host "  patch applies cleanly (checked)" -ForegroundColor Green

Step "1. backup prefab workspace -> $BackupDir"
Run "Copy-Item -Recurse -Force '$prefabRoot' '$BackupDir'"

Step "2. apply patch to preview-module.js"
Run "git -C '$prefabRoot' apply '$patch'"

Step "3. rebuild model + prefab (authoring)"
Run "douyin-world authoring resource model check model-garden-whitebox --prefab $PrefabId --workspace-id $WorkspaceId"
Write-Host "  expect: nodeCount 153 -> 155 (two extra boxes), modelType 2"
Run "douyin-world authoring resource archive model-garden-whitebox --kind model --prefab $PrefabId --workspace-id $WorkspaceId"
if ([string]::IsNullOrWhiteSpace($Uri)) {
  if ($Execute) { throw "archive returns a uri; re-run with -Uri <uri> to attach it" }
  Write-Host "  (dry-run) would then: prefab attach $PrefabId ... --uri <uri from archive>"
} else {
  Run "douyin-world authoring prefab attach $PrefabId --workspace-id $WorkspaceId --uri $Uri"
}
Run "douyin-world authoring prefab validate $PrefabId --workspace-id $WorkspaceId"
Write-Host "  expect: items [] (no validation problems)"
Run "douyin-world authoring prefab build $PrefabId --workspace-id $WorkspaceId"
Run "douyin-world authoring result archive $PrefabId --workspace-id $WorkspaceId"

Step "4. scene swap (runtime must be stopped first)"
Run "douyin-world runtime stop --session '$SessionFile'"
Run "douyin-world scene import --prefab $PrefabId --position 120,50,115 --name garden-whitebox --request-id c-crownfix-import"
Write-Host "  capture the returned rootIDs -> new root id"
Run "douyin-world scene remove $OldGardenRootId --request-id c-crownfix-remove"
Run "douyin-world scene save --request-id c-crownfix-save"

Step "5. verify"
Run "douyin-world runtime start --session '$SessionFile' --timeout-ms 180000"
Run "douyin-world runtime js eval --file '$repo\tools\c-garden-verify.js' --session '$SessionFile'"
Write-Host "  expect: corridorPass true, crownVerdict PASS, overall PASS"
Write-Host "  then walk the corridor with continuous input (no jump):"
Write-Host "    teleport (120,76.3,141.2) -> yaw 180 -> W:1200 -> W:900 -> expect (120,76.01,135)"
Write-Host "  then re-shoot the 4 vista directions and update reports/day-04/C/CLEAN-SCENE-RETEST.md"

if (-not $Execute) {
  Write-Host ""
  Write-Host "DRY-RUN finished. Nothing was changed. Re-run with -Execute after approval." -ForegroundColor Yellow
}
