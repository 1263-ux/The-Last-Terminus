-- THE decisive test: can TERRAIN block the player?
--
-- Everything else is ruled out (size, layer, GLB vs native, collider presence).
-- The player is a kinematic NetworkActor body with velocity 0, so mesh colliders
-- never enter the solver. The one system that still works is the engine terrain
-- (we saw y track terrain height across 30+ m of walking).
--
-- So: raise the terrain itself under a patch of ground ahead of the player and
-- see whether walking into that patch is refused. If terrain blocks, C4 is
-- viable and must be built with the terrain brush, not with objects.
--
-- Terrain access differs per engine build, so this probes several APIs and
-- reports which one exists rather than assuming one.
local r = {}
local ok, err = pcall(function()
  local function has(label, fn)
    local o, v = pcall(fn)
    r[label] = o and tostring(v) or ("ERR:" .. tostring(v))
  end

  -- What terrain-ish types exist?
  has("Terrain", function() return CS.UnityEngine.Terrain end)
  has("TerrainData", function() return CS.UnityEngine.TerrainData end)

  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local roots = scene:GetRootGameObjects()

  -- find an active Terrain component anywhere in the hierarchy
  local terr = nil
  local terrObjName = nil
  local function walk(t, d)
    if d > 12 or terr then return end
    local o = t.gameObject
    local okt, tc = pcall(function()
      return o:GetComponent(typeof(CS.UnityEngine.Terrain))
    end)
    if okt and tc then terr = tc; terrObjName = o.name; return end
    for i = 0, t.childCount - 1 do walk(t:GetChild(i), d + 1) end
  end
  for i = 0, roots.Length - 1 do
    local o = roots:get_Item(i)
    if o then walk(o.transform, 0) end
    if terr then break end
  end

  if not terr then
    r.terrain = "NO Terrain component found in runtime hierarchy"
    r.note = "terrain may be a non-Unity-Terrain mesh in this build"
    return
  end

  r.terrainObject = terrObjName
  local td = terr.terrainData
  r.terrainSize = string.format("%.1f x %.1f x %.1f", td.size.x, td.size.y, td.size.z)
  r.heightmapResolution = tostring(td.heightmapResolution)

  local pos = terr.transform.position
  r.terrainPos = string.format("%.2f,%.2f,%.2f", pos.x, pos.y, pos.z)

  -- Convert a world point (just ahead of the player) to heightmap coords and
  -- raise it, giving a small plateau the player would have to climb.
  local wx, wz = 119.741669, 96.0
  local res = td.heightmapResolution
  local hx = (wx - pos.x) / td.size.x
  local hz = (wz - pos.z) / td.size.z
  r.converted = string.format("world(%.1f,%.1f) -> normalized(%.3f,%.3f)", wx, wz, hx, hz)

  if hx >= 0 and hx <= 1 and hz >= 0 and hz <= 1 then
    local cx = math.floor(hx * (res - 1))
    local cz = math.floor(hz * (res - 1))
    local heights = td:GetHeights(cx, cz, 4, 4)
    r.heightsShape = string.format("%d,%d", heights:GetLength(0), heights:GetLength(1))
    r.beforeH = tostring(heights[0][0])

    -- raise 4x4 samples by ~3 m in normalized height units
    local raise = 3.0 / td.size.y
    for a = 0, heights:GetLength(0) - 1 do
      for b = 0, heights:GetLength(1) - 1 do
        heights[a][b] = heights[a][b] + raise
      end
    end
    td:SetHeights(cx, cz, heights)
    r.raiseNorm = tostring(raise)
    r.afterH = tostring(td:GetHeights(cx, cz, 1, 1)[0][0])
    r.mutation = "APPLIED"
  else
    r.mutation = "SKIPPED - world point outside terrain bounds"
  end
end)
if not ok then r.error = tostring(err) end
return r
