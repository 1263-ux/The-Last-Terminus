local r = {}
local ok, err = pcall(function()
  local scene = CS.UnityEngine.SceneManagement.SceneManager.GetActiveScene()
  local rs = scene:GetRootGameObjects()
  local found = {}
  local function walk(t, d)
    if d > 16 then return end
    local nm = t.gameObject.name
    if nm:find("desk") or nm:find("map") or nm:find("previewGameRoot") then
      local p=t.position
      table.insert(found, string.format("%s d=%d pos=%.1f,%.1f,%.1f active=%s ch=%d",
        nm,d,p.x,p.y,p.z,tostring(t.gameObject.activeSelf),t.childCount))
    end
    for i=0,t.childCount-1 do walk(t:GetChild(i),d+1) end
  end
  for i=0,rs.Length-1 do local o=rs:get_Item(i); if o then walk(o.transform,0) end end
  r.hits=table.concat(found," | ")
  r.count=#found
end)
if not ok then r.error=tostring(err) end
return r
