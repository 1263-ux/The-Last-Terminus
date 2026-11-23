# reports/day-03/A/GLB-IMPORT-MATRIX.md

> Owner：成员 A
> 阶段：Day-3 A2
> 引擎：造世界编辑器 1.0.104；CLI douyin-world 1.0.104
> 导入路径：**`resource model import → resource archive → prefab attach → prefab build → result archive → scene import`**
> 共享资产：`reports/day-03/A/shared-assets/`（5 个 GLB + ASSET-MANIFEST.csv，含 SHA-256）

---

## 0. 结论（一句话）

**在我使用的这条导入链路里，GLB 尺寸 1:1 保留、无二次放大；X 轴镜像稳定复现；**
**B 报告的 `actual = source × longestEdge` / `sqrt(T)` 是「直接 scene import 裸 GLB」路径的局部现象，
不能升为全局公式。**

这一点支持总设计师 `EDITOR-TECHNICAL-FINDINGS.md` 的生产决策：
**"不发布未经复现的全局换算公式"**。

---

## 1. 资产准备（A1）

全部由 `make_day3_assets.py` / `GLBBuilder` 生成；每个 primitive 均带
`POSITION + NORMAL + TEXCOORD_0` —— **NORMAL 必带**（C-11：没有法线会出现"有影子没表面"）。

| 资产 | 作者 bounds（resource inspect 读回） | SHA-256（前16） | 字节 |
|---|---|---|---|
| `probe-cube-1m.glb` | min −0.5 / max +0.5（1 m 立方） | `fb0021dcc17077f5` | 2044 |
| `probe-cube-2m.glb` | min −1 / max +1（2 m 立方） | `6cf8c379f819b8b8` | 2044 |
| `probe-cube-4m.glb` | min −2 / max +2（4 m 立方） | `6e4024a19f122c3b` | 2044 |
| `probe-axis-marker.glb` | min (−0.2,0,−0.2) / max (2,0.8,1) | `ac6202d573aac7dd` | 7692 |
| `probe-textured-cube.glb` | min −0.5 / max +0.5，内嵌 885 B PNG | `6896c47f6241b001` | 3200 |

完整 SHA-256 见 `shared-assets/ASSET-MANIFEST.csv`。

**轴标设计**：`AxisPlusX_RED` 长臂沿 +X 到 x=+2；`AxisPlusZ_BLUE` 沿 +Z 到 z=+1；
`AxisPlusY_GREEN` 沿 +Y 到 y=+0.8。三色区分，导入后哪个方向翻了一目了然。

---

## 2. A2 尺寸矩阵：源 → 数据层 → 运行时

### 2.1 数据层（prefab 文档读回，`A2-prefab-scales.json`）

| 源尺寸 | prefab 节点 scale | 判定 |
|---|---|---|
| 1 m | (1, 1, 1) | 无放大 |
| 2 m | (1, 1, 1) | 无放大 |
| 4 m | (1, 1, 1) | 无放大 |
| 轴标 / 贴图 cube | (1, 1, 1) | 无放大 |

**5 个资产的 8 个节点全部 scale=(1,1,1)。**

### 2.2 运行时层（真实世界包围盒，`A2-runtime-bounds.json`）

| 源尺寸 | 运行时实测 bounds | 判定 |
|---|---|---|
| **1 m** | **1 × 1 × 1** | **PASS**（1:1） |
| **2 m** | **2 × 2 × 2** | **PASS**（1:1） |
| **4 m** | **4 × 4 × 4** | **PASS**（1:1） |
| 轴标 +X 臂 | 几何 2 × 0.2 × 0.2，节点位置 x = **−1** | **X 镜像确认** |
| 轴标 +Z 臂 | 几何 0.2 × 0.2 × 1，节点位置 z = +0.5 | Z 不镜像 |
| 轴标 +Y 臂 | 几何 0.2 × 0.6 × 0.2，节点位置 y = +0.3 | Y 不镜像 |
| 贴图 cube | 1 × 1 × 1 | PASS |

