# 失重花园｜Day 01 技术探针结果

> Owner：成员 C
> 编辑器版本：造世界编辑器 **1.0.105**（`douyin-world` CLI 1.0.105，安装包 `D:\wow-land\造世界编辑器`）
> 项目：`失重花园白盒`（`project-8e9f55c1-590c-4ffa-9dc7-403b8759d19a`）
> 工作区：`workspace_ihycinrp`／WPrefab：`garden-whitebox`
> 所有结论标注：**[已验证]** = 当天实测通过；**[实测不支持]** = 当天实测被拒绝或不存在；**[TO-VERIFY]** = 未测到，不得当作可用

---

## 摘要

| # | 探针 | 结论 | 等级 |
|---|---|---|---|
| T-01 | 项目创建 / 实例启动 | 可创建、可离屏启动 | [已验证] |
| T-02 | SCAD 地图离线渲染 | 可渲染、可导出 GLB、可出三视图 | [已验证] |
| T-03 | **AI 地形生成浮空岛** | **服务明确不支持浮空岛** | [实测不支持] |
| T-04 | Three.js 作者源白盒 | 63 节点，validate/archive/attach/build 全通 | [已验证] |
| T-05 | 碰撞与可走性 | GLB 自带碰撞，玩家能真实走通连续可走面 | [已验证] |
| T-06 | **移动平台组件** | **组件表里不存在** | [实测不支持] |
| T-07 | 程序驱动平台 + 载人 | 平台可上升，玩家被带走 | [已验证] |
| T-08 | **GLB 材质 / 分层配色** | **运行时被统一覆盖，三种改法全失败** | [实测不支持] |
| T-09 | 场景保存 / 关闭重开 | 白盒与可走性都保留 | [已验证] |
| T-10 | 运行时世界边界 | `[0,255]`，越界对象被销毁 | [已验证] |
| T-11 | `prefab attach` 语义 | **追加而非替换**，会留重复副本 | [已验证] |
| T-12 | PCG 地形续轮 | 卡在参考图确认，CLI 无可用回答格式 | [实测不支持] |
| T-13 | 触发体（Trigger）组件 | 组件存在且可写，未接玩法 | [TO-VERIFY] |
| T-14 | 运行时世界边界外的出生点 | 出生在世界中心，白盒必须放在 `[0,255]` 内 | [已验证] |

---

## T-01｜项目创建与实例启动 [已验证]

```
douyin-world project create 失重花园白盒
→ project-8e9f55c1-590c-4ffa-9dc7-403b8759d19a
```

**遇到并绕过的问题**：新实例第一次 `instance start` 失败，日志为
> 独立实例登录状态准备失败，请确认认证源可用或改用新的独立 profile

复现：新 profile 目录里只有 `.awc-auth-bootstrap.lease` 和 `awc-launch.log`，没有 `config.json` / `session/`。

绕过方式（**未修改任何用户既有 profile**，只在启动该次进程时设环境变量）：
```
AWC_CREATOR_AUTH_SOURCE_DIR = <一个已验证可用的既有 profile 目录>
```
设了之后同一命令立即成功。**这属于环境级绕过，不是产品能力结论**，已写进 `BLOCKERS.md` B-01 供 A 参考（A 也要面对同一问题）。

---

## T-02｜SCAD 地图离线渲染 [已验证]

不需要实例、不需要登录，纯本地渲染：

```
authoring resource map render map-probe-01 --backend scad --sources-dir <dir> --width 640 --height 480
→ data.screenshots.overview / reverse / top（Base64 PNG）
→ data.mapGlbSha256 = 0ab0941780...
→ data.layout.slots = []，instances = []
```

**踩到的一个坑**：SCAD 源文件带 UTF-8 BOM 时，渲染报
`Isolated browser page failed: The encoded data was not valid.`
去掉 BOM（写成无 BOM UTF-8）后立刻成功。**结论：SCAD 源必须无 BOM**。已记入 `HANDOFF.md` 供 B 复用。

