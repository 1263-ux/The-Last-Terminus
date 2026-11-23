-- Does the trigger actually FIRE when the player walks through it?
-- If yes, the C4 REST->RAMP switch is implementable without any collision.
-- Test: stand a trigger zone ahead, watch its state via a counter we can read.
local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local v3 = CS.UnityEngine.Vector3
  local prim = CS.UnityEngine.PrimitiveType
  local compType = typeof(CS.UnityEngine.Component)

  -- locate player + its trigger type
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
  if not player then r.player = "not found" return end

  local trigType = nil
  local cs = player:GetComponents(compType)
  for i = 0, cs.Length - 1 do
    local c = cs:get_Item(i)
    if c and c:GetType().Name == "U3dObjectTrigger" then trigType = c:GetType(); break end
  end
  if not trigType then r.type = "none" return end

  -- read player position so we can place the zone right where it will walk
  local pp = player.transform.position
  r.playerPos = string.format("%.2f,%.2f,%.2f", pp.x, pp.y, pp.z)

  -- place the zone just ahead of the player
  local zone = go.CreatePrimitive(prim.Cube)
  zone.name = "FIRE_TEST_ZONE"
  zone.transform.position = v3(pp.x, pp.y + 1.0, pp.z + 3.0)
  zone.transform.localScale = v3(8.0, 4.0, 2.0)
  local bc = zone:GetComponent(typeof(CS.UnityEngine.BoxCollider))
  if bc then bc.isTrigger = true end
  local tz = zone:AddComponent(trigType)
  r.zonePos = string.format("%.2f,%.2f,%.2f", pp.x, pp.y + 1.0, pp.z + 3.0)
  r.zoneAdded = tostring(tz ~= nil)

  -- Does it need a douyin script bound to fire? Check the script list field type.
  if tz then
    local ty = tz:GetType()
    local flags = CS.System.Reflection.BindingFlags.NonPublic + CS.System.Reflection.BindingFlags.Instance
    local f = ty:GetField("_douyinScriptList", flags)
    if f then
      local v = f:GetValue(tz)
      r.scriptList = tostring(v)
      if v ~= nil then
        local okc, cnt = pcall(function() return v.Count end)
        r.scriptListCount = okc and tostring(cnt) or "not a list with Count"
      end
    end
  end
end)
if not ok then r.error = tostring(err) end
return r
