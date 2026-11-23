-- The camera looks 18 deg DOWN, so following its forward vector goes underground:
-- at 13 m the ray is 3.9 m below the camera, i.e. under the terrain.
--
-- Correct approach: place objects ON THE GROUND (y ~ 80) at various distances,
-- and check they fit the vertical frame. Since the camera is at y=79.59 and looks
-- down, a ground object at distance d appears at angle atan((80-79.59)/d).
-- For small d that angle is large positive (above centre) -> cropped.
-- So the object must be FAR enough that the angle drops inside 22.5 deg:
--   atan(0.41/d) + 18 <= 22.5   =>  atan(0.41/d) <= 4.5  =>  d >= 5.2 m
-- And it must not be so far that the ground horizon swallows it.
--
-- This places ground objects at 6, 10 and 16 m, sized to stay under the ceiling:
--   ceiling topY = 79.59 + d*0.0787
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
  local camY, camZ = cp.y, cp.z
  local k = 0.0787
  r.cam = string.format("%.2f,%.2f,%.2f", cp.x, cp.y, cp.z)

  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local rs = scene:GetRootGameObjects()
  local doomed = {}
  local function collect(t, d)
    if d > 12 then return end
    local o = t.gameObject
    if o.name:find("^VIS_") or o.name:find("^C4_") then table.insert(doomed, o) end
    for i = 0, t.childCount - 1 do collect(t:GetChild(i), d + 1) end
  end
  for i = 0, rs.Length - 1 do local o = rs:get_Item(i); if o then collect(o.transform, 0) end end
  for _, o in ipairs(doomed) do pcall(function() CS.UnityEngine.Object.Destroy(o) end) end

  local G = 79.84   -- ground surface, just above the camera's own y
  local made, info = 0, {}
  local function ground(name, dz, w, frac, depth, rgb)
    local z = camZ + dz
    local topY = camY + dz * k * frac
    if topY < G then topY = G + 0.15 end
    local h = topY - (G - 1.0)
    local o = go.CreatePrimitive(prim.Cube)
    o.name = name
    o.transform.position = v3(cp.x, (G - 1.0) + h/2, z)
    o.transform.localScale = v3(w, h, depth)
    local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
    if mr and sh then
      local m = CS.UnityEngine.Material(sh)
      m:SetColor("_BaseColor", CS.UnityEngine.Color(rgb[1], rgb[2], rgb[3], 1.0))
      mr.material = m
    end
    local ang = math.atan((topY - camY) / dz) * 57.29578 - math.asin(-cf.y) * 57.29578
    table.insert(info, string.format("%s d=%.0f ang=%.1f top=%.2f", name, dz, ang, topY))
    made = made + 1
  end

  ground("VIS_A_6M",  6.0, 1.6, 0.85, 1.2, {0.95,0.25,0.20})
  ground("VIS_B_10M", 10.0, 2.2, 0.85, 1.5, {0.25,0.85,0.35})
  ground("VIS_C_16M", 16.0, 3.0, 0.85, 2.0, {0.30,0.50,0.95})

  r.meshes = made
  r.info = table.concat(info, " ;; ")
end)
if not ok then r.error = tostring(err) end
return r
