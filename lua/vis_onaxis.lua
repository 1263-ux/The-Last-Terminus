-- Place three cubes EXACTLY on the camera forward ray at 5, 9 and 13 m.
-- On-axis means they are at the centre of the frame by definition; if anything
-- other than culling/masking is wrong, this MUST show them.
local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local v3 = CS.UnityEngine.Vector3
  local prim = CS.UnityEngine.PrimitiveType
  local sh = CS.UnityEngine.Shader.Find("Universal Render Pipeline/Lit")
  local camType = typeof(CS.UnityEngine.Camera)

  local cams = go.FindGameObjectsWithTag("MainCamera")
  local e = cams:get_Item(0)
  local cam = e:GetComponent(camType)
  local cp = cam.transform.position
  local cf = cam.transform.forward
  r.cam = string.format("%.2f,%.2f,%.2f", cp.x, cp.y, cp.z)

  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local rs = scene:GetRootGameObjects()
  local doomed = {}
  local function collect(t, d)
    if d > 12 then return end
    local o = t.gameObject
    if o.name:find("^VIS_") or o.name:find("^C4_") then table.insert(doomed, o) end
    for i = 0, t.childCount - 1 do collect(t:GetChild(i), d + 1) end
  end
  for i = 0, rs.Length - 1 do local o = rs:get_Item(i); if o then collect(o.transform, 0) end end
  for _, o in ipairs(doomed) do pcall(function() CS.UnityEngine.Object.Destroy(o) end) end

  local made = 0
  local function onAxis(name, dist, size, rgb)
    local x = cp.x + cf.x * dist
    local y = cp.y + cf.y * dist
    local z = cp.z + cf.z * dist
    local o = go.CreatePrimitive(prim.Cube)
    o.name = name
    o.transform.position = v3(x, y, z)
    o.transform.localScale = v3(size, size, size)
    local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
    if mr and sh then
      local m = CS.UnityEngine.Material(sh)
      m:SetColor("_BaseColor", CS.UnityEngine.Color(rgb[1], rgb[2], rgb[3], 1.0))
      mr.material = m
    end
    made = made + 1
    return string.format("%s@(%.1f,%.1f,%.1f)", name, x, y, z)
  end

  local pos = {}
  table.insert(pos, onAxis("VIS_A_5M",  5.0, 0.8, {0.95, 0.20, 0.15}))
  table.insert(pos, onAxis("VIS_B_9M",  9.0, 1.2, {0.20, 0.90, 0.30}))
  table.insert(pos, onAxis("VIS_C_13M", 13.0, 1.6, {0.25, 0.45, 0.95}))
  r.placed = table.concat(pos, " ")
  r.meshes = made
end)
if not ok then r.error = tostring(err) end
return r
