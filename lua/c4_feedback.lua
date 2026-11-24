-- C4 gate with FEEDBACK, satisfying the director's §3.2 line:
--   "Avoid repeated teleporting without feedback."
--   "the player should understand locked/unlocked state from visible affordances"
--
-- Before activation, walking into the far zone does not silently warp the player.
-- It:
--   1. shows a visible barrier band at the gate line (the affordance)
--   2. flashes the ruler in rest pose (pointing at the answer)
--   3. returns the player to the near safe point
--   4. logs the reason so the run is auditable
--
-- After activation the ramp replaces the gap, the barrier band disappears, and
-- the same zone lets the player through.
--
-- This is a driver script: call with mode "tick" repeatedly while walking, and
-- "activate" once the player has interacted.
local r = {}
local ok, err = pcall(function()
  local go   = CS.UnityEngine.GameObject
  local v3   = CS.UnityEngine.Vector3
  local prim = CS.UnityEngine.PrimitiveType
  local sh   = CS.UnityEngine.Shader.Find("Universal Render Pipeline/Lit")
  local camType = typeof(CS.UnityEngine.Camera)
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()

  local function find(n)
    local hit = nil
    local function w(t, d)
      if d > 14 or hit then return end
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

  -- ---------- build (only if missing) ----------
  local anchor = find("C4_DECK_A")
  if not anchor then
    local cams = go.FindGameObjectsWithTag("MainCamera")
    local cam = cams:get_Item(0):GetComponent(camType)
    local cp = cam.transform.position
    local camX, camY, camZ = cp.x, cp.y, cp.z
    local G = camY + 0.20
    local k = 0.0787

    local rs = scene:GetRootGameObjects()
    local doomed = {}
    local function collect(t, d)
      if d > 12 then return end
      local o = t.gameObject
      if o.name:find("^C4_") then table.insert(doomed, o) end
      for i = 0, t.childCount - 1 do collect(t:GetChild(i), d + 1) end
    end
    for i = 0, rs.Length - 1 do local o = rs:get_Item(i); if o then collect(o.transform, 0) end end
    for _, o in ipairs(doomed) do pcall(function() CS.UnityEngine.Object.Destroy(o) end) end

    local function slab(name, xoff, dz, w, depth, frac, rgb)
      if dz < 5.6 then dz = 5.6 end
      local z = camZ + dz
      local topY = camY + dz * k * frac
      if topY < G + 0.10 then topY = G + 0.10 end
      local h = topY - (G - 0.8)
      local o = go.CreatePrimitive(prim.Cube)
      o.name = name
      o.transform.position = v3(camX + xoff, (G - 0.8) + h/2, z)
      o.transform.localScale = v3(w, h, depth)
      local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
      if mr and sh then
        local m = CS.UnityEngine.Material(sh)
        m:SetColor("_BaseColor", CS.UnityEngine.Color(rgb[1], rgb[2], rgb[3], 1.0))
        mr.material = m
      end
      return o
    end

    slab("C4_WALL_L", -5.0, 8.0, 1.6, 14.0, 0.90, {0.52,0.26,0.22})
    slab("C4_WALL_R",  5.0, 8.0, 1.6, 14.0, 0.90, {0.24,0.36,0.44})
    slab("C4_DECK_A",  0.0, 9.0, 10.0, 5.0, 0.90, {0.74,0.68,0.52})
    slab("C4_GAP",     0.0, 13.5, 10.0, 2.0, 0.22, {0.09,0.09,0.13})
    slab("C4_DECK_B",  0.0, 17.5, 10.0, 5.0, 0.90, {0.74,0.68,0.52})
    slab("C4_RULER_REST", -3.5, 9.5, 1.0, 6.5, 0.55, {0.84,0.68,0.46})
    slab("C4_TOWN",    0.0, 22.0, 4.5, 3.5, 0.90, {0.62,0.58,0.44})
    for i = 1, 4 do
      local s = slab("C4_RAMP_"..i, 0.0, 10.5 + i*1.3, 3.0, 1.3, 0.85, {0.90,0.76,0.46})
      s:SetActive(false)
    end
    -- THE AFFORDANCE: a barrier band across the gate line, visible while locked
    local band = slab("C4_BARRIER", 0.0, 13.5, 10.0, 0.35, 0.75, {0.95,0.42,0.20})
    band:SetActive(true)
    -- destination lamps, off until arrival
    for i = 1, 3 do
      local l = slab("C4_LAMP_"..i, -1.5 + (i-1)*1.5, 22.5, 0.5, 0.5, 0.70, {0.28,0.26,0.20})
      l:SetActive(false)
    end
    r.built = "gated scene + barrier + lamps"
  else
    r.built = "already present"
  end

  -- ---------- mode ----------
  local mode = "tick"
  if c4_mode ~= nil then mode = c4_mode end

  local solvedFlag = find("C4_RAMP_1")
  local solved = solvedFlag and solvedFlag.activeSelf or false

  if mode == "activate" then
    local rest = find("C4_RULER_REST")
    if rest then rest:SetActive(false) end
    local shown = 0
    for i = 1, 4 do
      local s = find("C4_RAMP_"..i)
      if s then s:SetActive(true); shown = shown + 1 end
    end
    local band = find("C4_BARRIER")
    if band then band:SetActive(false) end       -- affordance changes
    local town = find("C4_TOWN")
    if town then
      local mr = town:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
      if mr and mr.material then
        pcall(function() mr.material:SetColor("_BaseColor", CS.UnityEngine.Color(0.86,0.80,0.52,1.0)) end)
      end
    end
    for i = 1, 3 do
      local l = find("C4_LAMP_"..i)
      if l then l:SetActive(true) end
    end
    r.result = "ACTIVATED"
    r.rampShown = shown
    return
  end

  -- tick: enforce, with feedback instead of a silent warp
  local player = find("Player_1")
  if not player then r.error = "no player" return end
  local pp = player.transform.position
  r.playerZ = string.format("%.2f", pp.z)
  r.solved = tostring(solved)

  local gateZ = find("C4_BARRIER")
  local gateZpos = gateZ and gateZ.transform.position.z or (pp.z + 10)
  r.gateWorldZ = string.format("%.2f", gateZpos)

  if (not solved) and pp.z > (gateZpos + 1.0) then
    -- the affordance is already visible (barrier band). Now return with a reason.
    local rest = find("C4_RULER_REST")
    if rest then
      -- flash the ruler: make it briefly brighter so the eye is drawn to it
      local mr = rest:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
      if mr and mr.material then
        pcall(function() mr.material:SetColor("_BaseColor", CS.UnityEngine.Color(1.0,0.95,0.55,1.0)) end)
      end
    end
    player.transform.position = v3(pp.x, pp.y, gateZpos - 8.0)
    r.result = "REPELLED_WITH_FEEDBACK"
    r.feedback = "barrier band visible; ruler highlighted; returned to near side"
  else
    r.result = "OK"
  end
end)
if not ok then r.error = tostring(err) end
return r
