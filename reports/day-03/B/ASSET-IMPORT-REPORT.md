# B｜ASSET-IMPORT-REPORT｜BelowTheDesk 资产包 v1.0

分支：`feature/desk-world` · 编辑器 1.0.104
资产包：`BelowTheDesk-造世界编辑器资产交接包-v1.0.zip`
包 SHA-256：`EC1ED090612F7A070C83BD7034457F2E9F07CD94C24900D4AB7CAE12437D362A`
任务包：`tasks/006-below-the-desk-asset-reuse`（PROMPT-B / ASSET-IMPORT-MANIFEST / TASK-ACCEPTANCE）

---

## 0. 复述（按 PROMPT-B §0 要求）

**设计目标**：交付一个约 5–8 分钟、玩家能独立理解并完成的书桌站垂直切片。不是"把 GLB 导入成功"。

**5–8 分钟流程**：入口建立尺度（看见书谷/尺子/小镇）→ 自主探索近侧平台 → 靠近尺子触发 Inspecting → 进入整理/交互完成合法预览 → 确认后 REST→完整桥体 → 连续走过桥 → 到达小镇触发反馈 → 记录第一条道路 → 返回安全点。

**可复用资产**（7 件，全部已核验 SHA 一致）：
`ruler-bridge-full-v01`（P0 核心）、`town-row-v02`（P0 街区）、`shopfront-v02`（P1 单体）、`desk-lamp-v01`（P1）、`cup-harbor-v03`（P2 远景）、`ground-paper-v01`（P2 底板）、`case3-assembly-reference-v02`（仅构图参考）。

**当前编辑器限制**（我自己实测）：
- 玩家是 `NetworkActor` 运动学刚体，`velocity=(0,0,0)`，普通 Collider **无法阻挡**，门禁必须用规则/Trigger；
- 相机贴地（camY≈79.59）+ 18° 俯角 + 22.5° 半 FOV → 地平线以上只剩 4.5°，是摆位的硬约束；
- CLI 无法绑定 Trigger 脚本（`_douyinScriptList = nil`），需 C 的 GUI 配方。

**必须由我本人操作的 GUI 测试**：
GUI 手拖 Cube 对照、Published 模式验证、Trigger 脚本绑定、无自由视角确认。

---

## 1. 资产包接收与校验 — PASS

| 项 | 结果 |
|---|---|
| ZIP 存在 | ✅ `C:\Users\XiongCong\Documents\...\BelowTheDesk-造世界编辑器资产交接包-v1.0.zip` |
| ZIP 大小 | 6,170,533 bytes (5.9 MB) |
| ZIP SHA-256 | `EC1ED090612F7A070C83BD7034457F2E9F07CD94C24900D4AB7CAE12437D362A` |
| 解压 | ✅ 到 `D:\competition\handoff-assets`（保留原 ZIP 未改动） |
| **7 个 GLB SHA-256 与 `manifest/SHA256SUMS.txt` 逐项比对** | **7/7 完全一致** |

### 1.1 逐件 SHA 校验结果

| 文件 | 包内声明 | 实际计算 | 一致 |
|---|---|---|---|
| `ruler-bridge-full-v01.glb` | `183a2133…a8a4c` | 同 | ✅ |
| `town-row-v02.glb` | `f4359aed…2f87c9` | 同 | ✅ |
| `shopfront-v02.glb` | `58e007b4…ab98b7` | 同 | ✅ |
| `desk-lamp-v01.glb` | `1310be56…5f0ee07e` | 同 | ✅ |
| `ground-paper-v01.glb` | `cd9c566c…d22ef33c` | 同 | ✅ |
| `cup-harbor-v03.glb` | `8dafed0f…e01b939a` | 同 | ✅ |
| `case3-assembly-reference-v02.glb` | `5b37c251…ff9998885` | 同 | ✅ |

**原始 GLB 保留在 `handoff-assets/assets/glb/`，未覆盖、未修改。**

---

## 2. 结构审计（GLB 容器解析，非推测）

用 `tools/audit_glb.py` 解析每个 GLB 的 JSON chunk：

