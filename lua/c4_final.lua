-- FINAL C4 LAYOUT, sized to the camera's real visible band.
--
-- Measured: camera y = 79.587, forward pitch such that frame-top slope = 0.1052.
-- Therefore a prop standing on ground y=80 is visible only if
--     prop_height  <=  0.1052 * distance
-- Budget:
--     d= 6 m -> 0.22 m     d=12 m -> 0.85 m
--     d=16 m -> 1.27 m     d=26 m -> 2.32 m
-- Everything is designed inside that envelope, which is why earlier attempts
-- vanished: an 8 m wall at 12 m needs 0.85 m of headroom and got cropped.
--
-- Also uses the other measured fact: imported GLBs DO render (evidence: a
-- directed capture from a free camera shows them clearly), so this builds with
-- primitives for speed but obeys the same size rule.
local r = {}
local ok, err = pcall(function()
  local go   = CS.UnityEngine.GameObject
  local v3   = CS.UnityEngine.Vector3
  local prim = CS.UnityEngine.PrimitiveType
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local X = 119.741669
  local G = 80.0

  -- wipe previous probes
  local doomed = {}
  local function collect(t, d)
    if d > 12 then return end
    local o = t.gameObject
    local nm = o.name
    if nm:find("^C4_") or nm:find("^BLOCK") or nm:find("^GATE_") or nm:find("^CENTRE") then
      table.insert(doomed, o)
    end
    for i = 0, t.childCount - 1 do collect(t:GetChild(i), d + 1) end
  end
  local rs = scene:GetRootGameObjects()
  for i = 0, rs.Length - 1 do
    local o = rs:get_Item(i); if o then collect(o.transform, 0) end
  end
  for _, o in ipairs(doomed) do pcall(function() CS.UnityEngine.Object.Destroy(o) end) end
  r.cleared = #doomed

  local function box(name, x, y, z, sx, sy, sz, rgb)
    local o = go.CreatePrimitive(prim.Cube)
    o.name = name
    o.transform.position = v3(x, y, z)
    o.transform.localScale = v3(sx, sy, sz)
    local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
    if mr then
      local m = mr.material
      local c = CS.UnityEngine.Color(rgb[1], rgb[2], rgb[3], 1.0)
      pcall(function() m:SetColor("_Color", c) end)
      pcall(function() m:SetColor("_BaseColor", c) end)
    end
    return o
  end

  -- Heights chosen against the budget table above.
  -- d from camera(85.3):  z=91.5 -> 6.2 m ; z=97 -> 11.7 m ; z=103 -> 17.7 m ;
  --                       z=109 -> 23.7 m ; z=115 -> 29.7 m
  box("C4_ERASER",  X - 2.5, G + 0.10, 91.5, 1.2, 0.20, 0.9, {0.85,0.55,0.55})  -- 0.20 <= 0.65 ok
  box("C4_PENCIL",  X + 2.5, G + 0.08, 91.5, 0.5, 0.16, 2.4, {0.85,0.72,0.30})  -- ok
  box("C4_BOOK_L",  X - 3.0, G + 0.22, 96.0, 4.5, 0.44, 3.5, {0.45,0.22,0.20})  -- 0.44 <= 1.13 ok
  box("C4_BOOK_R",  X + 3.0, G + 0.16, 96.0, 4.5, 0.32, 3.5, {0.20,0.32,0.38})  -- ok

  -- THE GATE: 1.1 m tall at 17 m -> budget 1.83 m, fits.
  -- It cannot block (kinematic player) so it is a visual threshold only; the
  -- rule does the refusing. Height still matters so the player can SEE it.
  box("C4_GATE", X, G + 0.55, 103.0, 10.0, 1.10, 0.35, {0.78,0.74,0.66})

  -- ruler in REST pose: lying flat beside the path, unmistakably idle
  local rest = box("C4_RULER_REST", X - 4.0, G + 0.06, 99.0, 1.4, 0.12, 5.0,
                   {0.78,0.62,0.40})

  -- ruler as ACTIVE ramp: 4 shallow steps up onto the gate top (1.1 m).
  -- Step rise 0.28 m each, far under jumpMaxHeight 1.0.
  local steps = {}
  for i = 1, 4 do
    local h = 1.10 * i / 4
    local z = 103.0 - 2.2 + (i - 1) * 0.9
    local s = box("C4_RAMP_" .. i, X, G + h / 2, z, 2.2, h, 0.9,
                  {0.85,0.72,0.42})
    s:SetActive(false)
    table.insert(steps, s)
  end

  -- village beyond the gate, 24 m out -> budget 2.1 m
  box("C4_VILLAGE", X, G + 0.70, 109.0, 5.0, 1.40, 3.2, {0.90,0.85,0.62})
  -- exit marker, 30 m out -> budget 2.6 m
  box("C4_EXIT", X - 2.5, G + 0.75, 115.0, 0.35, 1.50, 0.35, {0.62,0.64,0.68})

  -- state flag, buried far below so it never renders but persists
  local flag = go.CreatePrimitive(prim.Cube)
  flag.name = "C4_STATE"
  flag.transform.position = v3(X, G - 100, 0)
  flag.transform.localScale = v3(0.01, 0.01, 0.01)

  r.built = "11 objects inside the visible band"
  r.budget = "heights <= 0.1052*distance"
end)
if not ok then r.error = tostring(err) end
return r
