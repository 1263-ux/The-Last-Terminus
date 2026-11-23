-- Lift the C4 objects 3 m into the air. If they become visible, the problem was
-- never materials or masking - it was that they sat INSIDE the terrain surface
-- (they are 0.1-0.75 m above y=80 while the terrain may be at or above that).
local r = {}
local ok, err = pcall(function()
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local rs = scene:GetRootGameObjects()
  local moved = {}
  local function walk(t, d)
    if d > 12 then return end
    local o = t.gameObject
    local nm = o.name
    if nm:find("^C4_") and nm ~= "C4_STATE" then
      local p = t.position
      t.position = CS.UnityEngine.Vector3(p.x, p.y + 3.0, p.z)
      table.insert(moved, nm)
    end
    for i = 0, t.childCount - 1 do walk(t:GetChild(i), d + 1) end
  end
  for i = 0, rs.Length - 1 do local o = rs:get_Item(i); if o then walk(o.transform, 0) end end
  r.moved = #moved
  r.names = table.concat(moved, ",")
end)
if not ok then r.error = tostring(err) end
return r
