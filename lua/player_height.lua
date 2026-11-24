-- Settle the player height definitively: capsule height, avatar bounds, and the
-- actual rendered extent. Earlier reports disagreed (1.7 m vs 0.90 m).
local r = {}
local ok, err = pcall(function()
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local rs = scene:GetRootGameObjects()
  local pl = nil
  local function find(t, d)
    if d > 12 or pl then return end
    local o = t.gameObject
    if o.name == "Player_1" then pl = o; return end
    for i = 0, t.childCount - 1 do find(t:GetChild(i), d + 1) end
  end
  for i = 0, rs.Length - 1 do local o = rs:get_Item(i); if o then find(o.transform, 0) end; if pl then break end end
  if not pl then r.error = "no player" return end

  local cap = pl:GetComponent(typeof(CS.UnityEngine.CapsuleCollider))
  if cap then
    r.capsuleHeight = string.format("%.3f", cap.height)
    r.capsuleRadius = string.format("%.3f", cap.radius)
    r.capsuleCenterY = string.format("%.3f", cap.center.y)
  end

  -- measure the avatar's actual renderer bounds
  local miny, maxy = 1e9, -1e9
  local n = 0
  local function walk(t, d)
    if d > 12 then return end
    local o = t.gameObject
    local smr = o:GetComponent(typeof(CS.UnityEngine.SkinnedMeshRenderer))
    local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
    local rend = smr or mr
    if rend then
      local b = rend.bounds
      local lo = b.center.y - b.extents.y
      local hi = b.center.y + b.extents.y
      if lo < miny then miny = lo end
      if hi > maxy then maxy = hi end
      n = n + 1
    end
    for i = 0, t.childCount - 1 do walk(t:GetChild(i), d + 1) end
  end
  walk(pl.transform, 0)
  r.renderers = n
  r.avatarBottomY = string.format("%.3f", miny)
  r.avatarTopY = string.format("%.3f", maxy)
  r.avatarHeight = string.format("%.3f", maxy - miny)
  r.footY = string.format("%.3f", pl.transform.position.y)
end)
if not ok then r.error = tostring(err) end
return r
