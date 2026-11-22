# DAY 01｜B｜证据台账

本文件记录 Day 1 全部**真实执行**的证据。原则：每条证据都能被第三方复现或点开；未能取得的也明确写出，不含糊。

---

## 0. 环境基线

| 项 | 值 |
|---|---|
| 编辑器 | 造世界编辑器 **1.0.104**，安装于 `D:\wow-land\造世界编辑器` |
| CLI | `douyin-world` 1.0.104（`C:\Users\XiongCong\.local\bin\douyin-world.cmd`） |
| 实例 ID | `e96ad682-ead0-42a6-b622-2aea64ef1510` |
| 工程目录 | `%APPDATA%\AI World Creator\projects\project-006822bc-d20b-4e2b-b6ae-b80fc9498688` |
| 工程名 | 「我的项目」（空白 avatar 底图，Day 1 直接在此验证，未新建项目） |
| Blender | **未安装**（全盘检索无 Blender；Day 4 需补装或改用几何体方案） |

---

## 1. 探针 P-01｜实例发现

```
$ douyin-world doctor
✓ 来源：安装包：D:\wow-land\造世界编辑器，编辑器 1.0.104
✓ CLI 连接：命令指向这一份
✓ Creator：e96ad682-ead0-42a6-b622-2aea64ef1510：已就绪

$ douyin-world instance list
{ "instances": [ { "instanceId": "e96ad682-...", "pid": 18828,
                   "projectRoot": "...project-006822bc...",
                   "baseUrl": "http://127.0.0.1:65405" } ] }
```
**结论：** 编辑器可用，CLI 可驱动。

---

## 2. 探针 P-02｜GLB 入库（含 Tripo 产线格式）

**先验证既有资产**（小木船，Tripo 生成，`KHR_texture_basisu` + KTX2）：

```
$ douyin-world asset import 7d3dcb97-....glb --instance <IID>
{ "failedFiles": [], "successCount": 1, "totalCount": 1,
  "assets": [{ "id": "12170880637698", "faceCount": "2028", "capacity": "2228", ... }] }
```

**再验证自建白盒**（9 个，由 `tools/make_whitebox.py` 生成，无任何第三方依赖）：

```
$ douyin-world asset import WB_*.glb --instance <IID>
{ "failedFiles": [], "successCount": 9, "totalCount": 9 }
```

**结论：**
- ✅ GLB 入库可用，Tripo 的 KTX2 贴图正常解析（`faceCount` / `capacity` 被读出）；
- ✅ 手写最小 GLB（POSITION + COLOR_0 + 索引，无贴图）也能入库；
- **这证明 Day 4 的 Tripo 通路不必再冒格式风险。**

---

## 3. 探针 P-03｜场景实例化

多次 `scene import`，主体全部 `status=committed`：

| 顺序 | 对象 | 位置 | rootID |
|---|---|---|---|
| 1 | 船（测试） | 0,0,10 | `-1541147901` |
| 2 | WB_DESK | 0,0,0 | `501973369` |
| 3 | WB_BOOK_A | -13,0,-6 | `1321260460` |
| 4 | WB_BOOK_B | -13,0,4 | `553917970` |
| 5 | WB_RULER | -8,0.7,0 | `-1170089122` |
| 6 | WB_PENCILCASE | 12,0.6,0 | `-478005239` |
| 7 | WB_PENCILCASE（重复） | 12,0.6,0 | `-168887970` |
| 8 | WB_ERASER | -3.5,0.6,-9 | `-734897796` |
| 9 | WB_PENCIL | -3.5,0.6,9 | `1930925036` |
| 10 | WB_LAMP | 26,0,0 | `-448382378` |
| 11 | WB_MUG | 30,0,0 | `1514353337` |

**已知瑕疵：** 第 6/7 项是同一物体的重复实例（一次超时重试导致）。**必须在 Day 2 清理**，已记入 §7。

---

## 4. 探针 P-04｜保存与重开

```
$ douyin-world scene save --request-id save-day1-wb2
{ "operationId": "edc6a43e...", "status": "committed", "hasUnsavedChanges": false }
```

