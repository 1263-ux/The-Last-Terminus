-- Isolate why the PLAYER camera does not draw geometry while a directed capture does.
-- Checks: all cameras present, cullingMask write test, and whether an object placed
-- at the exact view centre with a forced mask becomes visible.
local r = {}
local ok, err = pcall(function()
  local go = CS.UnityEngine.GameObject
  local camType = typeof(CS.UnityEngine.Camera)

  -- 1) enumerate EVERY camera, not just MainCamera tag
  local all = go.FindObjectsOfType and nil or nil
  local okf, cams = pcall(function() return go.FindGameObjectsWithTag("MainCamera") end)
  r.mainCamCount = okf and cams.Length or -1

  -- 2) decode cullingMask properly
  local e = cams:get_Item(0)
  local c = e:GetComponent(camType)
  local mask = c.cullingMask
  r.maskRaw = tostring(mask)
  r.maskAsUint = string.format("%08X", mask & 0xFFFFFFFF)
  local bits = {}
  for L = 0, 31 do
    if (mask & (1 << L)) ~= 0 then table.insert(bits, L) end
  end
  r.layersOn = table.concat(bits, ",")

  -- 3) try forcing the mask to everything
  local okw = pcall(function() c.cullingMask = -1 end)
  r.maskWriteOk = tostring(okw)
  r.maskAfter = tostring(c.cullingMask)

  -- 4) does the player object itself render? It clearly does (we see the avatar).
  --    So something about our created objects differs. Compare their layers.
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local rs = scene:GetRootGameObjects()
  local info = {}
  local function walk(t, d)
    if d > 12 then return end
    local o = t.gameObject
    local nm = o.name
    if nm == "Player_1" or nm:find("^C4_GATE") or nm:find("^C4_BOOK_L") then
      local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
      local sh = "none"
      if mr and mr.material and mr.material.shader then sh = mr.material.shader.name end
      table.insert(info, string.format("%s layer=%d layerName=%s shader=%s",
        nm, o.layer, CS.UnityEngine.LayerMask.LayerToName(o.layer), sh))
    end
    for i = 0, t.childCount - 1 do walk(t:GetChild(i), d + 1) end
  end
  for i = 0, rs.Length - 1 do local o = rs:get_Item(i); if o then walk(o.transform, 0) end end
  r.objects = table.concat(info, " ;; ")
end)
if not ok then r.error = tostring(err) end
return r
