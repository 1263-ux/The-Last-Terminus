---@id aae47e30-ec23-4690-8e97-24bb552b9a55
---@referenceName desk-proximity.lua
---@displayName 书谷断口·架桥交互
-- 玩家走到侧躺的尺子旁边时，脚本自己把尺子架到断口上（隐藏桥体变为出现）。
-- 全部由玩家移动驱动：不依赖 Trigger 几何回调，不依赖外部 lua 命令。
-- 断口是真的 1.5 m 落差；不架桥就走不过去（控制器没有 step-up，1.2 m 就挡住）。
-- 走到对岸小镇后，窗户点亮并给出到达反馈。
---@start
---@var TriggerZ:number=93.0
---@name 交互区 Z 坐标
---@desc 玩家世界坐标 z 走到这里即触发"架桥"
---@var TriggerRadius:number=1.6
---@name 触发半径
---@var ArriveZ:number=118.0
---@name 到达小镇的 Z 坐标
---@var WindowGlowBoost:number=0.55
---@name 暖窗亮度增益
---@end

local activated = false
local arrived = false
local player = nil

local function findPlayer()
  if player ~= nil then return player end
  local ok, go = pcall(function() return CS.UnityEngine.GameObject.Find("Player_1") end)
  if ok and go then player = go end
  return player
end

local function findNode(relPath)
  local ok, go = pcall(function()
    return CS.UnityEngine.GameObject.Find("previewGameRoot/deskworld/" .. relPath)
  end)
  if ok then return go end
  return nil
end

-- 收集 Environment 下所有 MeshRenderer，用于按位置定位"可操作对象"
local function collectMeshes()
  local items = {}
  local env = findNode("Environment")
  if env == nil then return items end
  local function walk(g)
    local ok, mr = pcall(function() return g:GetComponent(typeof(CS.UnityEngine.MeshRenderer)) end)
    if ok and mr ~= nil then items[#items + 1] = { go = g, mr = mr } end
    for k = 0, g.transform.childCount - 1 do
      walk(g.transform:GetChild(k).gameObject)
    end
  end
  walk(env)
  return items
end

-- 把 SCAD 里那支"侧躺的备用尺"整套藏起来（按包围盒位置判定，不依赖节点名）
local function hideRestRuler()
  local meshes = collectMeshes()
  local hidden = 0
  for i = 1, #meshes do
    local mr = meshes[i].mr
    local b = mr.bounds
    -- 侧躺尺在 Unity (122.9, 93.2) 附近，长 7.6 m 沿 +z
    if math.abs(b.center.x - 122.94) < 3.0 and math.abs(b.center.z - 93.24) < 5.0 and b.size.y < 0.4 then
      local host = meshes[i].go
      if host.transform.parent ~= nil then host = host.transform.parent.gameObject end
      host:SetActive(false)
      hidden = hidden + 1
    end
  end
  return hidden
end

-- 到达小镇后把暖窗调亮（颜色有效；自发光在运行时不生效，见报告）
local function lightTown()
  local meshes = collectMeshes()
  local lit = 0
  for i = 1, #meshes do
    local mr = meshes[i].mr
    local b = mr.bounds
    -- 暖窗色块在小镇一侧 z≈122..131，尺寸近似 1.2 x 1.05
    if math.abs(b.center.z - 122.3) < 4.0 and b.size.y > 0.8 and b.size.y < 1.4 and b.size.x < 2.0 then
      local ok, mat = pcall(function() return mr.material end)
      if ok and mat ~= nil then
        local okc, col = pcall(function() return mat.color end)
        if okc and col ~= nil then
          pcall(function()
            mat.color = CS.UnityEngine.Color(
              math.min(1, col.r + WindowGlowBoost),
              math.min(1, col.g + WindowGlowBoost * 0.72),
              math.min(1, col.b + WindowGlowBoost * 0.18),
              1)
          end)
          lit = lit + 1
        end
      end
    end
  end
  return lit
end

local function activate()
  if activated then return end
  activated = true
  local bridge = findNode("ruler-bridge-full-v01")
  if bridge ~= nil then bridge:SetActive(true) end
  hideRestRuler()
end

function Start()
  findPlayer()
  -- 出生时桥体收起，只有侧躺的尺子在断口前
  local bridge = findNode("ruler-bridge-full-v01")
  if bridge ~= nil then bridge:SetActive(false) end
  activated = false
  arrived = false
end

function Update()
  local p = findPlayer()
  if p == nil then return end
  local pos = p.transform.position

  if not activated and math.abs(pos.z - TriggerZ) <= TriggerRadius then
    activate()
  end

  if not arrived and pos.z >= ArriveZ then
    arrived = true
    lightTown()
  end
end

-- 保留 trigger 回调，若将来导入资产进入运行时也会工作
function OnPlayerTriggerEnter(other)
  activate()
end
