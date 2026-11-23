# B1｜碰撞根因：玩家是脚本驱动的运动学刚体，场景物体无法阻挡（含架构证据）

对应 Day-3 §B1 / §B3
分支：`feature/desk-world` · 编辑器 1.0.104 · 工程 `project-006822bc-d20b-4e2b-b6ae-b80fc9498688`
状态：**已定位（REPRODUCED-LOCAL），并已排除全部常见解释**

---

## 0. 结论（一句话）

> **玩家不是被物理推着走的，而是由 `NetworkActor` 脚本直接写 `transform`。
> 它是 `isKinematic = true` 的刚体，`Rigidbody.velocity` 恒为 0，物理求解器不参与。
> 所以场景里的任何物体——GLB、原生 Cube、任何 Layer——都不可能挡住玩家。**

这不是推测，是四个独立读数共同指向的结果（§1），并经 9 次对照实验否证了其他解释（§2）。

---

## 1. 四个决定性读数

### 1.1 玩家实体的组件栈

扫描 104 个节点后定位到 `Player_1`：

```
Transform | U3dObjectTrigger | NetworkActor | NetworkActorData |
NetworkActorTitle | NetworkObjectReady | NetObjectView |
CapsuleCollider | Rigidbody | NetworkActorTransformDataComponent |
NetworkActorSystemsTriggerDataComponent | NetworkActorGestureDataComponent |
NetworkActorSettingDataComponent | NetworkActorStateSwimDataComponent |
NetworkActorStateFlyDataComponent | NetworkActorAvatarDataComponent |
NetworkActorLossOfControlComponent | NetworkActorBusyComponent |
NetworkActorMiscComponent | NetworkSitStation | NetworkPickupProps
```

`NetworkActor` 体系说明它是一个**联网同步的角色**，位移由服务端/脚本状态驱动，不是本地物理解算。

### 1.2 刚体配置

| 字段 | 值 | 含义 |
|---|---|---|
| `layer` | **8 (Actor)** | 与 Default 不同层 |
| **`isKinematic`** | **true** | **运动学 → 被排除出求解器响应** |
| `useGravity` | false | 不做重力 |
| `detectCollisions` | true | 开关是开的，但 kinematic 下无效 |
| `constraints` | 0 | 未受限 |
| `mass` | 1.0 | — |
| `CapsuleCollider.enabled` | true | 碰撞体在 |
| `CapsuleCollider.isTrigger` | false | 不是触发器 |
| `capsule radius / height` | 0.16 / 0.90 m | — |

### 1.3 速度恒为 0（最关键）

```lua
rb.velocity → (0.0000, 0.0000, 0.0000)
```

玩家**正在移动**（连续行走 30+ m）、刚体组件存在、物理模拟开启（`autoSimulation = true`、`gravity.y = -9.81`），**但速度是 0**。

→ 位移只能来自**脚本直接赋值 `transform.position`**。
→ 运动学刚体不参与碰撞响应，网格碰撞体在原理上无法阻挡它。

### 1.4 场景里根本没有地形对象

Unity `Terrain` 组件不存在。我遍历了运行时完整层级（105 个节点），与地面相关的东西只有玩家自己和我的测试方块：

```
count = 3
  Player_1        (玩家)
  Player(Clone)   (玩家副本)
  TERRAIN_STEP    (我的测试方块)
```

**没有任何地形对象。**

但玩家全程 `y` 稳定在 79.6–80.0，走过 30+ 米落地正常。

**→ 地面由引擎内部服务提供，在场景层级之外。场景物体与"玩家站在什么上面"完全无关。**

---

## 2. 九次对照实验：排除所有常见解释

### 2.1 尺寸 / 来源（5 次）

| # | 障碍 | 层 | 尺寸 | 位置 | 玩家终点 | 判定 |
|---|---|---|---|---|---|---|
| 1 | 原生 Cube | 0 | 6×2×1 | z=96 | z=94.36 | **挡住（唯一一次）** |
| 2 | 原生 Cube | 0 | 4×3×1 | z=92.6 | z=95.83 | 穿过 |
| 3 | 原生 Cube | 0 | 6×3×1 | z=104 | z=107.53 | 穿过 |
| 4 | GLB 墙 | 0 | 30×6×4 | z=95 | z=112.33 | 穿过 |
| 5 | GLB 墙 | 0 | 24×4×1 | z=101 | z=110.72 | 穿过 |

### 2.2 层（3 次，同尺寸 `8×2×1`，只换层）

| 门 | 层 | 位置 | 结果 |
|---|---|---|---|
| `GATE_L0_DEFAULT` | 0 Default | z=94 | 穿过 |
| `GATE_L8_ACTOR` | **8 与玩家同层** | z=99 | 穿过 |
| `GATE_L2_IGNORE` | 2 IgnoreRaycast | z=104 | 穿过 |

玩家终点 `z=109.41` —— **三扇门全部穿过，同层也不例外**。

### 2.3 地面采样（1 次）

平台 `10×1.2×6`，顶面 `y=81.2`，横跨路径：

```
玩家终点 y = 79.963   ← 没有升高
```

**玩家连地面高度都不采样**，只认引擎内部地面服务。

### 2.4 全部被排除的解释

