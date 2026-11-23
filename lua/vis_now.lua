local r={}
local ok,err=pcall(function()
  local scene=CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local out={}
  local function walk(t,d)
    if d>12 then return end
    local o=t.gameObject
    if o.name:find("^C4_") then
      local mr=o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
      local p=o.transform.position
      if mr then
        local m=mr.material
        local okc,col=pcall(function() return m:GetColor("_Color") end)
        table.insert(out, string.format("%s y=%.2f z=%.1f vis=%s a=%.2f",
          o.name,p.y,p.z,tostring(mr.isVisible), okc and col.a or -1))
      end
    end
    for i=0,t.childCount-1 do walk(t:GetChild(i),d+1) end
  end
  local rs=scene:GetRootGameObjects()
  for i=0,rs.Length-1 do local o=rs:get_Item(i); if o then walk(o.transform,0) end end
  r.items=table.concat(out," ;; ")
  r.n=#out
end)
if not ok then r.error=tostring(err) end
return r
