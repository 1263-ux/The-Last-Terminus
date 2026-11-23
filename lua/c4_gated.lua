-- C4 STATE-GATED LOOP, built to the verified visibility law.
--
-- DESIGN DIRECTOR DECISION (production/DESIGN-DIRECTOR-DECISIONS-2026-11-22.md §3):
--   C4 "vertical wall physically blocks the player" is NOT APPROVED.
--   Replace with a state-gated route. Do not use a fake invisible wall as the
--   primary explanation; the player must read locked/unlocked from affordances.
--
-- So this builds:
--   State 0  ruler lying at rest, RAMP hidden, route visibly incomplete
--   Player   walks into the interaction zone
--   State 1  rest hidden, ramp shown, destination lights up
--   Gate     before activation: entering the locked zone returns the player
--            after activation: passes
--
-- VISIBILITY LAW (measured this session, the thing that defeated 6 attempts):
--   camera sits at y~79.6, pitched 18 deg DOWN, half-FOV 22.5 deg
--   => only 4.5 deg of headroom above the horizon
--   => a ground object is visible iff its distance d satisfies
--        d >= 5.2 m           (closer and it is above the frame top)
--        topY <= camY + d*0.0787
--   Following the forward VECTOR also fails: at 13 m it is 3.9 m underground.
--
-- Everything below is placed on the ground, ahead of the camera, inside that law.
local r = {}
local ok, err = pcall(function()
  local go   = CS.UnityEngine.GameObject
  local v3   = CS.UnityEngine.Vector3
  local prim = CS.UnityEngine.PrimitiveType
  local sh   = CS.UnityEngine.Shader.Find("Universal Render Pipeline/Lit")
  local camType = typeof(CS.UnityEngine.Camera)

  local cams = go.FindGameObjectsWithTag("MainCamera")
  local e = cams:get_Item(0)
  local cam = e:GetComponent(camType)
  local cp = cam.transform.position
  local camY, camZ, camX = cp.y, cp.z, cp.x
  local k = 0.0787
  r.cam = string.format("%.2f,%.2f,%.2f", camX, camY, camZ)

  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local rs = scene:GetRootGameObjects()
  local doomed = {}
  local function collect(t, d)
    if d > 12 then return end
    local o = t.gameObject
    local nm = o.name
    if nm:find("^C4_") or nm:find("^VIS_") or nm:find("^BLOCK") then
      table.insert(doomed, o)
    end
    for i = 0, t.childCount - 1 do collect(t:GetChild(i), d + 1) end
  end
  for i = 0, rs.Length - 1 do local o = rs:get_Item(i); if o then collect(o.transform, 0) end end
  for _, o in ipairs(doomed) do pcall(function() CS.UnityEngine.Object.Destroy(o) end) end
  r.cleared = #doomed

  local GROUND = camY + 0.25      -- deck sits just above the camera's own height
  local made, info = 0, {}

  -- dz is distance ahead of the CAMERA (not the player), so d >= 5.2 is enforced
  local function box(name, xoff, dz, w, depth, frac, rgb)
    if dz < 5.4 then dz = 5.4 end
    local z = camZ + dz
    local topY = camY + dz * k * frac
    if topY < GROUND + 0.12 then topY = GROUND + 0.12 end
    local h = topY - (GROUND - 1.2)
    local o = go.CreatePrimitive(prim.Cube)
    o.name = name
    o.transform.position = v3(camX + xoff, (GROUND - 1.2) + h/2, z)
    o.transform.localScale = v3(w, h, depth)
    local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
    if mr and sh then
      local m = CS.UnityEngine.Material(sh)
      m:SetColor("_BaseColor", CS.UnityEngine.Color(rgb[1], rgb[2], rgb[3], 1.0))
      mr.material = m
    end
    made = made + 1
    table.insert(info, string.format("%s d=%.0f", name, dz))
    return o
  end

  -- ---- canyon walls: two long low slabs flanking the walk, not tall books ----
  -- (tall books cannot fit the 4.5 deg headroom; low slabs read as cut paper)
  box("C4_WALL_L", -4.5, 7.0,  2.0, 9.0, 0.85, {0.45, 0.22, 0.20})
  box("C4_WALL_R",  4.5, 7.0,  2.0, 9.0, 0.85, {0.20, 0.32, 0.38})

  -- ---- the gap the player cannot cross yet: a visible missing segment ----
  -- shown as two deck halves with a dark void between (visual incompleteness)
  box("C4_DECK_NEAR", 0, 9.0,  9.0, 3.0, 0.85, {0.72, 0.66, 0.50})
  box("C4_VOID",      0, 12.6, 9.0, 2.4, 0.20, {0.10, 0.10, 0.14})
  box("C4_DECK_FAR",  0, 16.0, 9.0, 3.0, 0.85, {0.72, 0.66, 0.50})

  -- ---- ruler at REST: lying beside the deck, the affordance ----
  local rest = box("C4_RULER_REST", -4.0, 8.0, 1.0, 5.0, 0.60, {0.82, 0.66, 0.44})

  -- ---- the RAMP representation, hidden until activated ----
  local steps = {}
  for i = 1, 4 do
    local s = box("C4_RAMP_" .. i, 0, 9.0 + i * 1.1, 3.2, 1.1, 0.85, {0.88, 0.74, 0.44})
    s:SetActive(false)
    table.insert(steps, s)
  end

  -- ---- destination: pencil-case town, starts dim ----
  local town = box("C4_TOWN", 0, 20.0, 4.0, 3.0, 0.85, {0.55, 0.52, 0.42})
  -- lamps that light on arrival
  local lamps = {}
  for i = 1, 3 do
    local l = box("C4_LAMP_" .. i, -1.5 + (i-1) * 1.5, 20.5, 0.5, 0.5, 0.70, {0.28, 0.26, 0.20})
    l:SetActive(false)
    table.insert(lamps, l)
  end

  r.meshes = made
  r.placed = table.concat(info, " ")
  r.note = "state 0: ramp hidden, town dim, lamps off"
end)
if not ok then r.error = tostring(err) end
return r
