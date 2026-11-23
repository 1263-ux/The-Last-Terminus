# B｜Day 3 技术能力矩阵（书桌站视角实测）

分支：`feature/desk-world` · 编辑器 1.0.104 · 工程 `project-006822bc-d20b-4e2b-b6ae-b80fc9498688`
证据等级：**OBSERVED-LOCAL / REPRODUCED-LOCAL**（本机、本工程、可复现脚本见 `lua/`）

> 本文件只写我**实际跑过**的东西。没跑过的标 `NOT TESTED`，不推断。

---

## 0. 能力总表

| 能力 | 结论 | 等级 |
|---|---|---|
| **物体阻挡玩家** | ❌ **不可能**（任何网格、任何层） | REPRODUCED-LOCAL |
| **地形抬高阻挡玩家** | ❓ `NOT TESTED`（需地形笔刷，CLI 无法创建） | — |
| **触发器组件可创建** | ✅ 可 `AddComponent`，暴露 `OnTriggerEnter/Exit/Portal` | OBSERVED-LOCAL |
| **触发器可绑定脚本触发** | ❌ **需要脚本注册，CLI 做不到** | OBSERVED-LOCAL |
| **玩家位置可读** | ✅ `Player_1.transform.position` | REPRODUCED-LOCAL |
| **可主动切换物体状态** | ✅ `SetActive` 立即生效 | OBSERVED-LOCAL |
| **相机参数可读** | ✅ 位置/朝向/FOV/跟随距离全部可读 | REPRODUCED-LOCAL |
| **相机参数可写** | ❌ 反射写 `Single` 字段失败；且每帧被控制器覆写 | REPRODUCED-LOCAL |
| **GLB 可导入** | ✅ 入库成功、字段齐全 | REPRODUCED-LOCAL |
| **GLB 运行时实例化** | ❌ **运行时层级里不存在** | OBSERVED-LOCAL |
| **场景可保存/重开** | ✅ 节点持久化 | REPRODUCED-LOCAL |

---

## 1. 玩家：为什么物体挡不住

### 1.1 实测配置

| 字段 | 值 |
|---|---|
| 对象名 | `Player_1`（另有 `Player(Clone)`） |
| layer | **8 (Actor)** |
| `Rigidbody.isKinematic` | **true** |
| `Rigidbody.useGravity` | **false** |
| `Rigidbody.detectCollisions` | true |
| `Rigidbody.velocity`（行走中） | **(0, 0, 0)** |
| `CapsuleCollider` | enabled, isTrigger=false, r=0.16, h=0.90 |
| 组件家族 | `NetworkActor` + 5 个 `NetworkActor*DataComponent` |

### 1.2 推论（有直接证据）

运动学刚体被排除出碰撞求解。速度恒为 0 而位置在变 → 位移由脚本写 `transform`。
**因此网格碰撞体在原理上无法阻挡玩家。**

### 1.3 九次对照实验

| 类型 | 次数 | 结果 |
|---|---|---|
| 原生 Cube（4–30 m 宽，1.2–6 m 高） | 3 | 1 次挡住（异常），2 次穿过 |
| GLB 墙（24–30 m 宽） | 2 | 全部穿过 |
| 三层门（Default / Actor / IgnoreRaycast） | 3 | **全部穿过，同层也不例外** |
| 地形台（顶面 +1.2 m，横跨路径） | 1 | 玩家 y 不升高，说明不采样物体高度 |

**排除：** 尺寸、缺 Collider、层掩码、GLB 格式、`autoSimulation`、`detectCollisions`。

### 1.4 场景里没有地形对象

遍历 105 个运行时节点，与地面相关的只有玩家和我的测试方块。Unity `Terrain` 组件不存在。
**地面由引擎内部服务提供，在场景层级之外。**

---

## 2. 触发器：机制在，但绑定不到脚本

### 2.1 可用部分

