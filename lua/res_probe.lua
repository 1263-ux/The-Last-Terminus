-- Last technical route: maybe the scene prefab lives in Resources / an AssetBundle
-- that the runtime can load synchronously. If so I can instantiate the real level
-- myself rather than waiting for the loader.
local r = {}
local ok, err = pcall(function()
  local R = CS.UnityEngine.Resources
  local tries = {}
  local names = { "scene", "Scene", "level", "Level", "world", "WorldRoot",
                  "main", "Main", "HamletPreview", "sceneData" }
  for _, n in ipairs(names) do
    local oo, v = pcall(function() return R.Load(n) end)
    if oo and v then table.insert(tries, n .. "=FOUND") end
  end
  r.resources = (#tries > 0) and table.concat(tries, ",") or "nothing loadable by name"

  -- enumerate what IS in Resources if the API allows
  local oo2, all = pcall(function() return R.LoadAll("") end)
  r.loadAllOk = tostring(oo2)
  if oo2 and all then r.loadAllCount = tostring(all.Length) end

  -- AssetBundle: any loaded bundles?
  local AB = CS.UnityEngine.AssetBundle
  local oo3, bundles = pcall(function() return AB.GetAllLoadedAssetBundles() end)
  r.loadedBundles = oo3 and tostring(bundles) or ("err:" .. tostring(bundles))
end)
if not ok then r.error = tostring(err) end
return r
