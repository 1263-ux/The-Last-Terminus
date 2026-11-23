-- Identify what the walkable ground actually is.
-- Unity Terrain is absent, yet y tracked the ground across 30+ m of walking, so
-- something else provides collision/height. Candidates: a mesh with a collider,
-- a custom heightfield component, or the actor script doing a raycast against a
-- named layer/object.
--
-- Report every object that sits near the player's feet height and its component
-- stack, plus anything whose name suggests terrain/landscape.
local r = {}
local ok, err = pcall(function()
  local compType = typeof(CS.UnityEngine.Component)
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local roots = scene:GetRootGameObjects()

  local groundish = {}
  local scanned = 0

  local function stackOf(o)
    local cs = o:GetComponents(compType)
    local names = {}
    for i = 0, cs.Length - 1 do
      local c = cs:get_Item(i)
      if c then table.insert(names, c:GetType().Name) end
    end
    return table.concat(names, "|")
  end

  local function walk(t, d)
    if d > 12 then return end
    scanned = scanned + 1
    local o = t.gameObject
    local nm = o.name
    local p = t.position
    local st = stackOf(o)
    -- name hints, or something with a Collider sitting low (ground-like)
    local nameHit = nm:find("地形") or nm:find("地面") or nm:find("Terrain")
                 or nm:find("Land") or nm:find("Ground") or nm:find("Map")
                 or nm:find("地图")
    local colliderLow = (st:find("Collider") ~= nil) and (p.y < 82.0) and (p.y > 74.0)
    if nameHit or colliderLow then
      table.insert(groundish, string.format("%s @%.1f,%.1f,%.1f [%s]",
        nm, p.x, p.y, p.z, st))
    end
    for i = 0, t.childCount - 1 do walk(t:GetChild(i), d + 1) end
  end

  for i = 0, roots.Length - 1 do
    local o = roots:get_Item(i)
    if o then walk(o.transform, 0) end
  end

  r.scanned = scanned
  r.count = #groundish
  r.objects = table.concat(groundish, " ;; ")
end)
if not ok then r.error = tostring(err) end
return r