```lua
-- 从玩家身上的实例取类型（typeof(CS.U3dObjectTrigger) 返回 nil，必须走实例）
cs.U3dObjectTrigger → View.U3dObjectTrigger
-- 创建并挂载成功
zone:AddComponent(trigType) → OK
-- 暴露的回调
OnCollisionEnter, OnTriggerEnter, OnTriggerPortal, OnTriggerExit, GetScriptClassName
```

### 2.2 不可用部分

```lua
-- 反射读它的字段：
_douyinScriptList     = nil
_douyinScriptBehaviourList = nil
triggerPortal         = false
```

**脚本列表为空。** 触发器需要绑定编辑器脚本才能产生行为，而脚本注册在工程侧（`.lua` 文件 + 编辑器绑定），CLI 无法写入运行时。

→ **触发器可以摆，但不会自己做事。**

---

## 3. 相机：全部可读，几乎不可写

| 项 | 值 | 可写性 |
|---|---|---|
| 对象 | `TPCameraAvatar` | — |
| 位置 | `(119.741, 79.616, 85.312)` | 写入被每帧覆盖 |
| 前向 | `(0.0003, −0.3090, 0.9511)`（+Z，俯角 18°） | 同上 |
| FOV / near / far | 45 / 0.05 / 1000 | — |
| `_pitch` | 18.0 | ❌ 写 8° 后 0.5 s 回到 18° |
| `_minPitchAngle` / `_maxPitchAngle` | −40 / 70 | 只读 |
| `_followDistance` / `_followMaxDistance` | 3.5 / **6.0** | ❌ `Single` 类型写不进去 |
| `VerticalHeadOffset` | −0.40 | — |

**写入失败原因：** Lua number 是 Double，Unity 字段是 Single。`Convert.ToSingle` 走这条桥仍返回 Double；`Array.CreateInstance` 要的 typeof 传不进去；`CS.System.Single(x)` 不存在。

---

## 4. 可见带：只有贴地平线的一条窄缝

相机只比地面高约 0.4 m、俯角 18°、半 FOV 22.5°：

```
帧顶 y(d) = 79.6 + 0.105 · d
d=10 m → 80.65      d=20 m → 81.70
```

地面物件高于 `0.105·d` 就被切顶。**10 m 处 1.1 m 的书已经出画。**
结合 `_followMaxDistance = 6.0`，玩家贴近巨物时相机退不开 → **"立式巨物"表达微缩不成立**。

---

## 5. GLB：能进库，但不进运行时

| 层 | 状态 | 证据 |
|---|---|---|
| 数据层 | ✅ | `scene.data` 有节点、变换、`physicsColliderData.enableCollision=true` |
| 运行时层级 | ❌ | 遍历 105 节点，**一个 GLB 对象都没有** |
| 渲染层 | ⚠️ | 有阴影、无本体（原生 primitive 同样如此） |

**→ GLB 文件本身可能是好的，问题在导入后的实例化/加载。**

---

## 6. 对 A 和 C 的直接告警

> **不要把任何导入或 primitive 物体当作地板、墙壁或平台。**
>
> - A 的**列车站台、安全落脚区**：若靠物体承载玩家 → 失效
> - C 的**平台、台阶、屋顶、根系通道**：同上
> - 两者都只能依赖**引擎内部地面服务**或**地形**
>
> **触发器的脚本绑定需要工程侧配置**，纯 CLI 搭出来的触发器不会触发。
>
> 复现脚本：`lua/find_player.lua`、`diag_physics.lua`、`prove_kinematic.lua`、
> `layer_gates.lua`、`find_ground.lua`、`make_trigger.lua`、`probe_trigger3.lua`

---

## 7. 仍待验证（需 GUI，我做不了）

| # | 项 | 状态 |
|---|---|---|
| 1 | GUI 手动拖 Cube 是否行为不同 | NOT TESTED |
| 2 | **地形笔刷堆堤能否挡住玩家** | NOT TESTED ← **最关键** |
| 3 | `NetworkActor` 查询哪些层/是否 raycast | NOT TESTED |
| 4 | Preview 与 Published 差异 | NOT TESTED |
| 5 | 触发器脚本绑定后能否触发 | NOT TESTED |
| 6 | 换新工程是否复现 | NOT TESTED |
