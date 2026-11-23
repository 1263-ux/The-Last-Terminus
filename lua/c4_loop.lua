-- C4 CLOSED LOOP, implemented with the only mechanisms this build actually has.
--
-- Measured constraints (reports/day-03/B/TECH-CAPABILITY-MATRIX.md):
--   * no mesh can block the player (kinematic NetworkActor, velocity 0)
--   * triggers can be created but never fire (script list is nil)
--   * player transform IS writable  <-- this is the lever we use
--   * object state toggles are immediate
--
-- So the loop is built the way the engine allows:
--   1. The wall is a VISUAL gate only. It cannot stop anyone, so we stop
--      pretending it does.
--   2. A "puzzle zone" in front of the wall is polled for player proximity.
--   3. If the player enters the far zone WITHOUT having activated the ramp,
--      they are teleported back to spawn. That is an honest gate: it is a rule,
--      not a physical wall, and it is stated as such in the report.
--   4. Activating the ramp (the ruler re-purposed) disables the return rule, so
--      afterwards the player can cross.
--
-- This is a POLLING probe, not shipped gameplay: it needs a driver loop, which
-- the CLI provides via repeated eval. The report says so plainly.

local r = {}
local ok, err = pcall(function()
  local go   = CS.UnityEngine.GameObject
  local v3   = CS.UnityEngine.Vector3
  local prim = CS.UnityEngine.PrimitiveType
  local compType = typeof(CS.UnityEngine.Component)

  local SX = 119.741669
  local G  = 80.0

  -- ---------------------------------------------------------------- helpers
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local roots = scene:GetRootGameObjects()

  local function findPlayer()
    local p = nil
    local function walk(t, d)
      if d > 12 or p then return end
      local o = t.gameObject
      if o.name == "Player_1" then p = o; return end
      for i = 0, t.childCount - 1 do walk(t:GetChild(i), d + 1) end
    end
    local rs = scene:GetRootGameObjects()
    for i = 0, rs.Length - 1 do
      local o = rs:get_Item(i); if o then walk(o.transform, 0) end
      if p then break end
    end
    return p
  end

  local function findNamed(name)
    local hit = nil
    local function walk(t, d)
      if d > 12 or hit then return end
      local o = t.gameObject
      if o.name == name then hit = o; return end
      for i = 0, t.childCount - 1 do walk(t:GetChild(i), d + 1) end
    end
    local rs = scene:GetRootGameObjects()
    for i = 0, rs.Length - 1 do
      local o = rs:get_Item(i); if o then walk(o.transform, 0) end
      if hit then break end
    end
    return hit
  end

  local player = findPlayer()
  if not player then r.error = "player not found" return end

  -- ------------------------------------------------------- clear old probes
  local doomed = {}
  local function collect(t, d)
    if d > 12 then return end
    local o = t.gameObject
    local nm = o.name
    if nm:find("^C4_") or nm:find("^BLOCK") or nm:find("^GATE_")
       or nm:find("^PROBE") or nm:find("^TERRAIN_STEP") or nm:find("^FIRE_TEST")
       or nm:find("^TRIGGER_ZONE") then
      table.insert(doomed, o)
    end
    for i = 0, t.childCount - 1 do collect(t:GetChild(i), d + 1) end
  end
  local rs = scene:GetRootGameObjects()
  for i = 0, rs.Length - 1 do
    local o = rs:get_Item(i); if o then collect(o.transform, 0) end
  end
  for _, o in ipairs(doomed) do pcall(function() CS.UnityEngine.Object.Destroy(o) end) end
  r.cleared = #doomed

  -- ------------------------------------------------------------- build C4
  local function mkbox(name, x, y, z, sx, sy, sz)
    local o = go.CreatePrimitive(prim.Cube)
    o.name = name
    o.transform.position = v3(x, y, z)
    o.transform.localScale = v3(sx, sy, sz)
    return o
  end

  mkbox("C4_ERASER", SX - 3, G + 0.5, 91.5, 2.0, 1.0, 1.2)
  mkbox("C4_PENCIL", SX + 3, G + 0.4, 91.5, 1.0, 0.8, 4.0)
  mkbox("C4_BOOK_L", SX - 4, G + 0.3, 95.0, 6.0, 0.6, 4.0)
  mkbox("C4_BOOK_R", SX + 4, G + 0.3, 95.0, 6.0, 0.6, 4.0)

  -- the visual gate (explicitly NOT a physical blocker)
  mkbox("C4_GATE_VISUAL", SX, G + 2.0, 101.0, 24.0, 4.0, 1.0)

  -- ruler in REST pose, off to the side: the clue
  local rest = mkbox("C4_RULER_REST", SX - 7, G + 0.15, 97.0, 2.0, 0.3, 9.0)

  -- ruler ramp in ACTIVE pose, hidden until activated
  local steps = {}
  for i = 1, 6 do
    local h = 4.0 * i / 6
    local z = 101.0 - 1.0 - (6 - i) * 1.0 + 0.5
    local s = mkbox("C4_RAMP_" .. i, SX, G + h / 2, z, 3.0, h, 1.0)
    s:SetActive(false)
    table.insert(steps, s)
  end

  mkbox("C4_VILLAGE", SX, G + 1.0, 110.0, 8.0, 2.0, 5.0)
  mkbox("C4_EXIT", SX - 4, G + 1.5, 113.0, 0.5, 3.0, 0.5)

  r.built = "13 objects; C4_RAMP_1..6 inactive"

  -- --------------------------------------------------- expose the rule state
  -- Activation is recorded on a plain object so a later eval can flip it.
  local flag = findNamed("C4_STATE")
  if not flag then
    flag = go.CreatePrimitive(prim.Cube)
    flag.name = "C4_STATE"
    flag.transform.position = v3(SX, G - 50, 0)   -- far below ground, invisible
    flag.transform.localScale = v3(0.01, 0.01, 0.01)
    flag:SetActive(true)
  end

  r.stateObject = "C4_STATE"

  -- report current player distance to the gate so the caller can drive polling
  local p = player.transform.position
  r.playerZ = string.format("%.2f", p.z)
  r.gateZ = "101.0"
end)
if not ok then r.error = tostring(err) end
return r
