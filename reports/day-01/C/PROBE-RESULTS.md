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
| T-08 | **GLB 材质 / 分层配色** | **已解决：必须写 shader `_BaseColor`，`material.color` 无效** | [已验证·已解] |
| T-08b | 带贴图 GLB 进场景 | **我的最小带贴图 GLB 导入失败；去贴图即成功** | [信号明确·待真机复测] |
| T-09 | 场景保存 / 关闭重开 | 白盒与可走性都保留 | [已验证] |
| T-10 | 运行时世界边界 | `[0,255]`，越界对象被销毁 | [已验证] |
| T-11 | `prefab attach` 语义 | **追加而非替换**，会留重复副本 | [已验证] |
| T-12 | PCG 地形续轮 | 卡在参考图确认，CLI 无可用回答格式 | [实测不支持] |
| T-13 | 触发体（Trigger）驱动玩法 | 回调/位移/复位/计时器全通 | [已验证·端到端] |
| T-17 | 可跨越台阶高度上限 | 实测 ∈ [0.45, 0.50) m，修正了 0.30 m 的保守假设 | [已验证] |
| T-18 | 可走坡度上限 | 实测 > 50°，45° 设计假设成立；陡坡拖慢水平推进 | [已验证] |
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

1. 第一次修正：把圆管换成 7 级扁平方块台阶，每级抬高 ≤ 0.3 m，第一级与岛顶面重叠。（当时按保守的 0.30 m 取值设计；T-17 实测上限其实是 0.45 m，0.3 m 仍安全。）
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

## T-08｜GLB 材质与分层配色 [已验证·已解决] ✅

> **状态更新**：Day 1 当天一度判定为"不支持"，**当天已攻破并交付可持久化方案**。下面的失败记录保留，因为"哪些入口无效"对 A/B 同样有价值。

### 现象

白盒在 Three.js 里给每层设了不同颜色的 `MeshStandardMaterial`（根系层绿、温室层蓝、花冠层紫、岩层棕、玻璃半透明）。进入运行时后，**所有几何体都是同一个青蓝色**，层与层无法区分。

### 三次失败（当天前半段）

| 尝试 | 做法 | 结果 |
|---|---|---|
| 1 | Three.js 源里 `new MeshStandardMaterial({color})` | 导出后在运行时失效 |
| 2 | `appearanceData` 组件写 `color` + `isModified: true` | 写入成功（`components: 5`），渲染无变化，且**重新 attach 后组件直接丢失** |
| 3 | 运行时改 `mr.sharedMaterial.color` | 无变化 |

运行时诊断，遍历 `MeshRenderer.sharedMaterial.name`：

```
__optimized_merged_material_0..7 → "EnvLit_AI_Mat"
__optimized_merged_material_4    → "EnvLit_AlphaBlend_AI_Mat"  ← 玻璃（透明）
EntryIsland / UnderGreenhousePad / RootCorridor_Y0 / Greenhouse_Y9 / CrownZone_Y18
                                 → "Standard (Instance)"
```

### 根因（关键发现）

拉出 shader 属性表：

```
shader: Douyin/AI/PBR/EnvLit_AI
34 个属性，其中颜色相关的是 _BaseColor，不是 Unity 标准的 _Color。
```

**`material.color` 访问的是 `_Color`，而这个 shader 根本不使用 `_Color`。** 所以前三次尝试看起来"写成功了"却毫无渲染变化——写进了一个没人读的属性。

### 正确做法（已验证）

```javascript
mr.sharedMaterial.SetColor("_BaseColor", new CS.UnityEngine.Color(r, g, b, 1));
```

A/B 对照实测：

- 只改 `_BaseColor`、**不动** `_UseVertexColor` → 颜色立即生效（远处浮岛变紫，入口岛保持红）。
- 结论：`_UseVertexColor` 不是必要条件，无需一起改。

### 持久化方案（本项目采用）

运行时改色只活一轮。为了"每次运行自动正确"，绑定了一个 Lua 脚本：

```
scripts/garden_layer_tint.lua
→ scripts.bind({ nodes: [<Model 根节点>], script: <scriptId> })
```

脚本在 `Start()` 里遍历子树所有 `MeshRenderer`，按**相对本节点原点的局部高度**分三层赋色，走 `_BaseColor`。参数（五层颜色 + 两个高度分界）都做成面板可调：

