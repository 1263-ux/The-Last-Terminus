local r = {}
local ok, err = pcall(function()
  r.hasCS = CS ~= nil
  if CS and CS.UnityEngine then
    local ok2, p = pcall(function()
      return CS.UnityEngine.GameObject.Find("Player_1")
    end)
    r.findOk = tostring(ok2)
    if ok2 and p then
      local v = p.transform.position
      r.player = string.format("%.2f,%.2f,%.2f", v.x, v.y, v.z)
    end
  end
end)
if not ok then r.error = tostring(err) end
return r