证据：`evidence/day-01/C/01-scad-terrain-probe-overview.png`

---

## T-03｜AI 地形生成浮空岛 [实测不支持]

这是 Day 1 最重要的否决结论。

提交：
```
generation start map --prompt "漂浮花园地形：三座椭圆形浮岛…浮岛底部呈倒锥形岩层…"
→ taskId generation-36755978-...
```

服务在第一个追问就明确回复：

> **「地图主体是漂浮在空中的浮岛，暂不支持。」**

并强制给出两个选项：改成"地面花园台地地形"，或坚持原要求。

**含义**：AI 地形服务的地形是**连续地面**模型，没有"浮空体"这一概念。因此：

1. 不能用 PCG 地形直接长出浮岛。
2. 可选路线只有两条：
   - **路线 1（推荐）**：AI 地形只负责"台地/谷地"这类连续地形，浮岛由**独立 Model** 承担，再用 Map 槽位装配。这与 `guide map` 的「Map 环境 + 独立 Model 槽位」架构一致。
   - **路线 2**：完全放弃 AI 地形，用 SCAD 或 Three.js 手工做浮岛形状。
3. 这条结论**不阻塞玩法闭环**：白盒已经证明三层垂直关系可以在没有地形的前提下成立。

改答"生成相同风格的其他类型地图参考图"后，服务产出了 4 个台地型候选（中央花丘台地 / 三丘花园谷地 / 层叠花田阶梯 / 岩台花园群），随后卡在下一步，见 T-12。

---

## T-04｜Three.js 作者源白盒 [已验证]

```
authoring resource model create model-garden-whitebox --prefab garden-whitebox --workspace-id workspace_ihycinrp
→ 编辑 static/preview-module.js
→ resource model check → nodeCount: 63
→ resource archive → uri
→ prefab attach → prefab validate → prefab build → result archive
→ scene import → runtime start
```

全链路一次跑通。**白盒结构**（Three.js 内坐标，+Y 上）：

| 层 | 内容 | 高度 |
|---|---|---|
| 根系层 Y=0 | 入口浮岛 r6、根系通道 7 级台阶、温室下方落点平台 r4、远景浮岛群 | 0 – 1.5 |
| 温室层 Y=9 | 倒悬温室（六棱柱 + 半球顶，绕 X 轴 180°）、6 立柱、2 环箍、门框 | 9 – 14 |
| 花冠层 Y=18 | 空中平台链 5 级、花冠观景平台 r4.5、三面护栏 | 10.8 – 18 |

**已知非预期行为**：Three.js 里的 `mesh.name` 在导出后被合并成 `__optimized_merged_material_N`。渲染器被按材质合并，这是引擎的批处理优化，不是错误；但它使"按节点名改单个部件的材质"在白盒阶段不可行（见 T-08）。

---

## T-05｜碰撞与可走性 [已验证]

**第一版失败**（这是有价值的失败）：玩家从入口岛往西走，在 `x = 130.0` 停住，再走不动。

原因：根系桥管抬到 `y = 1.2`，可走面高 = 0，形成 **1.2 m 垂直台阶**，角色控制器上不去。

**修正过程**（两次迭代，都留了记录）：

1. 第一次修正：把圆管换成 7 级扁平方块台阶，每级抬高 ≤ 0.3 m，第一级与岛顶面重叠。
   → 玩家在 `x = 128.7` 仍被挡住。
2. 第二次修正：查出是同一条根系的**圆管半径 0.55、管心与可走面同高**，管顶自然高出可行走面约 0.4 m，物理上是一道矮墙。把圆管统一下沉到 `y = -0.55`（管顶低于方块顶面），装饰支根抬到 3.6 m 以上（高于玩家头顶）。
   → **走通**。

**修正后实测**（真实 `MoveContinuously`，逐帧采样）：

