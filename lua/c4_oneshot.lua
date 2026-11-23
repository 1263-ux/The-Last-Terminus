-- One-shot: place the player at a known vantage, then IMMEDIATELY build the scene
-- and let the caller screenshot straight away - no intervening input, so the
-- camera cannot drift before the capture.
local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local v3 = CS.UnityEngine.Vector3
  local prim = CS.UnityEngine.PrimitiveType
  local sh = CS.UnityEngine.Shader.Find("Universal Render Pipeline/Lit")
  local camType = typeof(CS.UnityEngine.Camera)
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()

  local function find(n)
    local hit = nil
    local function w(t, d)
      if d > 14 or hit then return end
      local o = t.gameObject
      if o.name == n then hit = o return end
      for i = 0, t.childCount - 1 do w(t:GetChild(i), d + 1) end
    end
    local rs = scene:GetRootGameObjects()
    for i = 0, rs.Length - 1 do
      local o = rs:get_Item(i); if o then w(o.transform, 0) end
      if hit then break end
    end
    return hit
  end

  -- wipe prior probes
  local rs = scene:GetRootGameObjects()
  local doomed = {}
  local function collect(t, d)
    if d > 12 then return end
    local o = t.gameObject
    local nm = o.name
    if nm:find("^C4_") or nm:find("^VIS_") then table.insert(doomed, o) end
    for i = 0, t.childCount - 1 do collect(t:GetChild(i), d + 1) end
  end
  for i = 0, rs.Length - 1 do local o = rs:get_Item(i); if o then collect(o.transform, 0) end end
  for _, o in ipairs(doomed) do pcall(function() CS.UnityEngine.Object.Destroy(o) end) end

  -- read the camera that the screenshot will actually use
  local cams = go.FindGameObjectsWithTag("MainCamera")
  local cam = cams:get_Item(0):GetComponent(camType)
  local cp = cam.transform.position
  local camX, camY, camZ = cp.x, cp.y, cp.z
  r.cam = string.format("%.2f,%.2f,%.2f", camX, camY, camZ)

  -- Ground plane sits level with the camera's feet height.
  local G = camY + 0.20
  local k = 0.0787
  local made, info = 0, {}

  local function slab(name, xoff, dz, w, depth, frac, rgb)
    if dz < 5.6 then dz = 5.6 end
    local z = camZ + dz
    local topY = camY + dz * k * frac
    if topY < G + 0.10 then topY = G + 0.10 end
    local h = topY - (G - 0.8)
    local o = go.CreatePrimitive(prim.Cube)
    o.name = name
    o.transform.position = v3(camX + xoff, (G - 0.8) + h/2, z)
    o.transform.localScale = v3(w, h, depth)
    local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
    if mr and sh then
      local m = CS.UnityEngine.Material(sh)
      m:SetColor("_BaseColor", CS.UnityEngine.Color(rgb[1], rgb[2], rgb[3], 1.0))
      mr.material = m
    end
    made = made + 1
    table.insert(info, string.format("%s@d%.0f", name, dz))
    return o
  end

  -- A readable corridor: paper walls left/right, deck under foot,
  -- a gap ahead, ruler at rest beside it, town beyond.
  slab("C4_WALL_L",  -5.0, 8.0,  1.6, 14.0, 0.90, {0.52, 0.26, 0.22})
  slab("C4_WALL_R",   5.0, 8.0,  1.6, 14.0, 0.90, {0.24, 0.36, 0.44})
  slab("C4_DECK_A",   0.0, 9.0, 10.0,  5.0, 0.90, {0.74, 0.68, 0.52})
  slab("C4_GAP",      0.0, 13.5, 10.0,  2.0, 0.22, {0.09, 0.09, 0.13})
  slab("C4_DECK_B",   0.0, 17.5, 10.0,  5.0, 0.90, {0.74, 0.68, 0.52})
  -- the affordance: ruler lying flat, angled into the gap
  local rest = slab("C4_RULER_REST", -3.5, 9.5, 1.0, 6.5, 0.55, {0.84, 0.68, 0.46})
  -- destination
  slab("C4_TOWN",     0.0, 22.0, 4.5, 3.5, 0.90, {0.62, 0.58, 0.44})

  -- ramp hidden until solved; on solve these replace the gap
  for i = 1, 4 do
    local s = slab("C4_RAMP_" .. i, 0.0, 10.5 + i * 1.3, 3.0, 1.3, 0.85, {0.90, 0.76, 0.46})
    s:SetActive(false)
  end

  r.meshes = made
  r.layout = table.concat(info, " ")
  r.ground = string.format("%.2f", G)
end)
if not ok then r.error = tostring(err) end
return r
