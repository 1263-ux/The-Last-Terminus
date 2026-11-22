# reports/day-01/A/RESULTS.md

> Owner：成员 A
> 分支：`feature/train-core`
> 阶段：Day-01
> 证据目录：`reports/day-01/A/evidence/`
> 状态图例：**PASS** = 实际跑通并有证据 / **FAIL** = 实测失败 / **NOT TESTED** = 未验证

---

## 0. 一句话结论

编辑器 1.0.104 的**项目保存与重开、GLB 导入（含贴图/层级/透明度）、WPRE 跨工程交接、
以及"Trigger + Lua Teleport"世界连接机制**均已实测跑通；
Gate 1 要求的「至少完成一次真实资产交接」**已满足**（Probe 06）。
最大的两个风险是 **GLB 导入会把 X 轴镜像**、以及 **`.wprefab` 依赖外部 URI 导致跨账号失效**（跨账号未验证）。

---

## 1. Git 与仓库

| 项 | 结果 | 说明 |
|---|---|---|
| 本机已有仓库 | 无 | `D:\competition` 为空，`git rev-parse` 失败 |
| 克隆方式 | **镜像** | GitHub 直连 TCP 重置；改用 `https://ghfast.top/https://github.com/...` |
| 克隆结果 | **PASS** | 90 个文件，`main` 在 `d6361a3` |
| `feature/train-core` 是否已存在 | **不存在** | 已从 `origin/main` 创建 |
| 分支状态 | `feature/train-core...origin/main` | 跟踪已设置 |
| 工作目录 | `D:\zjx\projects\The-Last-Terminus` | 独立于编辑器原生工程目录（合规） |
| **push 权限** | **FAIL（阻塞）** | 见 `BLOCKERS.md` #1：无凭据，`git push` 要求 Username |

> 未执行任何 `reset` / `clean` / `force push`。

---

## 2. Probe 01｜项目保存 / 关闭 / 重开 / 目录

| 子项 | 结果 | 证据 |
|---|---|---|
| 新项目可创建 | **PASS** | `project create TrainCore_A` → `project-fb583637-...` |
| CLI 实例启动 | **PASS（有前置条件）** | 需先关闭已运行的编辑器窗口，见 `BLOCKERS.md` #2 |
| 场景保存写盘 | **PASS** | `scene.data` 758476 → 779578 字节；回执 `status: committed`, `hasUnsavedChanges: false` |
| 关闭后文件完整 | **PASS** | 关闭后仍 10 个文件，`scene.data` 保持 779578 字节 |
| 重开后场景恢复 | **PASS** | 重开截图与保存前视觉一致；`runtime start` 成功 |
| 保存需先停预览 | **OBSERVED** | 预览中保存被拒（`scene-edit-preview-active`），必须先 `runtime stop` |

### 1.1 玩家尺度基线（修正）

原先我按角色模型比例推断胶囊高 1.6–1.8 m，**实测结果是错的**，现更正：

| 项 | 值 | 状态 | 依据 |
|---|---|---|---|
| 玩家胶囊**半径** | **0.16 m** | **OBSERVED** | `P07-actor-members.json`：`radius: 0.1599999964237213` |
| 玩家胶囊**总高** | **0.90 m** | **OBSERVED** | 同上：`height: 0.8999999761581421` |
| 胶囊中心 | y = **0.45 m** | **OBSERVED** | 同上：`centerY: 0.44999998807907104` |
| 胶囊直径（碰撞宽度） | **0.32 m** | **OBSERVED** | 半径 ×2 |
| 默认移动速度 | 约 4 m/s | OBSERVED | 场景 `moveMaxSpeed = 4.0` |
| 默认跳跃高度 | 1.0 m | OBSERVED | 场景 `jumpMaxHeight = 1.0` |
| 坠落恢复高度 | y = −50 | OBSERVED | 场景 `respawnHeightY = -50.0` |

