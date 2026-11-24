---@displayName 尺子桥交互
-- 玩家进入交互区后主动激活一次：REST 尺子被搬走、桥体出现、物理门移除。
-- 这是真正的 bound script，由 OnPlayerTriggerEnter 驱动，而不是外部命令。
---@start
---@var BridgePath:string=Environment/ruler-ramp
---@name 桥体路径
---@var RestPath:string=Environment/ruler-rest
---@name 静止尺路径
---@var GatePath:string=Environment/gate
---@name 物理门路径
---@end

local RuntimeScope = require("official.core.runtime_scope")
local runtimeScope, runtimeScopeReason = RuntimeScope.from(self)

local activated = false

local function setVisible(path, visible)
  if not runtimeScope or not path or path == "" then return false end
  local go, reason = runtimeScope:GetGameObjectByPath(path)
  if not go then return false end
  local ok = pcall(function() go:SetActive(visible) end)
  return ok
end

function OnPlayerTriggerEnter(player)
  if activated then return end
  activated = true
  setVisible(BridgePath, true)
  setVisible(RestPath, false)
  setVisible(GatePath, false)
end
