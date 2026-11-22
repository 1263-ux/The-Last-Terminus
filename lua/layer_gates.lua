-- Test the layer hypothesis.
--
-- Measured: player layer = 8 (Actor), Rigidbody isKinematic = true,
-- useGravity = false, and the blocker sits on layer 0 (Default). A kinematic
-- body is moved by script, not by the solver, so whether it stops at an
-- obstacle depends on which layers that script queries. The obstacle being on
-- Default while the actor is on Actor is the leading explanation for every
-- penetration we saw.
--
-- This places three identical cubes on three different layers, all ahead of the
-- player, so one walk tells us which layer (if any) the controller respects.
local r = {}
local ok, err = pcall(function()
  local go   = CS.UnityEngine.GameObject
  local v3   = CS.UnityEngine.Vector3
  local prim = CS.UnityEngine.PrimitiveType
  local X    = 119.741669

  local function cube(name, z, layer)
    local o = go.CreatePrimitive(prim.Cube)
    o.name = name
    o.transform.position = v3(X, 81.0, z)
    o.transform.localScale = v3(8.0, 2.0, 1.0)
    o.layer = layer
    return o
  end

  -- Sequential gates: the player meets these in order as it walks +Z.
  cube("GATE_L0_DEFAULT", 94.0, 0)    -- Default
  cube("GATE_L8_ACTOR",   99.0, 8)    -- same layer as the player
  cube("GATE_L2_IGNORE", 104.0, 2)    -- Ignore Raycast

  r.placed = "GATE_L0_DEFAULT@94, GATE_L8_ACTOR@99, GATE_L2_IGNORE@104"
  r.allScale = "8 x 2 x 1"
end)
if not ok then r.error = tostring(err) end
return r
