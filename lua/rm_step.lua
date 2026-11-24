local r={}
local ok,err=pcall(function()
  local scene=CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local rs=scene:GetRootGameObjects()
  local doomed={}
  local function col(t,d) if d>12 then return end local o=t.gameObject
    if o.name:find("^STEP_") then table.insert(doomed,o) end
    for i=0,t.childCount-1 do col(t:GetChild(i),d+1) end end
  for i=0,rs.Length-1 do local o=rs:get_Item(i); if o then col(o.transform,0) end end
  for _,o in ipairs(doomed) do pcall(function() CS.UnityEngine.Object.Destroy(o) end) end
  r.removed=#doomed
end)
if not ok then r.error=tostring(err) end
return r
