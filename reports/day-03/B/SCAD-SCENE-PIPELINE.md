# B｜场景制作正确路径已打通（重大进展）

分支：`feature/desk-world` · 编辑器 1.0.104
日期：2026-11-24
状态：**数据层 PASS（44 节点装配成功）｜运行层仍 BLOCKED**

---

## 0. 本节最重要的一句话

> **我之前一直在用错误的路径做场景。**
> `scene import --asset-id <GLB>` 只把 GLB 当**模型资产**放进场景；
> 真正的关卡必须走 **SCAD map → generate-map-assembly → prefab attach → build → asset import → scene import**。

这条链现在**已经跑通到数据层**（58 节点写入 `scene.data`）。

---

## 1. 正确路径（完整验证过，可复用）

```powershell
# 1. 创建作者工作区与 WPrefab
douyin-world authoring prefab create --workspace <WS> --prefab deskworld

# 2. 初始化 SCAD 地图资源（不传 backend 即 SCAD）
douyin-world authoring skill run initialize-map --workspace <WS> --argv-file argv.json
#   argv.json = ["--config","{\"prefabId\":\"deskworld\",\"resourceId\":\"map-desk\",
#                \"displayName\":\"书桌站\",\"bounds\":[40,48],\"seed\":7}"]

# 3. 编辑 source/scene.scad（见 §3）

# 4. 编译检查 —— 必须看到 colliderTriangles > 0
douyin-world authoring resource map check map-desk --prefab deskworld --workspace <WS>

# 5. 生成装配脚本，再执行到 prefab 上
douyin-world authoring skill run generate-map-assembly --workspace <WS> --argv-file asm.json
#   然后：
douyin-world authoring prefab execute deskworld --file <WS>/wprefabs/deskworld/.tmp/scene-execute/map-assemble.js --workspace <WS>

# 6. 校验 + 构建 + 导出
douyin-world authoring prefab validate deskworld --workspace <WS>
douyin-world authoring prefab build    deskworld --workspace <WS>
douyin-world authoring prefab export   deskworld --workspace <WS> --out <OUT>

# 7. 作为资产入库，再导入场景
douyin-world asset import <OUT>/deskworld.wprefab
douyin-world scene import --asset-id <ID> --position=0,0,0
```

### 关键陷阱（我踩过的）

| 错误做法 | 症状 | 正确做法 |
|---|---|---|
| `scene import --asset-id <裸 GLB>` | 节点写入但层级扁平，无 map 语义 | 必须走 map → assembly |
| `prefab create` 不传 `--prefab` | `缺少 --prefab` | 显式给 `--prefab <id>` |
| `--workspace` 用自建目录 | `External archive requires an existing workspace` | 用 `prefab create` 生成的 `ai-sessions/workspace_*` |
| `generate-map-assembly` 无 `--output` | usage 报错 | 必须给 `wprefabs/<id>/.tmp/scene-execute/*.js` |
| `--output` 用绝对路径 | `codeFile must be a safe JavaScript path` | **必须用相对路径** |
| `world_visual_form(...)` 无 `structure_kind` | `Primary visual form requires a semantic kind` | 加 `structure_kind="landform|building|path|assembly"` |
| `scene import --uri <本地路径>` | `Prefab 下载失败: 500` | 只能先用 `asset import` 入库 |

---

## 2. 装配结果（实测数字）

```
generate-map-assembly  → { "codeFile": "...map-assemble.js", "byteLength": 7297 }
prefab execute         → updated 87 nodes, 67 components
                          result: { root: "n1", environment: "n2", placements: [] }
prefab export          → 21,684 bytes
```

### 2.1 导出的 prefab 层级（44 节点）

```
1  map-desk
2  └─ Environment
3     ├─ world_visual_form → world_surface → world_collider → Node-4
7     ├─ world_visual_form → world_surface → world_collider → Node-8
11    ├─ world_material  → Node-10
13    ├─ world_material  → Node-12
15    ├─ world_visual_form → Node-14
17    ├─ world_visual_form → world_surface → world_collider → Node-18
...
```

