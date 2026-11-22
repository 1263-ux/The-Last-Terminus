# 失重花园｜Day 01 交接

> Owner：成员 C
> 分支：`feature/floating-garden`
> 说明：本文件是**可直接转发**的交接文本。当前没有团队群/连接工具，因此**不声称已通知任何人**；请 A / B 从本文件自取。

---

## 给 A｜列车与集成

### 交付内容

失重花园 Day 1 空间白盒草案 + 入口/出口约定草案。

### 分支 / Commit

- 分支：`feature/floating-garden`
- 基于：`origin/main` @ `d6361a3`
- 本文件所在 Commit 见 PR 描述（每次 push 后更新）

### 文件或资源路径

- 报告：`reports/day-01/C/`
- 证据：`evidence/day-01/C/`
- 编辑器工程：**不在本仓库**（按 `START-HERE-FOR-MEMBERS.md` §5 分离）

### 当前状态

- 白盒几何：**可用**（可走通、可保存、可重开）
- 分层配色：**可用**（`_BaseColor` + Lua 持久化，跨实例重开保留）
- 入口/出口 Anchor：**临时占位**

### 入口 / 出口 / 出生朝向（草案，`[待 A 确认]`）

按 `COORDINATION-CONTRACT` 要求，先给最小可用集合：

| 字段 | 值 | 备注 |
|---|---|---|
| World ID | `02-floating-garden` | |
| 入口锚点（世界内） | 入口浮岛中心，白盒内 `(-14, 0.4, 2.5)` | 世界坐标需 A 的基线确定后换算 |
| 出生朝向 | 面向中央倒挂温室（白盒 +X 方向） | 目标必须在出生 10 秒内可见 |
| 玩家眼平 | 1.60 m | 待与 A 的尺度基线统一 |
| 安全落脚区半径 | ≥ 6 m 无落差 | 白盒入口岛 r=6 |
| 世界边界（建议） | 半径 60 m 的圆柱 | 需 A 确认列车停靠点相对位置 |
| 离开时机 | 玩家从花冠观景点折返，或任意时刻返回入口岛 | **本世界无强制完成锁**，可随时离开 |
| 离开锚点 | 与入口锚点同位 | 首版不做双向传送，靠同一锚点 |

**A 需要注意的两点**：

1. 运行时世界坐标有效区间是 `[0,255]`，越界对象会被销毁。白盒被放到 `(120,60,120)` 才能正常运行。**列车站台与花园入口的对接坐标必须落在这个区间内。**
2. 新实例启动需要 `AWC_CREATOR_AUTH_SOURCE_DIR` 环境变量绕过登录引导（见 B-01）。A 启实例前先确认自己有没有可用 profile。

### 如何复现

```
douyin-world instance start --project <项目> --mode offscreen
douyin-world runtime start --wait 90
douyin-world runtime screenshot --out <png>
```

### 依赖

- **需要 A 提供**：玩家尺度基线、Entry/Exit Anchor 的正式格式、列车站台到花园入口的对接方式。
- **A 可先用的临时成果**：白盒 WPrefab 已归档，A 可以直接 `scene import` 到自己的集成场景试连接，不必等 C 完成美术。
- **A 必须知道的一条**：`prefab attach` 是追加不是替换，迭代模型前要删旧副本（B-05）。
- **A 可复用的已验证能力**：Trigger + Lua 已端到端跑通（T-13），列车到站/离站的触发与玩家传送可以直接照抄这条路径。

### 已知问题

见 `BLOCKERS.md`。对 A 影响最大的是 **B-04（PCG 参考图确认无法回答）**——A 的终点站也要地形，建议 A 优先攻这个。

### 希望 A 做什么

1. 确认或修正上面的入口/出口草案。
2. 给出玩家尺度基线（现在 C 用的是眼平 1.60 m，需与列车统一）。
3. 若 A 已攻下 PCG 参考图确认，请把可用的答案格式回传。

---

## 给 B｜书桌站

### 交付内容

失重花园 Day 1 参考研究 + 空间方案 + 编辑器探针结论。

### 状态

- 参考研究：**已交付**（`REFERENCE-STUDY.md`，564 行）
- 空间方案：**已交付**（`SPATIAL-PROPOSALS.md`，561 行）
- 技术结论：**已交付**（`PROBE-RESULTS.md`，14 项探针）

### 想和 B 交换的三件事

**1｜材质改色：已攻破，B 直接抄这个结论**

用 GLB 导入后，几何会被按材质合并成 `__optimized_merged_material_N` 并统一使用 `EnvLit_AI_Mat`。**三种常见改法全部无效**：

| 做法 | 结果 |
|---|---|
| Three.js 里 `new MeshStandardMaterial({color})` | 运行时失效 |
| `appearanceData` 组件写 `color` | 无变化，且重新 attach 后组件丢失 |
| `mr.sharedMaterial.color = ...` | 无变化（写错属性名） |

