-- Can the camera follow-distance cap be raised? This is the single gate on
-- whether 21-27 m props can ever be framed from close range (plan S2).
-- If the field is driven every frame the write will be reverted; we check.
local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local cams = go.FindGameObjectsWithTag("MainCamera")
  local entry = cams:get_Item(0)
  local comps = entry:GetComponents(typeof(CS.UnityEngine.Component))

  local tpc = nil
  for i = 0, comps.Length - 1 do
    local c = comps:get_Item(i)
    if c and c:GetType().Name == "ThirdPersonCameraController" then tpc = c break end
  end
  if not tpc then r.error = "controller not found" return end

  local ty = tpc:GetType()
  local flags = CS.System.Reflection.BindingFlags.Public
             + CS.System.Reflection.BindingFlags.NonPublic
             + CS.System.Reflection.BindingFlags.Instance

  local function field(name)
    return ty:GetField(name, flags)
  end

  local fMax = field("_followMaxDistance")
  local fPitch = field("_pitch")
  if not fMax then r.error = "no _followMaxDistance" return end

  r.beforeMax = tostring(fMax:GetValue(tpc))
  r.beforePitch = fPitch and tostring(fPitch:GetValue(tpc)) or "n/a"
  r.fieldType = tostring(fMax.FieldType.Name)

  -- Lua numbers are Doubles; Unity fields are Single. Try several construction
  -- routes because this bridge is picky about what counts as a Single:
  --   1) CS.System.Single(x)      -- may not exist as a callable
  --   2) typed array round-trip   -- needs typeof for CreateInstance
  local function asSingle(x)
    local ok1, v1 = pcall(function() return CS.System.Single(x) end)
    if ok1 and v1 ~= nil then return v1 end
    local ok2, v2 = pcall(function()
      local t = typeof(CS.System.Single)
      local arr = CS.System.Array.CreateInstance(t, 1)
      arr:SetValue(x, 0)
      return arr:GetValue(0)
    end)
    if ok2 and v2 ~= nil then return v2 end
    return nil
  end

  local probe = asSingle(35.0)
  r.singleOk = probe ~= nil
  if not r.singleOk then
    r.note = "could not construct Single; write skipped"
    return
  end

  -- Attempt to widen the follow cap so a 27 m book can be framed from ~30 m.
  local okw, werr = pcall(function() fMax:SetValue(tpc, asSingle(35.0)) end)
  r.writeOk = okw
  if not okw then r.writeErr = tostring(werr) end
  r.afterMaxImmediate = tostring(fMax:GetValue(tpc))

  -- Also try nudging pitch to -20 (player looks up), which the clamp allows.
  if fPitch then
    local okp, perr = pcall(function() fPitch:SetValue(tpc, asSingle(-20.0)) end)
    r.pitchWriteOk = okp
    if not okp then r.pitchWriteErr = tostring(perr) end
    r.afterPitchImmediate = tostring(fPitch:GetValue(tpc))
  end
end)
if not ok then r.error = tostring(err) end
return r