**这是正确的 map 结构**：每个 `world_visual_form` 下挂 `world_surface` + `world_collider`，
材质用 `world_material` 单独成节点。

### 2.2 SCAD 编译指标

| 指标 | 值 |
|---|---|
| `colliderTriangles` | **48**（可走碰撞面） |
| `nodes` | 43 |
| `materials` | 13 |
| `visualTriangles` | 612 |
| `glbBytes` | 63,620 |

`colliderTriangles = 48 > 0` 说明**可走表面已真正生成**，不是空壳。

---

## 3. 场景内容（`scene.scad`）

按 `BELOWTHEDESK-DESIGN-BASIS.md` 与 `TASK-ACCEPTANCE` §B-06 的八步流程布置：

| 区域 | 位置 (SCAD XY) | 尺寸 | 对应设计 |
|---|---|---|---|
| 桌面 | 全图 40×48 | — | 一张连续桌面 |
| 近侧平台 | (-4..4, 0..10) | 8×10, 顶 0.30 | 书谷入口、出生点 |
| 书脊/书页 | 平台边缘 | — | 让玩家读出"这是一本书" |
| **断口** | (-4..4, 10..12) | 8×2.2 | **刻意无 collider**，尺子桥要跨 |
| 对岸平台 | (-4..4, 12..24) | 8×12 | 桥对岸 |
| **尺子 REST** | (-7.2, 2..10) | 0.9×8.0 | 躺在左侧，指向断口 |
| **尺子 RAMP** | (-4..4, 9.6) | 8.0×1.2 | 横跨断口（与 REST 互斥） |
| 铅笔盒小镇 | (-12..12, 26..30) | 24×4×5 | town-row 24.13 m |
| 暖窗 | 小镇立面 ×6 | 1.2×1.4 | `MAT_window_glow` 语义 |
| 台灯 | (16, 34) | r1.05, 高 3.35 | 远景"太阳" |

**尺寸全部取自 asset kit 的 GLB 实测值。**

---

## 4. 运行层仍然为空

同样的问题复现：

```
数据层 scene.data : 58 节点，deskworld 根 -1429749754，完整 world_* 层级
运行层 WorldRoot  : 0 子节点
运行层 MeshRenderers : 0
```

**所以断点不在"场景制作方式"，而在"场景数据 → 运行时"。**

这排除了一个新假设：**不是因为我之前用裸 GLB 所以不加载**。用正确的 map 路径制作，
数据层完美，运行层依然为空。

---

## 5. 与运行时日志的呼应

日志显示启动的是 `HamletWorldGame`（角色世界），按 `EntryType` 切换状态。
现在可以更精确地说：

> **`runtime start` 启动的是角色预览世界，它不消费 `scene.data` 的关卡内容。
> 无论关卡是用裸 GLB 还是 SCAD map 制作，都不会出现在这个世界里。**

---

## 6. 本轮实际收获

即使运行层仍阻塞，本轮解锁了**建世界的正确方法**：

| 之前 | 现在 |
|---|---|
| 只能用运行时 primitive 摆假物体 | ✅ **能写 SCAD 生成真实关卡几何 + 碰撞面** |
| 无法产出 `colliderTriangles` | ✅ **48 个碰撞三角面已生成** |
| 不知道 map/prefab 关系 | ✅ **完整链路已验证** |
| 资产只能裸导入 | ✅ **能装配成带语义层级的 prefab** |

**这些能力在运行层修好后可以直接交付。**

---

## 7. 下一步

1. **等待 GUI 验证**（人工点"运行"看地形是否出现）
2. 若 GUI 可见 → 我的 SCAD 场景即可直接使用
3. 若 GUI 也不可见 → 需要编辑器方说明关卡世界的启动方式

**我这边已经没有任何"我可以自己试"的路径了。**
