-- Deterministic camera read. FindGameObjectsWithTag -> get_Item(0) works;
-- GetComponent needs a resolved System.Type, obtained via
-- typeof(CS.UnityEngine.Camera) rather than the class table itself.
local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local cams = go.FindGameObjectsWithTag("MainCamera")
  r.count = cams.Length

  local entry = cams:get_Item(0)
  r.entryName = entry.name

  local camType = typeof(CS.UnityEngine.Camera)
  r.camType = tostring(camType)

  local c = entry:GetComponent(camType)
  if not c then r.error = "no Camera component" return end

  local p = c.transform.position
  local f = c.transform.forward
  r.camPos = string.format("%.3f,%.3f,%.3f", p.x, p.y, p.z)
  r.camFwd = string.format("%.4f,%.4f,%.4f", f.x, f.y, f.z)
  r.fov = string.format("%.1f", c.fieldOfView)
  r.near = string.format("%.2f", c.nearClipPlane)
  r.far = string.format("%.1f", c.farClipPlane)
end)
if not ok then r.error = tostring(err) end
return r