```lua
---@var RootColor:Color=(0.42,0.72,0.44,1)
---@var GreenhouseColor:Color=(0.36,0.66,0.82,1)
---@var CrownColor:Color=(0.72,0.56,0.86,1)
---@var RockColor:Color=(0.30,0.26,0.24,1)
---@var FarColor:Color=(0.62,0.70,0.78,1)
```

**重要设计取舍**：用**局部高度**而不是世界坐标。WPrefab 可以被放到任意世界位置、旋转、缩放，写死世界坐标会在集成时全部错位。这条也写进了 `HANDOFF.md`。

### 验证链（全部通过）

1. 手动改 `_BaseColor` → 颜色变（截图 `mat-test-red-entry.png`）
2. 绑定 Lua → 重新运行自动变（截图 `11-entry-colored-layers.png`）
3. **关闭实例 → 新实例 → 新 profile → 重新运行 → 颜色仍在**（截图 `13-colors-persisted-after-restart.png`）
4. 着色后复测行走：`134.00 → 127.40`，可走性未受影响

### 对 A/B 的意义

| 结论 | 影响 |
|---|---|
| 颜色必须写 `_BaseColor` | 任何用 GLB 做视觉区分的场景都必须走这条路 |
| `material.color` / `appearanceData` 无效 | 不要在这两个入口上浪费时间 |
| `appearanceData` 重新 attach 会丢 | 不要依赖组件做持久视觉配置 |
| 持久化必须用 Lua 脚本 | 运行时手改不跨轮次 |
| **贴图是否保留仍未验证** | 只测了纯色，**带贴图的 GLB 是下一个必须测的项** |

**残留风险**：`_BaseTex` 属性存在，说明 shader 支持贴图，但**没有验证导入的 GLB 贴图实际是否被采样**。Day 4 的 Tripo 模型如果依赖贴图细节，必须先补这个探针。已记入 `BLOCKERS.md` 的 R-06。

---

## T-08b｜带贴图 GLB 是否保留贴图 [部分验证·有明确信号]

**为什么要测**：T-08 只修好了**纯色**。Day 4 的 Tripo 模型如果依赖贴图细节，必须先知道贴图会不会被吞掉。

### 做法

用 Python 手写一个最小带贴图 GLB（24 顶点立方体 + 256×256 红蓝棋盘 PNG，`baseColorTexture` 指向内嵌 bufferView），
`resource model import` 导入 → `check` 通过（`modelType: 1, nodeCount: 1`）→ `archive` 成功拿到 URI。

### 结果（这是一个真实信号，不是"没测出结论"）

| 步骤 | 结果 |
|---|---|
| GLB 导入 + check + archive | **通过**（贴图随包被打包，没有在导入阶段报错） |
| `prefab attach` 到已有 WPrefab | 通过 |
| `prefab build` + `result archive` | 通过 |
| **`scene import` 到主场景** | **失败** —— `节点导入失败，脚本已保留，可重试导入（阶段：runtime）` |

**关键对照**：把带贴图节点从 prefab 里删掉、重新 build/archive 后，同一场景**立刻导入成功**（`c-import-base-02`）。

也就是说：**失败是带贴图节点引起的，不是场景或流程问题。** 同一个 prefab、同一台机器、同一个 request 流程，去掉贴图节点就能进，带上就进不去。

### 含义

1. **不能假定"Tripo 导出的带贴图 GLB 能直接进场景"**。这条在 Day 4 之前必须由总设计师/我一起处理。
2. 当前可用的安全路线是：**几何承重 + `_BaseColor` 上色 + 分件材质**，不依赖贴图。这条路线已在白盒上完整验证（T-08）。
3. 尚未定位失败的具体原因（是 bufferView 布局、mimeType、还是编辑器对贴图 GLB 的额外约束）。**我手写的是最小 GLB，可能是我的构造有问题，不排除标准的 Blender/Tripo 导出能正常导入。**

### 诚实边界

这条结论的强度是"**我的最小带贴图 GLB 进不了场景**"，不等于"所有带贴图 GLB 都进不了"。要下后者结论，必须用**一个真实导出器（Blender 或 Tripo）产出的带贴图 GLB** 再测一次。已列入 Day 2 待办。

### 对 Day 4 的直接影响

| 如果…… | 那么 Tripo 模型应该…… |
|---|---|
| 真实导出的带贴图 GLB 能进 | 正常走贴图流程，细节靠贴图 |
| 真实导出的带贴图 GLB 也进不去 | **必须改为分件 + `_BaseColor`**，花瓣/花心/茎/根分成独立 Model，靠几何和纯色表达层次，不靠贴图 |

