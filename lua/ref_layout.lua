-- Build a 1:1 PROPORTION REFERENCE from the real kit dimensions, using runtime
-- primitives (which DO render). This does not certify the assets - it verifies the
-- SPATIAL relationships the assets will need to satisfy, so that when the loader
-- is fixed I know the layout works.
--
-- Real dimensions from the GLB containers and ASSET-IMPORT-MANIFEST:
--   ruler-bridge : 8.00 x 1.08 x 1.25   (long axis X in source, 8 m)
--   town-row     : 24.13 x 5.00 x 3.59
--   shopfront    : 5.43 x 2.60 x 2.13
--   desk-lamp    : 2.06 x 3.35 x 1.50
--   cup-harbor   : 9.17 x 3.85 x 4.64
--   ground-paper : 12.00 x 0.06 x 8.00
--
-- Player is 0.90 m tall (capsule h=0.90, r=0.16 measured earlier), so an 8 m ruler
-- is ~8.9x the player and a 24 m town row is ~27x. Those are the ratios that make
-- the micro-scale read work.
local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local v3 = CS.UnityEngine.Vector3
  local prim = CS.UnityEngine.PrimitiveType
  local sh = CS.UnityEngine.Shader.Find("Universal Render Pipeline/Lit")
  local camType = typeof(CS.UnityEngine.Camera)
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()

  -- clear old probes
  local rs = scene:GetRootGameObjects()
  local doomed = {}
  local function collect(t, d)
    if d > 12 then return end
    local o = t.gameObject
    if o.name:find("^REF_") or o.name:find("^C4_") or o.name:find("^VIS_") then
      table.insert(doomed, o)
    end
    for i = 0, t.childCount - 1 do collect(t:GetChild(i), d + 1) end
  end
  for i = 0, rs.Length - 1 do local o = rs:get_Item(i); if o then collect(o.transform, 0) end end
  for _, o in ipairs(doomed) do pcall(function() CS.UnityEngine.Object.Destroy(o) end) end

  local cams = go.FindGameObjectsWithTag("MainCamera")
  local cam = cams:get_Item(0):GetComponent(camType)
  local cp = cam.transform.position
  local camX, camY, camZ = cp.x, cp.y, cp.z
  r.cam = string.format("%.2f,%.2f,%.2f", camX, camY, camZ)

  local G = camY + 0.20
  local k = 0.0787
  local made, info = 0, {}

  -- box(name, xoff, dz, sizeX, sizeY, sizeZ, rgb)
  -- height is clamped to the visibility budget so it actually appears on screen
  local function box(name, xoff, dz, sx, sy, sz, rgb)
    if dz < 5.6 then dz = 5.6 end
    local z = camZ + dz
    local topY = camY + dz * k * 0.85
    local baseY = G - 1.0
    local h = topY - baseY
    if h < 0.2 then h = 0.2 end
    local o = go.CreatePrimitive(prim.Cube)
    o.name = name
    o.transform.position = v3(camX + xoff, baseY + h/2, z)
    -- keep the plan footprint truthful, only the height is budget-clamped
    o.transform.localScale = v3(sx, h, sz)
    local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
    if mr and sh then
      local m = CS.UnityEngine.Material(sh)
      m:SetColor("_BaseColor", CS.UnityEngine.Color(rgb[1], rgb[2], rgb[3], 1.0))
      mr.material = m
    end
    made = made + 1
    table.insert(info, string.format("%s %.1fx%.1f dz=%.0f", name, sx, sz, dz))
    return o
  end

  -- RULER BRIDGE: 8.0 long. Placed ACROSS the walking axis so it reads as a span.
  -- Long axis becomes Z (8 m deep) at 4.6 m wide-ish footprint; height clamped.
  box("REF_RULER_SPAN", 0, 9.0, 2.6, 1, 8.0, {0.86, 0.70, 0.44})
  -- Resting ruler beside the path, same 8 m length, laid along Z
  box("REF_RULER_REST", -7.0, 9.0, 1.4, 1, 8.0, {0.78, 0.62, 0.40})

  -- TOWN ROW: 24.13 long. Spans the far side; X is its long axis.
  box("REF_TOWN_ROW", 0, 18.0, 24.13, 1, 3.6, {0.55, 0.56, 0.52})
  -- SHOPFRONT as a splittable single module, 5.43 x 2.13
  box("REF_SHOPFRONT", -10.0, 14.0, 5.43, 1, 2.13, {0.62, 0.58, 0.44})

  -- DESK LAMP 2.06 x 1.50 footprint, tall landmark
  box("REF_LAMP", 13.0, 20.0, 2.06, 1, 1.50, {0.80, 0.66, 0.42})
  -- CUP HARBOR 9.17 x 4.64 far landmark
  box("REF_HARBOR", -16.0, 24.0, 9.17, 1, 4.64, {0.88, 0.86, 0.80})

  r.meshes = made
  r.layout = table.concat(info, " | ")
  r.note = "plan footprints are true to the manifest; heights clamped to the camera budget"
end)
if not ok then r.error = tostring(err) end
return r
