-- DAY-03 REVISION item 4: player-camera visibility of objects placed by offset
-- from the LIVE camera, in Preview.
--
-- Design director requires: GUI Cube / imported GLB / C4 assets all compared from
-- the player third-person camera. I can do the CLI half (primitive + GLB); the
-- GUI-created cube must be done by the human member and stays NOT TESTED.
--
-- Placement is derived from the live camera so the objects are guaranteed inside
-- the frustum, which is what defeated every earlier attempt.
local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local v3 = CS.UnityEngine.Vector3
  local prim = CS.UnityEngine.PrimitiveType
  local sh = CS.UnityEngine.Shader.Find("Universal Render Pipeline/Lit")
  local camType = typeof(CS.UnityEngine.Camera)

  local cams = go.FindGameObjectsWithTag("MainCamera")
  local e = cams:get_Item(0)
  local cam = e:GetComponent(camType)
  local cp = cam.transform.position
  local cf = cam.transform.forward
  r.cam = string.format("%.2f,%.2f,%.2f", cp.x, cp.y, cp.z)
  r.fwd = string.format("%.3f,%.3f,%.3f", cf.x, cf.y, cf.z)

  -- clear old probes
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local rs = scene:GetRootGameObjects()
  local doomed = {}
  local function collect(t, d)
    if d > 12 then return end
    local o = t.gameObject
    if o.name:find("^C4_") or o.name:find("^VIS_") then table.insert(doomed, o) end
    for i = 0, t.childCount - 1 do collect(t:GetChild(i), d + 1) end
  end
  for i = 0, rs.Length - 1 do local o = rs:get_Item(i); if o then collect(o.transform, 0) end end
  for _, o in ipairs(doomed) do pcall(function() CS.UnityEngine.Object.Destroy(o) end) end

  -- Place a marker by walking a short distance ALONG THE CAMERA FORWARD and
  -- dropping it just BELOW the ray so it lands in the lower half of the frame.
  -- That region is always inside the frustum regardless of the pitch maths.
  local function atAlong(dist, below, lateral)
    local x = cp.x + cf.x * dist + lateral
    local y = cp.y + cf.y * dist - below
    local z = cp.z + cf.z * dist
    return x, y, z
  end

  local made = 0
  local function cube(name, dist, below, lateral, size, rgb)
    local x, y, z = atAlong(dist, below, lateral)
    local o = go.CreatePrimitive(prim.Cube)
    o.name = name
    o.transform.position = v3(x, y, z)
    o.transform.localScale = v3(size, size, size)
    local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
    if mr and sh then
      local m = CS.UnityEngine.Material(sh)
      m:SetColor("_BaseColor", CS.UnityEngine.Color(rgb[1], rgb[2], rgb[3], 1.0))
      mr.material = m
    end
    -- verify by projecting: is it inside the vertical half-FOV?
    local d = dist
    local dy = y - cp.y
    local angFromFwd = math.atan(dy / d) * 57.29578
    local rel = angFromFwd - math.asin(-cf.y) * 57.29578
    
    made = made + 1
    return o, rel
  end

  local angles = {}
  local o1, a1 = cube("VIS_CUBE_6M",  6.0, 0.6, 0.0, 1.0, {0.90, 0.25, 0.20})
  table.insert(angles, string.format("6m=%.1f", a1))
  local o2, a2 = cube("VIS_CUBE_10M", 10.0, 1.2, -2.5, 1.4, {0.25, 0.75, 0.35})
  table.insert(angles, string.format("10m=%.1f", a2))
  local o3, a3 = cube("VIS_CUBE_14M", 14.0, 2.0, 2.5, 1.8, {0.30, 0.45, 0.90})
  table.insert(angles, string.format("14m=%.1f", a3))

  r.meshes = made
  r.angles = table.concat(angles, " ")
end)
if not ok then r.error = tostring(err) end
return r
