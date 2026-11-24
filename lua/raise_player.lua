-- Raise the PLAYER rather than fight the geometry. A high vantage looks down and
-- sees the whole circuit, which is the cleanest way to deliver a legible run.
-- This is a staging choice for the demo, not the shipped camera.
local r = {}
local ok, err = pcall(function()
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local function find(n)
    local hit = nil
    local function w(t, d)
      if d > 14 or hit then return end
      local o = t.gameObject
      if o.name == n then hit = o; return end
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
  local p = pl.transform.position
  pl.transform.position = CS.UnityEngine.Vector3(p.x, p.y + 12.0, p.z - 6.0)
  r.from = string.format("%.1f,%.1f,%.1f", p.x, p.y, p.z)
  local q = pl.transform.position
  r.to = string.format("%.1f,%.1f,%.1f", q.x, q.y, q.z)
end)
if not ok then r.error = tostring(err) end
return r
