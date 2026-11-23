-- Clean rebuild: remove stray test cubes, rebuild C4 with the corrected angular
-- budget, and report the composition so the screenshot is reproducible.
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
    local nm = o.name
    if nm:find("^C4_") or nm:find("^BESIDE") or nm:find("^CENTRE") or nm:find("^BLOCK") then
      table.insert(doomed, o)
    end
    for i = 0, t.childCount - 1 do collect(t:GetChild(i), d + 1) end
  end
  for i = 0, rs.Length - 1 do local o = rs:get_Item(i); if o then collect(o.transform, 0) end end
  for _, o in ipairs(doomed) do pcall(function() CS.UnityEngine.Object.Destroy(o) end) end
  r.cleared = #doomed

  local camY, camZ = 79.587, 85.3
  local k = 0.0787
  local X = 119.741669
  local G = 78.9
  local made = 0

  local function box(name, x, z, w, topFrac, depth, rgb)
    local topY = camY + (z - camZ) * k * topFrac
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
    made = made + 1
    return o
  end

  -- books flank the corridor
  box("C4_BOOK_L", X - 3.2, 97.0, 4.2, 0.80, 3.2, {0.45,0.22,0.20})
  box("C4_BOOK_R", X + 3.2, 97.0, 4.2, 0.72, 3.2, {0.20,0.32,0.38})
  -- the gate the player must get past
  box("C4_GATE",   X,      104.0, 9.0, 0.80, 0.6, {0.78,0.74,0.66})
  -- ruler at rest: lying flat, off to the left, the clue
  local rest = box("C4_RULER_REST", X - 5.0, 99.0, 1.3, 0.55, 4.5, {0.78,0.62,0.40})
  -- village beyond, the goal
  box("C4_VILLAGE", X, 112.0, 4.5, 0.80, 2.8, {0.90,0.85,0.62})
  box("C4_EXIT", X - 3.0, 120.0, 0.3, 0.75, 0.3, {0.62,0.64,0.68})

  -- ruler as ramp: activated state, hidden for now
  for i = 1, 4 do
    local z = 100.5 + i * 0.9
    local s = box("C4_RAMP_" .. i, X, z, 2.0, 0.80, 0.9, {0.85,0.72,0.42})
    s:SetActive(false)
  end

  r.meshes = made
  r.note = "books flank, gate ahead, ruler flat-left, village beyond"
end)
if not ok then r.error = tostring(err) end
return r