**根因**：shader 是 `Douyin/AI/PBR/EnvLit_AI`，颜色属性叫 **`_BaseColor`**，不是 Unity 标准的 `_Color`。`material.color` 访问的是 `_Color`，这个 shader 根本不读。

**正确做法**：
```javascript
mr.sharedMaterial.SetColor("_BaseColor", new CS.UnityEngine.Color(r, g, b, 1));
```
只改 `_BaseColor` 即可，**不需要**动 `_UseVertexColor`（A/B 对照已确认）。

**持久化**：运行时手改只活一轮。写一个 Lua 脚本绑到模型根节点，在 `Start()` 里遍历 `MeshRenderer` 按**局部高度**赋色。我用局部高度而不是世界坐标，因为 WPrefab 可能被放到任意世界位置/旋转/缩放。

我的脚本在 `ai-sessions/workspace_ihycinrp/wprefabs/garden-whitebox/scripts/garden_layer_tint.lua`，可以直接拿来改造。

**贴图结论已更新（轮 8，T-08b）**：用编辑器自己的 Three.js 作者管线生成 KTX2 贴图 GLB，
`scene import` 通过、运行时 `_BaseTex` 采样有效，红蓝棋盘与 UV 完整可见
（截图 `42-texture-glb-retained.png`）。**贴图可以依赖，不必退回纯色 + `_BaseColor` 的降级方案。**

唯一要注意的是**格式**：之前手写 `image/png` 的 GLB 在 runtime 阶段导入失败，
真实导出器用的是 `image/ktx2`。Tripo 产物若带贴图，先确认格式或过一道编辑器 authoring 转换。
这一条同样给 A/B——书桌站/终点站若用贴图资产，别直接塞裸 PNG GLB。

**多通道贴图结论（轮 9，T-19）**：把 5 个通道一起导出后逐通道检查，
**albedo / emissive / `alphaMode:BLEND` 保留**，`normalMap` / `metallicRoughnessTexture(ORM)`
虽然写进了 GLB，但**运行时 `_Normalmap` 和 `_ORM` 都是 null，被丢弃**
（截图 `43-multichannel-texture-probe.png`：棋盘+黄点可见、透明面板能透出背景）。

=> **给总设计师 / Tripo 排期**：可以要 albedo + emissive + 透明；
**不要为法线贴图或 ORM 贴图投入生成成本**，表面质感靠真实几何与分件材质。
=> 玻璃温室（`GARDEN-002`）可行，但玻璃质感要靠分片、框架、真实厚度，不能靠法线贴图。
仍未验证：`_Alpha` 的实际控制方式、三通道同材质叠加、Tripo 实际导出格式。

**2｜可走面的碰撞必须实测，不能靠几何判断**

我这边两次失败：1.2 m 台阶挡住玩家、圆管管顶高出走面 0.4 m 也挡住玩家。两次在视觉上都"看起来能走"。书桌站如果有"尺子桥"这类细长可走面，同样的坑会以同样的方式出现。

**3｜SCAD 源文件必须无 BOM**，且 **GLB 导出会镜像 X 轴**（新发现，高优先级）

带 UTF-8 BOM 的 `.scad` 会报 `The encoded data was not valid`。去掉 BOM 立刻正常。B 若用 SCAD 做书桌地形，可以直接省掉这个排查。

更重要的是：**Three.js 源码里的 `+X` 导出 GLB 后变成运行时的 `−X`**（T-16）。对照实测：

```
导入位置 x=120，下坡源码 x=+4.2
  落点 x=115.8 (=120−4.2) → 站在台阶上 y=67.50 ✅
  落点 x=124.2 (=120+4.2) → 掉下云海 y=−11.15 ❌
```

**任何依赖源码坐标的外部脚本（触发器、传送点、集成 Anchor）都必须用运行时实测坐标，或统一做一次 X 取反。** 这条同样适用于 A 的列车站台对接：不要用 C 源码里的坐标去算世界位置，找 C 要实测 Anchor。

顺带两条同源结论：① 在编辑器里旋转节点不改变运行时包围盒（几何是烘死的，要改布局必须改 GLB 源）；② `Physics.Raycast` 在合并后的白盒上持续打空，判断"能不能站"要靠真实角色落地，不能靠射线。

**4｜Trigger 已跑通，但 Lua 实例方法必须用冒号调用**（新，T-13）

我用 `triggerData`（box）+ 一个 Lua 脚本端到端验证了：玩家真实走过边界 → 6 个 enter/exit 回调全部触发；回调里写 `self.transform.position` 能挪动节点；`CS.DouyinActorService.GetLocalActor():Teleport(v)` 能把玩家复位回检查点。

