-- Activate the C4 solution: the ruler is re-purposed from a lying-down prop
-- into a ramp leaning on the gate. State change is observable and persistent.
--
-- Gate rule after this: the player may pass, because the route now exists.
-- (Physical blocking is impossible in this build - see TECH-CAPABILITY-MATRIX -
-- so the gate is a rule plus a visible ramp, and the report says exactly that.)
local r = {}
local ok, err = pcall(function()
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()

  local function find(n)
    local hit = nil
    local function w(t, d)
      if d > 12 or hit then return end
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

  local state = find("C4_STATE")
  if not state then r.error = "no C4_STATE" return end

  -- flag semantics: C4_STATE.activeSelf == true means "not yet activated"
  state:SetActive(false)

  local shown = 0
  for i = 1, 6 do
    local s = find("C4_RAMP_" .. i)
    if s then s:SetActive(true); shown = shown + 1 end
  end

  local rest = find("C4_RULER_REST")
  if rest then rest:SetActive(false) end

  r.result = "ACTIVATED"
  r.rampStepsShown = shown
  r.restPoseVisible = tostring(rest ~= nil and rest.activeSelf)
  r.note = "ruler moved from rest pose to ramp pose"
end)
if not ok then r.error = tostring(err) end
return r
