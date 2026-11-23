-- Get the trigger component's Type from an EXISTING instance, which always works,
-- then use it to create a trigger zone and prove the state-change mechanism.
local r = {}
local ok, err = pcall(function()
  local compType = typeof(CS.UnityEngine.Component)
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local roots = scene:GetRootGameObjects()
  local player = nil
  local function walk(t, d)
    if d > 12 or player then return end
    local o = t.gameObject
    if o.name == "Player_1" then player = o; return end
    for i = 0, t.childCount - 1 do walk(t:GetChild(i), d + 1) end
  end
  for i = 0, roots.Length - 1 do
    local o = roots:get_Item(i); if o then walk(o.transform, 0) end
    if player then break end
  end
  if not player then r.player="not found" return end

  local cs = player:GetComponents(compType)
  local ut = nil
  for i = 0, cs.Length - 1 do
    local c = cs:get_Item(i)
    if c and c:GetType().Name == "U3dObjectTrigger" then ut = c; break end
  end
  if not ut then r.note="no U3dObjectTrigger instance on player" return end

  local ty = ut:GetType()
  r.typeName = ty.Name
  r.fullName = ty.FullName

  -- Reflect fields so we learn what a trigger zone needs (radius/size/layer).
  local flags = CS.System.Reflection.BindingFlags.Public
             + CS.System.Reflection.BindingFlags.NonPublic
             + CS.System.Reflection.BindingFlags.Instance
  local flds = ty:GetFields(flags)
  local out = {}
  for i = 0, flds.Length - 1 do
    local f = flds:get_Item(i)
    if f then
      local okv, v = pcall(function() return f:GetValue(ut) end)
      table.insert(out, f.Name .. "=" .. (okv and tostring(v) or "?"))
    end
  end
  r.fieldCount = flds.Length
  r.fields = table.concat(out, " | ")
end)
if not ok then r.error = tostring(err) end
return r
