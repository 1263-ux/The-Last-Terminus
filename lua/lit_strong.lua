-- Make the arrival feedback unmistakable: re-apply a strong warm gold, and
-- brighten the town face slightly so the whole facade reads as "now alive".
local r = {}
local ok, err = pcall(function()
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local function find(n)
    local hit=nil
    local function w(t,d) if d>12 or hit then return end local o=t.gameObject
      if o.name==n then hit=o return end
      for i=0,t.childCount-1 do w(t:GetChild(i),d+1) end end
    local rs=scene:GetRootGameObjects()
    for i=0,rs.Length-1 do local o=rs:get_Item(i); if o then w(o.transform,0) end; if hit then break end end
    return hit
  end
  local n = 0
  for k = 0, 4 do
    local wnd = find("PAPER_WIN_" .. k)
    if wnd then
      local mr = wnd:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
      if mr then
        local m = mr.material
        local c = CS.UnityEngine.Color(1.0, 0.82, 0.30, 1.0)
        pcall(function() m:SetColor("_BaseColor", c) end)
        pcall(function() m:SetColor("_Color", c) end)
        pcall(function() m:EnableKeyword("_EMISSION") end)
        pcall(function() m:SetColor("_EmissionColor", CS.UnityEngine.Color(1.0,0.75,0.25,1)) end)
        n = n + 1
      end
    end
  end
  -- roof edge glow
  local roof = find("PAPER_TOWN_ROOF")
  if roof then
    local mr = roof:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
    if mr and mr.material then
      pcall(function() mr.material:SetColor("_BaseColor", CS.UnityEngine.Color(0.95,0.45,0.35,1)) end)
    end
  end
  r.windows = n
end)
if not ok then r.error = tostring(err) end
return r
