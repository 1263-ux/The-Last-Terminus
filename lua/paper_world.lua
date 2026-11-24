-- Full walk-on-paper composition: sheet, page fold, ruler bridge, town at the edge.
-- Everything stays at or near ground level so the 4.5-degree headroom is irrelevant.
local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local v3 = CS.UnityEngine.Vector3
  local prim = CS.UnityEngine.PrimitiveType
  local sh = CS.UnityEngine.Shader.Find("Universal Render Pipeline/Lit")
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()

  local function find(n)
    local hit=nil
    local function w(t,d) if d>12 or hit then return end local o=t.gameObject
      if o.name==n then hit=o return end
      for i=0,t.childCount-1 do w(t:GetChild(i),d+1) end end
    local rs=scene:GetRootGameObjects()
    for i=0,rs.Length-1 do local o=rs:get_Item(i); if o then w(o.transform,0) end; if hit then break end end
    return hit
  end
  local pl = find("Player_1")
  if not pl then r.error="no player" return end
  local p = pl.transform.position
  r.player = string.format("%.2f,%.2f,%.2f", p.x, p.y, p.z)

  -- clean
  local rs = scene:GetRootGameObjects()
  local doomed = {}
  local function collect(t, d)
    if d > 12 then return end
    local o = t.gameObject
    local nm = o.name
    if nm:find("^SHEET_") or nm:find("^PAPER_") then table.insert(doomed, o) end
    for i = 0, t.childCount - 1 do collect(t:GetChild(i), d + 1) end
  end
  for i = 0, rs.Length - 1 do local o = rs:get_Item(i); if o then collect(o.transform, 0) end end
  for _, o in ipairs(doomed) do pcall(function() CS.UnityEngine.Object.Destroy(o) end) end

  local Y = p.y
  local made, info = 0, {}
  local function box(name, dx, dz, sx, sy, sz, dy, rgb)
    local o = go.CreatePrimitive(prim.Cube)
    o.name = name
    o.transform.position = v3(p.x + dx, Y + dy, p.z + dz)
    o.transform.localScale = v3(sx, sy, sz)
    local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
    if mr and sh then
      local m = CS.UnityEngine.Material(sh)
      m:SetColor("_BaseColor", CS.UnityEngine.Color(rgb[1],rgb[2],rgb[3],1))
      mr.material = m
    end
    made = made + 1
    table.insert(info, name)
    return o
  end

  -- LEFT PAGE (player spawns here)
  box("PAPER_LEFT",  -5.0, 5.0, 10, 0.05, 14, 0.02, {0.93,0.90,0.81})
  -- RIGHT PAGE (across the fold)
  box("PAPER_RIGHT",  5.0, 5.0, 10, 0.05, 14, 0.02, {0.91,0.88,0.78})
  -- FOLD: dark valley between the pages, 1.6 m wide
  box("PAPER_FOLD",   0.0, 5.0,  1.6, 0.03, 14, 0.005, {0.30,0.26,0.22})
  -- page edges: outer rims so the sheet boundary reads
  box("PAPER_EDGE_L", -10.2, 5.0, 0.45, 0.10, 14, 0.05, {0.58,0.46,0.34})
  box("PAPER_EDGE_R",  10.2, 5.0, 0.45, 0.10, 14, 0.05, {0.58,0.46,0.34})
  -- spine ridge at the far left: 0.30 tall
  box("PAPER_SPINE", -10.8, 5.0, 0.8, 0.30, 14, 0.15, {0.36,0.20,0.16})

  -- RULER at rest: lying on the left page, pointing at the fold
  box("PAPER_RULER_REST", -7.5, 2.0, 0.9, 0.08, 7.0, 0.08, {0.84,0.68,0.44})
  -- ruler ramp: bridging the fold
  box("PAPER_RULER_RAMP", 0.0, 5.0, 1.4, 0.10, 8.0, 0.10, {0.84,0.68,0.44})
  -- tick marks on the ramp
  for k = 0, 6 do
    box("PAPER_TICK_" .. k, 0.0, 1.6 + k*1.1, 1.4, 0.02, 0.10, 0.17, {0.26,0.20,0.14})
  end

  -- TOWN: sits at the far edge, low massing 1.6 m tall so it still fits
  box("PAPER_TOWN", 0.0, 16.0, 12, 1.6, 3.0, 0.85, {0.22,0.34,0.40})
  box("PAPER_TOWN_ROOF", 0.0, 16.0, 12.4, 0.25, 3.4, 1.75, {0.62,0.24,0.22})
  -- warm windows on the town face
  for k = 0, 4 do
    box("PAPER_WIN_" .. k, -4.0 + k*2.0, 14.4, 0.9, 0.7, 0.1, 0.75, {1.0,0.86,0.50})
  end

  r.made = made
  r.names = table.concat(info, ",")
end)
if not ok then r.error = tostring(err) end
return r
