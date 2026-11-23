-- Add the two missing design pieces with existing mechanisms only:
--   1) OBSERVE GUIDANCE: the resting ruler reads as a "long flat thing that could
--      span the gap" - laid diagonally pointing AT the gate, with tick marks.
--   2) ARRIVAL FEEDBACK: the village lights up after the crossing.
--
-- Also adds a proper "blocked" presentation placeholder: a translucent band at
-- the gate line so being returned reads as passing a threshold rather than a
-- teleport with no cause. Colour only - no new capability.
local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local v3 = CS.UnityEngine.Vector3
  local prim = CS.UnityEngine.PrimitiveType
  local sh = CS.UnityEngine.Shader.Find("Universal Render Pipeline/Lit")
  local camY, camZ = 79.587, 85.3
  local k = 0.0787
  local X, G = 119.741669, 78.9

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

  local made = 0
  local function box(name, x, z, w, frac, depth, rgb)
    local topY = camY + (z - camZ) * k * frac
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

  -- canyon books
  box("C4_BOOK_L", X - 3.2, 97.0, 4.2, 0.80, 3.2, {0.45,0.22,0.20})
  box("C4_BOOK_R", X + 3.2, 97.0, 4.2, 0.72, 3.2, {0.20,0.32,0.38})

  -- THE GATE, with a visible threshold band on it
  box("C4_GATE", X, 104.0, 9.0, 0.80, 0.6, {0.78,0.74,0.66})
  -- threshold hint: a slightly different coloured strip at the base
  box("C4_GATE_LINE", X, 104.0, 9.2, 0.30, 0.45, {0.42,0.38,0.30})

  -- 1) GUIDANCE: ruler at rest, laid DIAGONALLY pointing at the gate, with
  -- tick-mark ribs so it reads as a ruler rather than a plank.
  box("C4_RULER_REST", X - 4.6, 99.5, 1.1, 0.62, 5.2, {0.80,0.64,0.42})
  for i = 1, 4 do
    box("C4_RULER_TICK_" .. i, X - 4.6 + i * 0.16, 99.5 - 1.6 + i * 0.8,
        0.28, 0.66, 0.22, {0.30,0.24,0.14})
  end

  -- 2) ARRIVAL FEEDBACK target: village starts dark, lights after crossing
  local v = box("C4_VILLAGE", X, 112.0, 4.5, 0.80, 2.8, {0.55,0.52,0.40})
  -- lamps that switch on
  for i = 1, 3 do
    local l = box("C4_VILLAGE_LAMP_" .. i, X - 1.6 + (i-1) * 1.6, 112.6,
                  0.35, 0.55, 0.35, {0.30,0.28,0.22})
    l:SetActive(false)
  end

  box("C4_EXIT", X - 3.0, 120.0, 0.3, 0.75, 0.3, {0.62,0.64,0.68})

  -- ramp steps, hidden until solved
  for i = 1, 4 do
    local z = 100.5 + i * 0.9
    local s = box("C4_RAMP_" .. i, X, z, 2.0, 0.80, 0.9, {0.85,0.72,0.42})
    s:SetActive(false)
  end

  r.meshes = made
  r.added = "ruler ticks, gate threshold line, 3 village lamps (off)"
end)
if not ok then r.error = tostring(err) end
return r
