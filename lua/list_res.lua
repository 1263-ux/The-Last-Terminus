local r = {}
local ok, err = pcall(function()
  local R = CS.UnityEngine.Resources
  local all = R.LoadAll("")
  r.total = tostring(all.Length)
  local names, hits = {}, {}
  for i = 0, all.Length - 1 do
    local o = all:get_Item(i)
    if o then
      local nm = o.name or "?"
      if #names < 40 then table.insert(names, nm) end
      local ln = nm:lower()
      if ln:find("ruler") or ln:find("bridge") or ln:find("town") or ln:find("shopfront")
         or ln:find("desk") or ln:find("lamp") or ln:find("harbor") then
        table.insert(hits, nm .. "(" .. o:GetType().Name .. ")")
      end
    end
  end
  r.sample = table.concat(names, ",")
  r.hits = table.concat(hits, " ;; ")
  r.hitCount = #hits
end)
if not ok then r.error = tostring(err) end
return r