> **重要更正：** 玩家碰撞体**只有 0.9 m 高、0.32 m 宽**，是"矮胖"胶囊，
> 不是常见人类比例。这**放宽**了通道与门洞要求，但**收紧**了"玩家能否被看见/被挡住"的判断：
> 视觉模型比碰撞体高得多，**看起来挡住了、其实能钻过去**的情况很常见
> （反之亦然）。B/C 布置障碍物时必须按 **0.32 m 宽 × 0.9 m 高** 判断可通过性，
> 不能按角色视觉体积判断。

**对 B/C 的硬要求（按实测修正）：**
1. 所有**可站立平台**必须是实体 Collider（`isTrigger = false`），不得只有 Trigger。
2. 玩家必须行走的通道净宽 **≥ 0.8 m**（碰撞直径 0.32 m + 两侧余量）；
   若希望视觉上不挤，仍建议 **≥ 1.5 m**。
3. 玩家必须通过的**门洞净高 ≥ 1.2 m**、净宽 **≥ 0.6 m**（碰撞体可过）；
   但为避免视觉穿模，实际应做 **≥ 2.0 m 高 / ≥ 1.0 m 宽**。
4. 任何可达区域的地面高度差单步 **≤ 0.45 m**（需跳上则 ≤ 1.0 m，并留出助跑距离）。
5. **Trigger 竖直方向必须覆盖 y≈0.45 m 那一层**（胶囊中心），
   而不是按"角色头顶高度"设 volume —— 这是我 Day-01 踩到的实际坑（见 §5.3）。
6. 出生点必须落在**实体平台上**，不得让玩家出生即坠落。

### 1.2 项目真实目录结构（重要，B/C 必读）

```
<projectRoot>/
├── project.json                 # 名称 / 封面 / creator.version
├── project.json.bak
├── world-config.json            # worldId / worldType("avatar") / quickPreview
├── world-config.json.bak
├── scene.data                   # ★ 整个主场景（ZIP 容器）
├── ai-asset-generate-config.json
├── ai-pcg-generate-config.json
├── ai-topology-generate-config.json
├── scripts/client/index.lua      # 客户端脚本（仅 ---@id 注解）
├── settings/env-param-overrides.json
└── .creator/runtime-payloads/
```

**`scene.data` 是 ZIP**，内部条目：

| 条目 | 大小 | 作用 |
|---|---|---|
| `SerializePcgData.json` | 9210（示例工程） | ★ **完整场景 JSON**（节点树、变换、组件、环境、出生点、音频） |
| `HeightMap_*.data` | 264196 | 地形高度图（二进制） |
| `SplatMap_*.png` ×2 | ~11 KB | 地形混合贴图 |
| `MatCoverTex_*.png` | 728056 | 地表覆盖贴图 |

**结论：** 场景是**二进制 ZIP 包**，**不能做 Git 文本 diff / merge**。
→ 直接印证 `INTEGRATION-CONTRACT.md` §3「同一二进制文件只允许一个主要写入者」。
→ 场景级协作**只能靠分支隔离 + 一方集成**，不能多人同时改同一 `scene.data`。

`SerializePcgData.json` 顶层键（可用于程序化检查）：
`version, moveMaxSpeed, jumpMaxHeight, respawnHeightY, respawnLogicType,
objectBehaviourAtRespawn, audioData, spawnPointData, nodeTransformDatas,
resourceRefs, runtimeScripts, envType, envSettingPath, envParamJson`

节点记录结构：每个节点含 `basic`（含 `nodeName`/`pos`/`rot`/`scale`/`tag`/`parentId`）
+ 组件分区（`physics` / `resource` / `editor` / `terrain` 等）。
本场景实测 74 个节点，`tag` 取值含 `Map` / `Terrain` / `Spawner` / `BornPoint` / `Untagged`。

---

## 3. Probe 02｜GLB 导入与属性保留

### 3.1 导入链路（已验证可用）

```
GLB → resource model import --glb → resource model check → resource archive --kind model
    → prefab attach --uri → prefab build → result archive → scene import → runtime start
```

### 3.2 逐项属性结论

