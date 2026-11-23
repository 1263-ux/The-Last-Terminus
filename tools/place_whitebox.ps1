# Deterministic white-box placement using the MEASURED camera transform.
#
# Measured at runtime via lua (see reports/day-01/B/WHITEBOX-FIX.md):
#   camera name : TPCameraAvatar
#   camera pos  : (119.703, 78.921, 82.489)
#   camera fwd  : (0.0724, -0.3090, 0.9483)   -> looks toward +Z, pitched down
#   fov 45, near 0.05, far 1000
#
# CRITICAL: the camera sits at y=78.92, which is BELOW the player's foot plane
# (y=80.0) because a third-person camera rides behind and below. Any ground slab
# whose top is at the player's feet therefore occludes the entire view. That is
# why "props exist and cast shadows but nothing is visible".
#
# So: no raised slab under the player. Props are laid out along the measured
# forward ray, on the terrain surface itself, with the desk split around the
# chasm at ground level.

$ErrorActionPreference = 'Stop'
$IID = 'awc-e4f18ace-b23c-4103-bab6-0e16356556b2'

$A = @{
  WB_DESK       = '12134446524674'
  WB_BOOK_A     = '12141537799938'
  WB_BOOK_B     = '12185050115330'
  WB_RULER      = '12107437594626'
  WB_PENCILCASE = '12065306652930'
  WB_ERASER     = '12056513177602'
  WB_PENCIL     = '12114172065026'
  WB_LAMP       = '12141537801730'
  WB_MUG        = '12049862359810'
}

# Measured camera basis
$CX = 119.703; $CY = 78.921; $CZ = 82.489
$FX = 0.0724;  $FY = -0.3090; $FZ = 0.9483

# Ground surface: props sit at y = 80.0 (player foot plane).
$GY = 80.0

# Walk the forward ray at a horizontal-ish distance and drop each prop onto
# y = GY, so everything stays in frame and on the ground.
function Ray($t) {
  # advance along the horizontal component of the forward vector only,
  # then pin to ground height -- this keeps props ahead, not underneath.
  $hx = $FX; $hz = $FZ
  $len = [Math]::Sqrt($hx*$hx + $hz*$hz)
  $nx = $hx / $len; $nz = $hz / $len
  return @([Math]::Round($CX + $nx*$t, 3), $GY, [Math]::Round($CZ + $nz*$t, 3))
}

$plan = @(
  @{ n='WB_BOOK_A';     t=12; dx=-7 },
  @{ n='WB_BOOK_B';     t=12; dx= 7 },
  @{ n='WB_ERASER';     t=7;  dx=-9 },
  @{ n='WB_PENCIL';     t=7;  dx= 9 },
  @{ n='WB_RULER';      t=20; dx=-6 },
  @{ n='WB_PENCILCASE'; t=30; dx= 0 },
  @{ n='WB_LAMP';       t=34; dx= 8 },
  @{ n='WB_MUG';        t=34; dx=-8 }
)

Write-Host "camera ($CX,$CY,$CZ) fwd ($FX,$FY,$FZ) -> placing on y=$GY`n"

foreach ($p in $plan) {
  $r = Ray $p.t
  $x = [Math]::Round($r[0] + $p.dx, 3)
  $z = $r[2]
  $o = douyin-world scene import --asset-id $A[$p.n] "--position=$x,$GY,$z" `
         --instance $IID --request-id "wbA-$($p.n)" 2>&1 | Out-String
  $st = if ($o -match '"status":\s*"([^"]+)"') { $matches[1] } else { 'TIMEOUT' }
  Write-Host ("  {0,-14} t={1,-3} -> ({2},{3},{4})  {5}" -f $p.n,$p.t,$x,$GY,$z,$st)
  Start-Sleep -Seconds 2
}

# Desk: placed flat on the ground with the chasm ahead. Its local z span is
# -6..44 and the chasm sits at local z 22..32, so offset the whole desk so that
# local z0 lands ~4 m in front of the player and the chasm lands ~26..36 m out.
$deskZ = [Math]::Round($CZ + 10, 3)      # local z=0 at 10 m ahead
$deskY = 80.0                            # slab bottom at ground, no occlusion
Write-Host "`n  WB_DESK -> ($CX,$deskY,$deskZ)"
$o = douyin-world scene import --asset-id $A['WB_DESK'] "--position=$CX,$deskY,$deskZ" `
       --instance $IID --request-id "wbA-WB_DESK" 2>&1 | Out-String
Write-Host "  desk: " + $(if ($o -match '"status":\s*"([^"]+)"') { $matches[1] } else { 'TIMEOUT' })

Start-Sleep -Seconds 2
Write-Host "`n=== save ==="
douyin-world scene save --instance $IID --request-id save-wbA 2>&1 | Out-String
