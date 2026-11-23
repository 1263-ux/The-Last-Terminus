-- Hunt for renderable engine shaders. The avatar renders with
-- Douyin/AI/Cartoon/AvatarNPR_AIHaiHai, so this build may only draw its own
-- shader family. Try a list of plausible names and report which resolve.
local r = {}
local ok, err = pcall(function()
  local names = {
    "Douyin/AI/Cartoon/AvatarNPR_AIHaiHai",
    "Douyin/AI/Cartoon/AvatarNPR",
    "Douyin/AI/Cartoon/Lit",
    "Douyin/AI/Lit",
    "Douyin/AI/Common",
    "Douyin/AI/Common/Lit",
    "Douyin/Common/Lit",
    "Douyin/AI/Unlit",
    "Douyin/AI/Lambert",
    "Douyin/WPrefab/Lit",
    "Universal Render Pipeline/Simple Lit",
    "Universal Render Pipeline/Baked Lit",
  }
  local found, missing = {}, 0
  for _, n in ipairs(names) do
    local oks, sh = pcall(function() return CS.UnityEngine.Shader.Find(n) end)
    if oks and sh then
      table.insert(found, n .. " [supported=" .. tostring(sh.isSupported) .. "]")
    else
      missing = missing + 1
    end
  end
  r.found = table.concat(found, " ;; ")
  r.foundCount = #found
  r.missingCount = missing

  -- What shader does an imported GLB object use? Those DID render in the
  -- directed capture, so their shader is a known-good reference.
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local rs = scene:GetRootGameObjects()
  local glbShaders = {}
  local function walk(t, d)
    if d > 14 then return end
    local o = t.gameObject
    if o.name:find("^WB_") then
      local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
      if mr and mr.material and mr.material.shader then
        table.insert(glbShaders, o.name .. "=" .. mr.material.shader.name)
      end
    end
    for i = 0, t.childCount - 1 do walk(t:GetChild(i), d + 1) end
  end
  for i = 0, rs.Length - 1 do local o = rs:get_Item(i); if o then walk(o.transform, 0) end end
  r.glbShaders = table.concat(glbShaders, " ;; ")
  r.glbCount = #glbShaders
end)
if not ok then r.error = tostring(err) end
return r
