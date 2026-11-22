-- Confirm the actual root cause: the player is a KINEMATIC body whose position
-- is written by script, so no mesh collider can ever stop it.
--
-- Measured earlier:
--   player layer 8 Actor | CapsuleCollider enabled, not trigger
--   Rigidbody isKinematic = true | useGravity = false | constraints = 0
--   obstacles on layer 0, 2, 8 all PENETRATED
--
-- A kinematic rigidbody is excluded from the solver's response. If movement is
-- transform-driven, collision is decided by whatever the movement script queries
-- - and this script evidently does not query mesh colliders at all, since three
-- different layers all failed.
--
-- This probe proves it by doing the one thing a mesh-collider check could not:
-- watching the rigidbody's own velocity. If the script drives position directly
-- while the body stays kinematic, velocity stays ~0 and physics never engages.
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
    local o = roots:get_Item(i)
    if o then walk(o.transform, 0) end
    if player then break end
  end

  if not player then r.error = "player not found" return end

  local rb = player:GetComponent(typeof(CS.UnityEngine.Rigidbody))
  r.isKinematic = tostring(rb.isKinematic)
  r.useGravity = tostring(rb.useGravity)
  local v = rb.velocity
  r.velocity = string.format("%.4f,%.4f,%.4f", v.x, v.y, v.z)
  r.isSleeping = tostring(rb.IsSleeping())

  -- Unity 6 / newer: velocity may be linearVelocity
  local okv, lv = pcall(function() return rb.linearVelocity end)
  if okv and lv then
    r.linearVelocity = string.format("%.4f,%.4f,%.4f", lv.x, lv.y, lv.z)
  end

  -- List the actor components that could own movement, so the report can name
  -- what to look at instead of hand-waving at "the script".
  local cs = player:GetComponents(compType)
  local movers = {}
  for i = 0, cs.Length - 1 do
    local c = cs:get_Item(i)
    if c then
      local tn = c:GetType().Name
      if tn:find("Network") or tn:find("Actor") or tn:find("Move") or tn:find("Motor") then
        table.insert(movers, tn)
      end
    end
  end
  r.movementComponents = table.concat(movers, ",")
end)
if not ok then r.error = tostring(err) end
return r
