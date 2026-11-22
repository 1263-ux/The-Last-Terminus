-- Report whether the gate rule WOULD fire at the player's current position.
-- Pure function, no teleport, so the controller cannot fight it.
local r = {}
local ok, err = pcall(function()
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local function find(n)
    local hit=nil
    local function w(t,d) if d>12 or hit then return end local o=t.gameObject
      if o.name==n then hit=o return end
      for i=0,t.childCount-1 do w(t:GetChild(i),d+1) end end
    local rs=scene:GetRootGameObjects()
    for i=0,rs.Length-1 do local o=rs:get_Item(i); if o then w(o.transform,0) end; if hit then break end end
    return hit
  end
  local p = find("Player_1")
  local st = find("C4_STATE")
  if not p then r.error="no player" return end
  local activated = st and (not st.activeSelf) or false
  local z = p.transform.position.z
  r.playerZ = string.format("%.2f", z)
  r.activated = tostring(activated)
  r.gateAtZ = "101.00"
  r.blockingLineZ = "103.00"
  r.pastGate = tostring(z > 103.0)
  r.ruleFires = tostring((not activated) and z > 103.0)
  if (not activated) and z > 103.0 then
    r.wouldReturnToSpawn = "true"
  else
    r.wouldReturnToSpawn = "false"
  end
end)
if not ok then r.error=tostring(err) end
return r
