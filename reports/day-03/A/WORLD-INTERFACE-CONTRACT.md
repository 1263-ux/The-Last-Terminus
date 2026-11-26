# World Interface Contract v0.2｜世界接口契约

> Owner：成员 A（公共接口维护者）
> 状态：**PROPOSED → 部分 CONFIRMED**（待总设计师 Gate D3 与 B/C 回填）
> 基于：v0.1（`reports/day-01/A/`）+ Day-3 实测（`GLB-IMPORT-MATRIX.md`、`COLLISION-MATRIX.md`）
> 标记：**CONFIRMED** 已实测 / **PROPOSED** 建议 / **TO-VERIFY** 待验证

---

## 1. 玩家尺度基线

| 字段 | 值 | 状态 | 适用条件 |
|---|---|---|---|
| 胶囊半径 | **0.16 m** | CONFIRMED | 编辑器 1.0.104，默认角色配置（Day-1 P07） |
| 胶囊总高 | **0.90 m** | CONFIRMED | 同上 |
| 胶囊中心 | y = **0.45 m** | CONFIRMED | 同上 |
| **玩家渲染高度** | **0.941 m** | **CONFIRMED (B)** | **B `player_height.lua` 实测渲染包围盒（两渲染器 body+face）；foot y=77.905** |
| 碰撞直径 | **0.32 m** | CONFIRMED | 半径 ×2 |
| 视觉身高 | ≈ **1.7 m** | PROPOSED | 用于地标可见性判断，不用于通道判定 |
| 相机高度 | 角色上方约 **1.01 m** | CONFIRMED | Day-1 P08 |
| 相机跟随距离 | **1.80 m**（默认），有碰撞避让 | CONFIRMED | Day-1 CAMERA-REPORT A/B |
| `moveMaxSpeed` | 4.0 | CONFIRMED | 场景数据 |
| `jumpMaxHeight` | 1.0 | CONFIRMED | 场景数据 |
| `respawnHeightY` | −50.0 | CONFIRMED | 场景数据 |

> 角色 / 配置 / 版本变化时须复测（总设计师 `EDITOR-TECHNICAL-FINDINGS.md` 已标此缺口）。

**几何判定规则（CONFIRMED 部分）：**
- 行走通道硬下限 **0.8 m**（0.32 m 直径 + 余量）；视觉舒适建议 ≥ 1.5 m。
- 门洞硬下限 **0.6 × 1.2 m**；视觉舒适 ≥ 1.0 × 2.0 m。
- Trigger 竖直范围必须覆盖 **y ≈ 0.45 m**（胶囊中心层）。
- **可跨越台阶上限 0.45 m**（CONFIRMED by C，2026-11-25）：花冠台沿 0.56 m 实测挡死玩家；可走面周边不得用 ≥ 0.45 m 围边。
- **可走面正中央不得放 ≥ 0.25 m 装饰体**（SpawnMarker 事故）；观景点护栏须低于视线或留缺口。

## 2. Entry / Exit Anchor

| 字段 | 类型 | 状态 | 说明 |
|---|---|---|---|
| `world_id` | string | CONFIRMED 格式 | `desk` / `garden` / `terminus` / `train` |
| `world_version` | string | CONFIRMED 格式 | `YYYYMMDD-<commit7>` |
| `source_commit` | string | CONFIRMED 格式 | 交付快照 commit |
| `anchor_id` | string | CONFIRMED 格式 | 唯一，如 `desk.entry` |
| `role` | enum | CONFIRMED | `entry` / `exit` |
| `position` | vec3 m | CONFIRMED 格式 | **world 坐标**，须落 `[0,255]`（C 的约束，A 的边界测试部分支持） |
| `spawn_position` | vec3 m | CONFIRMED 格式 | 玩家实际落脚地面点 |
| `spawn_yaw` | float deg | **garden CONFIRMED / desk TO-VERIFY** | 面向下车后第一个地标；**Garden 实测 = 0°(+Z)**，见 §2b；Desk 待 B 回填 |
| `safe_zone_radius` | float m | CONFIRMED 格式 | ≥ 2.5 建议；C 的入口岛 r=6 |
| `trigger_size` | vec3 m | CONFIRMED 默认 | A 默认 `(3,4,3)`；`center.y=0.5`（**局部坐标，不预乘祖先缩放**） |
| `return_target` | string | CONFIRMED 格式 | `train.hub` 或另一 anchor_id |
| `fallback` | object | CONFIRMED 格式 | 失败恢复点 |

