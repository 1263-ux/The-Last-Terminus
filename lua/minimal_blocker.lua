-- Minimal controlled blocker test.
-- Small probe cube blocked the player earlier; a large wall did not. This script
-- isolates the variable: same position, same size class, one at a time, and it
-- clears prior obstacles so the player cannot start already past them.
local r = {}
local ok, err = pcall(function()
  local go   = CS.UnityEngine.GameObject
  local v3   = CS.UnityEngine.Vector3
  local prim = CS.UnityEngine.PrimitiveType
  local compType = typeof(CS.UnityEngine.Component)

  -- remove every prior probe/C4 object so start state is clean
  local removed = 0
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local roots = scene:GetRootGameObjects()
  local doomed = {}
  local function walk(t, d)
    if d > 10 then return end
    local o = t.gameObject
    local nm = o.name
    if nm:find("^PROBE") or nm:find("^C4_") then table.insert(doomed, o) end
    for i = 0, t.childCount - 1 do walk(t:GetChild(i), d + 1) end
  end
  for i = 0, roots.Length - 1 do
    local o = roots:get_Item(i)
    if o then walk(o.transform, 0) end
  end
  for _, o in ipairs(doomed) do
    pcall(function() CS.UnityEngine.Object.Destroy(o) end)
    removed = removed + 1
  end
  r.removed = removed

  -- Place a single blocker 4 m in front of spawn (z=92.6). Deliberately modest
  -- size (4 x 3 x 1) - comparable to the probe cube that DID block, not the huge
  -- wall that did not.
  local x = 119.741669
  local wall = go.CreatePrimitive(prim.Cube)
  wall.name = "BLOCK_TEST"
  wall.transform.position = v3(x, 81.5, 92.6)
  wall.transform.localScale = v3(4.0, 3.0, 1.0)
  r.placed = "BLOCK_TEST @ (119.74,81.5,92.6) scale 4x3x1"

  local cs = wall:GetComponents(compType)
  local names = {}
  for i = 0, cs.Length - 1 do
    local c = cs:get_Item(i)
    if c then table.insert(names, c:GetType().Name) end
  end
  r.components = table.concat(names, ",")
end)
if not ok then r.error = tostring(err) end
return r
