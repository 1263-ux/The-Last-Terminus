-- Directly invoke the bound script's callback to verify the Lua logic itself.
-- self.gameObject is the host node (map-desk); hiding it would hide the map, so
-- for this probe just report what the script can see.
local r = {}
local ok, err = pcall(function()
  r.hasSelf = self ~= nil
  r.hasGO = self ~= nil and self.gameObject ~= nil
  if self and self.gameObject then
    r.goName = tostring(self.gameObject.name)
    r.activeBefore = tostring(self.gameObject.activeSelf)
  end
  r.canCall = type(OnPlayerTriggerEnter) == "function"
end)
if not ok then r.error = tostring(err) end
return r