| 属性 | 结果 | 证据 / 说明 |
|---|---|---|
| GLB 可导入 | **PASS** | `sourceState: "topology"`，`modelType: 1` |
| 贴图（内嵌 PNG） | **PASS** | 棋盘纹理 + 红色角标在渲染截图中完整可见 → `P02-02-glb-object-closeup.png` |
| UV | **PASS** | 同上，贴图未拉伸/翻转错乱 |
| 材质（PBR 参数） | **PASS（实测确认）** | 材质被统一到 `Douyin/AI/PBR/EnvLit_AI` shader，**但颜色与贴图完整保留**到 `_BaseColor` / `_BaseTex`。见 §3.4 的实测与踩坑 |
| 层级（父子结构） | **PASS** | 3 节点 GLB → 编辑器中 `Model` + `ProbeChildArmA` + `ProbeChildArmB`，父子关系保留 |
| 透明度（alpha BLEND） | **OBSERVED** | 半透明面板在截图中呈半透效果（`P02-04-transparent.png`），但未见独立 alpha 参数字段 |
| 动画（glTF node animation） | **PARTIAL** | `ProbeAnimatedNode` 子节点存在，且该节点使用 **`aigcModelData`** 组件（静态模型用 `glbSliceData`）；但 `animatorData`/`ugcAnimatorData` **未生成** → GLB 动画不会自动变成引擎动画，需另配 |
| 碰撞 | **FAIL（需重建）** | GLB 不含碰撞；`physicsColliderData` 默认生成 `enableCollision: true` 但形状需重建 |
| 单位 / 原点 | **PASS** | `resource inspect` 返回 `min [-0.5,-0.5,-0.5] max [0.5,0.5,0.5]`（1 m 立方体），米制正确 |
| **坐标手性** | **FAIL（重要）** | 见 §3.3 |

### 3.3 ★ X 轴镜像（必须写进所有资产规范）

作者侧写入的四个子节点，导入编辑器后读回：

| 节点 | glTF 作者坐标 | 编辑器读回 | 结论 |
|---|---|---|---|
| `AxisTestPx` | (+2, 0, 0) | **(−2, 0, 0)** | **X 取反** |
| `AxisTestNx` | (−2, 0, 0) | **(+2, 0, 0)** | **X 取反** |
| `AxisTestPz` | (0, 0, +2) | (0, 0, +2) | Z 保持 |
| `AxisTestNz` | (0, 0, −2) | (0, 0, −2) | Z 保持 |

同时 `ProbeChildArmA`（作者写 `+0.75 X`）读回为 `−0.75 X`，独立复现同一结论。

**影响：** glTF（右手系）→ Unity（左手系）的 X 取反。
**对 B/C 的硬要求：** 非对称模型（如带单侧贴纸的物件、单向朝向的装置）
在编辑器内必须**重新确认朝向**，不能凭 Blender 视图判断左右；
若需要在导入后保持原朝向，应在导出 GLB 前对 X 做预镜像，或在编辑器内统一加 180° Y 旋转并记录。

### 3.4 材质颜色与贴图的真实保留情况（含一次自我纠错）

**曾一度误判的结论：** 用 `Renderer.material.color` / `.mainTexture` 读取时，
所有材质都返回 `(0,0,0,0)` 且 `mainTexture = null`，据此差点写下"GLB 材质颜色与贴图丢失"。

**实际不是丢失，是查错了属性。** 该编辑器的材质统一使用
`Douyin/AI/PBR/EnvLit_AI` shader，颜色与贴图的真实属性名是
**`_BaseColor`** 与 **`_BaseTex`**，不是 Unity 常规的 `_Color` / `_MainTex`。

按正确属性名读回（`P08-base-props.json`）：

| 节点 | `_BaseColor` (RGBA) | `_BaseTex` |
|---|---|---|
| `WB_Floor`（作者设 0.55,0.53,0.50） | **0.767, 0.755, 0.735, 1** | null |
| `WB_StoveColumn`（作者设 0.35,0.33,0.32） | **0.626, 0.610, 0.601, 1** | null |
| `WB_JourneyMap`（作者设 0.30,0.45,0.55） | **0.584, 0.701, 0.767, 1** | null |
| `ProbeTexturedCube`（带内嵌贴图） | 1,1,1,1 | **非 null** |

