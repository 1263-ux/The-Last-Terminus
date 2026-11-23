local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local cams = go.FindGameObjectsWithTag("MainCamera")
  local entry = cams:get_Item(0)
  r.name = entry.name
  local comps = entry:GetComponents(typeof(CS.UnityEngine.Component))
  r.compCount = comps.Length
  local names = {}
  for i = 0, comps.Length - 1 do
    local c = comps:get_Item(i)
    if c then table.insert(names, c:GetType().Name) end
  end
  r.components = table.concat(names, ",")
end)
if not ok then r.error = tostring(err) end
return r
