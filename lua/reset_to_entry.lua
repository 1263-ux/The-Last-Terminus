-- Put the player back at the entry vantage point so the composition is
-- reproducible, then report what should be visible from there.
local r = {}
local ok, err = pcall(function()
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local function find(n)
    local hit = nil
    local function w(t, d)
      if d > 14 or hit then return end
      local o = t.gameObject
      if o.name == n then hit = o return end
      for i = 0, t.childCount - 1 do w(t:GetChild(i), d + 1) end
    end
    local rs = scene:GetRootGameObjects()
    for i = 0, rs.Length - 1 do
      local o = rs:get_Item(i); if o then w(o.transform, 0) end
      if hit then break end
    end
    return hit
  end
  local pl = find("Player_1")
  if not pl then r.error = "no player" return end
  pl.transform.position = CS.UnityEngine.Vector3(119.741669, 80.0, 88.64061)
  local p = pl.transform.position
  r.playerPos = string.format("%.2f,%.2f,%.2f", p.x, p.y, p.z)
  r.note = "reset to spawn; camera will sit ~3.5 m behind at y~79.6"
end)
if not ok then r.error = tostring(err) end
return r
