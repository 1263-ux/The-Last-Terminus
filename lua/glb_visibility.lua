local r = {}
local ok, err = pcall(function()
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local out = {}
  local function walk(t, d)
    if d > 12 then return end
    local o = t.gameObject
    local nm = o.name
    if nm:find("^WB_") then
      local mr = o:GetComponent(typeof(CS.UnityEngine.MeshRenderer))
      if mr then
        local m = mr.material
        local col = m and m:GetColor("_Color") or nil
        local a = col and col.a or -1
        table.insert(out, string.format("%s visible=%s a=%.2f shader=%s",
          nm, tostring(mr.isVisible), a, (m and m.shader and m.shader.name) or "nil"))
      else
        table.insert(out, nm .. " no MeshRenderer")
      end
    end
    for i = 0, t.childCount - 1 do walk(t:GetChild(i), d + 1) end
  end
  local rs = scene:GetRootGameObjects()
  for i = 0, rs.Length - 1 do local o = rs:get_Item(i); if o then walk(o.transform, 0) end end
  r.count = #out
  r.items = table.concat(out, " ;; ")
end)
if not ok then r.error=tostring(err) end
return r
