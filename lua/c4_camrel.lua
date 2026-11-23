-- Build the composition around the CAMERA's CURRENT position, not an assumed
-- spawn. The controller keeps moving the player, so anchoring to the real camera
-- is the only way the screenshot is reproducible.
--
-- Camera measured at (119.757, 79.554, 104.369), forward (0.001, -0.309, 0.951).
-- Visible band (vertical, the tight axis): topY <= camY + (z-camZ)*0.0787
-- Lateral budget at FOV45 / 16:9 is far wider, so x offsets up to ~0.7*d are fine.
local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local v3 = CS.UnityEngine.Vector3
  local prim = CS.UnityEngine.PrimitiveType
  local sh = CS.UnityEngine.Shader.Find("Universal Render Pipeline/Lit")
  local camType = typeof(CS.UnityEngine.Camera)

  -- read the live camera rather than assume
  local cams = go.FindGameObjectsWithTag("MainCamera")
  local e = cams:get_Item(0)
  local cam = e:GetComponent(camType)
  local cp = cam.transform.position
  local camY, camZ, camX = cp.y, cp.z, cp.x
  r.cam = string.format("%.2f,%.2f,%.2f", camX, camY, camZ)
  local k = 0.0787

  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local rs = scene:GetRootGameObjects()
  local doomed = {}
  local function collect(t, d)
    if d > 12 then return end
    local o = t.gameObject
    if o.name:find("^C4_") then table.insert(doomed, o) end
    for i = 0, t.childCount - 1 do collect(t:GetChild(i), d + 1) end
  end
  for i = 0, rs.Length - 1 do local o = rs:get_Item(i); if o then collect(o.transform, 0) end end
  for _, o in ipairs(doomed) do pcall(function() CS.UnityEngine.Object.Destroy(o) end) end

  local G = 78.9
  local made = 0
  local angles = {}
  local function box(name, xoff, dz, w, frac, depth, rgb)
    local z = camZ + dz
    local topY = camY + dz * k * frac
    local h = topY - G
    local x = camX + xoff
    local o = go.CreatePrimitive(prim.Cube)
    o.name = name
    o.transform.position = v3(x, G + h/2, z)
    o.transform.localScale = v3(w, h, depth)
    local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
    if mr and sh then
      local m = CS.UnityEngine.Material(sh)
      m:SetColor("_BaseColor", CS.UnityEngine.Color(rgb[1], rgb[2], rgb[3], 1.0))
      mr.material = m
    end
    local ang = math.atan((topY - camY) / dz) * 57.29578 + 18.0
    table.insert(angles, string.format("%s=%.0f", name, ang))
    made = made + 1
    return o
  end

  -- everything laid out AHEAD of the live camera
  box("C4_BOOK_L", -3.5,  8.0, 4.0, 0.45, 3.0, {0.45,0.22,0.20})
  box("C4_BOOK_R",  3.5,  8.0, 4.0, 0.40, 3.0, {0.20,0.32,0.38})
  box("C4_RULER_REST", -5.0, 5.0, 1.2, 0.30, 4.0, {0.80,0.64,0.42})
  box("C4_GATE", 0, 14.0, 9.0, 0.45, 0.6, {0.78,0.74,0.66})
  box("C4_VILLAGE", 0, 20.0, 4.5, 0.45, 2.8, {0.88,0.82,0.55})

  -- ramp hidden until solved
  for i = 1, 4 do
    local s = box("C4_RAMP_" .. i, 0, 10.5 + i * 0.8, 2.0, 0.45, 0.8, {0.85,0.72,0.42})
    s:SetActive(false)
  end

  r.meshes = made
  r.angles = table.concat(angles, " ")
end)
if not ok then r.error = tostring(err) end
return r
