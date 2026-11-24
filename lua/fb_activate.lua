local r={}
local ok,err=pcall(function()
  local scene=CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local function find(n)
    local hit=nil
    local function w(t,d) if d>14 or hit then return end local o=t.gameObject
      if o.name==n then hit=o return end
      for i=0,t.childCount-1 do w(t:GetChild(i),d+1) end end
    local rs=scene:GetRootGameObjects()
    for i=0,rs.Length-1 do local o=rs:get_Item(i); if o then w(o.transform,0) end; if hit then break end end
    return hit
  end
  local rest=find("C4_RULER_REST"); if rest then rest:SetActive(false) end
  local shown=0
  for i=1,4 do local s=find("C4_RAMP_"..i); if s then s:SetActive(true); shown=shown+1 end end
  local band=find("C4_BARRIER"); if band then band:SetActive(false) end
  local town=find("C4_TOWN")
  if town then local mr=town:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
    if mr and mr.material then pcall(function() mr.material:SetColor("_BaseColor", CS.UnityEngine.Color(0.86,0.80,0.52,1.0)) end) end end
  for i=1,3 do local l=find("C4_LAMP_"..i); if l then l:SetActive(true) end end
  r.result="ACTIVATED"; r.rampShown=shown
end)
if not ok then r.error=tostring(err) end
return r