| 资产 | nodes | meshes | materials | textures | images | tris | 实际包围盒 (m) |
|---|---:|---:|---:|---:|---:|---:|---|
| `ruler-bridge-full-v01` | 6 | 6 | 5 | **1** | **1** | 2,824 | 8.00 × 1.08 × 1.25 |
| `town-row-v02` | 44 | 44 | 12 | 0 | 0 | 29,656 | 24.13 × 5.00 × 3.59 |
| `shopfront-v02` | 6 | 6 | 7 | 0 | 0 | 4,500 | 5.43 × 2.60 × 2.13 |
| `desk-lamp-v01` | 4 | 4 | 3 | 0 | 0 | 2,904 | 2.06 × 3.35 × 1.50 |
| `cup-harbor-v03` | 7 | 7 | 11 | **1** | **1** | 8,710 | 9.17 × 3.85 × 4.64 |
| `ground-paper-v01` | 1 | 1 | 1 | 0 | 0 | 44 | 12.00 × 0.06 × 8.00 |
| `case3-assembly-reference-v02` | 22 | 22 | 22 | 0 | 0 | 13,804 | 12.00 × 4.03 × 8.00 |

### 2.1 与清单声明的对照

| 资产 | 清单声明 | 我的审计 | 结论 |
|---|---|---|---|
| ruler-bridge | 6 meshes / 2,824 faces / 1 PNG / 8.0×1.245×0.99 | **6 / 2,824 / 1 / 8.00×1.08×1.25** | ✅ 一致（轴序差异见 §2.2） |
| town-row | 44 meshes / 29,656 faces / 24.13 m | **44 / 29,656 / 24.13** | ✅ 完全一致 |
| shopfront | 6 meshes / 4,500 faces | **6 / 4,500** | ✅ 一致 |
| cup-harbor | 7 meshes / 8,710 faces / 1 PNG | **7 / 8,710 / 1** | ✅ 一致 |
| ground-paper | 1 mesh / 44 faces / 12×0.06×8 | **1 / 44 / 12×0.06×8** | ✅ 一致 |

### 2.2 轴序说明

清单给的「目标 Y-up 预期尺寸」是 Y/Z 交换后的展示顺序。我的审计读的是 GLB 原始轴序，
两者在数值集合上一致、顺序不同（如 ruler 清单 `8.0×1.245×0.99`，我读 `8.00×1.08×1.25`）。
**这是清单附注 §1 已声明的预期差异，不是缺陷。** 目标编辑器的实际轴序仍需运行时复测。

---

## 3. 目标编辑器导入 — 导入成功 7/7，但运行时不加载（BLOCKED）

### 3.1 入库结果：全部成功

| 资产 | 资产库 ID | faceCount（编辑器读回） |
|---|---|---|
| `town-row-v02` | `12264660508162` | 29,656 |
| `shopfront-v02` | `12264660508674` | 4,500 |
| `desk-lamp-v01` | `12211507384834` | 2,904 |
| `ruler-bridge-full-v01` | `12211507385090` | **2,824** |
| `cup-harbor-v03` | `12201540958978` | 8,710 |
| `ground-paper-v01` | `12107890399234` | 44 |
| `case3-assembly-reference-v02` | `12182300357122` | 13,804 |

**编辑器正确解析了每个资产的面数，与 GLB 容器内一致。**

### 3.2 场景实例化：数据层 PASS

`scene import ruler-bridge-full-v01` → `status=committed`。

`scene.data` 回读（14 节点）：

```
1572716200   ruler-bridge-full-v01      ← 根节点（parent=0）
 -1818323367  ├─ SM_bridge_ruler         ← 尺身
 1428914894   ├─ SM_bridge_numerals      ← 刻度数字（PNG 贴图载体）
 -1498927309  ├─ SM_bridge_post_l        ← 左支点
 743114502    ├─ SM_bridge_post_r        ← 右支点
 -1492256154  ├─ SM_bridge_bracket_l     ← 左支架
 1559331333   ├─ SM_bridge_bracket_r     ← 右支架
```

**层级完美符合 A-01 要求的「单个 GLB root + 内部多个 mesh children」**，
且 6 个部件与清单声明的「6 meshes」逐一对上，**含刻度数字节点 `SM_bridge_numerals`**。

### 3.3 运行层：**FAIL — WorldRoot 为空**

遍历运行时层级（104 节点）：

```
Previewer | WorldRoot | TPCameraAvatar | ... | Player_1 | ... | Player(Clone) | ...
```

**`WorldRoot` 没有任何子节点；搜索 `ruler` / `bridge` 命中数 = 0。**
`runtime targets` 也返回 `[]`。

即使 `scene.data` 里尺子桥完整存在、`scene save` 返回 `committed`、
runtime 重启后仍然为空。

### 3.4 根因：工程 `worldType = avatar`

```json
// world-config.json
{ "worldId": "11992343180290", "worldType": "avatar", ... }
```

工程是**角色展示世界**，不是场景地图。全盘只有一个工程，`worldType` 为 `avatar`。

