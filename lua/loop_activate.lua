-- Activate the C4 solution: hide the resting ruler, show the ramp, flip the rule.
-- This is the state change the gate requires; the rest pose is REMOVED (not left
-- sitting alongside), which is what distinguishes it from merely pre-placing two
-- poses.
local r = {}
local ok, err = pcall(function()
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

  local rest = find("C4_RULER_REST")
  if rest then rest:SetActive(false) end
  r.restHidden = tostring(rest ~= nil and (not rest.activeSelf))

  local shown = 0
  for i = 1, 4 do
    local s = find("C4_RAMP_" .. i)
    if s then s:SetActive(true); shown = shown + 1 end
  end
  r.rampShown = shown
  r.solved = "true"
end)
if not ok then r.error = tostring(err) end
return r
