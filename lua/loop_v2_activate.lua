-- Activate the physical-gate loop. One authored state change:
--   gate is removed (path opens), resting ruler hidden, ramp + ticks shown.
local r = {}
local ok, err = pcall(function()
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local function find(n)
    local hit = nil
    local function w(t, d)
      if d > 12 or hit then return end
      local o = t.gameObject
      if o.name == n then hit = o; return end
      for i = 0, t.childCount - 1 do w(t:GetChild(i), d + 1) end
    end
    local rs = scene:GetRootGameObjects()
    for i = 0, rs.Length - 1 do
      local o = rs:get_Item(i); if o then w(o.transform, 0) end
      if hit then break end
    end
    return hit
  end

  local gate = find("LOOP_GATE")
  if gate then gate:SetActive(false) end
  r.gateRemoved = tostring(gate ~= nil and (not gate.activeSelf))

  local rest = find("LOOP_RULER_REST")
  if rest then rest:SetActive(false) end
  r.restHidden = tostring(rest ~= nil and (not rest.activeSelf))

  local shown = 0
  local ramp = find("LOOP_RULER_RAMP")
  if ramp then ramp:SetActive(true); shown = shown + 1 end
  for k = 0, 5 do
    local t = find("LOOP_TICK_" .. k)
    if t then t:SetActive(true); shown = shown + 1 end
  end
  r.rampPartsShown = shown
  r.verdict = "ACTIVATED"
end)
if not ok then r.error = tostring(err) end
return r
