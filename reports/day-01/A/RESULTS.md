# reports/day-01/A/RESULTS.md

> Owner：成员 A
> 分支：`feature/train-core`
> 阶段：Day-01
> 证据目录：`reports/day-01/A/evidence/`
> 状态图例：**PASS** = 实际跑通并有证据 / **FAIL** = 实测失败 / **NOT TESTED** = 未验证

---

## 0. 一句话结论

编辑器 1.0.104 的**项目保存与重开、GLB 导入（含贴图/层级/透明度）、WPRE 单文件交接、
以及"Trigger + Lua Teleport"世界连接机制**均已实测跑通；
最大的两个风险是 **GLB 导入会把 X 轴镜像**、以及 **`.wprefab` 不内嵌模型二进制**（依赖外部 URI）。

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

### 1.1 项目真实目录结构（重要，B/C 必读）

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
| 材质（PBR 参数） | **PARTIAL** | `glbSliceData` 仅存 `sourceUri`/`slicePath`/`isShowTex`/`opType`，**未单独保存 baseColor/roughness/metallic 字段**；实际外观由 GLB 源文件提供 |
| 层级（父子结构） | **PASS** | 3 节点 GLB → 编辑器中 `Model` + `ProbeChildArmA` + `ProbeChildArmB`，父子关系保留 |
| 透明度（alpha BLEND） | **OBSERVED** | 半透明面板在截图中呈半透效果（`P02-04-transparent.png`），但未见独立 alpha 参数字段 |
| 动画（glTF node animation） | **PARTIAL** | `ProbeAnimatedNode` 子节点存在；但 `animatorData`/`ugcAnimatorData` 组件**未生成** → GLB 动画不会自动变成引擎动画，需另配 |
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

### 3.4 导入限制（实测返回值）

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

## 6. 交付物

| 文件 | 内容 | 状态 |
|---|---|---|
| `PLAN.md` | 今日目标与分工 | 完成 |
| `RESULTS.md`（本文） | 实测结论 | 完成 |
| `EVIDENCE.md` | 证据索引与命令复现 | 完成 |
| `BLOCKERS.md` | 阻塞与降级 | 完成 |
| `HANDOFF.md` | 可直接转发给 B/C | 完成 |
| `WORLD-INTERFACE-CONTRACT.md` | 公共接口契约 v0.1 | PROPOSED |
| `research/REFERENCES-ANALYSIS.md` | 参考研究与 Hub/终点方案 | 完成 |
| `evidence/` | 截图、回执、读回 JSON | 15.2 MB |