```
start (134.00, 60.00) → end (117.60, 61.50)
路径采样: 130.67/60.15 → 129.32/60.15 → 127.58/60.30 → 126.26/60.55 → 125.81/60.55
```

玩家从入口岛一路走到倒挂温室正下方平台，`y` 单调从 60.00 抬到 61.50，全程踩在可走面上，中间无坠落。

**关掉实例、重开后复测**：`134.00 → 127.90`，`y 60.00 → 60.30`，结论一致。

**这条探针的真实价值**：它证明了「**看得见的连接 ≠ 走得过去的连接**」。参考研究硬结论 2（禁止依赖单一视角的视觉连桥）在此得到本项目的实测支撑——如果白盒阶段不做行走验证，1.2 m 的台阶和 0.4 m 的管壁都会在美术阶段被漂亮的根系模型完整保留下来。

---

## T-06｜移动平台组件 [实测不支持]

`components.listTypes` 返回的全部可写组件：

```
assetData, editorOnlyData, terrainDisplayData, waterDisplayData, riverDisplayData,
waterEditorData, waterBodyAuthoringData, waterAppearanceData, billboardPlantData,
physicsColliderData, triggerData, animatorData, ugcAnimatorData, effectData,
particleSystemData, text3DData, appearanceData, lightData, aigcModelData,
localPrefabData, glbSliceData
```

**没有任何平台/移动/路径组件。** `physicsColliderData` 只有 `enableRigidBody / mass / isKinematic / useGravity / drag / angularDrag` 等刚体标量，没有速度、路径、往返、触发位移字段。`animatorData` / `ugcAnimatorData` 是角色与骨骼动画，不是场景物件位移。

**结论**：想做移动平台，只能用 Lua/JS 程序驱动 Transform。这决定了移动平台的实现成本，也决定了降级顺序。

---

## T-07｜程序驱动平台 + 载人 [已验证]

既然没有原生组件，就当场验证"程序驱动是否够用"。

```
创建 Cube（3 × 0.3 × 3），置于 (128, 70, 120)
循环 20 次，每次 y += 0.25，每步 awaitFrames(2)
→ start 70.00 → end 74.75  moved: true
```

载人验证：
```
玩家 teleport 到平台正上方 (128, 76.5, 120)
平台从 y = 74.75 抬到 y = 80.55（+5.80）
玩家 y: 74.90 → 78.09  carried: true
```

**结论**：程序驱动平台**可行性已确认**，且玩家会被平台带走（不是穿模掉落）。

**但这不是"移动平台玩法已验证"**。缺的是：往返循环、玩家离开后的复位、多人/网络同步、以及"平台移动时玩家跳跃"的组合行为。这些留到 Day 3（C-G3）。

**降级顺序**（按 `COORDINATION-PROTOCOL.md` §5 要求的最低成本方案）：
1. 程序驱动往返平台（当前可行性最高）
2. 固定平台 + 触发式状态切换（平台瞬移到另一位置）
3. 短距离传送点
4. 纯固定平台（**这是底线，且已经足够**：白盒证明不需要移动平台也能完成三层通行）

第 4 条很关键：**失重花园不依赖移动平台也能成立**。移动平台是加强项，不是体验成立的前提。这意味着 T-06 的否决不构成玩法风险。

---

## T-08｜GLB 材质与分层配色 [实测不支持] ⚠️ 当天最严重问题

**现象**：白盒在 Three.js 里给每个层设了不同颜色的 `MeshStandardMaterial`（根系层绿、温室层蓝、花冠层紫、岩层棕、玻璃半透明）。进入运行时后，**所有几何体都是同一个青蓝色**，层与层无法区分。

**三次改法全部失败**，逐条记录：

