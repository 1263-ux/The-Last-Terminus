-- Diagnose the player's physics setup: collider layer, rigidbody mode, and the
-- obstacle's layer. BoxCollider + Rigidbody + CapsuleCollider all exist, so the
-- penetration must come from layer masking or kinematic/mass settings.
local r = {}
local ok, err = pcall(function()
  local compType = typeof(CS.UnityEngine.Component)
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local roots = scene:GetRootGameObjects()

  local player = nil
  local wall = nil
  local function walk(t, d)
    if d > 12 then return end
    local o = t.gameObject
    if o.name == "Player_1" then player = o end
    if o.name:find("BLOCK") or o.name:find("C4_BREAK") then wall = o end
    for i = 0, t.childCount - 1 do walk(t:GetChild(i), d + 1) end
  end
  for i = 0, roots.Length - 1 do
    local o = roots:get_Item(i)
    if o then walk(o.transform, 0) end
  end

  if player then
    r.playerLayer = player.layer
    r.playerLayerName = CS.UnityEngine.LayerMask.LayerToName(player.layer)

    local cap = player:GetComponent(typeof(CS.UnityEngine.CapsuleCollider))
    if cap then
      r.capsuleEnabled = tostring(cap.enabled)
      r.capsuleIsTrigger = tostring(cap.isTrigger)
      r.capsuleRadius = tostring(cap.radius)
      r.capsuleHeight = tostring(cap.height)
    end

    local rb = player:GetComponent(typeof(CS.UnityEngine.Rigidbody))
    if rb then
      r.rbKinematic = tostring(rb.isKinematic)
      r.rbUseGravity = tostring(rb.useGravity)
      r.rbMass = tostring(rb.mass)
      r.rbConstraints = tostring(rb.constraints)
      r.rbDetectCollisions = tostring(rb.detectCollisions)
    end
  else
    r.player = "NOT FOUND"
  end

  if wall then
    r.wallName = wall.name
    r.wallLayer = wall.layer
    r.wallLayerName = CS.UnityEngine.LayerMask.LayerToName(wall.layer)
    local bc = wall:GetComponent(typeof(CS.UnityEngine.BoxCollider))
    if bc then
      r.wallColliderEnabled = tostring(bc.enabled)
      r.wallColliderIsTrigger = tostring(bc.isTrigger)
    end
  else
    r.wall = "no BLOCK/C4 object in scene this run"
  end

  -- Physics global: how many layers can interact, and is the sim even running?
  r.physicsAutoSim = tostring(CS.UnityEngine.Physics.autoSimulation)
  r.gravity = tostring(CS.UnityEngine.Physics.gravity.y)
end)
if not ok then r.error = tostring(err) end
return r
