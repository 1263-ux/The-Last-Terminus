-- Something still blocks at z~100.98 after the gate was removed. Enumerate every
-- collider near the player and report its bounds so I can see what it is.
local r = {}
local ok, err = pcall(function()
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local rs = scene:GetRootGameObjects()
  local out = {}
  local function walk(t, d)
    if d > 12 then return end
    local o = t.gameObject
    if o.name:find("^LOOP_") and o.activeInHierarchy then
      local bc = o:GetComponent(typeof(CS.UnityEngine.BoxCollider))
      if bc and bc.enabled then
        local p = t.position
        local s = t.localScale
        table.insert(out, string.format("%s z=%.2f depth=%.2f top=%.2f",
          o.name, p.z, s.z, p.y + s.y/2))
      end
    end
    for i = 0, t.childCount - 1 do walk(t:GetChild(i), d + 1) end
  end
  for i = 0, rs.Length - 1 do local o = rs:get_Item(i); if o then walk(o.transform, 0) end end
  r.active = table.concat(out, " ;; ")
  r.count = #out
end)
if not ok then r.error = tostring(err) end
return r
