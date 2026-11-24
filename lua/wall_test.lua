-- Map the blocking threshold precisely. Clean the field, then place one wall of a
-- given height a fixed distance ahead and report whether the player advances.
-- Height comes from step_height global.
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

  -- clear all probes
  local rs = scene:GetRootGameObjects()
  local doomed = {}
  local function col(t,d) if d>12 then return end local o=t.gameObject
    local nm=o.name
    if nm:find("^STEP_") or nm:find("^SHEET_") or nm:find("^PAPER_") then table.insert(doomed,o) end
    for i=0,t.childCount-1 do col(t:GetChild(i),d+1) end end
  for i=0,rs.Length-1 do local o=rs:get_Item(i); if o then col(o.transform,0) end end
  for _,o in ipairs(doomed) do pcall(function() CS.UnityEngine.Object.Destroy(o) end) end

  -- solid floor under the player so they can walk
  local p0 = pl.transform.position
  local fl = go.CreatePrimitive(prim.Cube)
  fl.name = "STEP_FLOOR"
  fl.transform.position = v3(p0.x, p0.y - 0.25, p0.z + 12.0)
  fl.transform.localScale = v3(10.0, 0.5, 30.0)
  local fmr = fl:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
  if fmr and sh then
    local m = CS.UnityEngine.Material(sh)
    m:SetColor("_BaseColor", CS.UnityEngine.Color(0.88,0.85,0.78,1))
    fmr.material = m
  end

  local h = 0.60
  if step_height ~= nil then h = step_height end
  local wall = go.CreatePrimitive(prim.Cube)
  wall.name = "STEP_WALL"
  wall.transform.position = v3(p0.x, p0.y + h/2, p0.z + 7.0)
  wall.transform.localScale = v3(10.0, h, 0.6)
  local wmr = wall:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
  if wmr and sh then
    local m = CS.UnityEngine.Material(sh)
    m:SetColor("_BaseColor", CS.UnityEngine.Color(0.80,0.25,0.22,1))
    wmr.material = m
  end

  r.height = string.format("%.2f", h)
  r.startZ = string.format("%.2f", p0.z)
  r.wallZ = string.format("%.2f", p0.z + 7.0)
end)
if not ok then r.error = tostring(err) end
return r
