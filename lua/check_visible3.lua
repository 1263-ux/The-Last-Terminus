local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local function find(n)
    local hit=nil
    local function w(t,d) if d>12 or hit then return end local o=t.gameObject
      if o.name==n then hit=o return end
      for i=0,t.childCount-1 do w(t:GetChild(i),d+1) end end
    local rs=scene:GetRootGameObjects()
    for i=0,rs.Length-1 do local o=rs:get_Item(i); if o then w(o.transform,0) end; if hit then break end end
    return hit
  end
  local o = find("C4_GATE_VISUAL")
  if not o then r.error="not found" return end
  local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
  r.isVisible = tostring(mr.isVisible)
  r.enabled = tostring(mr.enabled)
  r.layer = o.layer
  r.activeInHierarchy = tostring(o.activeInHierarchy)
  local wp = o.transform.position
  r.worldPos = string.format("%.2f,%.2f,%.2f", wp.x, wp.y, wp.z)
  local cams = go.FindGameObjectsWithTag("MainCamera")
  local e = cams:get_Item(0)
  local c = e:GetComponent(typeof(CS.UnityEngine.Camera))
  local cp = c.transform.position
  r.camPos = string.format("%.2f,%.2f,%.2f", cp.x, cp.y, cp.z)
  local dx, dy, dz = wp.x-cp.x, wp.y-cp.y, wp.z-cp.z
  r.distance = string.format("%.2f", math.sqrt(dx*dx+dy*dy+dz*dz))
  local f = c.transform.forward
  local dot = dx*f.x + dy*f.y + dz*f.z
  r.inFront = tostring(dot > 0)
  r.dotForward = string.format("%.2f", dot)
  local m = mr.material
  local okc, col = pcall(function() return m:GetColor("_Color") end)
  r.colorAfterFix = okc and string.format("%.2f,%.2f,%.2f,a=%.2f", col.r,col.g,col.b,col.a) or "fail"
  r.shader = m.shader and m.shader.name or "nil"
end)
if not ok then r.error=tostring(err) end
return r
