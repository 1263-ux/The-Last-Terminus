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
    if o.name:find("^SHEET_") then table.insert(doomed, o) end
    for i = 0, t.childCount - 1 do collect(t:GetChild(i), d + 1) end
  end
  for i = 0, rs.Length - 1 do local o = rs:get_Item(i); if o then collect(o.transform, 0) end end
  for _, o in ipairs(doomed) do pcall(function() CS.UnityEngine.Object.Destroy(o) end) end

  local function find(n)
    local hit=nil
    local function w(t,d) if d>12 or hit then return end local o=t.gameObject
      if o.name==n then hit=o return end
      for i=0,t.childCount-1 do w(t:GetChild(i),d+1) end end
    local rs2=scene:GetRootGameObjects()
    for i=0,rs2.Length-1 do local o=rs2:get_Item(i); if o then w(o.transform,0) end; if hit then break end end
    return hit
  end
  local pl = find("Player_1")
  if not pl then r.error="no player" return end
  local p = pl.transform.position
  r.player = string.format("%.2f,%.2f,%.2f", p.x, p.y, p.z)

  local function flat(name, dx, dz, sx, sz, y, rgb)
    local o = go.CreatePrimitive(prim.Cube)
    o.name = name
    o.transform.position = v3(p.x + dx, y, p.z + dz)
    o.transform.localScale = v3(sx, 0.04, sz)
    local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
    if mr and sh then
      local m = CS.UnityEngine.Material(sh)
      m:SetColor("_BaseColor", CS.UnityEngine.Color(rgb[1],rgb[2],rgb[3],1))
      mr.material = m
    end
    return o
  end

  -- the sheet the player stands on, edge visible ahead
  flat("SHEET_PAPER", 0, 6, 14, 16, p.y + 0.02, {0.92,0.89,0.80})
  -- a darker page edge so the boundary reads
  flat("SHEET_EDGE", 0, 14.2, 14, 0.5, p.y + 0.03, {0.55,0.42,0.30})
  -- spine: a low ridge along the left, 0.25 m tall
  local sp = flat("SHEET_SPINE", -6.6, 6, 0.6, 16, p.y + 0.125, {0.36,0.20,0.16})
  -- a second sheet layer, slightly raised, to imply stacked pages
  flat("SHEET_STACK", 0, 10, 12, 3, p.y + 0.06, {0.86,0.83,0.74})
  r.made = 4
end)
if not ok then r.error = tostring(err) end
return r
