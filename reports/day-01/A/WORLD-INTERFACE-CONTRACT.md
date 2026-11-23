# World Interface Contract｜世界接口契约 v0.1

> Owner：成员 A（公共接口维护者）
> 状态：**PROPOSED**（待 B/C 确认后冻结为 v1.0）
> 依据：Day-01 编辑器实测（见 `reports/day-01/A/EVIDENCE.md`）
> 本文档只定义**接口**，不定义 B/C 世界内部玩法与场景。B/C 的世界内部由各自 Owner 决定。

---

## 0. 为什么需要这份文件

三个世界分别由三人独立制作，最终要串成一趟连续旅程。若入口/出口/尺度在集成阶段才对齐，
会出现玩家出生朝向错误、落脚点悬空、返回路径缺失、重复进入触发等问题。
本契约把 A 与 B/C 之间**唯一必须一致**的最小集合写死，其余交给世界 Owner。

---

## 1. 玩家尺度基线（全网统一，不可各自改动）

| 项 | 值 | 状态 | 依据 |
|---|---|---|---|
| 玩家胶囊半径 | **0.16 m** | **OBSERVED** | `P07-actor-members.json` |
| 玩家胶囊总高 | **0.90 m** | **OBSERVED** | 同上 |
| 胶囊中心 | y = **0.45 m** | **OBSERVED** | 同上 |
| 碰撞直径（实际宽度） | **0.32 m** | **OBSERVED** | 半径 ×2 |
| 默认移动速度 | 约 4 m/s | OBSERVED | 场景 `moveMaxSpeed = 4.0` |
| 默认跳跃高度 | 1.0 m | OBSERVED | 场景 `jumpMaxHeight = 1.0` |
| 重力/坠落恢复高度 | y = −50 | OBSERVED | 场景 `respawnHeightY = -50.0` |

> **⚠ 玩家碰撞体远小于视觉角色。** 碰撞体只有 **0.32 m 宽 × 0.9 m 高**。
> 这意味着"看起来挡住了"的地方，玩家可能真的能钻过去。
> **布置障碍与通道时请按碰撞体尺寸判断，不要按角色视觉体积判断。**

**对 B/C 的硬要求：**

1. 所有**可站立平台**必须是实体 Collider（`isTrigger = false`），不得只有 Trigger。
2. 行走通道净宽：**硬下限 0.8 m**（碰撞直径 + 余量）；
   视觉舒适建议 **≥ 1.5 m**。
3. 门洞：**硬下限 0.6 m 宽 × 1.2 m 高**（碰撞体可过）；
   为避免视觉穿模，实际应做 **≥ 1.0 m 宽 × 2.0 m 高**。
4. 任何可达区域的**地面高度差单步 ≤ 0.45 m**（需跳上则 ≤ 1.0 m，并留出助跑距离）。
5. **下落不得低于 y = −50**，否则触发自动重生；低洼地形需自备兜底。
6. 出生点必须落在**实体平台上**，不得让玩家出生即坠落。
7. **Trigger 的竖直范围必须覆盖 y ≈ 0.45 m 这一层**（胶囊中心）。
   按"角色头顶高度"设 volume 会静默失效 —— 这是 A 在 Day-01 实际踩到的坑。

---

## 2. Entry / Exit Anchor 定义

Anchor 是一个**世界内的接口位置**，不是 UI 标记。它在编辑器中的实现已被 A 实测跑通
（见 §5 已验证机制），B/C 只需按格式提供数据，由 A 在集成时装配。

### 2.1 必填字段

| 字段 | 类型 | 含义 | 谁填 |
|---|---|---|---|
| `world_id` | string | `desk` / `garden` / `terminus` | A 统一分配 |
| `world_version` | string | 该世界快照版本（建议 `YYYYMMDD-<短commit>`） | B/C |
| `source_commit` | string | 交付快照的 Git commit | B/C |
| `anchor_id` | string | 唯一名，建议 `desk.entry` / `desk.exit` | B/C |
| `role` | enum | `entry`（从列车进入）/ `exit`（返回列车） | B/C |
| `position` | vec3 (m) | Anchor 世界坐标（**编辑器 world 空间**，不是 local） | B/C |
| `spawn_position` | vec3 (m) | 玩家实际落脚的**地面点**，通常 = position 的 y 取地面高度 | B/C |
| `spawn_yaw` | float (deg) | 玩家出生后**面向**的朝向，绕 Y 轴 | B/C |
| `safe_zone_radius` | float (m) | 落脚点周围可安全站立/转身的半径，建议 ≥ 2.0 | B/C |
| `trigger_size` | vec3 (m) | 触发体积尺寸；A 默认 `3 × 4 × 3` | B/C 可覆写 |
| `return_target` | string | 离开时回到哪个 anchor_id（或 `train.hub`） | B/C |
| `fallback` | object | 失败恢复：见 §4 | B/C |

