local r={}
local ok,err=pcall(function()
  local scene=CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local roots=scene:GetRootGameObjects()
  local n=0
  local doomed={}
  local function walk(t,d)
    if d>12 then return end
    local o=t.gameObject
    if o.name:find("BLOCK") or o.name:find("GATE_") or o.name:find("^C4_") or o.name:find("^PROBE") then table.insert(doomed,o) end
    for i=0,t.childCount-1 do walk(t:GetChild(i),d+1) end
  end
  for i=0,roots.Length-1 do local o=roots:get_Item(i); if o then walk(o.transform,0) end end
  for _,o in ipairs(doomed) do pcall(function() CS.UnityEngine.Object.Destroy(o) end); n=n+1 end
  r.removed=n
end)
if not ok then r.error=tostring(err) end
return r
