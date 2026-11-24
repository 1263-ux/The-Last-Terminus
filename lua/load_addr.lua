-- Try loading an imported kit asset through Addressables using known keys.
-- Asset ids seen earlier: 12211507385090 (original project), 12241720842754 (this project).
local r = {}
local ok, err = pcall(function()
  local ab = CS.UnityEngine.Addressables.Addressables
  local keys = { "12241720842754", "ruler-bridge-full-v01" }
  local reports = {}
  for _, k in ipairs(keys) do
    local okh, handle = pcall(function() return ab.LoadAssetAsync(k) end)
    if okh and handle then
      local st = "?"
      pcall(function() st = tostring(handle.Status) end)
      local okr, res = pcall(function() return handle.Result end)
      table.insert(reports, string.format("%s -> handle ok, status=%s, result=%s",
        k, st, okr and tostring(res) or "n/a"))
    else
      table.insert(reports, string.format("%s -> %s", k, tostring(handle)))
    end
  end
  r.reports = table.concat(reports, " ;; ")
end)
if not ok then r.error = tostring(err) end
return r