**结论：**
1. **贴图确实保留** —— 带贴图的模型 `_BaseTex` 有值，截图里棋盘纹也可见。
2. **颜色确实保留，但经过色彩空间转换** —— 作者值被转到线性空间
   （0.55 → 0.767 ≈ sRGB→Linear；0.35 → 0.626 同理）。
   这不是丢失，**不要**按"数值变了"判断材质出错。
3. `glbSliceData` 组件本身**不存**颜色/粗糙度字段，说明材质数据是**导入时生成**到
   运行时材质实例里，而不是随节点保存。**跨工程导入后颜色仍然正确**（Probe 06 已验证渲染）。

> **给 B/C 的提示：** 检查材质是否正确时，请查 `_BaseColor` / `_BaseTex`，
> 不要查 `color` / `mainTexture`，否则会得到"全黑、无贴图"的假故障。

### 3.5 模型组件的两条分支（实测）

同样的 `resource model import` 路径，导入后节点上出现的组件**不同**：

| 源 GLB | 生成组件 | 引用字段 |
|---|---|---|
| 静态模型（无动画） | `glbSliceData` | `sourceUri` |
| **含 node animation 的模型** | **`aigcModelData`** | `uri` |

证据：`P02-model-component-types.json`（11 个模型节点中，仅含动画的 `n2` 使用 `aigcModelData`，
其余 10 个全部 `glbSliceData`）。

**含义：** 动画模型走的是另一条运行时路径。若 B/C 交付带动画的资产，
**不能假设它与静态资产行为一致**，必须单独在编辑器内验证播放。

### 3.6 导入限制（实测返回值）

- **30000 面 / 10 MiB** —— `resource inspect` 明确输出「资产导入限制 30000 面 / 10485760 字节」
- WPrefab 单文件上限 **64 MiB**
- 场景容量按权重计：12 面方块 `capacity=212`；四件套 132 面 `capacity=2796`；
  → **容量不是面数线性**，装饰物会显著吃容量，需按 `capacity` 而非面数做预算

---

## 4. Probe 03｜WPRE 交接

| 子项 | 结果 | 证据 |
|---|---|---|
| 可导出本地单文件 | **PASS** | `prefab export` → `probeA.wprefab`，21244 字节 |
| 文件格式 | **ZIP** | 含 3 个条目 |
| 是否自包含 | **FAIL** | `resourceRefs` 为**空数组**；模型靠**外部 URI** 引用 |
| 层级保留 | **PASS** | 12 节点，父子关系与源一致 |
| 碰撞配置保留 | **PASS** | `physics.physicsColliderData` 完整（含摩擦/弹性/质量） |
| 脚本绑定保留 | **PASS** | `inspect` 报「脚本 9 · 绑定 0」；实际两处 binding 在运行时可查 |
| 资源依赖 | **FAIL（外部）** | 依赖 `hamlet-ugc/...` 形式的外部 URI，跨账号/跨机存在失效风险 |

`probeA.wprefab` 内部条目：

| 条目 | 大小 |
|---|---|
| `SerializePcgData.json` | 100910 |
| `asset-metadata.json` | 143（含 `capacity` / `faceCount` / `logicalCenter`） |
| `ai-author/meta.json` | 63 |

节点在 WPRE 中的结构：
`{ id, basic:{nodeName,pos,rot,scale,tag,parentId,...}, physics:{...}, resource:{glbSliceData:{sourceUri,...}} }`

**结论：** WPRE **不是**完整工程/场景等价物，是「层级 + 组件配置 + 外部资源引用」的清单。
→ 交接必须**同时附裸 GLB 与贴图**作为兜底，否则资源 URI 失效即不可恢复。

---

## 5. Probe 05｜世界连接（核心职责）

### 5.1 三种候选机制与实测结论

| 机制 | 存在性 | 可用性 |
|---|---|---|
| 内置传送门组件 `DouyinWorldPortal` | **存在**（白名单 + 运行时 `CS.DouyinWorldPortal != null`） | **NOT TESTED**：成员枚举受限，未验证配置方式与跨场景语义 |
| Trigger + Lua `actor:Teleport()` | **PASS** | 已完整跑通（见 5.2） |
| Trigger/`triggerData` 组件本身 | **PASS（几何）** | 只是几何体，**不自带事件**；必须由 Lua 回调消费 |

