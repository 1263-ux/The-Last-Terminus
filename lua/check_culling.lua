local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local cams = go.FindGameObjectsWithTag("MainCamera")
  if not cams or cams.Length == 0 then r.error="no camera" return end
  local e = cams:get_Item(0)
  local c = e:GetComponent(typeof(CS.UnityEngine.Camera))
  if not c then r.error="no Camera comp" return end
  r.camName = e.name
  r.cullingMask = tostring(c.cullingMask)
  r.cullingMaskMeaning = "bitmask; 1 = only Default layer"
  -- decode a few layers
  local interesting = {0,2,5,8,9,10}
  local out = {}
  for _, L in ipairs(interesting) do
    local bit = 1 << L
    local on = (c.cullingMask & bit) ~= 0
    table.insert(out, L .. "=" .. tostring(on))
  end
  r.layersEnabled = table.concat(out, " ")
  r.clearFlags = tostring(c.clearFlags)
  r.enabled = tostring(c.enabled)
  r.depth = tostring(c.depth)
end)
if not ok then r.error=tostring(err) end
return r
