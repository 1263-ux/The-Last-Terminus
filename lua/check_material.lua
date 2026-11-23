-- Why is nothing visible despite: correct culling mask, enabled renderer,
-- correct geometry? Inspect the material and shader on a created cube.
local r = {}
local ok, err = pcall(function()
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

  local o = find("C4_GATE_VISUAL") or find("C4_VILLAGE")
  if not o then r.error="no C4 object found" return end
  r.obj = o.name
  r.activeSelf = tostring(o.activeSelf)

  local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
  if not mr then r.renderer="nil" return end
  r.rendererEnabled = tostring(mr.enabled)
  r.isVisible = tostring(mr.isVisible)         -- engine thinks it's visible?
  r.shadowCasting = tostring(mr.shadowCastingMode)
  r.receiveShadows = tostring(mr.receiveShadows)

  local m = mr.material
  if not m then r.material="nil" return end
  r.materialName = m.name
  local sh = m.shader
  if sh then
    r.shaderName = sh.name
    r.shaderIsSupported = tostring(sh.isSupported)
    r.renderQueue = tostring(m.renderQueue)
  else
    r.shader = "nil"
  end

  -- sample the base color we tried to set
  local okc, col = pcall(function() return m:GetColor("_BaseColor") end)
  r.baseColor = okc and string.format("%.2f,%.2f,%.2f,%.2f", col.r, col.g, col.b, col.a) or "read failed"

  local bounds = mr.bounds
  r.boundsSize = string.format("%.1f,%.1f,%.1f", bounds.size.x, bounds.size.y, bounds.size.z)
end)
if not ok then r.error=tostring(err) end
return r
