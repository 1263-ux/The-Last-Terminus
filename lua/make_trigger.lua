-- Can we CREATE a trigger zone and bind a script to it? If yes, the C4 state
-- change is achievable without collision, and the loop becomes provable.
local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local v3 = CS.UnityEngine.Vector3
  local prim = CS.UnityEngine.PrimitiveType

  -- get the trigger TYPE from an existing instance on the player
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
  local trigType = nil
  if player then
    local cs = player:GetComponents(compType)
    for i = 0, cs.Length - 1 do
      local c = cs:get_Item(i)
      if c and c:GetType().Name == "U3dObjectTrigger" then trigType = c:GetType(); break end
    end
  end
  r.gotType = tostring(trigType ~= nil)
  if not trigType then return end

  -- create a zone object and attach the trigger component
  local zone = go.CreatePrimitive(prim.Cube)
  zone.name = "TRIGGER_ZONE_TEST"
  zone.transform.position = v3(119.741669, 81.0, 97.0)
  zone.transform.localScale = v3(6.0, 3.0, 2.0)

  local okAdd, added = pcall(function() return zone:AddComponent(trigType) end)
  r.addOk = tostring(okAdd)
  if okAdd and added then
    r.addedName = tostring(added:GetType().Name)
    -- make it a trigger volume so the player can pass through and still fire
    local bc = zone:GetComponent(typeof(CS.UnityEngine.BoxCollider))
    if bc then bc.isTrigger = true; r.isTrigger = "true" end
  else
    r.addErr = tostring(added)
  end

  -- does a script-list API exist on the trigger?
  if okAdd and added then
    local ty = added:GetType()
    local flags = CS.System.Reflection.BindingFlags.Public
               + CS.System.Reflection.BindingFlags.NonPublic
               + CS.System.Reflection.BindingFlags.Instance
    local mets = ty:GetMethods(flags)
    local mnames = {}
    for i = 0, mets.Length - 1 do
      local m = mets:get_Item(i)
      if m and (m.Name:lower():find("script") or m.Name:lower():find("trigger")
             or m.Name:lower():find("enter") or m.Name:lower():find("bind")) then
        table.insert(mnames, m.Name)
      end
    end
    r.methods = table.concat(mnames, ",")
  end
end)
if not ok then r.error = tostring(err) end
return r
