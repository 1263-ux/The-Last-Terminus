---@displayName 尺子桥靠近交互
-- 玩家走到尺子附近时，由绑定脚本自己检测距离并激活一次。
-- 不依赖触发器几何（导入资产在当前运行时没有实体），
-- 也不依赖外部 lua 命令——这是真正的玩家驱动交互。
---@start
---@var TriggerZ:number=92.0
---@name 交互区 Z 坐标
---@var TriggerRadius:number=3.0
---@name 触发半径
---@end

local activated = false

local function playerPosition()
  if not CS or not CS.UnityEngine then return nil end
  local ok, go = pcall(function()
    return CS.UnityEngine.GameObject.Find("Player_1")
  end)
  if not ok or not go then return nil end
  local okp, p = pcall(function() return go.transform.position end)
  if not okp or not p then return nil end
  return p
end

local function activate()
  if activated then return end
  activated = true
  -- self.gameObject 是宿主节点；隐藏它即"静止的尺子被搬走"
  if self and self.gameObject then
    self.gameObject:SetActive(false)
  end
end

function Update()
  if activated then return end
  local p = playerPosition()
  if not p then return end
  if math.abs(p.z - TriggerZ) <= TriggerRadius then
    activate()
  end
end

-- 保留 trigger 回调，若将来导入资产进入运行时也会工作
function OnPlayerTriggerEnter(player)
  activate()
end
