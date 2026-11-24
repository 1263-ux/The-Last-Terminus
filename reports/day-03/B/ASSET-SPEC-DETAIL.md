# B｜资产规格明细（数据层，运行前可判定部分）

分支：`feature/desk-world` · 编辑器 1.0.104
数据来源：直接解析 GLB 容器 JSON chunk（`tools/audit_glb.py` 同源方法）
性质：**这些结论不依赖运行时加载**，因此不受 B-07 阻塞影响

---

## 0. 为什么先做这个

B-07（运行时 `WorldRoot` 为空）冻结了所有"画面"类验收，
但**规格问题可以在数据层先判死**，避免运行恢复后再返工。

本节回答三个具体问题：
1. X 镜像是不是模型自带的？
2. 尺子的刻度贴图到底挂在哪个材质上？
3. 小镇的"暖窗"是不是已经有了？

---

## 1. X 镜像：**GLB 本身不含镜像**

逐个扫描 7 个 GLB 的所有节点，检查负缩放：

| 资产 | 节点数 | 负缩放节点 |
|---|---:|---|
| `ruler-bridge-full-v01` | 6 | **无** |
| `town-row-v02` | 44 | **无** |
| `shopfront-v02` | 6 | **无** |

**结论：** 如果导入后出现 X 镜像，**成因在导入器，不在模型**。

这很重要——`ASSET-IMPORT-MANIFEST.md` §1 提到「已知项目 GLB 导入存在 X 镜像风险」。
现在可以确认：**修复点应在导入侧（缩放取负或旋转 180°），不需要改模型。**

---

## 2. 尺子桥材质规格（P0 核心资产）

### 2.1 五个材质，只有一个是贴图

| # | 材质名 | 用途 | baseColorTexture | metallic | roughness |
|---|---|---|---:|---:|---:|
| 0 | `MAT_ruler_wood` | 尺身木头 | 无 | 0 | 0.75 |
| 1 | `MAT_ruler_mark` | 刻度线 | 无 | 0 | 0.80 |
| 2 | **`MAT_ruler_numerals`** | **数字 0–70** | **#0（PNG）** | 0 | 0.75 |
| 3 | `MAT_post_wood` | 两个支点 | 无 | 0 | 0.85 |
| 4 | `MAT_bracket_iron` | 两个支架 | 无 | **0.70** | 0.50 |

### 2.2 贴图

| 项 | 值 |
|---|---|
| 图片名 | `numeral_strip` |
| MIME | `image/png` |
| 字节数 | **4,069** |
| 位置 | **内嵌**（bufferView，无外部 URI） |

### 2.3 部件 → 材质映射（可直接照此验收）

| mesh | material |
|---|---|
| `SM_bridge_ruler` | 0 `MAT_ruler_wood` **+ 1 `MAT_ruler_mark`**（同 mesh 两个 primitive） |
| `SM_bridge_numerals` | **2 `MAT_ruler_numerals`** |
| `SM_bridge_post_l` / `_r` | 3 `MAT_post_wood` |
| `SM_bridge_bracket_l` / `_r` | 4 `MAT_bracket_iron` |

### 2.4 运行时验收判据（阻塞解除后即可用）

| 若看到 | 判定 |
|---|---|
| 尺身有木色 + 刻度线 + **数字清晰** | **PASS** |
| 尺身正常但**数字黑块/空白** | **FAIL** — PNG 未解码（`TASK-ACCEPTANCE` §B-04 强制项） |
| 尺身纯色无刻度线 | **FAIL** — 材质 1 未应用 |
| 支架发亮（非哑光） | 正常（metallic 0.70） |

> `ASSET-IMPORT-MANIFEST.md` §4.1 明确：「若黑贴图或丢贴图，标记 FAIL」。
> 现在有了精确的判据和对照物，不用靠印象判断。

---

## 3. 小镇材质规格（P0）

`town-row-v02`：**12 个材质，0 张贴图**（纯色材质，符合清单「无贴图」）。

