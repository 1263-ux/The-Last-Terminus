-- Test whether the engine's own respawn catches a fall. If it does, the gate can
-- be a REAL GAP instead of a teleport I write, and the kinematic controller cannot
-- fight it because the engine owns respawn.
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
  local pl = find("Player_1")
  if not pl then r.error="no player" return end
  local p = pl.transform.position
  r.before = string.format("%.2f,%.2f,%.2f", p.x, p.y, p.z)
  -- drop the player far below the ground to trigger respawn
  pl.transform.position = CS.UnityEngine.Vector3(p.x, p.y - 80.0, p.z)
  r.dropped = "true"
end)
if not ok then r.error = tostring(err) end
return r