这条必须在 Day 4 前定，否则关键美术会返工。

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

**结论**：白盒几何、位置、碰撞、可走性在**跨实例、跨 profile 重开**后全部保留。**分层配色同样保留**（Lua 脚本在 `Start` 重新赋色，见 T-08）。

同时确认了 `PRODUCTION-OPERATING-SYSTEM.md` 里那句关键规则：`instance stop` **不会自动保存**。必须先 `scene save` 再停；停之前不保存，改动就丢。这条要转告 A/B。

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

## T-13｜Trigger 驱动玩法 [已验证·端到端跑通]

> 原为 `[TO-VERIFY]`，Day 2 补齐。这是 C-G3 的 backup cue（`SPATIAL-PROPOSALS.md` §8.6）与掉落复位的最小前置。

### 探针搭建

1. 新建节点 `C_TriggerProbe`，挂 `triggerData`：`shape="box"`, `center=(0,0,0)`, `size=(6,3,6)`
2. 新建 `scripts/trigger_probe.lua`，绑定该节点
3. 脚本里逐个声明 `OnActorTriggerEnter/Exit`、`OnPlayerTriggerEnter/Exit`、`OnTriggerEnter/Exit`
4. `validate → build → result archive → scene import → runtime start` 全链路通过

运行时实测 trigger 节点在世界 `(120, 70.5, 108)`，box 覆盖 `x∈[117,123]`, `y∈[69,72]`, `z∈[105,111]`。

### 验证 1：回调确实会触发

玩家从 `z=103` **真实走过**边界到 `z=108.6`（不是 teleport）：

```
BEFORE: 0:none
AFTER : 4:OnTriggerEnter,OnPlayerTriggerEnter,OnTriggerEnter,OnActorTriggerEnter
```

走出边界回到 `z=104.2`：

```
8:...,OnTriggerExit,OnActorTriggerExit,OnTriggerExit,OnPlayerTriggerExit
```

**结论**：6 个回调全部可用，enter/exit 成对触发。`OnTriggerEnter` 触发了两次（可能与 Actor 和 Collider 双重登记有关），需要在正式玩法里做去重或用 `OnPlayerTriggerEnter` 作为唯一入口。

### 验证 2：回调里能驱动节点位移

Lua 里 `self.transform.position = ...`（进入时 +1 m，退出时 −1 m）：

```
调用 MoveOnEnter() 前 trigger 节点 y = 70.50
调用后                        y = 71.50   ✅
```

**结论**：**触发式平台这个降级方案成立**。T-06 确认没有原生移动平台组件，但「Trigger + Lua 写 transform」这条路径可用，且不需要每帧 `Update`。

### 验证 3：掉落复位的最小形态

`RespawnLocal()` 用 `CS.DouyinActorService.GetLocalActor()` 拿到本地 Actor 并传送回入口检查点：

```
调用前 (130, 8.8, 150)   ← 玩家已掉出世界
调用后 (120, 70.5, 102)  ✅ 回到入口岛
```

**结论**：掉落复位可实现。这解掉了 `PLAN-C-WHITEBOX.md §5` 里的「坠落复位未做」，以及 `SPATIAL-PROPOSALS.md §4.7` 的 `[TO-VERIFY]`。

### 踩到的一个真实坑（Lua 冒号调用）

第一版写 `a.Teleport(v)`，报错：

```
System.InvalidCastException: Unable to cast object of type 'Vector3' to type 'DouyinActor'.
```

原因：Lua 里 `a.Teleport(v)` 把 `v` 当作 `self` 传给了 C# 实例方法。`Teleport` 是实例方法，必须用**冒号调用** `a:Teleport(v)`，才会把 `a` 作为 self。改成冒号后立刻成功。

这条与 `guide` 里「静态方法用 `.`、实例方法用 `:`」一致，但很容易在写探测脚本时漏掉，特此留档给 A/B。

### 观测方法的坑

`---@varSync` 注入的是**装箱对象**，外部 `lua eval` 读回是 `{"__type":"userdata"}`，无法直接观测。因此探针额外用了 `_G.C_TRIG_LOG` 普通全局表记录事件，并返回**纯字符串** `count:event1,event2,...`。这个模式可复用。

### 验证 4：计时器（backup cue 的核心机制）