重开后解包 `scene.data`（ZIP）验证节点仍在：

```
18 nodes：
  地图 / 地形 / 地形块(0,0) / 湖泊 / 边界墙 / 出生点(119.74, 80.0, 88.64)
  + 11 个导入对象（含 1 个重复）
moveMaxSpeed = 4.0   jumpMaxHeight = 1.0   respawnHeightY = -50.0
spawnPointData = [{"id": 118359383}]
```

**结论：** ✅ 工程可保存、可重开、节点持久化。

### 4.1 由该探针得到的实测尺度基准

| 参数 | 实测 | 意义 |
|---|---|---|
| `moveMaxSpeed` | **4.0** | 玩家移动速度 |
| `jumpMaxHeight` | **1.0** | **跳不过任何主要物件**（橡皮 1.8 m / 铅笔直径 1.7 m）→ 路线必须靠坡道 |
| `respawnHeightY` | **-50.0** | 掉落有安全回退，不会软锁 |
| 出生点 | (119.74, 80.0, 88.64) | 与白盒原点相距 148 m ← 见 §7 已知问题 |

---

## 5. 探针 P-05｜环境参数（「台灯暖光 vs 窗外冷蓝」）

`scene environment get` 返回 **44 个字段 / 8 个分组**，全部可写：

| 分组 | 字段数 | 关键能力 |
|---|---|---|
| MainLight | 10 | pitch/yaw/color/strength/shadow + **LensFlare（Sun01-03 / Moon01）** |
| Skybox | 4 | 天空盒贴图 + XYZ 旋转 |
| Weather | 6 | 雨/雪（6 种粒子）、颜色、密度、倾角 |
| Ambient | 2 | 角色环境光 |
| CharLight | 5 | 角色补光（色/强度/角度） |
| Reflection | 2 | 反射 cubemap |
| **Fog** | 4 | 雾开关/颜色/起止距离（0–2000） |
| PostProcess | 10 | Bloom（色/阈值/强度/scatter）+ Vignette |

**可用天空盒（实测枚举）：** 白天、夕阳、**夜晚**、**星空**、雨、雪。

**已实际写入并保存**（`envParamJson` 回读验证）：

```json
{ "mainLightColor": "#ffcf99", "mainLightStrength": 2.4,
  "mainLightPitch": 38, "mainLightYaw": 128, "shadowStrength": 0.88,
  "skyboxTextureUri": "hamlet-ugc/aigc_editor/MarsWorld_sky01_night01.tga",
  "fogEnable": true, "fogColor": "#1b2b47", "startFog": 90, "endFog": 320,
  "bloomColor": "#ffd9a8", "vignetteAmount": 0.30 }
```

回读确认：`mainLightColor = {r:1.0, g:0.8118, b:0.60}`、`skybox = ...night01.tga` → **写入成功且已持久化。**

> ⚠️ **但夜景未取得截图**（见 §8）。参数已生效于工程数据，视觉验证未完成。

---

## 6. 探针 P-06｜截图能力（远/中/近景）

| 能力 | 命令 | 结果 |
|---|---|---|
| 玩家视角整帧 | `runtime screenshot --out X` | ✅ 2537×1457 |
| 节点定向环绕 | `--object=<id> --yaw --pitch --distance --size` | ✅ 1400×1400 |
| 运行时层级枚举 | `runtime snapshot` | ✅ 返回完整节点树，可拿 `instanceId` |
| **录屏** | — | ❌ **CLI 无录屏命令**，见 `BLOCKERS.md` B-02 |

### 6.1 已交付截图（`evidence/day-01/`）

