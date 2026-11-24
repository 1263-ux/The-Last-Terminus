# B｜玩家驱动交互成立：绑定脚本自动激活

分支：`feature/desk-world` · 编辑器 1.0.104
日期：2026-11-24
脚本：`reports/day-03/B/desk_proximity.lua`
证据：`evidence/day-03/31-auto-activated.jpg`

---

## 0. 结论

> **书桌站第一次实现了真正的玩家驱动交互。**
> 玩家用 W 走进交互区，绑定脚本在 `Update()` 里自己检测到距离并激活，
> **没有任何外部 lua 命令介入**。

---

## 1. 实测证据链

### 1.1 走之前

```
binding f58d0bdd-... : active = true
playerZ              : 88.64
```

### 1.2 玩家操作

```powershell
douyin-world runtime input keys "W:1600"
```

**只发了这一条移动指令，没有调用任何激活命令。**

### 1.3 走之后

```
binding f58d0bdd-... : active = false     ← 脚本自己激活了
playerZ              : 93.33              ← 进入 [89, 95] 触发区
```

**这是完整的因果链：玩家移动 → 进入区域 →绑定脚本自动激活 → 世界状态改变。**

---

## 2. 为什么这次能成

`desk_proximity.lua` 不依赖触发器几何（上轮证明导入资产没有运行时实体），
而是在绑定脚本自己的 `Update()` 里读玩家位置：

```lua
function Update()
  if activated then return end
  local p = playerPosition()          -- GameObject.Find("Player_1")
  if not p then return end
  if math.abs(p.z - TriggerZ) <= TriggerRadius then
    activate()                        -- self.gameObject:SetActive(false)
  end
end
```

已验证绑定脚本环境里 `CS.UnityEngine` 可用，能读到玩家位置。

### 2.1 双重实现

脚本同时保留两条路径：

| 路径 | 适用 |
|---|---|
| `Update()` 距离检测 | **当前可用**（无需几何） |
| `OnPlayerTriggerEnter()` | 未来导入资产进入运行时后也可用 |

---

## 3. 与之前方案的区别

| 方案 | 触发方式 | 状态 |
|---|---|---|
| `lua eval` 命令 | 外部调用 | ❌ 不是玩家交互 |
| `U3dObjectTrigger`（运行时） | 无脚本列表 | ❌ 不可绑定 |
| `triggerData` 自动回调 | 需运行时几何 | ❌ B-07 阻塞 |
| **`Update()` 距离检测（本轮）** | **玩家真实移动** | ✅ **成立** |

---

## 4. 去抖与边界

| 项 | 实测 |
|---|---|
| 只激活一次 | ✅ `activated` 标志 |
| 重复调用无副作用 | ✅ 上轮实测 `afterSecond = false` |
| 玩家离开区域 | 不重置（设计如此，谜题完成后不回退） |
| 依赖玩家位置 | ✅ 实测 z=93.33 时触发 |

---

## 5. 这对闭环的意义

`LOOP-V2-PHYSICAL-GATE.md` 里唯一未成立的"主动触发"缺口，现在补上了。

**完整闭环的每一环现在都有实测：**

| 步骤 | 状态 |
|---|---|
| 出生看见三要素 | ✅ |
| 观察尺子 | ✅ |
| **玩家主动走近触发** | ✅ **本轮** |
| REST→RAMP 状态切换 | ✅ |
| 物理门挡住/放行 | ✅ |
| 连续行走到达 | ✅ |
| 暖窗反馈 | ✅ |

---

## 6. 仍需注意

| 项 | 状态 |
|---|---|
| 用的是 primitive 场景，不是真实 GLB | ⚠️ 机制验证，非资产验收 |
| `Update()` 每帧检测有性能成本 | 单一脚本、简单比较，可接受 |
| 宿主节点是 `map-desk` 根，隐藏它会隐藏整张地图 | ⚠️ **正式版需改为只隐藏尺子节点** |
| 两个绑定（旧+新）同时存在 | ⚠️ 需清理旧绑定避免混淆 |

### 6.1 最后两条要说明

当前脚本隐藏的是宿主 `map-desk`，这在验证阶段够用，
但正式版必须改绑定到**尺子自己的节点**，否则"搬走尺子"会变成"隐藏整张地图"。

清理旧绑定（`856203ac-...`）后，只保留新脚本（`f58d0bdd-...`），
即可消除歧义。这两项都是工程收尾，不影响机制已成立的结论。

---

## 7. 复现

```
1. prefab files write desk_proximity.lua → scripts/trigger_probe.lua
2. prefab build → export → asset import → scene import → save
3. runtime start
4. runtime input keys "W:1600"
5. runtime lua eval --binding=<新脚本 key> --file prox_state.lua
   → active = false
```
