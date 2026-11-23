-- Use the ONLY shader this build actually resolves: the avatar NPR shader.
-- If objects with this shader become visible, the whole rendering mystery is
-- solved: this build renders only its own shader family, and Standard/URP/Lit
-- materials are silently skipped by the camera while still casting shadows.
local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local v3 = CS.UnityEngine.Vector3
  local prim = CS.UnityEngine.PrimitiveType
  local sh = CS.UnityEngine.Shader.Find("Douyin/AI/Cartoon/AvatarNPR_AIHaiHai")
  if not sh then r.error = "shader nil" return end
  r.shader = sh.name

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
  r.cleared = #doomed

  local made = 0
  local function box(name, x, y, z, sx, sy, sz, rgb)
    local o = go.CreatePrimitive(prim.Cube)
    o.name = name
    o.transform.position = v3(x, y, z)
    o.transform.localScale = v3(sx, sy, sz)
    local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
    if mr then
      local m = CS.UnityEngine.Material(sh)
      local c = CS.UnityEngine.Color(rgb[1], rgb[2], rgb[3], 1.0)
      pcall(function() m:SetColor("_BaseColor", c) end)
      pcall(function() m:SetColor("_Color", c) end)
      pcall(function() m:SetColor("_MainColor", c) end)
      mr.material = m
      made = made + 1
    end
    return o
  end

  local X, G = 119.741669, 80.0
  box("C4_ERASER", X - 2.5, G + 0.6, 91.5, 1.2, 1.2, 0.9, {0.85,0.55,0.55})
  box("C4_PENCIL", X + 2.5, G + 0.6, 91.5, 0.6, 1.2, 2.4, {0.85,0.72,0.30})
  box("C4_BOOK_L", X - 3.0, G + 1.0, 96.0, 4.5, 2.0, 3.5, {0.45,0.22,0.20})
  box("C4_BOOK_R", X + 3.0, G + 1.0, 96.0, 4.5, 2.0, 3.5, {0.20,0.32,0.38})
  box("C4_GATE",   X,       G + 1.5, 103.0, 10.0, 3.0, 0.6, {0.78,0.74,0.66})
  box("C4_VILLAGE", X, G + 1.2, 109.0, 5.0, 2.4, 3.2, {0.90,0.85,0.62})

  r.meshes = made
end)
if not ok then r.error = tostring(err) end
return r
