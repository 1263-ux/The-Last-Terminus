-- Precise collision repro: build a wall at a known z with known depth, record the
-- exact front face, then walk into it and compare the player's stop z against
-- frontFace + capsuleRadius. A match at 0.16 m is geometric proof of a real
-- capsule-vs-box collision response, not a timing artefact.
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
  local p0 = pl.transform.position
  r.start = string.format("%.3f", p0.z)

  -- clear
  local rs=scene:GetRootGameObjects(); local doomed={}
  local function col(t,d) if d>12 then return end local o=t.gameObject
    if o.name:find("^GEO_") then table.insert(doomed,o) end
    for i=0,t.childCount-1 do col(t:GetChild(i),d+1) end end
  for i=0,rs.Length-1 do local o=rs:get_Item(i); if o then col(o.transform,0) end end
  for _,o in ipairs(doomed) do pcall(function() CS.UnityEngine.Object.Destroy(o) end) end

  -- floor
  local fl = go.CreatePrimitive(prim.Cube)
  fl.name="GEO_FLOOR"
  fl.transform.position = v3(p0.x, p0.y-0.25, p0.z+15.0)
  fl.transform.localScale = v3(8.0,0.5,40.0)

  -- wall: centre at start+8, depth 0.5, height 0.8
  local wallZ = p0.z + 8.0
  local depth = 0.5
  local height = 0.8
  local w = go.CreatePrimitive(prim.Cube)
  w.name="GEO_WALL"
  w.transform.position = v3(p0.x, p0.y+height/2, wallZ)
  w.transform.localScale = v3(8.0, height, depth)
  local mr=w:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
  local sh2=CS.UnityEngine.Shader.Find("Universal Render Pipeline/Lit")
  if mr and sh2 then
    local m=CS.UnityEngine.Material(sh2)
    m:SetColor("_BaseColor", CS.UnityEngine.Color(0.85,0.25,0.20,1))
    mr.material=m
  end

  local cap = pl:GetComponent(typeof(CS.UnityEngine.CapsuleCollider))
  r.capsuleRadius = cap and string.format("%.3f", cap.radius) or "?"
  r.wallCentreZ = string.format("%.3f", wallZ)
  r.wallFrontZ = string.format("%.3f", wallZ - depth/2)
  r.expectedStopZ = string.format("%.3f", wallZ - depth/2 - (cap and cap.radius or 0))
end)
if not ok then r.error=tostring(err) end
return r
