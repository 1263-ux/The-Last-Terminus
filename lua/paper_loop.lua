-- Closed loop driver for the paper world, using only mechanisms proven to work:
--   * position rule for the gate (no physical wall - the player is kinematic)
--   * SetActive for state change (immediate)
--   * colour swap for the warm-window feedback
--   * return-to-safe-point for failure recovery
--
-- Call with loop_mode = "tick" (enforce) or "activate" (solve).
local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local v3 = CS.UnityEngine.Vector3
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()

  local function find(n)
    local hit=nil
    local function w(t,d) if d>12 or hit then return end local o=t.gameObject
      if o.name==n then hit=o return end
      for i=0,t.childCount-1 do w(t:GetChild(i),d+1) end end
    local rs=scene:GetRootGameObjects()
    for i=0,rs.Length-1 do local o=rs:get_Item(i); if o then w(o.transform,0) end; if hit then break end end
    return hit
  end

  local pl = find("Player_1")
  if not pl then r.error = "no player" return end
  local p = pl.transform.position
  r.player = string.format("%.2f,%.2f,%.2f", p.x, p.y, p.z)

  local mode = "tick"
  if loop_mode ~= nil then mode = loop_mode end

  -- solved flag lives on the ramp's visibility
  local ramp = find("PAPER_RULER_RAMP")
  local solved = ramp ~= nil and ramp.activeSelf
  r.solved = tostring(solved)

  if mode == "activate" then
    local rest = find("PAPER_RULER_REST")
    if rest then rest:SetActive(false) end
    if ramp then ramp:SetActive(true) end
    for k = 0, 6 do
      local t = find("PAPER_TICK_" .. k)
      if t then t:SetActive(true) end
    end
    r.result = "ACTIVATED"
    return
  end

  -- tick: gate + feedback
  -- safe point: spawn. gate line: z = spawn + 12 (past the fold).
  local spawnZ = 88.64
  local gateZ = spawnZ + 12.0
  r.gateZ = string.format("%.1f", gateZ)

  if (not solved) and p.z > gateZ then
    pl.transform.position = v3(p.x, p.y, spawnZ)
    r.result = "REPELLED_TO_SAFE_POINT"
  elseif solved and p.z > spawnZ + 14.0 then
    -- arrival: light the warm windows
    local lit = 0
    for k = 0, 4 do
      local w = find("PAPER_WIN_" .. k)
      if w then
        w:SetActive(true)
        local mr = w:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
        if mr and mr.material then
          pcall(function() mr.material:SetColor("_BaseColor", CS.UnityEngine.Color(1.0,0.92,0.62,1)) end)
        end
        lit = lit + 1
      end
    end
    r.result = "ARRIVED_WINDOWS_LIT"
    r.windowsLit = lit
  else
    r.result = "OK"
  end
end)
if not ok then r.error = tostring(err) end
return r
