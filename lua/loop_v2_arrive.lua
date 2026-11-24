-- Arrival feedback: light the town windows once the player is in front of it.
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

  local n = 0
  for k = 0, 3 do
    local wnd = find("LOOP_WIN_" .. k)
    if wnd then
      wnd:SetActive(true)
      local mr = wnd:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
      if mr then
        local m = mr.material
        local c = CS.UnityEngine.Color(1.0, 0.84, 0.32, 1.0)
        pcall(function() m:SetColor("_BaseColor", c) end)
        pcall(function() m:SetColor("_Color", c) end)
        n = n + 1
      end
    end
  end
  r.windowsLit = n
  r.verdict = "ARRIVED_FEEDBACK_ON"
end)
if not ok then r.error = tostring(err) end
return r