| 尝试 | 做法 | 结果 |
|---|---|---|
| 1 | Three.js 源里 `new MeshStandardMaterial({color})` | 导出后在运行时失效 |
| 2 | `appearanceData` 组件写 `color` + `isModified: true` | 写入成功（`components: 5`），渲染无变化 |
| 3 | 运行时直接改 `mr.sharedMaterial.color` | 改完截图仍无变化 |

**运行时诊断**：遍历所有 `MeshRenderer` 的 `sharedMaterial.name`：

```
__optimized_merged_material_0..7 → "EnvLit_AI_Mat"
__optimized_merged_material_4    → "EnvLit_AlphaBlend_AI_Mat"  ← 玻璃（透明）
EntryIsland / UnderGreenhousePad / RootCorridor_Y0 / Greenhouse_Y9 / CrownZone_Y18
                                 → "Standard (Instance)"
```

**根因**：编辑器在导入 GLB 后，把几何按材质**合并**并统一赋予环境光照材质 `EnvLit_AI_Mat`。原始的 PBR 颜色不再是权威来源。

**含义与影响**：

1. 白盒阶段的"分层配色"必须换一条路：**用独立的 Model 资源分件**（每种材质一个资源），或在编辑器侧用原生材质系统重建，而不是靠 GLB 内嵌材质。
2. **美术阶段的风险放大**：如果 Day 4 用 Tripo 生成带颜色贴图的巨花/温室，导入后可能同样被统一材质覆盖。这条必须**在 Day 4 之前**由总设计师与 A 共同确认，否则关键美术会白做。
3. Day 2 的「哪些能走」灰度测试（参考研究硬结论 1 的验收方法）**必须先解决材质问题**才能做。

**未解决**，已列为 `BLOCKERS.md` B-02，优先级最高。

---

## T-09｜场景保存 / 关闭重开 [已验证]

```
runtime stop
scene save --request-id c-save-02
→ status: committed, hasUnsavedChanges: false

instance stop <instanceId>        ← 完全关闭进程
instance start --project <同上>   ← 新实例、新 profile
runtime start
→ GameObject.Find('garden-whitebox') → present: true, pos (120, 60, 120)
→ 走位复测 134.00 → 127.90，y 60.00 → 60.30
```

**结论**：白盒几何、位置、碰撞、可走性在**跨实例、跨 profile 重开**后全部保留。

同时确认了 `PRODUCTION-OPERATING-SYSTEM.md` 里那句关键规则：`instance stop` **不会自动保存**。必须先 `scene save` 再停；停之前不保存，改动就丢。这条要转告 A/B。

---

## T-10｜运行时世界边界 `[0,255]` [已验证]

`guide` 的 `player-movement-jumping-and-triggers.md` 写明：任一轴 < 0 或 > 255 的 GameObject 会被 Runtime 边界清理销毁。

**我方踩了一次**：白盒初始用 `z = -25` 这类坐标（Three.js 里很自然），`scene import` 不带 `--position` 时沿用原落点，对象被销毁，`GameObject.Find` 返回 `null`，画面全空。

修正：`scene import --position 120,60,120`，并且**白盒内部坐标必须保持正数**。修正后又发现导出时 X 轴被镜像（入口岛在 `x = 134` 而不是 `x = 114`），因此**所有按名字查位置的外部脚本都要以运行时实测坐标为准，不能用手写坐标**。

---

## T-11｜`prefab attach` 是追加不是替换 [已验证]

第二次 `prefab attach` 新版本模型后，`nodes.query` 出现**两套同名节点**：

```
n2  Model / n4 EntryIsland / n6 UnderGreenhousePad / n7 RootCorridor_Y0 / n8 Greenhouse_Y9 / n10 CrownZone_Y18
n28 Model / n30 EntryIsland / n32 ... / n36 ...
total = 53
```

后果：场景里有两份几何叠在一起，碰撞与视觉都会出错。

**正确做法**：attach 新版本前先 `scene.nodes.remove({nodes:[<旧 Model 句柄>]})` 删掉旧副本，再 attach。修正后 `total = 27`，`modelCount = 1`，`dup = []`。