`SPATIAL-PROPOSALS.md §8.6` 要求「玩家停留 > 45 s 未发现路线时给第一次提示」，这需要一个能跨帧计时、且能触发一次的条件状态机。

在同一个 `trigger_probe.lua` 里加 `Update()`，累加帧数并读 `CS.UnityEngine.Time.time`，探针阈值设 3 s（正式玩法改 45 s）。实测：

```
立即读取:   tick=471, span=23.64, cue=true
6 s 后:     tick=600, span=30.09, cue=true
事件日志:   0:TimerCue     ← TimerCue 已写入 _G.C_TRIG_LOG.events
```

**结论**：`Update()` 每帧运行、`Time.time` 可读、一次性触发的计时 cue 成立。backup cue 的最小技术集合（进入判定 + 计时 + 一次性触发）已全部打通。

### 仍未验证

| 项 | 说明 |
|---|---|
| 动态点光 / 声音触发 | backup cue 的第二、第三次提示需要它们；本轮只验证事件与位移 |
| 多 Trigger 去抖 | `OnTriggerEnter` 单次进入触发两次，正式玩法要定唯一入口 |
| 网络同步下的一致性 | 只在本地预览验证过 |
| 45 s 阈值的实际体验 | 探针用 3 s；真实时长需盲测 |

---

## T-17｜可跨越台阶高度上限 [已验证·修正了既有假设]

> `SPATIAL-PROPOSALS.md §4.10` 把台阶按 **0.28 m** 设计，并标 `[TO-VERIFY]`；
> 前几轮我在报告里反复写「角色控制器上限约 0.30 m」。
> **这两个数都偏保守，本轮实测修正。**

### 探针

新建独立 WPrefab `step-probe` / 模型 `model-step-probe`，一条沿 +Z 的直路，
每级台阶的**抬高量**逐级递增：

```
0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40, 0.45, 0.50, 0.60, 0.70, 0.80
```

每级宽 4 m（排除横向掉落干扰）、深 2 m、相邻重叠 0.5 m。导入到 `(180,60,180)`，与白盒隔离。

### 实测

**1｜连续实走**：从起点 `y=60` 一路推 +Z，玩家在 `(y=62.2, z=190.8)` 停住。再持续给 +Z 输入 140 帧，位置**一动不动**（`y=62.2, z=190.8` 全程不变）——是硬阻挡，不是 `StopMove` 造成的假象。

**2｜逐级落地对照**：分别传送到每一级顶面，全部能站住，落点高度与预期完全一致：

```
step1 d0.10 -> 60.10   step4 d0.25 -> 60.70   step7 d0.40 -> 61.75
step2 d0.15 -> 60.25   step5 d0.30 -> 61.00   step8 d0.45 -> 62.20
step3 d0.20 -> 60.45   step6 d0.35 -> 61.35   step9 d0.50 -> 62.70
```

说明**几何与碰撞体都齐全**，问题出在"爬升过渡"，不是缺面。

**3｜隔离失败的那一级**：

| 起点 | 终点 | 结果 |
|---|---|---|
| 第 7 级 → 第 8 级 | `y=62.20, z=190.8` | 成功爬上 **0.45 m** ✅ |
| 第 8 级 → 第 9 级 | `y=62.20, z=190.8` | 停在原地，**0.50 m 爬不上** ❌ |

### 结论

```
可跨越台阶高度上限 ∈ [0.45, 0.50) m，工程取值 0.45 m
```

**对既有文档的影响**：

| 位置 | 原值 | 修正 |
|---|---|---|
| `SPATIAL-PROPOSALS.md §4.10` | 按 0.28 m 设计 | 实测可用到 0.45 m；0.28 m 仍安全但过于保守，会不必要地增加台阶数量 |
| `PROBE-RESULTS.md` T-05 / T-16 / PLAN-C §5.1 | 「上限约 0.30 m」 | 改为 0.45 m |
| `ASSET-CARDS.md` 0.3 阈值 | 沿用 0.30 m | 同上 |

**注意不推翻已有结论**：之前两次"挡住玩家"的实测仍然成立——
- T-05 的 **1.2 m** 台阶：远超 0.45，确实过不去 ✅
- 圆管高出可走面 **0.4 m**：接近上限且是圆弧顶面，仍会挡人 ✅

而且白盒现在用的 **0.25 m（下坡）/ 0.294 m（上行）** 都在安全区内，不需要返工。

