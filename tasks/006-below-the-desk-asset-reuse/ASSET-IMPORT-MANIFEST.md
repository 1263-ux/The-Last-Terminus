# BelowTheDesk｜目标编辑器导入清单

> 资产来源：用户上传的 BelowTheDesk 精简档案（2026-11-20）。  
> 原始生产工具：Blender 4.5.16 LTS，程序化建模为主。  
> **Blender ACCEPTED 不代表新版造世界编辑器已通过导入。**

## 1. 坐标与尺寸口径

源 Blender 工程使用 Z-up；表中“目标 Y-up 预期尺寸”按 Y/Z 轴交换后的展示顺序列出，方便估算目标编辑器中的体积。它不是目标编辑器实际导入尺寸的保证。

- 目标编辑器实际尺寸、朝向、原点和 X 镜像必须由 B 在运行时复测。
- 已知项目 GLB 导入存在 X 镜像风险；不得直接从 Three.js/Blender 源坐标推算世界坐标。
- 任何缩放都要记录源尺寸、目标尺寸和比例。

## 2. 精选资产

| 文件 | Blender 审核状态 | 目标 Y-up 预期尺寸（m） | 几何规模 | 贴图 | 本项目用途 |
|---|---|---:|---:|---|---|
| ruler-bridge-full-v01.glb | 独立评审 ACCEPTED | 8.0 × 1.245 × 0.99 | 6 meshes / 2,824 faces | 1 张嵌入 PNG | **P0 核心尺子桥** |
| town-row-v02.glb | 独立评审 ACCEPTED | 24.13 × 5.84 × 3.592 | 44 meshes / 29,656 faces | 无 | **P0 铅笔盒小镇街区** |
| shopfront-v02.glb | 独立评审 ACCEPTED | 4.0 × 2.75 × 3.106 | 6 meshes / 4,500 faces | 无 | P1 单体建筑，供缩小/替换使用 |
| desk-lamp-v01.glb | Case 3 组合资产；未找到单体独立评审 | 2.69 × 2.818 × 1.5 | 4 meshes / 2,904 faces | 无 | P1 台灯地标候选 |
| ground-paper-v01.glb | Case 3 组合资产；未找到单体独立评审 | 12 × 0.06 × 8 | 1 mesh / 44 faces | 无 | P2 桌面底板参考，不保证玩家碰撞 |
| cup-harbor-v03.glb | 独立评审 ACCEPTED | 6.959 × 4.41 × 4.812 | 7 meshes / 8,710 faces | 1 张 1024×1024 PNG | P2 杯岸港口远景 |
| case3-assembly-reference-v02.glb | 组合参考；未找到独立评审文件 | 12 × 2.878 × 8 | 22 meshes / 13,804 faces | 无 | **仅构图/导入参考**，不是最终书桌站 |

注：town-row 的 GLB 面数与独立评审的三角面数使用不同统计口径；以原始 report/review 为准，不把两种计数混为同一指标。

## 3. SHA-256 校验

| 文件 | SHA-256 |
|---|---|
| ruler-bridge-full-v01.glb | 183a2133c784677dbb73d8951f8191f54db120a3c39cddc6a900230276ac8a4c |
| town-row-v02.glb | f4359aed765e9062a36cac389fb6678c9c3ec3436f18524426a0b422122f87c9 |
| shopfront-v02.glb | 58e007b4481d9c6d30779685c4875811116d6a2179cd55df8ed2fcc333ab98b7 |
| desk-lamp-v01.glb | 1310be56b57812e52f0fd37fe3a643e675c5c8ee2efadb5bd35795425f0ee07e |
| ground-paper-v01.glb | cd9c566c57bce394fa283d69396d7940733a76a65004d5cbe8748dcbd22ef33c |
| cup-harbor-v03.glb | 8dafed0fcca627e3612634c53c5b10bb5792d368d6321b0a70b7c3bbe01b939a |
| case3-assembly-reference-v02.glb | 5b37c251845cefee74435a2cdc6b053f242a60d3aae32e4bd3d6d07ff9998885 |

## 4. 已知条件与必须复验项

### 4.1 尺子桥
- 原档案存在独立 review.md，结论 ACCEPTED；6/6 parts 的轮廓、比例、刻度和支架通过。
- 非阻塞问题：木材表面偏平、无明显木纹；数字 0 带斜线。
- **强制集成条件：** 嵌入 PNG 在原评审中只验证了提取和 PNG 有效性，未完成 live browser/runtime decode。目标编辑器里必须确认刻度/数字纹理真实显示；若黑贴图或丢贴图，标记 FAIL。

### 4.2 铅笔盒小镇
- Town row v02 独立评审：44 parts、29,650 triangulated tris、0 blocking issues。
- 非阻塞问题：屋顶是连续瓦楞/瓦条纹，不是逐片重叠瓦；正视略平；D 建筑屋顶较平；背面较简化。
- 资产长约 24.13m，先按原尺寸导入测量，再决定是否缩放。不要未经记录地把 24m 资产塞进 4m 白盒范围。

### 4.3 杯岸港口
- v03 独立评审通过，glyph 修订完成。
- 包含 1 张嵌入 1024×1024 PNG；目标运行时解码仍需验证。
- 本轮不是 P0，不要让它阻塞尺子桥主闭环。

### 4.4 台灯、底板与组合参考
- desk-lamp 和 ground-paper 在 Case 3 组合报告中出现，但没有找到它们各自的独立 review 文件；按候选资产处理，先导入再决定是否采用。
- case3-assembly-reference-v02 作为组合参考使用；没有找到单独的独立 review 文件，不得称为已通过最终场景验收。

### 4.5 资产包缺项
该精简档案不包含主角最终 GLB/动画、完整造世界编辑器原生项目、可直接运行的 WPRE 世界或音乐文件最终授权交付包。因此不能把该包描述为“完整游戏已做好”。

## 5. 目标编辑器导入矩阵（由 B 填写）

| 文件 | SHA 核验 | 导入成功 | 层级/部件 | 尺寸/朝向 | 材质/贴图 | 玩家视角 | 保存重开 | 状态 |
|---|---|---|---|---|---|---|---|---|
| ruler-bridge-full-v01.glb | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED |
| town-row-v02.glb | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED |
| shopfront-v02.glb | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED |
| desk-lamp-v01.glb | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED |
| ground-paper-v01.glb | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED |
| cup-harbor-v03.glb | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED |
| case3-assembly-reference-v02.glb | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED | NOT TESTED |

接收方 B 在目标编辑器真实导入后更新本表，并附截图、录屏和 Commit SHA。