**没有**内置的"场景切换"逻辑组件（`components.listTypes` 返回 21 种组件，无场景加载类）。

### 5.2 Trigger + Lua Teleport 完整实测（PASS）

构建：同一 WPrefab 内两个 Anchor 节点，共用同一 Lua 脚本，参数不同。

| 验证点 | 结果 | 证据 |
|---|---|---|
| Lua 脚本可创建并构建进 WPrefab | **PASS** | `build` 返回 `hasRuntimeScript: true` |
| 脚本可绑定到节点并保存参数 | **PASS** | `bindings` 读回两节点各自参数 |
| 运行时两处绑定均 attached | **PASS** | `lua targets` 列出两条 bindingKey |
| 参数按节点隔离 | **PASS** | A = `20.0\|1.0\|0.0\|90.0`，B = `0.0\|1.0\|0.0\|90.0` |
| 直接调用 Enter 处理函数可传送 | **PASS** | A: `before=-0.11,0.72,-0.11 after=20.00,1.00,0.00` |
| **真实玩家输入触发回调** | **PASS** | 按 `W` 3 s，x 由 **119.74 → 20.00**（截图 `P05-03`） |
| 往返可回到原侧 | **PASS** | 站到 B 体积内后 z 由 110.66 → 路点侧 |
| 无临时调试残留 | **PASS** | `verifyNoTempHooks` → `residues: []` |

### 5.3 两个必须写进契约的坑（均已复现）

1. **Trigger 中心是局部坐标，不预乘祖先缩放。**
   节点本身在 y=78.9，`center.y` 再写 1 → 体积中心跑到 79.9，跨度 78.9–80.9，
   而玩家胶囊在 y≈77.9，**低了 1 m，永远进不去**。
   → 修正为 `center.y = 0.5`、`size = (3,4,3)` 后立即触发。
   **症状是静默的**：没有报错、没有日志，只有"走进去没反应"。

2. **脚本与 Trigger 必须在同一节点。**
   Hamlet 的 `OnActorTriggerEnter` **不沿父子冒泡**；
   "脚本在 root、Trigger 在 child" = 物理正常但回调永不触发。

3. **entry / exit 体积过近会形成传送振荡。** 首轮把两侧都放在原点附近，
   出现 A→B→A 反复传送。→ 契约要求两 Anchor 间距 ≥ 8 m 并加冷却。

---

## 6. Probe 06｜跨工程资产交接（原始需求"至少完成一次真实资产交接"）

按 `GATES-AND-ACCEPTANCE.md` Gate 1 要求「**至少完成一次真实资产交接**」，
在完成 Probe 03 后补做真实跨工程导入。

**做法：** 新建**独立工程** `Handoff_Test`（`project-eda6f596-...`），
用 A 工程已归档的同一 `.wprefab` URI 在**另一个工程**中 `scene import`。

| 检查项 | 结果 | 证据 |
|---|---|---|
| 跨工程场景导入 | **PASS** | `rootIDs: ["201049467"]` |
| 层级完整性 | **PASS** | 12 节点父子关系与源工程完全一致 |
| 模型实际渲染 | **PASS** | `P06-01-cross-project-render.png` |
| 碰撞体保留 | **PASS** | `BoxCollider isTrigger=true` ×2 + `MeshCollider` ×3 |
| Lua 脚本绑定保留 | **PASS** | 两条 binding 均 attached（`-2076:...` / `-2090:...`） |
| 脚本参数保留 | **PASS** | 读回 `20.0\|1.0\|0.0\|90.0`，与源工程一致 |
| 传送逻辑在新工程生效 | **PASS** | `before=119.74,77.91,88.64 after=20.00,1.00,0.00` |

**结论修正：** 原文把"外部 URI 引用"判为高风险；实测在**同账号 / 同机 / 同版本**下
跨工程交接**完全可用**。风险降级为"跨账号未验证"（见 `BLOCKERS.md` B-4）。