**已实测限制（CONFIRMED）：**
1. **脚本与 Trigger 必须同节点** —— Hamlet 的 `OnActorTriggerEnter` 不冒泡。
2. **Trigger 中心是局部坐标且不预乘祖先缩放** —— 节点抬高 1 m 后 `center.y` 再写 1 会静默失效。
3. **entry / exit 体积间距 ≥ 8 m，冷却 ≥ 2 s** —— 太近会来回传送振荡。
4. **坐标须在 [0,255]** —— C 实测越界异常；A 的边界测试看到越界后对象异常（部分支持）。
   A 提议分区：列车 (40,60,40)、书桌 (120,60,40)、花园 (120,60,120)、终点 (40,60,120)。

### 2b. 实测 Anchor 回填

| 世界 | anchor | position (m) | spawn_yaw | 状态 | 来源 |
|---|---|---|---|---|---|
| **Garden** | `garden.entry` | **(120, 70, 105)** | **0°(+Z)** | **CONFIRMED** | C `A-INTERFACE.json`，运行时实测（entry 岛可走面 y=70.05，玩家落 y=70.00） |
| Garden | `garden.exit` / vista | (120, 76.01, 135) | — | **PARTIAL FAIL** | 台面存在但 0.56 m 台沿挡死步行入口；C 提修复提案 |
| Garden | `garden.return` | (120, 70, 107) | — | **CONFIRMED** | 坠落复位实测：云垫→1:respawned→落该点 |
| Garden | 安全区（坠落体积） | center (120,55,127), size (60,4,70), y 53–57 | — | CONFIRMED | C_TriggerProbe 云垫 |
| Desk | `desk.entry` | **(119.74, 79.41, 88.64)** | 待 B 回填 | **CONFIRMED (B 实测)** | B `RUNTIME-ENTRY-DIAGNOSIS.md`：出生 z=88.64 y=79.41，桥 active=false |
| Desk | `desk.exit` / town arrival | **(≈119.74, 79.41, 120.07)** | 待 B 回填 | **CONFIRMED (B 实测)** | B：前进到 z=120.07 到小镇平台，y 全程 79.41，6 扇窗反馈 |
| Desk | `desk.gate` | (119.74, 79.41, 96.33) | — | CONFIRMED | B：z=96.33 玩家主动触发桥 REST→RAMP；关桥则掉入断口 |

**A 的集成动作（Garden B-01 阻塞）**：C 报告全局 `出生点` 仍在 (119.7,80,88.6)，落在地形顶而非入口岛；
花园路线在地形面以下（y 66–76，地形顶 77.90–78.31），全图无地形洞，从出生点走不到入口岛。
→ **需将全局出生点改到 (120,70,105) 或开正规入口**（GUI 操作 + 保存重开验收，待 GUI 会话）。
→ C 另附机器可读接口 `reports/day-04/C/A-INTERFACE.json`（在 C 的 `work/c-garden-closeout-1124` 分支）。

## 3. GLB 坐标 / 尺寸 / 材质 / Collider 规则

