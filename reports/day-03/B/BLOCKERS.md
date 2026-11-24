# B｜BLOCKERS｜DAY-03 / 资产复用轮

分支：`feature/desk-world` · 编辑器 1.0.104
工程：`project-006822bc-d20b-4e2b-b6ae-b80fc9498688`

状态标记：PASS / FAIL / NOT TESTED / INCONCLUSIVE / BLOCKED

---

## B-07｜BLOCKED：当前工程不加载场景几何（最高优先级）

### 现象

`scene import` 返回 `committed`，`scene.data` 里节点层级完整，
但**运行时 `WorldRoot` 子节点数为 0，全场景 `MeshRenderer` 数量为 0**。

### 复现步骤

```powershell
# 1. 导入资产到场景
douyin-world scene import --asset-id 12211507385090 --position=119.741669,80,95 \
  --instance <IID> --request-id kit-ruler
# -> status: committed

# 2. 保存
douyin-world scene save --instance <IID> --request-id save-kit
# -> status: committed

# 3. 启动运行时（含完全重启）
douyin-world runtime start --instance <IID>

# 4. 遍历运行时层级
# -> WorldRoot(children=0, active=true)
# -> meshRenderers = 0
```

### 数据层与运行层的分裂（关键证据）

**数据层 `scene.data` 完整（14 节点）：**

```
1572716200   ruler-bridge-full-v01      ← 根
 -1818323367  ├─ SM_bridge_ruler
 1428914894   ├─ SM_bridge_numerals      ← 刻度数字
 -1498927309  ├─ SM_bridge_post_l
 743114502    ├─ SM_bridge_post_r
 -1492256154  ├─ SM_bridge_bracket_l
 1559331333   ├─ SM_bridge_bracket_r
```

**运行层实际：**

```
roots: Previewer(0) | WorldRoot(0) | TPCameraAvatar(1) | NetworkActorInteractionManager(0)
       | NetworkMasterManager(0) | FestoonedVehicleSpawner(Clone)(0) | NPCSpawner(Clone)(0)
       | Player_1(1) | AvatarHeaderBarRoot(1) | Player(Clone)(0) | InputManager(Clone)(0)
       | ActorAudioGroup(Clone)(0)
meshRenderers   : 0
skinnedRenderers: 2      ← 只有角色
scene           : HamletPreview (1 个场景，已加载)
```

**场景名是 `HamletPreview`** —— 角色预览场景，不是关卡场景。

### 已排除的原因

| 假设 | 检查 | 结论 |
|---|---|---|
| `worldType` 类型错误 | 读官方模板 `templates/empty/project/world-config.json` | ❌ **模板本身也是 `avatar`**，不是异常 |
| 需要 runtime 重启 | 完全 stop → start → 等待 18 s | ❌ 仍为空 |
| 需要 `runtime reload` | 尝试 | ❌ 报 `runtime-generation-conflict` |
| 导入未落盘 | 解包 `scene.data` 回读 | ❌ 节点完整存在 |
| 层级找错位置 | 全图遍历 104 节点，含深度 14 | ❌ 全局 0 个 MeshRenderer |
| 资产本身有问题 | 7 个 GLB 的 SHA 与包内清单 7/7 一致；编辑器正确解析 faceCount | ❌ 资产是好的 |

### 影响

| 受阻项 | 状态 |
|---|---|
| 尺子桥 PNG 刻度解码验证（B-04 强制项） | ⛔ NOT TESTED |
| 玩家视角可见性（B-03） | ⛔ NOT TESTED |
| 尺寸/朝向/X 镜像运行时复测 | ⛔ NOT TESTED |
| REST → 桥体状态切换（B-04） | ⛔ NOT TESTED |
| 一镜到底连续通行（B-05） | ⛔ NOT TESTED |
| 5–8 分钟垂直切片（B-06） | ⛔ NOT TESTED |

**这冻结了 B 线几乎全部验收项。**

### 我的判断

**这不是我的代码或资产的问题。** 三条独立证据：

1. 资产 SHA 7/7 与总设计师交付的清单一致；
2. 编辑器**能**正确解析每个 GLB（`faceCount` 与容器内一致），入库 7/7 成功；
3. `scene.data` 写入完整、层级正确、含 6 个部件。

**失效点在"场景数据 → 运行场景"这一步。** 运行时加载的是 `HamletPreview`，
一个不含关卡几何的角色预览场景。

### 降级尝试（在阻塞期间继续工作）

| 尝试 | 结果 |
|---|---|
| 用运行时 `CreatePrimitive` 建代理几何 | ✅ **可行**——这是我在 Day 1–3 一直能"看到东西"的原因 |
| 用代理几何跑通闭环逻辑 | ✅ 已做到（门禁规则 `ruleFires true→false`、状态切换） |
| 用代理几何验证尺子桥的**比例关系** | ✅ 部分可行（用 8 m 箱体代替） |
| 验证真实 GLB 的材质/刻度 | ❌ **无法替代**，必须等真实加载 |

