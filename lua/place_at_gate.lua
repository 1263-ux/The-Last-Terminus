local r={}
local ok,err=pcall(function()
  local scene=CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local function find(n)
    local hit=nil
    local function w(t,d) if d>12 or hit then return end local o=t.gameObject
      if o.name==n then hit=o return end
      for i=0,t.childCount-1 do w(t:GetChild(i),d+1) end end
    local rs=scene:GetRootGameObjects()
    for i=0,rs.Length-1 do local o=rs:get_Item(i); if o then w(o.transform,0) end; if hit then break end end
    return hit
  end
  local p=find("Player_1")
  if p then p.transform.position=CS.UnityEngine.Vector3(119.741669,80.0,96.0) end
  r.done=true
end)
if not ok then r.error=tostring(err) end
return r