### 2.3 与 B 的结论对照

| | B 的路径（直接 `scene import` 裸 GLB） | A 的路径（resource model import 链路） |
|---|---|---|
| 1 m → | B 报告需 `sqrt(T)` 预缩放 | 实测 **1 m**，无需预缩放 |
| 4 m → | B 报告被放到 16 m（4×4） | 实测 **4 m** |
| 结论 | 局部适配经验 | 1:1 保留 |

→ **两条路径行为不同。** 不能把 B 的公式推广到 A/C 的路径，也不能反过来否定 B。
→ B/C 使用 Day-3 共享资产时，**必须沿用自己已验证的导入路径**，不要混用公式。

---

## 3. 坐标矩阵（X 轴镜像）

| 作者方向 | 作者坐标 | 导入后读回 | 结论 |
|---|---|---|---|
| +X（红长臂） | x = +1（几何中心） | **x = −1** | **X 取反** |
| +Z（蓝短臂） | z = +0.5 | z = +0.5 | 保持 |
| +Y（绿标记） | y = +0.3 | y = +0.3 | 保持 |

这与 Day-1 的 `P02-axis-readback.json`（+2→−2）独立复现一致。
**等级：REPRODUCED**（两次独立实验、不同资产、同一结论）。

> 未决（总设计师文档已列）：镜像来自导出设置、导入路径还是节点变换？
> 本矩阵只确认**现象稳定**，不指认机制。

---

## 4. 材质层

| 检查 | 结果 |
|---|---|
| 贴图 cube `_BaseColor` / `_BaseTex` | 已读回（Day-1 `P08-base-props`） |
| 本次运行时渲染 | 贴图 cube 在场景中可见，bounds 正确（未单独再看颜色，沿用 Day-1 结论） |
| NORMAL | 全部资产显式写入（本矩阵新增保证） |

**未决**：C 报告的"某路径运行时材质被覆盖"与 A 的读取结果不同 —— 
本矩阵**未复现**该现象，但也**未否定**；归为路径相关，标 TO-VERIFY。

---

## 5. 状态与证据

| 项 | 状态 |
|---|---|
| 尺寸 1:1（A 路径） | **PASS**（3 样本，源/数据/运行时三方对照） |
| 无二次放大（A 路径） | **PASS** |
| X 轴镜像 | **PASS / REPRODUCED** |
| Y/Z 不镜像 | **PASS** |
| 贴图保留 | **PASS** |
| B 的 sqrt(T) 是否普适 | **FAIL（不能推广）** —— 至少在 A 路径不成立 |
| 材质运行时覆盖（C 的现象） | **NOT TESTED**（本矩阵未覆盖该路径） |
| 直接 scene import 裸 GLB 的行为 | **NOT TESTED**（A 未走该路径；沿用 B 的局部结论，不自行复现） |

证据文件：
- `evidence/A2-prefab-scales.json`（数据层）
- `evidence/A2-runtime-bounds.json`（运行时层）
- `evidence/A2-scene-import.json`（导入回执）
- `shared-assets/ASSET-MANIFEST.csv`（SHA-256）

---

## 6. 给 B/C 的可用结论

1. **使用本目录的 5 个共享 GLB**，每个都带 SHA-256，大家测的是同一份字节。
2. **不要套用 B 的 `sqrt(T)` 到 A 的导入路径** —— 我已实测 1:1 保留。
3. **非对称资产朝向必须在导入后重新确认** —— X 稳定镜像，这是 REPRODUCED 结论。
4. **所有自制 GLB 必须带 NORMAL** —— 否则"有影子没表面"。
5. 若你走的是**直接 scene import 裸 GLB** 路径，请按你自己的实测处理尺寸，
   并把结果作为**路径局部经验**上报，不要写成全局公式。
