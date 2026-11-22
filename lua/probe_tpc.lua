-- Enumerate the ThirdPersonCameraController's serialized fields so we know
-- whether the 18 deg look-down is a tunable property or a hard-coded constant.
-- This decides whether large props can ever be framed from the ground.
local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local cams = go.FindGameObjectsWithTag("MainCamera")
  local entry = cams:get_Item(0)
  local comps = entry:GetComponents(typeof(CS.UnityEngine.Component))

  local tpc = nil
  for i = 0, comps.Length - 1 do
    local c = comps:get_Item(i)
    if c and c:GetType().Name == "ThirdPersonCameraController" then
      tpc = c
      break
    end
  end
  if not tpc then r.error = "controller not found" return end
  r.found = true

  -- Member names via .NET reflection
  local ty = tpc:GetType()
  local flags = CS.System.Reflection.BindingFlags.Public
             + CS.System.Reflection.BindingFlags.NonPublic
             + CS.System.Reflection.BindingFlags.Instance
  local fields = ty:GetFields(flags)
  local out = {}
  local rOnly = CS.System.Reflection.BindingFlags.Public
             + CS.System.Reflection.BindingFlags.Instance
  local props = ty:GetProperties(rOnly)
  for i = 0, fields.Length - 1 do
    local f = fields:get_Item(i)
    local nm = f.Name
    if nm:lower():find("pitch") or nm:lower():find("angle")
       or nm:lower():find("height") or nm:lower():find("dist")
       or nm:lower():find("offset") or nm:lower():find("elevation") then
      local v = "?"
      local okv, val = pcall(function() return f:GetValue(tpc) end)
      if okv then v = tostring(val) end
      table.insert(out, nm .. "=" .. v)
    end
  end
  for i = 0, props.Length - 1 do
    local p = props:get_Item(i)
    local nm = p.Name
    if nm:lower():find("pitch") or nm:lower():find("angle")
       or nm:lower():find("height") or nm:lower():find("dist")
       or nm:lower():find("offset") or nm:lower():find("elevation") then
      local okv, val = pcall(function() return p:GetValue(tpc) end)
      table.insert(out, "[P]" .. nm .. "=" .. (okv and tostring(val) or "?"))
    end
  end
  r.hits = table.concat(out, " | ")
  r.totalFieldCount = fields.Length
end)
if not ok then r.error = tostring(err) end
return r
