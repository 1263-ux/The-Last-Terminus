-- Are there multiple cameras, and which one is actually rendering?
-- A directed capture likely uses its own camera. If the player camera is disabled
-- or has a tiny viewport, that explains everything.
local r = {}
local ok, err = pcall(function()
  local camType = typeof(CS.UnityEngine.Camera)
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local rs = scene:GetRootGameObjects()

  local list = {}
  local function walk(t, d)
    if d > 14 then return end
    local o = t.gameObject
    local okc, c = pcall(function() return o:GetComponent(camType) end)
    if okc and c then
      local p = t.position
      table.insert(list, string.format(
        "%s cam[enabled=%s depth=%.1f fov=%.0f rect=%.2fx%.2f mask=%s pos=%.1f,%.1f,%.1f]",
        o.name, tostring(c.enabled), c.depth, c.fieldOfView,
        c.rect.width, c.rect.height, tostring(c.cullingMask),
        p.x, p.y, p.z))
    end
    for i = 0, t.childCount - 1 do walk(t:GetChild(i), d + 1) end
  end
  for i = 0, rs.Length - 1 do local o = rs:get_Item(i); if o then walk(o.transform, 0) end end

  r.cameras = table.concat(list, " ;; ")
  r.count = #list

  -- what does the player's own avatar renderer look like? it IS visible on screen
  local function find(n)
    local hit=nil
    local function w(t,d) if d>14 or hit then return end local o=t.gameObject
      if o.name==n then hit=o return end
      for i=0,t.childCount-1 do w(t:GetChild(i),d+1) end end
    local rs2=scene:GetRootGameObjects()
    for i=0,rs2.Length-1 do local o=rs2:get_Item(i); if o then w(o.transform,0) end; if hit then break end end
    return hit
  end
  local pl = find("Player_1")
  if pl then
    -- list renderers under the player and their shaders
    local shaders = {}
    local function wr(t,d)
      if d>10 then return end
      local o=t.gameObject
      local mr=o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
      local smr=o:GetComponent(typeof(CS.UnityEngine.SkinnedMeshRenderer))
      local rend = mr or smr
      if rend and rend.material and rend.material.shader then
        table.insert(shaders, o.name .. "=" .. rend.material.shader.name)
      end
      for i=0,t.childCount-1 do wr(t:GetChild(i),d+1) end
    end
    wr(pl.transform, 0)
    -- keep it short
    local keep = {}
    for i=1,math.min(#shaders,6) do keep[i]=shaders[i] end
    r.playerShaders = table.concat(keep, " ;; ")
    r.playerShaderCount = #shaders
  end
end)
if not ok then r.error = tostring(err) end
return r