### 附带收获

探针本身也复现了 T-16：源码里台阶在 `x=0`，运行时包围盒 `cx=180`（导入 x=180），一致；但所有节点被合并成 `__optimized_merged_material_0/1` 两个网格，按名字定位单级台阶**不可行**，只能靠坐标或 bounds 判断。这一点对将来做"逐面片碰撞"的探针很关键。

---

## T-18｜可走坡度上限 [已验证·设计假设成立]

> `SPATIAL-PROPOSALS.md §4.10` 按 **45°** 设计并标 `[TO-VERIFY]`，
> 最陡段是 C 的 27.0%（≈15°）、B 的 23.1%。本轮实测验证。

### 探针

独立 WPrefab `slope-probe` / 模型 `model-slope-probe`，8 条互相独立的斜坡：

```
10°, 20°, 27°, 30°, 35°, 40°, 45°, 50°
```

每条沿 +Z、宽 3 m、水平投影 8 m、两侧 0.3 m 矮挡边防止横向滑出，
起点平台 y=0、终点平台 y=8·tan(角度)。各条沿 X 错开 10 m。

**坐标修正**：T-16 的 X 镜像在这里再次生效。源码里第 i 条在 `x=10i`，
导入位置 `x=200` 后运行时在 `x=200−10i`。我第一次把 35° 误放在 `x=165`
（两条之间的空隙），玩家直接掉下云海（`y 21 → −68 → 重生`）。
**纠正后 x = 200,190,180,170,160,150,140,130 逐点落地，8 条全部能站住**，
且落地高度随角度递增（60.51 / 60.90 / 61.21 / 61.35 / 61.62 / 61.93 / 62.28 / 62.71）。

### 实测

| 角度 | 结果 | 关键数据 |
|---|---|---|
| 10° | ✅ 可走 | `y 60.00 → 60.88`，`z 168.4 → 174.1`，稳定爬升 |
| 20° | ✅ 可走 | `y → 60.51`，`z → 170.9` |
| 27°（设计最陡） | ✅ 可走 | `y 60.00 → 61.62`，`z 168.3 → 172.8` |
| 30° | ✅ 可走 | `y 60.00 → 61.76`，`z 168.3 → 172.7` |
| 35° | ✅ 可走 | `y 60.00 → 61.78`，`z 168.3 → 172.2` |
| 40° | ✅ 可走 | 落点 `y 60.8` |
| 45°（设计假设） | ✅ **可完整走完** | `y 60 → 67.8`（终点平台 68.0），`z → 177.5` |
| 50° | ✅ **可完整走完** | `y 60 → 68.46`（终点 69.53），`z → 176.8` |

**结论：可走坡度上限 > 50°。设计文档按 45° 假设是安全的，且有明显余量；
C 的最陡 27% 更是远远在安全区内。不需要为坡度改设计。**

### 但有一个必须记录的体验发现：陡坡显著拖慢玩家

同样的 `MoveContinuously(0.30)` 输入、同样约 108 帧：

| 角度 | z 前进 | y 抬升 |
|---|---|---|
| 10° | ≈ 5.7 m | 0.88 m |
| 27° | ≈ 4.5 m | 1.62 m |
| 35° | ≈ 3.9 m | 1.78 m |
| 45° | ≈ 3.5 m | 2.14 m |
| 50° | ≈ 3.4 m | 2.32 m |

**角度越大，水平推进越慢（约降到 10° 的 60%）**，虽然仍能到达终点。
这意味着陡坡段会拉长通行时间并可能让玩家觉得"走不动/在打滑"。

**对设计的建议**：坡度在技术上不是约束，但**体验上**应把长距离通道控制在 20° 以内。
C 的 27% 根桥（30 m）若按此速度会显得拖沓，建议白盒盲测时专门记录"这段是否觉得慢"。

### 一个方法论坑

短观察窗口会误判。第一次测 10° 只走了 70 帧就下结论"只前进 2.7 m，可能被挡住"，
逐帧采样后才发现是**持续爬升只是慢**。判断"能不能走完"必须给足帧数、
或明确记录到达终点平台的 y，而不是看单帧位移。

（`puerts-execution-timeout` 上限约 15–20 s，长坡测试要拆成多段调用，
每段结束用独立调用读 `actor.position` 续接。）

---

## T-14｜出生点与世界坐标 [已验证]

新项目运行时玩家出生在 `(119.74, 77.91, 88.64)`，即**世界中心附近**，不是白盒位置。