| 规则 | 状态 | 内容 |
|---|---|---|
| X 轴镜像 | **CONFIRMED (REPRODUCED)** | 作者 +X → 编辑器 −X；Y/Z 不变。两次独立实验（`P02`、`A2`）。机制未明（TO-VERIFY） |
| 尺寸 1:1（A 的 resource model import 链路） | **CONFIRMED** | 1/2/4 m 三样本，源/数据/运行时三方对照，scale 全 1，无二次放大 |
| 尺寸放大（直接 scene import 裸 GLB） | **PROPOSED（B 局部经验）** | `actual = source × longestEdge` / `sqrt(T)` 仅在 B 路径观察，**不得升为全局公式** |
| 材质字段 | **CONFIRMED** | `EnvLit_AI` shader 用 `_BaseColor` / `_BaseTex`；查 `color`/`mainTexture` 得空是假故障 |
| 贴图保留 | **CONFIRMED** | 内嵌 PNG 在 `_BaseTex` 可见，渲染正常 |
| NORMAL 必带 | **CONFIRMED（C-11）** | 无 NORMAL → 有影子没表面 |
| `triggerData` → BoxCollider(isTrigger) | **CONFIRMED** | Day-1 P05 |
| `physicsColliderData` 单独 → 无运行时 Collider | **CONFIRMED (FAIL)** | Day-3 A3：`enableCollision=true` 但运行时无 Collider；需 Mesh 配合（TO-VERIFY） |
| GLB 自带 MeshCollider | **PROPOSED** | Day-1 观察到 GLB 节点有 MeshCollider isTrigger=false，但**未做撞击行走**，不能宣称能挡人 |

## 4. WPRE 交接

| 项 | 状态 | 说明 |
|---|---|---|
| `.wprefab` 是 ZIP 清单 | CONFIRMED | `resourceRefs` 为空，模型靠外部 URI |
| 同机同账号跨工程导入 | **CONFIRMED (REPRODUCED)** | 层级/碰撞数据/脚本/参数/传送全保留 |
| 跨账号 / 跨机器 | **TO-VERIFY** | 未测；必须附裸 GLB + 贴图 + Manifest 兜底 |
| `prefab attach` 是追加 | CONFIRMED | B/C 均已独立发现；迭代前必须 `scene remove` 旧根 |

## 5. 交付文件清单（每个世界）

`WORLD-CARD.md` / `ASSET-MANIFEST.csv` / `SCENE-STRUCTURE.md` /
`INTERACTION-FLOW.md` / `ENTRY-EXIT.md` / `KNOWN-ISSUES.md` /
实际 `.wprefab` + 裸 GLB + 贴图 / 远中近截图 / 玩法录屏。

## 6. v0.1 → v0.2 变更

- 新增玩家胶囊 / 相机的适用条件与版本标记；
- 新增 `[0,255]` 坐标约束与四分区建议；
- GLB 尺寸规则拆成"两条路径"，明确禁止全局公式；
- 新增 Collider 三层结论（triggerData PASS / physicsColliderData FAIL）；
- WPRE 状态精确到 REPRODUCED-LOCAL（同机同账号）；
- 所有字段加 CONFIRMED / PROPOSED / TO-VERIFY 标记。


---

## 四世界连接当前状态（11/26 裁定后，诚实标注）

| 段 | 状态 | 依据 |
|---|---|---|
| `desk.entry/exit` | CONFIRMED（B 实测坐标） | 上表 |
| `garden.entry/return` | CONFIRMED（C 实测坐标） | §2b |
| `garden.exit/vista` | PARTIAL FAIL | 0.56m 台沿挡步行；C 的 A′ 补丁待批 |
| `hub.*` / `terminus.*` | **TO-VERIFY** | A 工程 BornPoint 仍在 (119.74,80,88.64)；无 GUI 验收 |
| Hub→Desk→Garden→Terminus 物理连接 | **NOT TESTED** | 坐标已部分回填，但"坐标写进契约"≠"连接跑通"；需 GUI + Trigger 实测 |

> 裁定明确：优先修 Hub 主出生点 + 可触发连接；无缝加载非硬目标，稳定过场/传送可交付。
