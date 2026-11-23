# PROMPT B｜《桌面以下》资产复用与玩家闭环负责人

你是《天空列车的最后一站》的 B：Desk World Lead。你有 DSH、新版造世界 AI 编辑器和 Blender。**本轮不要从零重建书桌资产**：总设计师提供的 BelowTheDesk 资产包已有独立评审通过的尺子桥、小镇、店铺、台灯和港口。

## 0. 必读
1. AGENTS.md
2. production/DESIGN-DIRECTOR-DECISIONS-2026-11-22.md
3. production/EDITOR-TECHNICAL-FINDINGS.md
4. tasks/003-b-desk-world/ 全部文件
5. tasks/005-day03-closeout-day04-entry/COMMON-ACCEPTANCE.md
6. tasks/006-below-the-desk-asset-reuse/README.md
7. tasks/006-below-the-desk-asset-reuse/ASSET-IMPORT-MANIFEST.md
8. tasks/006-below-the-desk-asset-reuse/TASK-ACCEPTANCE.md
9. 本文件

先向我复述：当前 B 哪些问题已经解决、核心闭环还差什么、资产包有哪些可直接复用的资产、哪些贴图风险仍未验证。

## 1. 收到资产包并校验

获取总设计师单独交付的：
`BelowTheDesk-造世界编辑器资产交接包-v1.0.zip`

如果 ZIP 不在工作区：
- 停止资产建模；
- 报告 `BLOCKED: ASSET_KIT_NOT_PRESENT`；
- 请求总设计师重新交付；
- 不要自行从网络下载同名模型或重新生成替代品。

解压到临时目录，按 `ASSET-IMPORT-MANIFEST.md` 核对 SHA-256。不要修改原始 GLB。先复制到工程资产目录。

## 2. 导入顺序与验证

### 先无纹理，后带纹理

1. `town-row-v02.glb`：无纹理，44 meshes，24.13×5.84×3.592m。验证多部件导入、层级、材质槽、尺寸和性能。
2. `shopfront-v02.glb`：无纹理，作为单体模块；若 24m town row 太大，可用它先搭小镇入口。
3. `desk-lamp-v01.glb`：无纹理，作为台灯视觉锚点；灯光另在编辑器配置。
4. `ruler-bridge-full-v01.glb`：核心资产，8m 长，6 meshes，带嵌入 PNG 数字/刻度。必须在玩家视角确认数字/刻度真实解码。
5. `cup-harbor-v03.glb`：可选远景，带嵌入 PNG；本轮不是 P0。
6. `case3-assembly-reference-v02.glb`：仅用于看组合关系和导入行为，不直接替换最终书桌世界。

每个资产记录：
- 文件 SHA、编辑器版本、导入步骤；
- 导入后节点层级/mesh 数；
- 尺寸、原点、朝向、X 镜像；
- 材质/贴图/透明/发光表现；
- 玩家第三人称视角截图；
- 保存、关闭、重开结果；
- 若失败，给出最小复现和降级。

## 3. 视觉与空间适配

保留当前设计基线：
- 书谷是微缩尺度和探索入口；
- 尺子桥是核心玩法物件；
- 铅笔盒小镇是主目标；
- 台灯提供暖光识别；
- 杯岸港口只做远景，不扩成新关卡。

先把已验收资产摆进当前白盒，不要先做大规模精修。
town-row 尺寸约 24m，先原尺寸导入测量，再决定是否缩放或拆分。任何缩放必须记录原始尺寸与最终比例。
当前 B 相机可见角度公式仅适用于当前相机参数；若改出生点/FOV/相机，重新测量。

## 4. 核心玩法闭环

目标：
玩家出生 → 看见 REST 尺子与对岸小镇 → 理解可改造 → 主动交互 → REST 隐藏/完整桥体出现 → 玩家实际走过桥 → 到达小镇 → 反馈。

关键说明：
- 不再强制要求 RAMP 恰好是 6 个独立节点。新资产 `ruler-bridge-full-v01.glb` 是一个 GLB，内部 6 个 mesh；导入后可能是一个 root 或拆成多个节点。**以完整桥体所有 mesh 正确显示为验收对象。**
- 如果是一个 root，切换 root；如果是多个 root，建立父节点或逐一切换。
- 不能只显示桥体的一部分。
- 玩家必须主动触发，不能出生自动解锁。
- 当前玩家是运动学控制，普通 Collider 不可靠阻挡。使用 Trigger/Lua 规则门禁，不做假实体墙。
- 玩家必须连续走过桥/坡道到达小镇，不能用 Teleport 截图代替。
- 到达至少有一个反馈：暖窗点亮、入口灯、音效（实际可听）或场景状态变化。

## 5. 任务优先级

P0：
1. 核心资产导入（town-row / ruler bridge）。
2. 玩家视角可见性。
3. REST → 完整桥体主动状态切换。
4. 连续玩家通行到小镇。
5. 失败恢复、保存重开。

P1：
- 台灯灯光和小镇暖窗；
- 单体 shopfront 作为 town-row 缩小替代；
- 一条短支路。

P2：
- 杯岸港口远景；
- 非关键装饰、居民、收藏系统。

## 6. 报告与提交

更新：
- `reports/day-03/B/REVISION.md`
- `reports/day-03/B/ASSET-IMPORT-REPORT.md`
- `reports/day-03/B/C4-PLAYABLE-LOOP.md`
- `reports/day-03/B/EVIDENCE.md`
- `reports/day-03/B/BLOCKERS.md`

必须提交：
- 资产导入矩阵；
- 完整闭环一镜到底录屏（45–90秒）；
- 远/中/近景截图；
- 失败恢复证据；
- Commit SHA。

Gate 只在总设计师 Review 后决定。逻辑 PASS、Blender ACCEPTED 或模型好看都不等于 B-Gate PASS。