因此白盒必须显式 `--position` 到玩家附近，或玩家必须被传送过去。Day 2 做入口白盒时，**入口浮岛应直接放在出生点脚下**，避免"进入世界后发现自己在云海上"。

**附带发现（相机朝向）**：第三人称相机是**独立 GameObject `TPCameraAvatar`**，不挂在角色下面。

实测行为：

| 操作 | 结果 |
|---|---|
| 直接写 `cam.transform.position` | **每帧被覆盖**，写后 3 帧内弹回原值 |
| 直接写 `cam.transform.rotation` | 同样被覆盖 |
| 改 `actor.rotation` | **相机不跟随**：actor 的 `rotation.y` 变成 0.707（转了 90°），相机 forward 仍是 `(0.19, 0.93)` |
| 相机相对 actor 的偏移 | 固定 `(0, +1.7, −3.33)`，即身后 3.33 m、上方 1.7 m |

也就是说：**相机有自己的朝向状态，与 `actor.rotation` 解耦，且不能被直接写 transform 控制。** 转相机只能走它自己的输入通道（鼠标/摇杆），CLI 的 `mouse drag` 语法当天没试通（`drag:x,y,x,y` 被拒，需另找正确格式 → `[TO-VERIFY]`）。

**对入口朝向设计的直接影响**：

不能假设"把角色转向目标，相机会自动对准"。实测温室中心相对相机轴偏 **94.3°**，而相机半 FOV 只有 **22.5°**——所以不是温室"看不见"，是相机压根没朝向它。

Day 2 必须解决的三条：

1. **入口白盒的方位布置要迁就相机初始朝向**。默认相机 forward ≈ `(0.19, −0.31, 0.93)` 即 +Z 略偏下。因此**温室必须放在出生点的 +Z 方向**。
2. 如果不得不放在侧向，必须找到转相机的正式入口（鼠标输入或相机脚本参数），不能靠写 transform。
3. 这条改变的不只是白盒，还包括 `SPATIAL-PROPOSALS.md` 里"出生朝 +Z"的设定——那是**对的**，是我白盒的朝向摆错了。

### 已修复（Day 1 当天）

按上面第 1 条重写了白盒源 `preview-module.js` 的布局：出生点在 `z=−13`，入口岛在 `z=−10`，根系通道沿 **+Z** 从 `z=−6` 走到 `z=+7.2`，温室下方平台 `z=+11`，倒悬温室 `(0, 9, 11)`，空中平台链 `z=15→24.6`，花冠观景台 `z=29`。

**修复后验证**（截图 `22-spawn-facing-greenhouse.png`）：

```
出生视角：玩家 (120, 60.5, 107)，相机 forward (0.01, 0.95) 即正对 +Z
画面：直接看到倒悬温室在正前方，根系台阶一路通向它，远处是花冠平台
```

**走位复测**：`z 112 → 127.9`，`y 61.5 → 61.5`，走完整个根系通道到温室下方。

**同时验证的一个坑**：在编辑器里旋转 `Model` 节点或 wrapper 节点（`transforms.set` 写 rotation）**不会改变运行时包围盒**——`glbSliceData` 的几何是烘死的。要让布局转向，必须**改 Three.js 源重新导出 GLB**，不能靠节点变换。

已记入 R-08（状态改为已解决）。

---

## T-15｜分层配色的明度问题 [实测发现·待美术阶段处理]

**在 T-08 解决"颜色能改"之后暴露出来的下一个问题。**

### 现象

配色生效后（截图 `19-east-side-view.png`），三层颜色确实可区分了，但**明度全部偏亮**：

- 根系层 绿 `(0.42, 0.72, 0.44)`
- 温室层 蓝 `(0.36, 0.66, 0.82)`
- 花冠层 紫 `(0.72, 0.56, 0.86)`
- 天空 亮青

在明亮天光下，温室层与花冠层的明度与天空太接近，**远景里这两层会溶进天空**。只有岩层的深褐 `(0.30,0.26,0.24)` 站得住。

### 为什么这是问题而不是"丑"

参考研究硬结论 1 与第 5 章要求：**主地标与背景的明度差 ≥ 15%**，否则远处地标会失去轮廓。当前配色在这个指标上不合格——温室是主地标，而它正好是最容易被天空吃掉的那个明度段。

### 修正方向（Day 2 执行）