### 2.2 语义约定

- **`spawn_yaw` 指向玩家下车后应该看见的第一个视觉目标**，不是列车方向。
  例如书桌站入口应朝向主地标，而不是朝向车尾。
- **`safe_zone_radius` 内不得有**：装饰物穿插、可推动刚体、其它 Trigger 的边界。
  否则玩家一下车就被二次触发或卡住。
- **`exit` anchor 的 trigger 必须与 `entry` 的 trigger 相距 ≥ 8 m**，
  否则往返会形成反复传送的振荡（A 已实测到该现象，见 EVIDENCE §5-3）。
- **同一世界内** `entry` 与 `exit` 可以是同一物理位置（下车即上车），
  但必须用不同 `anchor_id`，由 A 决定是否合并。

### 2.3 示例（虚构数值，仅示范格式）

```json
{
  "world_id": "desk",
  "world_version": "20261123-a1b2c3d",
  "source_commit": "a1b2c3d",
  "anchors": [
    {
      "anchor_id": "desk.entry",
      "role": "entry",
      "position": [0.0, 1.0, 0.0],
      "spawn_position": [0.0, 0.05, 0.0],
      "spawn_yaw": 180.0,
      "safe_zone_radius": 2.5,
      "trigger_size": [3.0, 4.0, 3.0],
      "return_target": "train.hub",
      "fallback": {
        "respawn": [0.0, 0.05, 0.0],
        "reason": "掉出世界边界时回到入口"
      }
    }
  ]
}
```

---

## 3. 世界交接物（每个世界交付时必须包含）

按 `production/INTEGRATION-CONTRACT.md` §7，最小集为：

1. **`WORLD-CARD.md`** — 目标、体验、空间规则、范围
2. **`ASSET-MANIFEST.csv`** — 全部资产及依赖
3. **`SCENE-STRUCTURE.md`** — 场景层级与关键对象
4. **`INTERACTION-FLOW.md`** — 交互逻辑、触发条件、反馈
5. **`ENTRY-EXIT.md`** — 本契约 §2 的全部字段
6. **`KNOWN-ISSUES.md`** — 未解决问题与降级项
7. 实际交付文件（见 §3.1）
8. 远 / 中 / 近景截图各 ≥ 1
9. 完整玩法录屏 ≥ 1

### 3.1 交付格式与顺序（A 实测的可用路径）

已验证可用的最小交接链路：

```
GLB（≤ 30000 面 / ≤ 10 MB）
  → douyin-world authoring resource model import <model-id> --prefab <ID> --glb <file>
  → authoring resource archive <model-id> --kind model --prefab <ID>   # 返回 uri
  → authoring prefab attach <ID> --kind model --uri <uri>
  → authoring prefab build <ID>
  → authoring result archive <ID> --name "<中文名>"                      # 返回 wprefab uri
  → authoring prefab export <ID> --out <dir>                            # 本地 .wprefab 单文件
```

**交接首选顺序：**
1. **首选**：`prefab export` 出的 `.wprefab` 单文件 + 本契约 §2 的 JSON + 截图。A 可在另一台机/另一工程导入。
2. **次选**：`.wprefab` 归档 URI（需同一账号体系可解析）。
3. **兜底**：裸 GLB 逐个交付 + A 在主工程内重建层级、碰撞、交互和脚本。

**注意（实测限制，不可假定）：**
- 资产导入上限 **30000 面 / 10 MiB**（`resource inspect` 明确返回该限制）。
- `.wprefab` 内**不内嵌**模型二进制，`resourceRefs` 为空，模型通过**外部 URI** 引用
  （`glbSliceData.sourceUri` / `aigcModelData.uri`）。→ **跨账号交接存在失效风险**，必须附带
  裸 GLB 作为兜底。
- 碰撞**不从 GLB 继承**，必须按 `physicsColliderData` / `triggerData` 在编辑器内重建。

---

## 4. 失败恢复（每个世界必须提供）

