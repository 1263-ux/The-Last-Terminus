---@displayName 门自移除
-- 玩家进入本节点触发区时，把自己（宿主对象）隐藏，通路打开。
---@start
---@end

local activated = false

function OnPlayerTriggerEnter(player)
  if activated then return end
  activated = true
  if self and self.gameObject then
    self.gameObject:SetActive(false)
  end
end