| 层 | 当前 | 建议 | 理由 |
|---|---|---|---|
| 根系层 | 亮绿 | 压暗到 `(0.28, 0.48, 0.30)` | 它是"地面"，应该是画面里最暗的可走面 |
| 温室层 | 亮蓝 | 压暗并加青 `(0.20, 0.42, 0.55)` | 主地标需要与天空拉开明度差，不能靠饱和度 |
| 花冠层 | 亮紫 | 压暗 `(0.48, 0.36, 0.62)` | 高处不等于高亮 |
| 岩层 | 深褐 | 保持 | 已经在正确区间 |
| 远景 | 冷灰蓝 | 再退一档到 `(0.55, 0.63, 0.72)` | 加强空气透视，与近景分开 |

**重要**：这只是白盒阶段的临时值。真正的明度关系要在 Day 4 有真实材质后重新定，因为 `EnvLit_AI_Mat` 的最终表现取决于环境光照参数，不是单纯的 `_BaseColor`。

### 这条探针的价值

它证明了"能改颜色"和"颜色改对"是两件事。T-08 解决的是**技术可行性**，T-15 暴露的是**视觉设计问题**——后者不能用技术手段绕过，必须在 Day 2 用参考研究里的明度检查表逐项验。

记入 `BLOCKERS.md` R-07。

新项目运行时玩家出生在 `(119.74, 77.91, 88.64)`，即**世界中心附近**，不是白盒位置。

因此白盒必须显式 `--position` 到玩家附近，或玩家必须被传送过去。Day 2 做入口白盒时，**入口浮岛应直接放在出生点脚下**，避免"进入世界后发现自己在云海上"。

---

## T-16｜GLB 导出镜像 X 轴 [已验证·高优先级]

**现象**：把上行台阶链从 `x=0` 移到源码里的 `x=+5.0` 后，按「世界坐标 = 导入位置 + 源码坐标」推算落点 `x=125`，玩家**直接掉下云海**。

**对照实验**（导入位置 `x=120`，下坡在源码 `x=+4.2`）：

| 落点 | 结果 |
|---|---|
| `x = 115.8`（= 120 − 4.2） | 落在下坡台阶上，`y = 67.50` ✅ |
| `x = 124.2`（= 120 + 4.2） | 掉下去，`y = −11.15` ❌ |

**结论**：Three.js 源码里的 `+X` 导出 GLB 后变成运行时的 `−X`。

**与 R-08 同源**：WPrefab 的 GLB 烘焙会重写变换（节点旋转不改变运行时包围盒也是同一机制）。因此：

1. **不能用 Three.js 源码坐标直接推算世界坐标。**
2. 任何依赖源码坐标的外部脚本（触发器、传送点、集成 Anchor）必须以**运行时实测坐标**为准，或在导入后统一做一次 X 取反。
3. 这也解释了为什么早期白盒里 `EntryIsland` 源码 `x=−14` 出现在运行时 `x=134`（= 120 + 14）而不是 `106`。

**用镜像坐标复测上行台阶**（真实 `MoveContinuously`）：

```
落点 (115.0, 66.91, 125.6)  ← 第 3 级台阶顶面 = 50 + 16.9 = 66.9 ✅
实走 y 66.91 → 70.71（+3.80 m），z 125.6 → 130.8，x 稳定 115
单调爬升、全程踩台阶、无坠落
```

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
| **GLB 材质改色** | **可用（需写 `_BaseColor`）** | `material.color` / `appearanceData` 均无效 |
| **分层配色持久化** | **可用（Lua 脚本）** | 按局部高度赋色，跨实例重开保留 |
| **GLB 导出会镜像 X 轴** | **已确认** | 源码 `+X` → 运行时 `−X`；外部脚本必须用实测坐标（T-16） |
| 原生移动平台组件 | **不存在** | |
| AI 地形生成浮空岛 | **不支持** | |
| GLB 贴图在运行时保留 | **有明确负面信号** | 最小带贴图 GLB 进不了场景（T-08b） |
| PCG 参考图确认 | **CLI 无可用格式** | |
| Trigger 驱动玩法 | **可用** | 6 个回调成对触发；能写 transform、能复位玩家、Update+Time 计时器可用（T-13）。灯光/声音仍未验 |
| 触发式平台降级方案 | **成立** | Trigger + Lua 写 transform，不需原生移动平台组件 |
| 重力方向变化 | 未测 | 本轮不需要，不做 |