---

## 7. Gate D1 自检（不代替总设计师评审）

按 `production/prompts/DAY-01-ORIENTATION-RESEARCH-PROBES.md` 的 Gate D1 条件自检：

| Gate D1 条件 | 自检 | 依据 |
|---|---|---|
| 能准确复述项目核心与各自边界 | **是** | `PLAN.md` §2 明确列出非目标；未触碰 B/C 世界 |
| 两个可玩世界的玩法差异明确 | **不归 A 判定** | 这是 B/C 的交付；A 只评估接口影响 |
| 关键工具未知与资产依赖被暴露 | **是** | `BLOCKERS.md` 8 条；`RESULTS.md` §3/§4 逐项 |
| 有下一阶段可执行的白盒方向 | **是** | `HUB-WHITEBOX.md` §6 + 相机约束 |

按 `tasks/002-a-train-core/GATES-AND-ACCEPTANCE.md` Gate 1 自检：

| Gate 1 条件 | 自检 | 依据 |
|---|---|---|
| 技术能力区分为已验证 / 失败 / 待验证 | **是** | 全文 PASS/FAIL/NOT TESTED 三态标注 |
| **至少完成一次真实资产交接** | **是** | Probe 06：跨工程导入，层级/碰撞/脚本/参数/传送全保留 |
| 有明确的连接方案或降级方案 | **是** | `WORLD-INTERFACE-CONTRACT.md` §5.3 |
| 没有把未验证能力写成事实 | **尽力** | 见 §8 自查出的三处已纠正错误 |

---

## 8. 本轮自查出的错误（已纠正，保留记录）

诚实记录，避免后续重复踩坑，也避免 Reviewer 以为文档一直是对的：

| # | 错误结论 | 实际情况 | 纠正位置 |
|---|---|---|---|
| 1 | 玩家胶囊高 1.6–1.8 m（按视觉比例**推断**） | 实测 **0.90 m 高 / 0.32 m 宽**，是矮胖胶囊 | §1.1、契约 §1、HANDOFF |
| 2 | GLB 材质颜色与贴图**丢失**（读 `color` 得 0,0,0,0） | 材质完好；该编辑器用 `_BaseColor`/`_BaseTex`，我**查错了属性名** | §3.4 |
| 3 | `.wprefab` 外部 URI 是**高风险** | 同账号同机跨工程实测**完全可用**，风险降级为"跨账号未验证" | §6、`BLOCKERS.md` B-4 |
| 4 | 相机会穿墙，车厢必须加宽到 4.4 m | **引擎自带避让**：车厢内请求 6 m 被压到 1.60 m 且不穿墙；开阔地同样请求得 5.98 m | `CAMERA-REPORT.md` |

> 第 2 条尤其值得记录：如果只看到"读回全是 0"就写进报告，会误导 B/C 去重做全部材质。
> 第 4 条同理：仅凭一次截图就断言"相机会穿墙"，会导致白白加宽车厢、破坏已定的 3.8 m 比例。

---

## 9. 交付物

| 文件 | 内容 | 状态 |
|---|---|---|
| `PLAN.md` | 今日目标与分工 | 完成 |
| `RESULTS.md`（本文） | 实测结论 | 完成 |
| `EVIDENCE.md` | 证据索引与命令复现 | 完成 |
| `BLOCKERS.md` | 阻塞与降级 | 完成 |
| `HANDOFF.md` | 可直接转发给 B/C | 完成 |
| `WORLD-INTERFACE-CONTRACT.md` | 公共接口契约 v0.1 | PROPOSED |
| `research/REFERENCES-ANALYSIS.md` | 参考研究与 Hub/终点方案 | 完成 |
| `HUB-WHITEBOX.md` | 列车 Hub 灰盒实测记录 | 完成（相机结论已修正） |
| `CAMERA-REPORT.md` | 相机避让 A/B 实测 + 对 Hub 设计的影响 | 完成 |
| `evidence/` | 截图、回执、读回 JSON | 9.0 MB |