| 场景 | 要求 |
|---|---|
| 玩家坠落出界 | 世界 y < `respawnHeightY`（默认 -50）会自动回出生点；若世界地形低于该值，必须自行加兜底 Trigger |
| 传送后卡住 | `spawn_position` 周围 `safe_zone_radius` 内必须无阻挡 |
| 进入后无法返回 | `exit` anchor 必须在**玩家已到达区域**内，不能要求完成玩法才能离开 |
| 资源丢失 | 交付时必须附裸 GLB 兜底，且提供 `ASSET-MANIFEST.csv` 说明依赖 |

---

## 5. A 已验证的接口机制（可直接给 B/C 复用）

### 5.1 传送锚点脚本（`world-interface-anchor.lua`）

A 已实现并跑通一个**通用传送 Anchor 脚本**，挂在任意节点上，靠参数区分入口/出口：

```lua
---@displayName 世界接口_传送锚点
---@start
---@var TargetX:number=0
---@var TargetY:number=1
---@var TargetZ:number=0
---@var TargetYaw:number=0
---@var CooldownSeconds:number=0.5
---@end

local lastTeleportTime = -100

local function applyTeleport(actor)
  if actor == nil or not actor.isLocal then return end
  if CS.UnityEngine.Time.time - lastTeleportTime < CooldownSeconds then return end
  lastTeleportTime = CS.UnityEngine.Time.time
  actor:Teleport(CS.UnityEngine.Vector3(TargetX, TargetY, TargetZ),
                 CS.UnityEngine.Quaternion.Euler(0, TargetYaw, 0))
end

function OnActorTriggerEnter(actor)
  if actor == nil or not actor.isLocal then return end
  applyTeleport(actor)
end

function OnActorTriggerExit(actor)
end
```

**实测结论（PASS）：**

| 项 | 结果 | 证据 |
|---|---|---|
| `OnActorTriggerEnter` 回调被触发 | PASS | 真实 W 输入走进 Trigger 后，玩家 x 由 119.74 → 20.00 |
| `actor:Teleport(pos, rot)` 生效 | PASS | 同上 |
| 脚本参数按节点独立保存 | PASS | 两节点同脚本不同参数，读回分别为 `20.0|1.0|0.0` 与 `0.0|1.0|0.0` |
| 冷却防重复触发 | PASS（设计上） | 参数 `CooldownSeconds` 已生效并被读回 |

### 5.2 关键约束（B/C 必读，否则接口会静默失效）

1. **脚本与 Trigger 必须在同一节点**。Hamlet 的 Actor 回调**不冒泡**，
   "脚本在 root、Trigger 在 child" 会表现为物理正常但回调永不触发。
2. `triggerData` 的 `center` 是**相对宿主节点的局部坐标**，且**不预乘祖先缩放**。
   若节点本身已抬高 1 m，`center.y` 再写 1 会把体积推到玩家头顶之上。
   → **推荐 `center.y = 0.5`、`size = (3,4,3)`**，让体积从节点下方半米覆盖到上方 2.5 m。
3. 空节点（无 Mesh）**可以**拥有 `BoxCollider(isTrigger=true)`，A 已实测确认。
   不需要为 Trigger 单独挂一个可见 Mesh。
4. 世界内**同一脚本**可用 `scripts.bind` 多次绑定到不同节点，参数互相独立；
   修改用 `scripts.setParams`，binding handle 格式为 `<nodeHandle>:s:<scriptId>`。

### 5.3 列车 Hub ↔ 世界 的接线方式

```
[列车 Hub 车门节点]  --Trigger-->  Teleport → 世界 entry.spawn_position / spawn_yaw
[世界 exit 节点]     --Trigger-->  Teleport → 列车 Hub 的下车点 / 朝向窗户
```

这意味着**当前版本不依赖跨场景加载**即可完成旅程串联：
三个世界可以先作为**同一工程内的三个分区**，由传送完成切换。
若后续验证出真正的跨场景切换能力，再替换为场景加载，接口字段不变。

---

## 6. 待 B/C 确认的问题（请在 HANDOFF 回复中逐条回答）

1. 你的世界最终**在哪个工程**里？独立工程，还是 A 的集成工程内分区？
2. `entry.spawn_yaw` 你希望玩家朝向哪个地标？给出该地标的名称与大致方位。
3. 你的世界是否需要玩家**返回列车才能算完成**，还是完成即自动返回？
4. 你的世界目前**有没有地面 Collider**（不是 Trigger）？若还没有，玩家会直接坠落。
5. 你预计交付格式是 `.wprefab`、裸 GLB，还是两者都有？

---

## 7. 变更记录

| 版本 | 日期 | 变更 | 状态 |
|---|---|---|---|
| v0.1 | Day-01 | 初稿；基于 A 实测的传送机制与资产交接链路 | PROPOSED |
