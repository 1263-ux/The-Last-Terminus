-- Extreme control: put a 2 m cube directly BESIDE the player (2 m away, same
-- height as the player's torso). At that distance it must fill a large part of
-- the frame if anything renders at all. If it does not appear, the player camera
-- is definitively not drawing created objects, and no placement can fix it.
local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local v3 = CS.UnityEngine.Vector3
  local prim = CS.UnityEngine.PrimitiveType
  local sh = CS.UnityEngine.Shader.Find("Universal Render Pipeline/Lit")

  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local rs = scene:GetRootGameObjects()
  local pl = nil
  local function find(t, d)
    if d > 14 or pl then return end
    local o = t.gameObject
    if o.name == "Player_1" then pl = o; return end
    for i = 0, t.childCount - 1 do find(t:GetChild(i), d + 1) end
  end
  for i = 0, rs.Length - 1 do local o = rs:get_Item(i); if o then find(o.transform, 0) end; if pl then break end end
  if not pl then r.error="no player" return end

  local pp = pl.transform.position
  r.playerPos = string.format("%.2f,%.2f,%.2f", pp.x, pp.y, pp.z)

  local o = go.CreatePrimitive(prim.Cube)
  o.name = "BESIDE_PLAYER"
  -- 1.5 m to the player's right, at chest height, 2 m cube
  o.transform.position = v3(pp.x + 1.8, pp.y + 1.0, pp.z + 1.0)
  o.transform.localScale = v3(2.0, 2.0, 2.0)
  local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
  if mr and sh then
    local m = CS.UnityEngine.Material(sh)
    m:SetColor("_BaseColor", CS.UnityEngine.Color(1.0, 0.0, 0.0, 1.0))
    mr.material = m
  end
  r.placed = string.format("%.2f,%.2f,%.2f", pp.x+1.8, pp.y+1.0, pp.z+1.0)
  r.scale = "2x2x2"
end)
if not ok then r.error = tostring(err) end
return r