这条要写进 `HANDOFF.md`：**A/B 迭代模型时如果不删旧副本，会得到几何翻倍的场景，而且看起来只是"有点卡"。**

---

## T-12｜PCG 地形续轮卡在参考图确认 [实测不支持]

改答第一个问题后，服务进入第二步，产出 4 个参考图候选，要求回答：

```json
{ "pcg": { "kind": "reference_image",
           "previewArtifactIds": ["preview_yj6wpsy9", ...],
           "recommendedArtifactId": "preview_yj6wpsy9" },
  "options": [{ "label": "确认" }] }
```

`generation answer` 对这道题**所有已试格式都被拒绝**：

| 尝试的答案载荷 | 服务返回 |
|---|---|
| `[{"questionId":"...","optionIndex":0}]` | `answers must contain string arrays` |
| `[["生成相同风格的其他类型地图参考图"]]` | `Invalid PCG question answer` |
| `[["确认"]]` | `Invalid PCG question answer` |
| `[["preview_yj6wpsy9"]]` | `Invalid PCG question answer` |
| `[{"artifactIds":["preview_yj6wpsy9"]}]` | `answers must contain string arrays` |

也就是说：普通选项题用 `[["标签"]]` 可以过（第一问我就是这么答过去的），但 `pcg` 类型的题目需要另一种结构，CLI 帮助里没有说明。

**影响**：地形续轮暂停。**不影响白盒与玩法闭环**（见 T-03 的结论 3）。
**建议**：A 若也要用 PCG 地形，会撞到同一堵墙。已写入 `HANDOFF.md` 与 `BLOCKERS.md` B-04，请 A 优先攻这个，因为 A 的终点站也需要地形。

---

## T-13｜Trigger 组件 [TO-VERIFY]

`triggerData` 组件存在且 `writable: true`，schema 支持 `box / sphere / capsule`、`center`、`size`、`radius`、`height`、`direction`、`enabled`。

**但 Day 1 没有接任何玩法逻辑**。因此"触发器能触发什么、能调用什么、与 Lua 绑定的实际入口"全部是 `[TO-VERIFY]`。

Day 3 前必须验证：玩家进入 Trigger → 是否能驱动另一节点位移（这决定"触发式平台"这个降级方案是否成立）。

---

## T-14｜出生点与世界坐标 [已验证]

新项目运行时玩家出生在 `(119.74, 77.91, 88.64)`，即**世界中心附近**，不是白盒位置。

因此白盒必须显式 `--position` 到玩家附近，或玩家必须被传送过去。Day 2 做入口白盒时，**入口浮岛应直接放在出生点脚下**，避免"进入世界后发现自己在云海上"。

---

## 结论：能力矩阵（交给 A / B 复用）

| 能力 | 状态 | 备注 |
|---|---|---|
| 项目创建 / 实例启停 | 可用 | 需 `AWC_CREATOR_AUTH_SOURCE_DIR` 绕过登录引导 |
| SCAD 地图离线渲染 | 可用 | 源文件必须无 BOM |
| Three.js 作者模型 → 场景 | 可用 | 全链路验证通过 |
| GLB 碰撞 + 玩家行走 | 可用 | 必须实测，不能靠几何判断 |
| 场景保存 / 跨实例重开 | 可用 | `instance stop` 不自动保存 |
| 程序驱动节点位移 | 可用 | 唯一的位移手段 |
| 平台载人 | 可用 | 已验证 |
| 原生移动平台组件 | **不存在** | |
| AI 地形生成浮空岛 | **不支持** | |
| GLB 材质在运行时保留 | **不支持** | 被 `EnvLit_AI_Mat` 覆盖 |
| PCG 参考图确认 | **CLI 无可用格式** | |
| Trigger 驱动玩法 | 未验证 | |
| 重力方向变化 | 未测 | 本轮不需要，不做 |