**所以我可以继续做逻辑与比例验证，但无法交付"真实资产看起来对"的证据。**

### 需要谁做什么

| 对象 | 请求 | 优先级 |
|---|---|---|
| **成员 B 本人（GUI）** | 在编辑器里**新建一个场景/地图类型的工程**，重复 `scene import`，看 `WorldRoot` 是否有子节点 | **P0** |
| 成员 B 本人（GUI） | 若新建工程可行 → 把资产导入该工程，B 线全部验收可在那里完成 | **P0** |
| A（集成） | A 在自己工程导入同一份 GLB，确认 `WorldRoot` 是否为空 | P1 |
| 编辑器侧 | 报告：avatar 预览场景是否本就不加载 `scene.data`；关卡场景如何创建 | P1 |

### 恢复条件

任一条满足即可恢复：
1. 有一个**能加载场景几何**的工程，`WorldRoot` 子节点 > 0；
2. 或确认 `runtime start` 需要额外参数/步骤才会加载场景内容；
3. 或提供官方说明：何种工程的 runtime 会实例化 `scene.data`。

---

## B-08｜尺度规律：`√T` 二次缩放（已复现，非阻塞）

### 现象

编辑器读回的 `scale` 字段**等于该资产的最长边**，因此实际尺寸是二次的。

### 在第三方成熟资产上复现

| 资产 | 原创最长边 | 编辑器 scale | 无修正实际尺寸 | 清单目标 |
|---|---:|---:|---:|---:|
| `ruler-bridge-full-v01` | 8.00 | **8.0** | **64.0 m** | 8.0 m |
| `town-row-v02` | 24.13 | **24.13** | **582 m** | 24.13 m |
| `shopfront-v02` | 5.43 | 5.43 | 29.5 m | 4.0 m |

### 修正公式

`节点 scale = 1 / T`（T = 目标尺寸）

| 资产 | 目标 T | 应设 scale |
|---|---:|---:|
| ruler-bridge | 8.0 | **0.125** |
| town-row | 24.13 | **0.041442** |
| shopfront | 4.0 | **0.135663** |
| desk-lamp | 2.69 | **0.633896** |
| cup-harbor | 6.96 | **0.082770** |
| ground-paper | 12.0 | **0.083333** |

### 状态

- **数据层已验证**（读回 `scale` 字段，7/7 全部符合规律）
- **运行层未验证**（因 B-07 阻塞，无法测量真实包围盒）
- 标记：**OBSERVED-LOCAL**，未达到 `REPRODUCED` 的运行时标准

> 这与 Day 1–3 用自建 GLB 实测的规律一致，现在在第三方资产上再次确认。
> 但 `TASK-ACCEPTANCE` 要求真实运行时复测，**在 B-07 解除前不能算通过**。

---

## B-09｜相机与可见带（已确认，转为设计约束）

### 实测

```
camY ≈ 79.587，camZ ≈ 85.3，俯角 18°（向下），FOV 45°（半 22.5°）
⟹ 地平线以上仅 4.5° 余量
⟹ 地面物体可见 ⟺ d ≥ 5.2 m 且 topY ≤ camY + d × 0.0787
```

### 影响

- 与 `TASK-ACCEPTANCE` §B-03 的可见性预算一致；
- `town-row` 24 m 长、5 m 高，**按原尺寸放在 10 m 外会超出上沿**；
  需按 §B-03 的预算摆位或远置。

### 状态

**PASS（实测一致）**，已作为摆位约束写入报告。

---

## B-10｜Trigger 脚本绑定（NOT TESTED，依赖 C）

### 现象

CLI 创建的 `U3dObjectTrigger` 可挂载，但 `_douyinScriptList = nil`，无法绑定行为。

### 状态

- **NOT TESTED**：我在 GUI 中未尝试绑定（CLI 做不到）
- `TASK-ACCEPTANCE` §A 特别要求：「B 的交互入口优先使用 C 已验证的 GUI Trigger + Lua 绑定路线」

### 需要

C 的 **bound Lua Trigger 配方**（`TASK-ACCEPTANCE` Cross-team 要求）。

### 我在等待期间的降级

用**位置规则**实现等效门禁（`ruleFires true→false`），已在
`reports/day-03/B/C4-LOOP-VERIFIED.md` 记录，并明确标注**不是真正的触发器绑定**。

---

## 汇总

| ID | 项 | 状态 | 阻塞等级 |
|---|---|---|---|
| **B-07** | 工程不加载场景几何 | **BLOCKED** | **P0 — 冻结全部资产验收** |
| B-08 | √T 尺度规律 | OBSERVED-LOCAL | P1（数据层已证，运行层待验） |
| B-09 | 相机可见带 | PASS | — |
| B-10 | Trigger 绑定 | NOT TESTED | P1（依赖 C 配方） |
