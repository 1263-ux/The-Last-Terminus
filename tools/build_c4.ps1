# C4: VERTICAL BREAK + RULER-AS-RAMP  (chosen over the horizontal chasm)
#
# WHY C4, in engine terms rather than taste:
#  - The horizontal chasm FAILED in testing. The terrain is one continuous
#    surface at y~80 and the desk sits only 0.4 m above it, so the gap had
#    terrain underneath and the player walked straight across (measured: camera y
#    stayed 79.6-80.0 from z=88.6 to z=136.6).
#  - Raising the slabs to 85.4 failed too: the player spawns on the terrain and
#    has no route up, and a fall from 8 m onto terrain would be a P0 soft-lock
#    because jumpMaxHeight is 1.0 m.
#  - A 3.0 m wall against jumpMaxHeight = 1.0 m CANNOT be jumped. That is
#    arithmetic, not assumption, so the blocker holds by construction.
#  - The player never leaves the terrain, so there is no fall and no soft-lock.
#  - It also matches the world doc wording better: "the broken passage between
#    two giant books" - the break belongs on the book faces, not as a hole in
#    the desk.
#
# ROUTE
#   spawn z=88.6  ->  eraser / pencil (3 m, readable props)
#                 ->  book terraces (flat, walkable)
#                 ->  BREAK WALL at z~101, 3 m tall, spans the corridor
#                 ->  RULER RAMP: rest pose beside the wall first, then the
#                     swapped pose leaning on it  [this is the puzzle]
#                 ->  over the wall, pencil-case village at z~112 = GOAL
#                 ->  EXIT SIGN beyond it

$ErrorActionPreference = 'Stop'
$IID = 'awc-1095fbb1-8dbd-40b0-b612-43cbe7ffa6df'

$A = @{
  WB_BREAK_WALL   = '12165622084098'
  WB_RULER_RAMP   = '12056514093826'
  WB_RULER_RAMP_UP= '12107453694210'
  WB_BOOK_S       = '12169622307842'
  WB_CASE_S       = '12056514094338'
  WB_SIGN         = '12049863265282'
  WB_ERASER       = '12141538596098'
  WB_PENCIL       = '12134447405570'
}

$SX = 119.741669
$G  = 80.0   # terrain surface: everything stands ON it, nothing is suspended

$plan = @(
  #   asset            relX   y      z      role
  @{ n='WB_ERASER';      x=-3;  z=91.5;  t='1. counterweight, 3 m out' }
  @{ n='WB_PENCIL';      x= 3;  z=91.5;  t='2. alt tool, 3 m out' }
  @{ n='WB_BOOK_S';      x=-4;  z=95;    t='3. book terrace L' }
  @{ n='WB_BOOK_S';      x= 4;  z=95;    t='4. book terrace R' }
  @{ n='WB_BREAK_WALL';  x= 0;  z=101;   t='5. THE BLOCKER (3 m > 1 m jump)' }
  @{ n='WB_RULER_RAMP';  x=-6;  z=97;    t='6. ramp REST pose (clue)' }
  @{ n='WB_RULER_RAMP_UP'; x=0; z=105;   t='7. ramp LEANING on wall (solved)' }
  @{ n='WB_CASE_S';      x= 0;  z=112;   t='8. village = GOAL, past the wall' }
  @{ n='WB_SIGN';        x=-4;  z=115;   t='9. EXIT' }
)

Write-Host "C4 build: ground y=$G, spawn z=88.64`n"
$rows = @()
$i = 0
foreach ($p in $plan) {
  $i++
  $wx = [Math]::Round($SX + $p.x, 3)
  $out = douyin-world scene import --asset-id $A[$p.n] "--position=$wx,$G,$($p.z)" `
           --instance $IID --request-id ("c4-" + $i) 2>&1 | Out-String
  $st = if ($out -match '"status":\s*"([^"]+)"') { $matches[1] } else { 'TIMEOUT' }
  Write-Host ("  {0,-18} z={1,6}  {2,-8} {3}" -f $p.n, $p.z, $st, $p.t)
  $rows += [pscustomobject]@{ idx=$i; name=$p.n; x=$wx; y=$G; z=$p.z; status=$st; role=$p.t }
  Start-Sleep -Seconds 1
}
$rows | ConvertTo-Json | Out-File -Encoding utf8 'D:\competition\evidence\c4-placement.json'

Write-Host "`n=== save ==="
douyin-world scene save --instance $IID --request-id save-c4 2>&1 | Out-String
