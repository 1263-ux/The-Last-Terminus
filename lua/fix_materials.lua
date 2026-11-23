-- ROOT CAUSE OF INVISIBILITY FOUND: the material alpha is 0.
--
-- Evidence from check_material.lua on C4_GATE_VISUAL:
--   shaderName   = Standard        (supported, so not a pipeline problem)
--   materialName = Standard (Instance)
--   isVisible    = false           (engine says not visible)
--   baseColor    = 0.00,0.00,0.00,0.00   <-- alpha ZERO = fully transparent
--
-- I had been setting "_BaseColor", which belongs to URP/Lit. The Standard shader
-- uses "_Color". Setting the wrong property left the material at its default
-- alpha of 0, so every object rendered as pure shadow.
--
-- This also explains why the shadow always worked: shadows use the geometry and
-- do not care about material alpha.
--
-- Fix: set both "_Color" and "_BaseColor" with alpha = 1, and force the
-- material to be opaque.
local r = {}
local ok, err = pcall(function()
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()

  local fixedList = {}
  local function fixOne(o, rgba)
    local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
    if not mr then return false end
    local m = mr.material
    if not m then return false end
    local c = CS.UnityEngine.Color(rgba[1], rgba[2], rgba[3], 1.0)
    pcall(function() m:SetColor("_Color", c) end)
    pcall(function() m:SetColor("_BaseColor", c) end)
    -- Standard shader opaque settings
    pcall(function() m:SetFloat("_Mode", 0) end)
    pcall(function() m:SetInt("_SrcBlend", 1) end)      -- One
    pcall(function() m:SetInt("_DstBlend", 0) end)      -- Zero
    pcall(function() m:SetInt("_ZWrite", 1) end)
    pcall(function() m:DisableKeyword("_ALPHABLEND_ON") end)
    pcall(function() m:DisableKeyword("_ALPHATEST_ON") end)
    pcall(function() m:EnableKeyword("_EMISSION") end)
    pcall(function() m:SetColor("_EmissionColor", CS.UnityEngine.Color(rgba[1]*0.25, rgba[2]*0.25, rgba[3]*0.25, 1.0)) end)
    m.renderQueue = -1
    local okc, col = pcall(function() return m:GetColor("_Color") end)
    return okc and col.a > 0.5
  end

  local palette = {
    C4_ERASER      = {0.85, 0.55, 0.55},
    C4_PENCIL      = {0.85, 0.72, 0.30},
    C4_BOOK_L      = {0.45, 0.22, 0.20},
    C4_BOOK_R      = {0.20, 0.32, 0.38},
    C4_GATE_VISUAL = {0.78, 0.74, 0.66},
    C4_RULER_REST  = {0.78, 0.62, 0.40},
    C4_VILLAGE     = {0.90, 0.85, 0.62},
    C4_EXIT        = {0.62, 0.64, 0.68},
    C4_RAMP_1 = {0.85,0.72,0.42}, C4_RAMP_2 = {0.85,0.72,0.42},
    C4_RAMP_3 = {0.85,0.72,0.42}, C4_RAMP_4 = {0.85,0.72,0.42},
    C4_RAMP_5 = {0.85,0.72,0.42}, C4_RAMP_6 = {0.85,0.72,0.42},
  }

  local function walk(t, d)
    if d > 12 then return end
    local o = t.gameObject
    local nm = o.name
    local base = nm
    if palette[base] then
      local okf = fixOne(o, palette[base])
      table.insert(fixedList, nm .. (okf and "=OK" or "=FAIL"))
    elseif nm:find("^C4_RAMP_") then
      local okf = fixOne(o, {0.85, 0.72, 0.42})
      if okf then table.insert(fixedList, nm .. "=OK") end
    end
    for i = 0, t.childCount - 1 do walk(t:GetChild(i), d + 1) end
  end

  local rs = scene:GetRootGameObjects()
  for i = 0, rs.Length - 1 do
    local o = rs:get_Item(i); if o then walk(o.transform, 0) end
  end

  r.fixedCount = #fixedList
  r.fixed = table.concat(fixedList, ",")
end)
if not ok then r.error = tostring(err) end
return r
