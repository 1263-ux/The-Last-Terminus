-- Find the PLAYER object and report everything about how it moves.
--
-- Unifying hypothesis: every collision test failed the same way (player walks
-- through a BoxCollider, y stays at 79.59-79.99 forever, never falls into the
-- chasm). That is the signature of a TERRAIN-LOCKED controller, not a physics
-- body: it samples terrain height and ignores mesh colliders entirely.
--
-- If true, the design consequence is large: no imported or native mesh can ever
-- block the player, so blocking must be done by terrain, not by objects.
local r = {}
local ok, err = pcall(function()
  local compType = typeof(CS.UnityEngine.Component)
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local roots = scene:GetRootGameObjects()

  local candidates = {}
  local scanned = 0

  local function stackOf(o)
    local cs = o:GetComponents(compType)
    local names = {}
    for i = 0, cs.Length - 1 do
      local c = cs:get_Item(i)
      if c then table.insert(names, c:GetType().Name) end
    end
    return names
  end

  local function walk(t, d)
    if d > 12 then return end
    scanned = scanned + 1
    local o = t.gameObject
    local names = stackOf(o)
    local joined = table.concat(names, "|")
    -- anything that looks like it controls movement
    if joined:find("CharacterController") or joined:find("Rigidbody")
       or joined:find("NavMesh") or joined:find("Movement")
       or joined:find("Motor") or joined:find("PlayerController")
       or joined:find("ActorController") then
      local p = t.position
      table.insert(candidates, string.format("%s [%s] pos=%.2f,%.2f,%.2f",
        o.name, joined, p.x, p.y, p.z))
    end
    for i = 0, t.childCount - 1 do walk(t:GetChild(i), d + 1) end
  end

  for i = 0, roots.Length - 1 do
    local o = roots:get_Item(i)
    if o then walk(o.transform, 0) end
  end

  r.scanned = scanned
  r.found = #candidates
  r.candidates = table.concat(candidates, " ;; ")
end)
if not ok then r.error = tostring(err) end
return r