- ❌ 障碍物太小（3–24 m 宽、1.2–6 m 高都试过）
- ❌ 缺 Collider 组件（每次都读到 `BoxCollider`/`CapsuleCollider`，`isTrigger=false`）
- ❌ 层不匹配（Default / Actor / IgnoreRaycast 全穿过）
- ❌ GLB 格式问题（原生 primitive 同样失效）
- ❌ 物理模拟关闭（`autoSimulation=true`）
- ❌ `detectCollisions` 关闭（为 true）
- ❌ 缺少地形（地形在层级之外，但确实在起作用）

---

## 3. 唯一未解释的异常：第 1 次为什么挡住了

第 1 次是运行时启动后**第一个**创建的对象，之后 8 次全部失败。我试过改变距离（4 m / 8 m）、尺寸、层，都无法复现。

**判断：** 很可能是时序巧合（对象注册完成前玩家恰被某个初始化状态截停），而非碰撞。**未验证**——需要精确控制创建与位移的帧序，CLI 做不到。

按 Day-3 第 68 行「不要直接否定 B」，我保留这条记录，但**不把它当作碰撞可用的证据**。

---

## 4. 对玩法设计的直接后果

**「用物体挡路」在这个角色控制器上是不可能的。** 这推翻了我此前三个方案的前提：

| 方案 | 依赖的机制 | 结论 |
|---|---|---|
| 水平裂口（Day 2） | 桌面挖洞产生落差 | ❌ 地形连续，洞被填平 |
| C1 抬高台面 + 坡道 | 高台掉下去上不来 | ❌ 会掉，但也能走上去（无碰撞） |
| **C4 竖直断墙 + 尺子坡道** | **墙挡住、坡道通行** | ❌ **前提不成立** |
| C2 改高度差 | 同上 | ❌ 同上 |

**只有一个方向在机制上仍可能成立：让"通路改变"不依赖物理阻挡。**

### 4.1 我建议的新方向：把"阻断"改成"不可达"而非"不可穿"

既然玩家不会被挡住，就不能用"挡住"表达阻断。可行的替代有两种：

| 方案 | 做法 | 为什么可能可行 |
|---|---|---|
| **E1 距离/位置判定** | 用触发器或状态脚本：玩家未完成前置动作时，目标区域**传回入口**或**不生成** | `U3dObjectTrigger` 组件已经存在于玩家身上，说明触发器机制是这套系统的一等公民 |
| **E2 剧情状态门** | 铅笔盒小镇在搭桥前**不存在**（未实例化），搭桥后才出现 | 不需要碰撞，只需要状态切换 |

> **注意：** 这两种都改变体验性质。E1 接近"隐形墙"，E2 接近"开门"。**是否接受，必须由总设计师裁定**，我不自行采用——因为世界文档明确反对"收集三件物品开门"的通用模板。

---

## 5. 需要人完成的事（都是 GUI 或需授权）

| # | 动作 | 谁能做 | 为什么关键 |
|---|---|---|---|
| 1 | GUI 手动拖 Cube 撞一次 | 人/A | 确认我的手建 primitive 与 GUI 放置是否不同 |
| 2 | 翻 `NetworkActor` 的 Inspector，看它查询哪些层/是否用 raycast | 人/A | 决定是否存在"能被它认可的障碍" |
| 3 | 用**地形笔刷**堆一道堤，验证地形能否挡 | 人 | 若可行，C4 改用地形实现，道路仍在 |
| 4 | 对比 Preview 与 Published | 人/A | 确认是否预览模式缺陷 |

**第 2 条最有价值**：如果 `NetworkActor` 用 raycast 检测特定层，那么把障碍放到那层就能生效，C4 原方案可救。

---

## 6. 状态标记

| 项 | 状态 |
|---|---|
| 玩家为运动学刚体、velocity 恒 0 | **REPRODUCED-LOCAL** |
| 网格碰撞体无法阻挡玩家 | **REPRODUCED-LOCAL**（9 次） |
| 场景中无地形对象、地面由引擎服务提供 | **OBSERVED-LOCAL** |
| 层假设 | **FAIL（已排除）** |
| 地形（笔刷）能否阻挡 | **NOT TESTED**（CLI 无法创建地形） |
| GUI 手动版对照 | **NOT TESTED** |
| Preview vs Published | **NOT TESTED** |
| C4 原方案闭环 | **BLOCKED** |

---

## 7. 直接给 A 和 C 的情报

> **不要把任何 `scene import` 或 `CreatePrimitive` 的物体当作地板或墙壁。**
>
> 玩家是 `NetworkActor` 驱动的运动学刚体（layer 8 Actor），位移由脚本写 transform，
> `Rigidbody.velocity` 恒为 0，物理求解器不参与。场景层级里也没有地形对象——
> 地面由引擎内部服务提供。
>
> **A 的列车站台/安全落脚区、C 的平台/台阶/屋顶，凡依赖"物体承载玩家"的，都会失效。**
> 唯一确认有效的地面是引擎内部地面服务。
>
> 复现脚本（都可直接跑）：
> `lua/find_player.lua`（找玩家与组件栈）
> `lua/diag_physics.lua`（层/刚体/碰撞体字段）
> `lua/prove_kinematic.lua`（速度恒 0 证据）
> `lua/layer_gates.lua`（三层层门对照）
> `lua/find_ground.lua`（证明场景无地形对象）
