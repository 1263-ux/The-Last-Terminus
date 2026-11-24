-- CALL the bound callback for real and observe whether it hides the host.
-- This distinguishes "script is callable" from "script logic actually works".
local r = {}
local ok, err = pcall(function()
  r.before = self.gameObject.activeSelf
  r.goName = self.gameObject.name
  -- invoke exactly what the trigger would call
  OnPlayerTriggerEnter(nil)
  r.after = self.gameObject.activeSelf
  r.secondCall = nil
  OnPlayerTriggerEnter(nil)   -- debounce check
  r.afterSecond = self.gameObject.activeSelf
end)
if not ok then r.error = tostring(err) end
return r
