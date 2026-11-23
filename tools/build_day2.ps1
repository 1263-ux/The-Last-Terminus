# Day-2 white-box, scale-corrected AND proximity-corrected.
#
# TWO measured facts drive this file:
#
# 1) IMPORT SCALE. `scene import` normalises a GLB to ~1 unit and bakes a scale
#    equal to the mesh's longest authored dimension back onto the node, so
#    effective size = authored_size x authored_longest (quadratic). Verified:
#    WB_BOOK_S (2.0 x 0.55 x 1.6) -> scale (2,2,2) -> world 4.0 x 1.1 x 3.2 m.
#    Assets used here are authored small ("_S") for that reason.
#
# 2) NARROW VISIBLE BAND. Camera sits ~0.4 m above the deck, pitched 18 deg down,
#    half-FOV 22.5 deg. The frame's top edge at distance d is y ~= 79.6 + 0.105d.
#    At d=10 that is y=80.65: a 1.1 m book top (y=81.1) is already cropped.
#    Objects therefore read only when the player is CLOSE, and the frame is
#    mostly FLOOR. That is a real composition constraint of the default camera,
#    recorded in reports/day-02/B/SPATIAL-FINDINGS.md - not something to fake by
#    tilting shots.
#
# Layout: a tight ~14 m corridor from spawn to the chasm, everything within
# 2-12 m so each element lands inside the visible band as the player advances.

$ErrorActionPreference = 'Stop'
$IID = 'awc-00f3a1b3-f042-405f-8f9b-667a559c37ea'

$A = @{
  WB_DESK   = '12107438299906'
  WB_BOOK_S = '12113944255490'
  WB_RULER_S= '12114440943618'
  WB_CASE_S = '12201538892290'
  WB_RULER  = '12165621930498'
  WB_RULER_SPAN = '12134447207170'
  WB_SIGN   = '12165621931522'
  WB_ERASER = '12169622143234'
  WB_PENCIL = '12201538832130'
  WB_LAMP   = '12056513882114'
  WB_MUG    = '12065307353602'
}

$SX = 119.741669
$DECK = 80.0

# Absolute world Z. Spawn z = 88.64.
#   88.6  spawn
#   91-93 first props (eraser / pencil) - 3-5 m out
#   95-99 book terraces (the canyon floor)
#   100   chasm edge (desk near slab ends)
#   104   ruler spans it
#   108   village across the gap
#   110   exit sign
$plan = @(
  @{ n='WB_ERASER';     x=-4;  y=$DECK; z=91.5;  tag='1. counterweight, 3 m out' }
  @{ n='WB_PENCIL';     x=4;   y=$DECK; z=91.5;  tag='2. alt span candidate' }
  @{ n='WB_BOOK_S';     x=-3;  y=$DECK; z=95;    tag='3. canyon terrace L' }
  @{ n='WB_BOOK_S';     x=3;   y=$DECK; z=95;    tag='4. canyon terrace R' }
  @{ n='WB_DESK';       x=0;   y=79.4; z=94.6;   tag='5. deck, chasm at z100-110' }
  @{ n='WB_RULER_S';    x=-4;  y=$DECK; z=97;    tag='6. ruler REST (clue pose)' }
  @{ n='WB_RULER_SPAN'; x=0;   y=$DECK; z=104;   tag='7. ruler SPANNED' }
  @{ n='WB_CASE_S';     x=0;   y=$DECK; z=108;   tag='8. village = GOAL' }
  @{ n='WB_SIGN';       x=-4;  y=$DECK; z=110;   tag='9. EXIT' }
  @{ n='WB_LAMP';       x=7;   y=$DECK; z=111;   tag='10. far landmark' }
  @{ n='WB_MUG';        x=-7;  y=$DECK; z=111;   tag='11. far landmark' }
)

Write-Host "Day-2 scale+proximity corrected. deck y=$DECK, spawn z=88.64`n"
$rows = @()
$idx = 0
foreach ($p in $plan) {
  $idx++
  $wx = [Math]::Round($SX + $p.x, 3)
  # requestId must be a plain token (no dots/spaces), and unique per call.
  $out = douyin-world scene import --asset-id $A[$p.n] "--position=$wx,$($p.y),$($p.z)" `
           --instance $IID --request-id ("d2f-" + $idx) 2>&1 | Out-String
  $status = if ($out -match '"status":\s*"([^"]+)"') { $matches[1] } else { 'TIMEOUT' }
  Write-Host ("  {0,-15} z={1,6}  {2,-8} {3}" -f $p.n, $p.z, $status, $p.tag)
  $rows += [pscustomobject]@{ idx=$idx; name=$p.n; x=$wx; y=$p.y; z=$p.z; status=$status; tag=$p.tag }
  Start-Sleep -Seconds 1
}
$rows | ConvertTo-Json | Out-File -Encoding utf8 'D:\competition\evidence\day2-placement-final.json'

Write-Host "`n=== save ==="
douyin-world scene save --instance $IID --request-id save-d2f 2>&1 | Out-String
