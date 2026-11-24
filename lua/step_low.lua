-- The 1.2 m platform BLOCKED the player (z froze at 88.64). That is a new and
-- important fact: runtime colliders DO stop horizontal movement.
--
-- So earlier "objects never block" conclusions need re-checking - what differs
-- here is that this box was created with CreatePrimitive in THIS session and the
-- player walked INTO it from a standing start.
--
-- Now test the step-up case: a low step (0.20 m, under maxStepHeight-ish) placed
-- in the path, to see whether the controller climbs it.
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
  r.before = string.format("%.2f,%.2f,%.2f", p.x, p.y, p.z)

  local rs = scene:GetRootGameObjects()
  local doomed = {}
  local function col(t,d) if d>12 then return end local o=t.gameObject
    if o.name:find("^STEP_") then table.insert(doomed,o) end
    for i=0,t.childCount-1 do col(t:GetChild(i),d+1) end end
  for i=0,rs.Length-1 do local o=rs:get_Item(i); if o then col(o.transform,0) end end
  for _,o in ipairs(doomed) do pcall(function() CS.UnityEngine.Object.Destroy(o) end) end

  -- low step 0.20 m tall, 4 m ahead, wide enough to walk on
  local o = go.CreatePrimitive(prim.Cube)
  o.name = "STEP_LOW"
  o.transform.position = v3(p.x, p.y + 0.10, p.z + 4.0)
  o.transform.localScale = v3(8.0, 0.20, 3.0)
  local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
  if mr and sh then
    local m = CS.UnityEngine.Material(sh)
    m:SetColor("_BaseColor", CS.UnityEngine.Color(0.30,0.60,0.90,1))
    mr.material = m
  end
  r.stepTopY = string.format("%.2f", p.y + 0.20)
end)
if not ok then r.error = tostring(err) end
return r
