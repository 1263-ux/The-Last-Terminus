local r = {}
local ok, err = pcall(function()
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local rs = scene:GetRootGameObjects()
  local names = {}
  local function walk(t,d)
    if d>14 then return end
    local o=t.gameObject
    if o.name:find("deskworld") or o.name:find("map") or o.name:find("ruler") or o.name:find("STEP_") then
      local mc=0
      local cs=o:GetComponents(typeof(CS.UnityEngine.Component))
      for i=0,cs.Length-1 do
        local tn=cs:get_Item(i):GetType().Name
        if tn:find("Collider") then mc=mc+1 end
      end
      local p=t.position
      table.insert(names, string.format("%s pos=%.1f,%.1f,%.1f colliders=%d", o.name,p.x,p.y,p.z,mc))
    end
    for i=0,t.childCount-1 do walk(t:GetChild(i),d+1) end
  end
  for i=0,rs.Length-1 do local o=rs:get_Item(i); if o then walk(o.transform,0) end end
  r.found=table.concat(names," | ")
  r.count=#names
end)
if not ok then r.error=tostring(err) end
return r