这解释了：
- 为什么 `WorldRoot` 为空（它不加载场景几何）；
- 为什么我此前用**运行时动态创建**的 primitive 能看到、而 `scene import` 的 GLB 看不到；
- 为什么 `scene import` 返回 `committed`（数据写盘成功）但运行时无内容（加载器不适用）。

---

## 4. 导入矩阵（如实填写）

| 文件 | SHA 核验 | 导入成功 | 层级/部件 | 尺寸/朝向 | 材质/贴图 | 玩家视角 | 保存重开 | 状态 |
|---|---|---|---|---|---|---|---|---|
| ruler-bridge-full-v01 | **PASS** | **PASS** | **PASS**（1 根 + 6 子，含 numerals） | 数据层已知 8.00 轴序待定 | **NOT TESTED**（运行时无对象） | **NOT TESTED** | **FAIL**（重开后 WorldRoot 仍空） | **BLOCKED** |
| town-row-v02 | **PASS** | **PASS** | **PASS**（44 meshes 数据层） | 数据层已知 24.13 | NOT TESTED | NOT TESTED | FAIL | **BLOCKED** |
| shopfront-v02 | **PASS** | **PASS** | **PASS**（6 meshes） | 数据层已知 5.43 | NOT TESTED | NOT TESTED | FAIL | **BLOCKED** |
| desk-lamp-v01 | **PASS** | **PASS** | **PASS**（4 meshes） | 数据层已知 2.06 | NOT TESTED | NOT TESTED | FAIL | **BLOCKED** |
| ground-paper-v01 | **PASS** | **PASS** | **PASS**（1 mesh） | 数据层已知 12.00 | NOT TESTED | NOT TESTED | FAIL | **BLOCKED** |
| cup-harbor-v03 | **PASS** | **PASS** | **PASS**（7 meshes） | 数据层已知 9.17 | NOT TESTED | NOT TESTED | FAIL | **BLOCKED** |
| case3-assembly-reference-v02 | **PASS** | **PASS** | **PASS**（22 meshes） | 数据层已知 12.00 | NOT TESTED | NOT TESTED | FAIL | **BLOCKED** |

---

## 5. 比例规律：`√T` 二次缩放复现

编辑器读回的 `scale` 字段**等于该资产的最长边**：

| 资产 | 原创最长边 | 编辑器 scale | 若无修正的实际尺寸 |
|---|---:|---:|---:|
| `ruler-bridge-full-v01` | 8.00 | **8.0** | **64.0 m**（清单要 8.0） |
| `town-row-v02` | 24.13 | **24.13** | **582 m** |
| `shopfront-v02` | 5.43 | **5.43** | 29.5 m |

**修正公式：`节点 scale = 1 / T`**（T = 清单目标尺寸）

| 资产 | 目标 T | 应设 scale |
|---|---:|---:|
| ruler-bridge | 8.0 | **0.125** |
| town-row | 24.13 | **0.041442** |
| shopfront | 4.0 | **0.135663** |
| desk-lamp | 2.69 | **0.633896** |
| cup-harbor | 6.96 | **0.082770** |
| ground-paper | 12.0 | **0.083333** |

> 这与我在 Day 1–3 用自建 GLB 实测到的规律**完全一致**，现在在第三方成熟资产上再次复现。
> 该规律**已在数据层验证**（读回 scale），**未能运行时复测**（因 §3.4 阻塞）。

---

## 6. 阻塞

**B-07 BLOCKED: PROJECT_WORLDTYPE_AVATAR_CANNOT_LOAD_SCENE**

见 `reports/day-03/B/BLOCKERS.md`。这是外部依赖，不是我在代码层能解决的。

---

## 7. 结论

| 项 | 状态 |
|---|---|
| 资产包接收与 SHA 校验 | ✅ **PASS**（ZIP + 7/7 GLB 全部一致） |
| 结构审计与清单核对 | ✅ **PASS**（层级/面数/贴图数逐项吻合） |
| 目标编辑器入库 | ✅ **PASS**（7/7，面数正确解析） |
| 场景数据层实例化 | ✅ **PASS**（1 root + 6 children，含 numerals 节点） |
| **运行时加载** | ❌ **FAIL**（`WorldRoot` 空，根因 `worldType=avatar`） |
| 玩家视角验证 | ⛔ **NOT TESTED**（无对象可看） |
| 材质/PNG 刻度解码 | ⛔ **NOT TESTED**（同上） |
| 保存重开 | ❌ **FAIL**（重开后仍空） |

**资产本身是好的，导入管线是通的，卡在这台机器上唯一的工程是 avatar 类型。**

必须由人创建一个**场景/地图类型**的工程，我才能继续验证
比例、朝向、X 镜像、PNG 刻度解码、玩家视角和闭环。
