-- Which render pipeline is active, and which shaders are available?
-- Hypothesis: URP is active, so the built-in "Standard" shader on primitives does
-- not render in the game camera (though it may still cast shadows).
local r = {}
local ok, err = pcall(function()
  -- pipeline
  local okp, pipe = pcall(function()
    return CS.UnityEngine.Rendering.GraphicsSettings.currentRenderPipeline
  end)
  r.currentRP = okp and tostring(pipe) or ("ERR:" .. tostring(pipe))

  local okd, deft = pcall(function()
    return CS.UnityEngine.Rendering.GraphicsSettings.defaultRenderPipeline
  end)
  r.defaultRP = okd and tostring(deft) or ("ERR:" .. tostring(deft))

  -- which shaders are findable
  local names = { "Standard", "Universal Render Pipeline/Lit",
                  "Universal Render Pipeline/Unlit", "Unlit/Color",
                  "Sprites/Default", "Legacy Shaders/Diffuse" }
  local found = {}
  for _, n in ipairs(names) do
    local oks, sh = pcall(function() return CS.UnityEngine.Shader.Find(n) end)
    if oks and sh then
      table.insert(found, n .. "=FOUND")
    else
      table.insert(found, n .. "=nil")
    end
  end
  r.shaders = table.concat(found, " | ")
end)
if not ok then r.error = tostring(err) end
return r