**踩到的坑**：写成 `a.Teleport(v)` 会报
`InvalidCastException: Unable to cast Vector3 to DouyinActor`。
Lua 里点号调用把 `v` 当成 `self`，实例方法必须用冒号 `a:Teleport(v)`。B 的尺子桥交互如果要传送玩家，直接避开这个坑。

另一个观测坑：`---@varSync` 注入的是装箱对象，外部 `lua eval` 读回是 `userdata`，看不出值。探针用 `_G` 普通全局表记日志并返回**纯字符串**才可读。

**5｜Lua 绑定也会重复追加**（T-20 发现，B-05 的延伸）

反复 `prefab attach` / 重建后，`runtime targets` 出现 5 个绑定：同一个节点上
`garden_layer_tint.lua` 有 3 份、`trigger_probe.lua` 有 2 份。
用 `Where-Object` 取值会拼成两个 ID 的字符串（如 `-10864:... -11182:...`），
导致 `lua-binding-not-found`。

**正式玩法必须显式指定单个 `bindingKey`，或重建前用 `scripts.unbind` 清理旧绑定。**
A 的列车到站/离站触发若反复迭代，同样会撞到这个坑。

**6｜动态点光可用**（T-20）：`lightData` 可写（type/color/intensity/range），
Lua 回调能 `GameObject.Find + GetComponent(typeof(Light))` 把 intensity 0.2→8.0 并改色，
读回持久生效。backup cue 第二次提示（温室从下方漏光）在技术上已具备。
仍需 A 的音频能力结论来做第三次提示。

### 玩法差异声明（避免重复）

| 维度 | 书桌站（B） | 失重花园（C） |
|---|---|---|
| 玩家动词 | 改造物件、利用既有物品的用途 | 观察空间结构、发现连接 |
| 核心谜题形态 | 物件多解 | 路线发现（同一目标，多条空间路径） |
| 空间 | 微缩尺度、近景为主 | 垂直三层、远中近景并重 |
| 失败方式 | 解错谜题 | 找不到路 |
| **本世界坚决不做** | — | 收集 N 个物件开门、零件搭桥、物件用途重构 |
| **书桌站坚决不做** | — | 垂直路线发现（避免抢 C 的核心体验） |

**这条需要 B 确认**：如果书桌站出现"从低处爬到高处找路"的设计，两世界会撞。请 B 回复是否会保留垂直路线。

### 如何复现 / 导入

见 `PROBE-RESULTS.md` T-04 的完整命令序列。

---

## 给总设计师

### 需要决策的三件事

| # | 决策 | 为什么现在必须定 | 推荐 |
|---|---|---|---|
| 1 | 是否接受方案 C（温室悬在入口**下方**）作为 Day 2 白盒方向 | Day 2 白盒一旦按 A/B 建，返工成本约半天 | 接受 C。空间方案文档已给出完整几何与 500 行规格；三方案对比 C 20 / B 19 / A 16，C 只在"路线发现强度"与"与书桌站差异度"领先，而这两项正是 TASK.md 的不可替代项 |
| 2 | AI 地形不支持浮空岛 → 是否接受"地形做台地、浮岛由独立 Model 承担"的拆法 | 决定 Day 2 的地面处理方式 | 接受。与编辑器「Map + 独立 Model 槽位」架构一致 |
| 3 | ~~GLB 材质~~ → **已解决**，改为：带贴图 GLB 是否保留贴图 | 若不解决，Day 4 关键美术可能白做 | 允许我在 Day 4 前做一次贴图探针，用结论决定 Tripo 模型的交付格式 |

### 顺带需要总设计师裁决的一条（来自空间方案）

`SPATIAL-PROPOSALS.md` §4.7 有两处视线**无法单帧入画**（根结台看向走面环与回望入口岛相差 105°；观景点正下方碗口与来路相差 44°），与参考研究硬结论 3 的"单帧看见来路与下一个目标"冲突。

建议的验收改法：把"转身"本身当作揭示，验收改为**转身后 3 s 内能指认**，不按单帧测。请确认这个改法。

### 已就绪的 Asset Card

见 `ASSET-CARDS.md`。四张 P0：巨花、倒悬温室、根系长廊、浮空岛。**只提交需求卡，未生成任何模型**，符合 `AGENTS.md` §9「总设计师负责关键 Tripo 生成」。

---

## 交接自检

- [x] 交付内容写清
- [x] 分支与基线 Commit 写清
- [x] 文件路径写清
- [x] 当前状态分级（可用 / 临时占位 / 待验证 / 不可用）
- [x] 如何复现
- [x] 依赖与需要对方做什么
- [x] 已知问题
- [x] **没有声称已通知任何人**（无团队群/连接工具，本文件供自取）
