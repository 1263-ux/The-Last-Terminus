-- CORRECTED budget. The earlier formula was wrong by the camY-80 offset.
-- Truth: visible iff  atan2(topY-camY, z-camZ) + pitchDeg  <=  halfFov
--   camY=79.587 camZ=85.3 pitch=18 halfFov=22.5
--   => topY <= camY + (z-camZ) * tan(22.5-18) = 79.587 + d*0.0787
-- Sanity: the cube BESIDE the player (d=4.3, topY=79.9) sat at +9.1 deg and DID
-- render, confirming the angular test rather than a height test.
--
-- Margin: I aim 20% under the ceiling so the objects sit safely on screen.
local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local v3 = CS.UnityEngine.Vector3
  local prim = CS.UnityEngine.PrimitiveType
  local sh = CS.UnityEngine.Shader.Find("Universal Render Pipeline/Lit")
  local camY, camZ = 79.587, 85.3
  local k = 0.0787   -- tan(4.5 deg)

  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local rs = scene:GetRootGameObjects()
  local doomed = {}
  local function collect(t, d)
    if d > 12 then return end
    local o = t.gameObject
    if o.name:find("^C4_") or o.name:find("^BESIDE") then table.insert(doomed, o) end
    for i = 0, t.childCount - 1 do collect(t:GetChild(i), d + 1) end
  end
  for i = 0, rs.Length - 1 do local o = rs:get_Item(i); if o then collect(o.transform, 0) end end
  for _, o in ipairs(doomed) do pcall(function() CS.UnityEngine.Object.Destroy(o) end) end

  local X = 119.741669
  local G = 78.9   -- base well below the deck so even tall shapes stay in band
  local made = 0
  local report = {}

  local function box(name, x, z, w, topY, depth, rgb)
    local h = topY - G
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
    -- self-check the angle
    local d = z - camZ
    local ang = math.atan((topY - camY) / d) * 57.29578 + 18.0
    table.insert(report, string.format("%s ang=%.1f", name, ang))
    made = made + 1
    return o
  end

  -- ceilings with 20% margin
  box("C4_ERASER",  X - 2.2,  92.0, 1.0, camY + (92.0-camZ)*k*0.8, 0.8, {0.85,0.55,0.55})
  box("C4_PENCIL",  X + 2.2,  92.0, 0.5, camY + (92.0-camZ)*k*0.8, 1.8, {0.85,0.72,0.30})
  box("C4_BOOK_L",  X - 3.0,  97.0, 4.0, camY + (97.0-camZ)*k*0.8, 3.0, {0.45,0.22,0.20})
  box("C4_BOOK_R",  X + 3.0,  97.0, 4.0, camY + (97.0-camZ)*k*0.8, 3.0, {0.20,0.32,0.38})
  box("C4_GATE",    X,       104.0, 9.0, camY + (104.0-camZ)*k*0.8, 0.6, {0.78,0.74,0.66})
  box("C4_VILLAGE", X,       112.0, 4.5, camY + (112.0-camZ)*k*0.8, 2.8, {0.90,0.85,0.62})
  box("C4_EXIT",    X - 3.0, 120.0, 0.3, camY + (120.0-camZ)*k*0.8, 0.3, {0.62,0.64,0.68})

  r.meshes = made
  r.angles = table.concat(report, " ")
  r.rule = "topY <= 79.587 + (z-85.3)*0.0787, then 80% margin"
end)
if not ok then r.error = tostring(err) end
return r
