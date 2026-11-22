-- Poll player position and report whether it is inside the ramp-trigger radius.
-- This is a PROBE, not a shipped mechanic: it proves the detection + swap logic
-- works even though box colliders cannot block and trigger scripts cannot be
-- bound from the CLI.
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

  local p = player.transform.position
  r.pos = string.format("%.2f,%.2f,%.2f", p.x, p.y, p.z)

  -- the "puzzle zone": within 4 m of the ruler rest position
  local RX, RZ = 112.741669, 97.0
  local dx, dz = p.x - RX, p.z - RZ
  local dist = math.sqrt(dx*dx + dz*dz)
  r.distToRulerRest = string.format("%.2f", dist)
  r.inside = tostring(dist < 4.0)

  -- report whether the ramp-up steps exist and are currently active
  local up, upActive = 0, 0
  local function scan(t, d)
    if d > 12 then return end
    local o = t.gameObject
    if o.name:find("^C4_RULER_UP_") then
      up = up + 1
      if o.activeSelf then upActive = upActive + 1 end
    end
    for i = 0, t.childCount - 1 do scan(t:GetChild(i), d + 1) end
  end
  for i = 0, roots.Length - 1 do
    local o = roots:get_Item(i); if o then scan(o.transform, 0) end
  end
  r.rampSteps = up
  r.rampActive = upActive
end)
if not ok then r.error = tostring(err) end
return r
