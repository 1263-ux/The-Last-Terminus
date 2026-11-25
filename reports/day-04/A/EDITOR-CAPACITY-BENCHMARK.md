# A｜造世界 1.0.104 代表性场景容量基准（A 工程）

> Owner：成员 A（全项目技术集成）
> 日期：2026-11-24
> 依据：Issue #18 §6 / Issue #23 §6（A 主责生产能力审计）
> 方法：**只读解析 A 工程 scene.data**，不做破坏性容量测试（遵守"不把项目撞崩"）。
> 原则：这是**当前项目代表性基线**，不是 1.0.104 理论上限；不拿 MCP 适配器参数冒充原生容量。

---

## 0. 一句话

对 A 的 Hub/Terminus 集成工程 `scene.data` 做只读统计，得到**代表性场景基线**：
253 节点 / 8 资源引用 / 34 运行时脚本注册 / 场景存档 793 KB。
这是 Issue #18 要求的"代表性场景基准"第一步，**不是**"世界最多 N 对象"的理论上限。

---

## 1. 实测基线（TESTED — 只读解析，2026-11-24）

工程：`project-fb583637-ca72-4350-8ff2-e6066aa03481`（A 的 TrainCore_A）

### 1.1 场景存档构成（scene.data，ZIP）

| 条目 | 未压缩大小 | 说明 |
|---|---|---|
| `SerializePcgData.json` | 367,738 B (~359 KB) | 场景节点树/组件/脚本/变换 |
| `HeightMap_1694159390.data` | 264,196 B (~258 KB) | 地形高度图 |
| `MatCoverTex_1694159390.png` | 728,056 B (~711 KB) | 地表覆盖纹理 |
| `SplatMap_..._0.png` | 11,183 B | 地形混合贴图 0 |
| `SplatMap_..._1.png` | 11,197 B | 地形混合贴图 1 |
| **scene.data 总计** | **793,068 B (~774 KB)** | 压缩后存档 |

### 1.2 SerializePcgData.json 统计

| 指标 | 实测值 |
|---|---|
| version | 2 |
| isOpenStreamingLoad | true |
| moveMaxSpeed / jumpMaxHeight / respawnHeightY | 4.0 / 1.0 / −50.0 |
| **nodeTransformDatas（场景节点）** | **253** |
| **resourceRefs（资源引用）** | **8** |
| **runtimeScripts（脚本注册）** | **34 keys** |
| spawnPointData | 1 |
| waterNetworks / waterTerrainBaselines | 0 / 0 |
| audioData keys | 4 |
| 结构递归统计 | 3,012 dict / 493 list / 最大深度 7 |

### 1.3 证据
- `evidence/scene-benchmark-a.json`
- `evidence/scene-benchmark-a-detailed.json`

---

## 2. 与 B 的 Desk 场景对比（B 报告数据）

| 场景 | 节点数 | 备注 |
|---|---|---|
| A 集成工程 | 253 | 本轮实测 |
| B Desk SCAD 场景 | 58 | B `SCAD-SCENE-PIPELINE.md`（写入 scene.data 的节点） |

两者都远低于任何工具输出上限（1000 节点读取上限是查询返回限制，非场景容量）。

---

## 3. 明确 NOT TESTED（未做，不猜测）

| 项 | 状态 | 原因 |
|---|---|---|
| 单 GLB 上传大小上限（20 MiB 等） | **NOT TESTED** | 20 MiB 是 MCP 适配器参数；未做 GUI 上传实测 |
| 单模型 mesh/vertex/triangle/texture 安全规模 | **NOT TESTED** | 未逐级加压测试 |
| 100/250/500 节点逐级添加与 FPS 曲线 | **NOT TESTED** | 需隔离工程 + GUI 预览计时，未做破坏性测试 |
| 地形尺寸上限 / 分块激活范围 | **NOT TESTED** | 未实测 |
| 运行时内存 / FPS / 加载 / 保存耗时 | **NOT TESTED** | 需 GUI 运行观测 |
| 发布容量字段（capacity 1–30）语义 | **NOT TESTED** | 未确认是玩家容量还是世界尺寸 |
| GLB MeshCollider 阻挡 / WPRE GUI 导入 | **BLOCKED / NOT TESTED** | 运行时入口 BLOCKED（B-07） |

---

## 4. 当前安全生产预算（基于实测基线的保守建议）

> 非理论上限，仅作为本项目的保守工作区间；合规 Issue #23 §6"控制在实测失效阈值 60–70%"的精神。
> 因未做失效阈值测试，这里给出的是**当前已验证规模**，不是阈值百分比推算。

| 资源 | 当前已验证规模（A 工程） | 建议工作区间 |
|---|---|---|
| 场景节点 | 253（实测 PASS） | 单场景 ≤ 300 节点保守；超出需 GUI 预览复核 |
| 资源引用 | 8（实测） | 复用为主，新增 GLB 逐个过导入 Gate |
| 运行时脚本注册 | 34（实测） | 保持少而专；状态用节点存储，避免多实例 |
| 场景存档 | ~774 KB（实测） | 纹理是大头（MatCoverTex ~711 KB），控制贴图分辨率与数量 |
| 地形 | 1 高度图 + 1 覆盖 + 2 混合（实测） | 单场景 1 套地形即可 |

**结论**：Hub/Terminus 当前体量（253 节点 / 8 资源）远未触及任何观测到的瓶颈。
四个世界按"独立 WPRE/场景模块 + 列车入口连接"拆分（Issue #23 §9 允许），
不合并成单张超大场景，即可保持在已验证规模内。

---

## 5. 下一步（需 GUI，A 不越权）

1. 隔离工程做 10/25/50/100 轻量对象逐级添加，记录 FPS/加载/保存（Issue #18 §A）。
2. 一份带材质 GLB 走完整链：文件→资产库→放置→保存→重开→Preview 可见（Tripo Gate 前置）。
3. B/C 各自 GUI 实测 Desk / Garden 场景节点量级，补齐全项目预算。
