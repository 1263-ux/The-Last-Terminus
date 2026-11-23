-- Full C4 loop driver. Reads state, enforces the rule, and can activate.
-- Rule is a pure function of position so the kinematic controller cannot fight it.
local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local v3 = CS.UnityEngine.Vector3
  local prim = CS.UnityEngine.PrimitiveType
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()

  local function find(n)
    local hit = nil
    local function w(t, d)
      if d > 14 or hit then return end
      local o = t.gameObject
      if o.name == n then hit = o return end
      for i = 0, t.childCount - 1 do w(t:GetChild(i), d + 1) end
    end
    local rs = scene:GetRootGameObjects()
    for i = 0, rs.Length - 1 do
      local o = rs:get_Item(i); if o then w(o.transform, 0) end
      if hit then break end
    end
    return hit
  end

  local player = find("Player_1")
  if not player then r.error = "no player" return end

  local p = player.transform.position
  r.playerZ = string.format("%.2f", p.z)

  -- the solver flag lives on C4_RAMP_1 visibility (true == solved)
  local ramp = find("C4_RAMP_1")
  local solved = ramp and ramp.activeSelf or false
  r.solved = tostring(solved)

  local GATE_Z = 104.0
  local BLOCK_Z = 105.5
  r.gateZ = tostring(GATE_Z)

  if (not solved) and p.z > BLOCK_Z then
    -- not solved but past the gate: this is the "blocked" case
    r.verdict = "BLOCKED_SHOULD_RETURN"
    r.ruleFires = "true"
  else
    r.verdict = "PASS"
    r.ruleFires = "false"
  end
end)
if not ok then r.error = tostring(err) end
return r
