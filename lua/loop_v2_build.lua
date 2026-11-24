-- PLAYABLE LOOP v2: physical gate, now that colliders are proven to work.
-- State 0: ruler at rest, solid wall blocks the path, town windows dark.
-- Activate: wall removed, ramp shown, rest hidden (a real state change).
-- State 1: player walks through, reaches town, windows light.
-- All primitives are runtime-created: proves the MECHANIC, not the kit assets.
local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local v3 = CS.UnityEngine.Vector3
  local prim = CS.UnityEngine.PrimitiveType
  local sh = CS.UnityEngine.Shader.Find("Universal Render Pipeline/Lit")
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()

  local function find(n)
    local hit = nil
    local function w(t, d)
      if d > 12 or hit then return end
      local o = t.gameObject
      if o.name == n then hit = o; return end
      for i = 0, t.childCount - 1 do w(t:GetChild(i), d + 1) end
    end
    local rs = scene:GetRootGameObjects()
    for i = 0, rs.Length - 1 do
      local o = rs:get_Item(i); if o then w(o.transform, 0) end
      if hit then break end
    end
    return hit
  end

  local pl = find("Player_1")
  if not pl then r.error = "no player" return end
  local p = pl.transform.position
  local X, Y, Z = p.x, p.y, p.z
  r.spawn = string.format("%.2f,%.2f,%.2f", X, Y, Z)

  local rs = scene:GetRootGameObjects()
  local doomed = {}
  local function col(t, d)
    if d > 12 then return end
    local nm = t.gameObject.name
    if nm:find("^LOOP_") or nm:find("^GEO_") or nm:find("^STEP_") or nm:find("^PAPER_") then
      table.insert(doomed, t.gameObject)
    end
    for i = 0, t.childCount - 1 do col(t:GetChild(i), d + 1) end
  end
  for i = 0, rs.Length - 1 do local o = rs:get_Item(i); if o then col(o.transform, 0) end end
  for _, o in ipairs(doomed) do pcall(function() CS.UnityEngine.Object.Destroy(o) end) end
  r.cleared = #doomed

  local function box(name, dx, dz, sx, sy, sz, dy, rgb)
    local o = go.CreatePrimitive(prim.Cube)
    o.name = name
    o.transform.position = v3(X + dx, Y + dy, Z + dz)
    o.transform.localScale = v3(sx, sy, sz)
    local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
    if mr and sh then
      local m = CS.UnityEngine.Material(sh)
      m:SetColor("_BaseColor", CS.UnityEngine.Color(rgb[1], rgb[2], rgb[3], 1))
      mr.material = m
    end
    return o
  end

  -- two pages with a shallow fold between them, all walkable
  box("LOOP_PAGE_L", -4.0, 5.0, 8.0, 0.10, 14.0, -0.05, {0.93,0.90,0.81})
  box("LOOP_PAGE_R",  4.0, 5.0, 8.0, 0.10, 14.0, -0.05, {0.91,0.88,0.78})
  box("LOOP_FOLD",    0.0, 5.0, 1.2, 0.04, 14.0, -0.16, {0.28,0.24,0.20})

  -- resting ruler, the affordance
  box("LOOP_RULER_REST", -5.5, 2.0, 0.9, 0.10, 6.5, 0.02, {0.84,0.68,0.44})

  -- ramp, hidden until solved
  local ramp = box("LOOP_RULER_RAMP", 0.0, 5.0, 1.8, 0.12, 8.0, 0.01, {0.84,0.68,0.44})
  ramp:SetActive(false)
  for k = 0, 5 do
    local t = box("LOOP_TICK_" .. k, 0.0, 2.0 + k * 1.1, 1.8, 0.03, 0.12, 0.09, {0.26,0.20,0.14})
    t:SetActive(false)
  end

  -- the real physical gate: removed on activation
  local gate = box("LOOP_GATE", 0.0, 3.0, 8.0, 0.80, 0.4, 0.40, {0.82,0.30,0.24})
  gate:SetActive(true)
  r.gateZ = string.format("%.2f", Z + 3.0)

  -- town with dark windows
  box("LOOP_TOWN", 0.0, 14.0, 10.0, 1.6, 3.0, 0.80, {0.22,0.34,0.40})
  box("LOOP_ROOF", 0.0, 14.0, 10.4, 0.25, 3.4, 1.70, {0.62,0.24,0.22})
  for k = 0, 3 do
    local wnd = box("LOOP_WIN_" .. k, -3.0 + k * 2.0, 12.4, 0.8, 0.7, 0.1, 0.75, {0.30,0.42,0.36})
    wnd:SetActive(false)
  end

  r.built = "loop v2 with physical gate"
end)
if not ok then r.error = tostring(err) end
return r
