-- THE decisive test: put a runtime primitive platform under the player at a KNOWN
-- height. If the player's y rises to meet it, walkable surfaces work and the
-- kinematic body DOES sample ground. If y stays put, it does not.
--
-- I already proved primitives carry the player (walked 14 m on paper at constant y).
-- So instead test the opposite: raise a platform and see if y follows.
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

  -- wipe old
  local rs = scene:GetRootGameObjects()
  local doomed = {}
  local function collect(t, d)
    if d > 12 then return end
    local o = t.gameObject
    if o.name:find("^STEP_") then table.insert(doomed, o) end
    for i = 0, t.childCount - 1 do collect(t:GetChild(i), d + 1) end
  end
  for i = 0, rs.Length - 1 do local o = rs:get_Item(i); if o then collect(o.transform, 0) end end
  for _, o in ipairs(doomed) do pcall(function() CS.UnityEngine.Object.Destroy(o) end) end

  -- a platform 1.2 m ABOVE the player's feet, right where they stand.
  -- If ground sampling works, walking shall raise y toward the top.
  local topY = p.y + 1.2
  local o = go.CreatePrimitive(prim.Cube)
  o.name = "STEP_PLATFORM"
  o.transform.position = v3(p.x, topY - 0.25, p.z + 2.0)
  o.transform.localScale = v3(6.0, 0.5, 6.0)
  local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
  if mr and sh then
    local m = CS.UnityEngine.Material(sh)
    m:SetColor("_BaseColor", CS.UnityEngine.Color(0.85,0.30,0.25,1))
    mr.material = m
  end
  r.platformTopY = string.format("%.2f", topY)
end)
if not ok then r.error = tostring(err) end
return r
