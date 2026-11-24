-- Can the runtime read the scene.data payload directly? If yes, I can rebuild the
-- imported hierarchy by hand even if the loader does not.
local r = {}
local ok, err = pcall(function()
  -- Unity WebGL cannot read arbitrary disk, but the CLI host may expose a bridge.
  r.hasFile = tostring(CS.System.IO ~= nil)
  r.hasFileIO = tostring(CS.System.IO.File ~= nil)
  if CS.System.IO and CS.System.IO.File and CS.System.IO.File.Exists then
    local p = "C:/Users/XiongCong/AppData/Roaming/AI World Creator/projects/project-2ab3d89a-6b01-49d6-8170-eb9dcc2152e6/scene.data"
    local okx, ex = pcall(function() return CS.System.IO.File.Exists(p) end)
    r.canRead = okx and tostring(ex) or ("err:" .. tostring(ex))
  end
  -- Resources-based loading as an alternative route
  r.hasResources = tostring(CS.UnityEngine.Resources ~= nil)
  r.hasAssetBundle = tostring(CS.UnityEngine.AssetBundle ~= nil)
  r.hasAddressables = tostring(CS.UnityEngine.Addressables ~= nil)
end)
if not ok then r.error = tostring(err) end
return r
