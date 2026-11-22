local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local v3 = CS.UnityEngine.Vector3
  local cams = go.FindGameObjectsWithTag("MainCamera")
  local e = cams:get_Item(0)
  local c = e:GetComponent(typeof(CS.UnityEngine.Camera))
  local cp = c.transform.position
  local f = c.transform.forward
  -- 8 m along the exact view axis
  local tx, ty, tz = cp.x + f.x*8, cp.y + f.y*8, cp.z + f.z*8
  local o = go.CreatePrimitive(CS.UnityEngine.PrimitiveType.Cube)
  o.name = "CENTRE_TEST"
  o.transform.position = v3(tx, ty, tz)
  o.transform.localScale = v3(2,2,2)
  local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
  local m = mr.material
  local col = CS.UnityEngine.Color(1.0, 0.1, 0.1, 1.0)
  pcall(function() m:SetColor("_Color", col) end)
  pcall(function() m:SetColor("_BaseColor", col) end)
  r.placed = string.format("%.2f,%.2f,%.2f", tx,ty,tz)
  r.camPos = string.format("%.2f,%.2f,%.2f", cp.x,cp.y,cp.z)
  r.camFwd = string.format("%.2f,%.2f,%.2f", f.x,f.y,f.z)
  r.expectVisible = "true"
end)
if not ok then r.error=tostring(err) end
return r