| 文件 | 内容 | 证明什么 |
|---|---|---|
| `01-editor-blank-spawn-before.jpg` | 导入前的空白出生点 | 底图基线：一片平地 + 默认角色 |
| `02-editor-post-import-hierarchy.jpg` | 导入后的**编辑器场景层级** | 左侧树列出全部 `WB_*` 对象 → **真实入库** |
| `03-player-view-whitebox.jpg` | 玩家视角（运行时） | 真实运行画面 |
| `04-wb-wide-far.jpg` | 远景：全体白盒 | 体量关系、书/尺/盒/杯/灯的相对尺度 |
| `05-wb-canyon-mid.jpg` | 中景：书谷 | 书墙与玩家通道的关系 |
| `06-wb-bridge-mid.jpg` | 中景：尺子桥位 | 裂口 + 尺子 + 两端关系 |
| `07-wb-village-goal.jpg` | 中景：小镇目标 | 目标可见性 |
| `08-editor-ui-scene-tree.jpg` | 编辑器 UI 全貌 | 场景树 + 资产库缩略图 + 容量条 207/4000 |

> **这些图是从真实运行的引擎里截的**，不是示意图、不是 Blender 渲染、不是概念图。

---

## 7. 已知问题（本轮真实存在的）

| # | 问题 | 影响 | 状态 |
|---|---|---|---|
| 1 | 白盒位于世界原点 (0,0,0)，出生点在 (119.74, 80, 88.64) | 进游戏**看不到**任何白盒（第一张玩家截图即空场景） | **未修复**，Day 2 处理 |
| 2 | `WB_PENCILCASE` 有**两个重复实例**（超时重试造成） | 场景脏 | **未修复**，Day 2 清理 |
| 3 | 夜间环境已写入但**无视觉截图** | 无法确认暖光冷调是否成立 | **未验证** |
| 4 | 无玩家行走录屏 | 无法证明"可走通" | **未取得** |
| 5 | CLI 无节点移动/变换命令 | 只能用 remove + re-import 调整布局，破坏性高 | **能力缺失** |

---

## 8. 未能取得的证据（明确声明）

| 证据 | 原因 | 计划 |
|---|---|---|
| **玩家视角录屏** | `douyin-world` 无录屏命令；运行实例 Day 1 后半段反复卡在 `status=loading` | Day 2 用 `runtime input` + 高频 screenshot + ffmpeg 合成 |
| **夜景截图** | 同上：写入夜间环境后运行实例持续 `loading`，无法截图 | Day 2 重试 |
| **行走穿越裂口** | 白盒位置未对齐出生点 | Day 2 对齐后再测 |
| **GLB 碰撞是否自动生成** | 未做专项探针 | Day 2 |
| **锚点吸附是否可行** | CLI 无对应 API，未验证 | Day 2，见 `BLOCKERS.md` B-03 |

> 按 `production/prompts/README.md` §4.7：「不得伪造完成状态」。上表即为此规则的执行。

---

## 9. 可复现工件

| 工件 | 路径 | 说明 |
|---|---|---|
| 白盒生成器 | `tools/make_whitebox.py` | 纯 numpy，产出 9 个 GLB，可复跑 |
| 白盒装配 | `tools/assemble_whitebox.ps1` | 10 次 scene import + save |
| GLB 审计器 | `tools/audit_glb.py` | 结构/材质/包围盒/面数 |
| GLB 预览器 | `tools/glb_preview.py` | 自写光栅器，识别无名资产 |
| WPREFAB 审计器 | `tools/inspect_wprefab.py` | 解 ZIP，读 PCG + 元数据 |
| 资产审计原始输出 | `evidence/asset-audit.json` | 7 个 GLB 全字段 |
| WPREFAB 审计输出 | `evidence/wprefab-audit.json` | 4 个 WPrefab 全字段 |
| 资产渲染图 | `evidence/asset-previews/` | 9 张（7 GLB 三视角 + 2 WPrefab 官方预览） |

---

## 10. Commit / 分支

- 分支：`feature/desk-world`
- 基线：`origin/main` @ `d6361a36a4bc3ecdc9085ae2f6a84d832353b371`
- **网络限制说明：** 本机 `git` 无法直连 `github.com:443`（TLS 被重置），`api.github.com` 正常。因此通过 GitHub **Git Data API** 推送（`tools/gh_push.py`），语义等价于 push，且**只写 `feature/desk-world`，从不触碰 `main`**。
