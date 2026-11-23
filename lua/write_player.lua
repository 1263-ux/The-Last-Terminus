-- Can we WRITE the player position? If yes, an out-of-bounds teleport-back is
-- implementable without collision, which is the last viable route to a real
-- pass/fail in the C4 loop.
local r = {}
local ok, err = pcall(function()
  local compType = typeof(CS.UnityEngine.Component)
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local roots = scene:GetRootGameObjects()
  local player = nil
  local function walk(t, d)
    if d > 12 or player then return end
    local o = t.gameObject
    if o.name == "Player_1" then player = o; return end
    for i = 0, t.childCount - 1 do walk(t:GetChild(i), d + 1) end
  end
  for i = 0, roots.Length - 1 do
    local o = roots:get_Item(i); if o then walk(o.transform, 0) end
    if player then break end
  end
  if not player then r.player = "not found" return end

  local before = player.transform.position
  r.before = string.format("%.2f,%.2f,%.2f", before.x, before.y, before.z)

  -- attempt a direct write to a point 5 m back toward spawn
  local okw, werr = pcall(function()
    local v3 = CS.UnityEngine.Vector3
    player.transform.position = v3(119.741669, 80.0, 92.0)
  end)
  r.writeOk = tostring(okw)
  if not okw then r.writeErr = tostring(werr) end

  local after = player.transform.position
  r.afterImmediate = string.format("%.2f,%.2f,%.2f", after.x, after.y, after.z)
  r.moved = tostring(math.abs(after.z - before.z) > 0.5)
end)
if not ok then r.error = tostring(err) end
return r