```
MAT_stone, MAT_door_wood, MAT_brass, MAT_window_glow, MAT_clock_dark,
MAT_clock_white, MAT_roof_red, MAT_wall_teal, MAT_awning_red,
MAT_awning_white, MAT_sign_cream, MAT_row_ground
```

### 3.1 **`MAT_window_glow` 是自发光材质** ★

扫描 `emissiveFactor` 非零的材质：

| 资产 | 自发光材质 |
|---|---|
| `town-row-v02` | **`MAT_window_glow`** |
| `shopfront-v02` | **`MAT_window_glow`** |

**这解决了 `TASK-ACCEPTANCE` §B-05 第 6 条「至少一个反馈（暖窗）」的资产来源问题——资产里已经内建，不需要额外制作。**

### 3.2 命名规范可直接用于分区

`town-row-v02` 的 44 个部件按前缀分组，层次清晰：

| 组 | 部件示例 | 数量 |
|---|---|---:|
| 塔楼 | `SM_tower_shaft/door/window_1/clock_f/clock_b/roof/finial` | 8 |
| 单体店铺 | `SM_shopfront_box/awning/door/window/sign_board/roof_trim` | 6 |
| 楼 A | `SM_bldgA_box/awning/door/window_l/window_r/sign/trim` | 7 |
| 楼 B | `SM_bldgB_*`（含 `oculus`） | 7 |
| 楼 C | `SM_bldgC_*`（含 `windows_up`、`ledge`、`roof`） | 8 |
| 楼 D | `SM_bldgD_*`（含 `oculus`、`roof`） | 7 |
| 地面 | `SM_row_ground` | 1 |
| **合计** | | **44** |

**意义：** 若需要缩小范围（`TASK-ACCEPTANCE` §B-02 第 2 条「如果 town-row 体积过大，用 shopfront 作为小镇入口局部」），
可以按前缀精确拆分，不必整条街塞进去。

---

## 4. shopfront 材质规格（P1）

`shopfront-v02`：**7 个材质，0 张贴图**，含 `MAT_window_glow`（自发光）。

材质是 `town-row` 的子集（`wall_teal`、`awning_red/white`、`door_wood`、`brass`、`window_glow`、`sign_cream`），
**说明两者视觉语言统一**，可混用而不拼贴。

---

## 5. 坐标与朝向（数据层可判定部分）

| 项 | 结论 |
|---|---|
| 源工具 | Blender 4.5（GLB generator 显示 Khronos glTF Blender I/O） |
| 负缩放（镜像） | **全部无** |
| 场景根节点 | 每个 GLB 的 `scenes[0].nodes` 均直接列出全部 mesh 名（扁平结构） |
| 导入后父级 | 编辑器为每个 GLB 生成一个 wrapper 根（实测 `ruler-bridge-full-v01` 下挂 6 子） |

**朝向（Y-up vs Z-up）与 X 镜像的最终确认，仍需运行时复测** —— 数据层只能证明模型自身无镜像。

---

## 6. 对阻塞解除后的验收清单（已备好）

| # | 检查项 | 判据 | 现在可否判定 |
|---|---|---|---|
| 1 | 尺子数字是否显示 | 见 §2.4 | ⛔ 需运行时 |
| 2 | 支架是否金属感 | metallic 0.70 | ⛔ 需运行时 |
| 3 | 小镇暖窗是否发光 | `MAT_window_glow` emissive | ⛔ 需运行时 |
| 4 | 尺寸是否符合清单 | `scale = 1/T`（见 BLOCKERS B-08） | ⛔ 需运行时测 bounds |
| 5 | X 镜像 | 模型无镜像 → 若出现则导入器问题 | ⛔ 需运行时 |
| 6 | 材质是否错配 | §2.3 / §3.2 的映射表 | ⛔ 需运行时 |

**这份清单保证：阻塞一解除，我可以逐条对照验收，不需要重新摸规格。**
