# Day-1 white-box placement, aligned to the real spawn point.
#
# Coordinate facts (measured, see reports/day-01/B/EVIDENCE.md):
#   spawn = (119.741669, 80.0, 88.64061), rotation identity
#   player walks in -Z, moveMaxSpeed 4.0, jumpMaxHeight 1.0
#   the CLI has NO move/rotate command -> every object's orientation is baked
#   into its GLB, and placement is one-shot at import time.
#
# WB_DESK is authored with the chasm as a gap in Z (local z in [-5,+5]).
# Placing the desk at rel z = -15 puts the gap at rel z [-20,-10]:
#   near slab  rel z [-10, +5]   <- player spawns at rel 0
#   chasm      rel z [-20,-10]   <- ahead of the player (-Z), so it blocks
#   far slab   rel z [-35,-20]   <- the pencil-case village / goal
#
# The ruler is 30 m long on a 10 m gap, so it NECESSARILY overhangs.
# It therefore rests off to the side (rel x -11) as the "clue" pose and is
# NOT walkable in the rest state. Moving it into the path is the puzzle.

$ErrorActionPreference = 'Stop'
$IID = 'e96ad682-ead0-42a6-b622-2aea64ef1510'

$A = @{
  WB_DESK       = '12169621355266'
  WB_BOOK_A     = '12163025467906'
  WB_BOOK_B     = '12169621355522'
  WB_PENCILCASE = '12163025468674'
  WB_ERASER     = '12169621355778'
  WB_PENCIL     = '12114171882242'
  WB_LAMP       = '12113943338242'
  WB_MUG        = '12134446359298'
  WB_RULER      = '12185049956098'
}

$SX = 119.741669
$SY = 80.0
$SZ = 88.64061

# name, relX, relY, relZ, note
$plan = @(
  @{ n='WB_DESK';       x=0;   y=-0.6; z=-15; note='desk: chasm at rel z -20..-10' }
  @{ n='WB_BOOK_A';     x=-9;  y=-0.6; z=-2;  note='canyon wall left, near slab' }
  @{ n='WB_BOOK_B';     x=9;   y=-0.6; z=-2;  note='canyon wall right, near slab' }
  @{ n='WB_RULER';      x=-11; y=-0.1; z=-6;  note='rest pose: beside path, overhangs chasm' }
  @{ n='WB_PENCILCASE'; x=0;   y=-0.0; z=-27; note='goal, on far slab' }
  @{ n='WB_ERASER';     x=-12; y=-0.0; z=0;   note='branch prop: eraser counterweight' }
  @{ n='WB_PENCIL';     x=12;  y=-0.0; z=0;   note='branch prop: pencil, runs along Z' }
  @{ n='WB_LAMP';       x=16;  y=0;    z=-30; note='far landmark right' }
  @{ n='WB_MUG';        x=-18; y=0;    z=-32; note='far landmark left (harbor vista)' }
)

Write-Host "spawn = ($SX, $SY, $SZ)`n"
$results = @()
foreach ($p in $plan) {
  $wx = [Math]::Round($SX + $p.x, 3)
  $wy = [Math]::Round($SY + $p.y, 3)
  $wz = [Math]::Round($SZ + $p.z, 3)
  $rid = "wb2-$($p.n)"
  $out = douyin-world scene import --asset-id $A[$p.n] "--position=$wx,$wy,$wz" `
           --instance $IID --request-id $rid 2>&1 | Out-String
  $status = if ($out -match '"status":\s*"([^"]+)"') { $matches[1] } else { 'TIMEOUT/CHECK' }
  $root = if ($out -match '"rootIDs":\s*\[\s*"(-?\d+)"') { $matches[1] } else { '' }
  Write-Host ("  {0,-14} {1,-16} @ ({2},{3},{4})  {5}  root={6}" -f $p.n, $p.note, $wx, $wy, $wz, $status, $root)
  $results += [pscustomobject]@{ name=$p.n; x=$wx; y=$wy; z=$wz; status=$status; rootID=$root; requestId=$rid }
  Start-Sleep -Seconds 2
}

$results | ConvertTo-Json | Out-File -Encoding utf8 'D:\competition\evidence\whitebox-placement.json'
Write-Host "`n=== save ==="
douyin-world scene save --instance $IID --request-id save-aligned 2>&1 | Out-String
