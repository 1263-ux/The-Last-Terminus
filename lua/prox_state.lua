local r={}
local ok,err=pcall(function()
  r.active = self.gameObject.activeSelf
  r.goName = self.gameObject.name
  local p=CS.UnityEngine.GameObject.Find("Player_1")
  if p then
    local v=p.transform.position
    r.playerZ=string.format("%.2f", v.z)
  end
end)
if not ok then r.error=tostring(err) end
return r
