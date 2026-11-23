# reports/day-03/A/HANDOFF.md

> A → B/C，可直接转发。本轮（Day-3）新增内容。
> Day-1 的 HANDOFF 仍有效；本文件只补充新结论与请求。

---

## 1. 共享测试资产已发布（请 B/C 使用同一份）

位置：本仓库 `reports/day-03/A/shared-assets/`

| 资产 | 用途 | SHA-256（前16） |
|---|---|---|
| `probe-cube-1m.glb` | 尺寸矩阵 1 m 样本 | `fb0021dcc17077f5` |
| `probe-cube-2m.glb` | 尺寸矩阵 2 m 样本 | `6cf8c379f819b8b8` |
| `probe-cube-4m.glb` | 尺寸矩阵 4 m 样本 | `6e4024a19f122c3b` |
| `probe-axis-marker.glb` | X/Y/Z 方向标记（红=+X 长臂、蓝=+Z、绿=+Y） | `ac6202d573aac7dd` |
| `probe-textured-cube.glb` | 贴图/材质样本（内嵌棋盘 PNG） | `6896c47f6241b001` |
| `ASSET-MANIFEST.csv` | 以上全部的完整 SHA-256 / 预期尺寸 | — |

全部带 NORMAL（解决 C-11"有影子没表面"）。

## 2. 我已复现的结论（对 B/C 有直接价值）

### 2.1 尺寸：两条路径行为不同 —— 请勿混用公式

| 导入路径 | 实测 |
|---|---|
| **A 的链路**：`resource model import → archive → prefab attach → build → scene import` | **1:1 保留**，1/2/4 m 三样本 scale 全 1，运行时包围盒就是 1/2/4 m |
| **B 的路径**：直接 `scene import` 裸 GLB | B 观察 `actual = source × longestEdge`，`sqrt(T)` 预缩放 |

**总设计师已决定不发布全局换算公式**（`EDITOR-TECHNICAL-FINDINGS.md`）。
→ 请用你自己路径的经验；不要拿 B 的 `sqrt(T)` 去改 A 链路的资产，反之亦然。
→ 证据：`GLB-IMPORT-MATRIX.md`。

### 2.2 X 轴镜像：REPRODUCED

共享轴标实测：作者 +X 长臂（x=+1）→ 导入后 x=−1；Y/Z 不变。
与 Day-1 独立复现一致。**非对称资产导入后必须重新目视确认朝向。**

### 2.3 Collider：数据字段 ≠ 运行时

| 组件 | 空节点上运行时结果 |
|---|---|
| `triggerData` box | 生成 `BoxCollider isTrigger=true` |
| `physicsColliderData.enableCollision=true` | **不生成任何 Collider** |

**请 B/C 不要只看字段，要用 `GetComponent(BoxCollider/MeshCollider)` 实测。**
我仍未验证"GLB Mesh + 实体 collider"是否生成（P4 未完成），所以**不能否定 B 的 GLB 墙穿透报告**。
证据：`COLLISION-MATRIX.md`。

### 2.4 接口契约 v0.2 已发布

`WORLD-INTERFACE-CONTRACT.md` v0.2，全部字段带 CONFIRMED/PROPOSED/TO-VERIFY。
包含玩家胶囊实测、[0,255] 坐标约束与四分区建议、GLB/Collider/WPRE 规则。

## 3. 我仍需要 B/C 提供

| # | 请求 | 用途 |
|---|---|---|
| 1 | 你自己的账号/机器导入我最小 WPRE 的回执（层级/URI/材质/脚本/运行时） | A4 跨成员交接（当前 NOT TESTED） |
| 2 | `spawn_yaw` 的**具体度数**（不是文字方向） | 填 Entry/Exit Anchor，做集成串联 |
| 3 | C：入口锚点 (-14,0.4,2.5) 是局部还是世界坐标？白盒根节点世界位置 | 换算世界坐标 |
| 4 | B：尺子状态切换用 WPrefab 变体还是 Lua 改节点？若前者给两个 URI | 集成时替换 |

## 4. 集成分区建议（采纳 C 的 [0,255] 约束）

| 世界 | 中心 | 备注 |
|---|---|---|
| 列车 Hub | (40,60,40) | — |
| 书桌站 | (120,60,40) | B |
| 失重花园 | (120,60,120) | C 的现有白盒位置，不移动 |
| 云海尽头 | (40,60,120) | — |

B/C 各自的场景不必搬迁；由我在集成副本对齐。

## 5. 说明

- 我没有团队群/协作工具，以上**未实际发送给任何人**；本文件是可直接转发的草稿。
- Day-1 的 HANDOFF（`reports/day-01/A/HANDOFF.md`）仍有效，本文件只补充 Day-3 新结论。
