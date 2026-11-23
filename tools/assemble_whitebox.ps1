# Day-1 white-box scene assembly.
# Places the 9 generated white-box GLBs into the real editor scene so the
# MICRO-SCALE READ can be tested from the player camera.
#
# Scale basis: editor player avatar ~1.7 m tall, jump 1.0 m, walk 4.0 m/s.
# Desk objects are therefore GIANT (book 7 m, ruler 30 m) -> ~4x / ~17x player height.

$ErrorActionPreference = 'Stop'
$IID = 'e96ad682-ead0-42a6-b622-2aea64ef1510'

$A = @{
  DESK       = '12134446243074'
  BOOK_A     = '12163025365506'
  BOOK_B     = '12107437307906'
  RULER      = '12114439885826'
  ERASER     = '12134446241794'
  PENCIL     = '12163025366018'
  PENCILCASE = '12116652454146'
  LAMP       = '12116652453378'
  MUG        = '12056512871938'
}

# name -> (assetKey, x, y, z, requestId)
# Chasm runs along Z at x in [-5, +5]. West slab x<0 (spawn side), east slab x>0.
$placements = @(
  @{ n = 'WB_DESK';        k = 'DESK';       x = 0;    y = 0;   z = 0;   r = 'wb-desk' }
  # --- Book Canyon (west, spawn side): two giant books forming a canyon the player walks between
  @{ n = 'WB_BOOK_A';      k = 'BOOK_A';     x = -13;  y = 0;   z = -6;  r = 'wb-booka' }
  @{ n = 'WB_BOOK_B';      k = 'BOOK_B';     x = -13;  y = 0;   z = 4;   r = 'wb-bookb' }
  # --- Ruler Bridge: the ruler spans the chasm at z=0 (rest state = NOT spanning; see NOTES)
  @{ n = 'WB_RULER';       k = 'RULER';      x = -8;   y = 0.7; z = 0;   r = 'wb-ruler' }
  # --- Pencil-case Village (east, the goal across the chasm)
  @{ n = 'WB_PENCILCASE';  k = 'PENCILCASE'; x = 12;   y = 0.6; z = 0;   r = 'wb-case' }
  # --- Support / branch props
  @{ n = 'WB_ERASER';      k = 'ERASER';     x = -3.5; y = 0.6; z = -9;  r = 'wb-eraser' }
  @{ n = 'WB_PENCIL';      k = 'PENCIL';     x = -3.5; y = 0.6; z = 9;   r = 'wb-pencil' }
  # --- Far landmarks (scale + world-beyond-the-desk)
  @{ n = 'WB_LAMP';        k = 'LAMP';       x = 26;   y = 0;   z = -16; r = 'wb-lamp' }
  @{ n = 'WB_MUG';         k = 'MUG';        x = 30;   y = 0;   z = 14;  r = 'wb-mug' }
)

foreach ($p in $placements) {
  $assetId = $A[$p.k]
  # Negative coordinates must use the --position= form (CLI arg parser treats
  # a leading '-' as a new option otherwise).
  $posArg = "--position=$($p.x),$($p.y),$($p.z)"
  Write-Host "-> $($p.n) [$assetId] @ $posArg"
  $out = douyin-world scene import --asset-id $assetId $posArg --instance $IID --request-id $p.r 2>&1 | Out-String
  $status = if ($out -match '"status":\s*"([^"]+)"') { $matches[1] } else { 'UNKNOWN' }
  Write-Host "   status=$status"
  if ($status -ne 'committed') { Write-Host $out.Substring(0, [Math]::Min(400, $out.Length)) }
}

Write-Host "`n=== saving ==="
douyin-world scene save --instance $IID --request-id save-day1-wb 2>&1 | Out-String
