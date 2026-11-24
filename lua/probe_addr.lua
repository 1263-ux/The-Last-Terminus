-- Probe the Addressables route: if the CLI stores imported GLBs in an
-- Addressables catalogue, loading by key would let me instantiate the real kit
-- asset even though the scene loader does not.
local r = {}
local ok, err = pcall(function()
  local ab = CS.UnityEngine.Addressables

  -- what top-level types exist?
  local names = {}
  local okc, v = pcall(function()
    for k, _ in pairs(ab) do
      if type(k) == "string" then table.insert(names, k) end
    end
  end)
  r.types = okc and table.concat(names, ",") or "enumeration failed"

  -- try the canonical entry points
  local function try(label, fn)
    local o, res = pcall(fn)
    r[label] = o and ("ok:" .. tostring(res)) or ("err:" .. tostring(res))
  end
  try("AddressablesType", function() return tostring(ab.Addressables) end)
  try("LoadAssetAsync", function() return tostring(ab.Addressables and ab.Addressables.LoadAssetAsync) end)
end)
if not ok then r.error = tostring(err) end
return r
