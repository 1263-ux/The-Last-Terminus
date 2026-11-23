-- Rebuild STRICTLY inside the measured visible band.
-- Rule: (top_y - 79.587) <= 0.1052 * distance_from_camera
-- Budget by z (camera at z=85.3, y=79.587):
--   z=91.5 dist 6.2 -> top <= 80.24  (height 0.24)
--   z=96.0 dist 10.7 -> top <= 80.71 (height 0.71)
--   z=103  dist 17.7 -> top <= 81.45 (height 1.45)
--   z=109  dist 23.7 -> top <= 82.08 (height 2.08)
local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local v3 = CS.UnityEngine.Vector3
  local prim = CS.UnityEngine.PrimitiveType
  local sh = CS.UnityEngine.Shader.Find("Universal Render Pipeline/Lit")

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

  local G = 79.0   -- sink the base slightly so tops land in budget
  local X = 119.741669
  local made = 0
  local function box(name, x, z, w, topY, depth, rgb)
    local h = topY - G
    local o = go.CreatePrimitive(prim.Cube)
    o.name = name
    o.transform.position = v3(x, G + h/2, z)
    o.transform.localScale = v3(w, h, depth)
    local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
    if mr and sh then
      local m = CS.UnityEngine.Material(sh)
      local c = CS.UnityEngine.Color(rgb[1], rgb[2], rgb[3], 1.0)
      pcall(function() m:SetColor("_BaseColor", c) end)
      mr.material = m
    end
    made = made + 1
    return o
  end

  -- tops strictly at or below the computed ceiling
  box("C4_ERASER", X - 2.5, 91.5, 1.2, 80.20, 0.9,  {0.85,0.55,0.55})
  box("C4_PENCIL", X + 2.5, 91.5, 0.6, 80.20, 2.2,  {0.85,0.72,0.30})
  box("C4_BOOK_L", X - 3.0, 96.0, 4.5, 80.65, 3.5,  {0.45,0.22,0.20})
  box("C4_BOOK_R", X + 3.0, 96.0, 4.5, 80.65, 3.5,  {0.20,0.32,0.38})
  box("C4_GATE",   X,      103.0, 10.0, 81.40, 0.6, {0.78,0.74,0.66})
  box("C4_VILLAGE", X,     109.0, 5.0, 82.00, 3.2,  {0.90,0.85,0.62})

  r.meshes = made
  r.budget = "tops: 80.20@6m / 80.65@11m / 81.40@18m / 82.00@24m"
  r.shader = sh and sh.name or "nil"
end)
if not ok then r.error = tostring(err) end
return r
