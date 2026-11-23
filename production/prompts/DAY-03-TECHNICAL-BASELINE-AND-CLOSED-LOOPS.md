# DAY 03｜公共技术基线与玩法闭环

本阶段不批量建模。目标是把影响三世界集成的技术未知变成可复现结论，同时让 B/C 各自的核心玩法形成真实运行闭环。

## 总目标
1. GLB 导入后的尺寸、坐标、材质如何变化？哪些规则可跨成员复现？
2. 原生几何体、GLB、WPRE 中的 Collider 是否真的阻挡玩家？数据字段存在不等于运行时生效。
3. A/B/C 能否按统一契约交付 Entry/Exit，并完成真实跨成员导入？
4. 两个可玩世界能否从玩家视角完成闭环，而非只证明场景可走或组件字段存在？

执行规则：
- 先检查 Git 状态、分支、远端和最新 Commit；保护未提交工作，禁止盲目 reset/clean/force push。
- 文档仓库与编辑器原生项目分开；原生场景/二进制只由 Owner 写入。
- 每个测试记录编辑器版本、项目环境、导入路径、源文件 SHA-256、步骤、运行时结果、截图/录屏。
- 状态只允许 PASS / FAIL / NOT TESTED / INCONCLUSIVE。
- 每次只改变一个变量；不可同时更换工程、GLB、碰撞形状和运行模式。
- 20–30 分钟无法解决的阻塞，记录复现和降级，继续独立任务。
- 需要 GUI 手动操作的测试由成员本人完成；Agent 不得假称操作。
- 本阶段不批量生产高成本 Tripo 资产。

## A｜公共技术基线与集成负责人（Claude 主控，GPT 独立 Red Team）

### A1. 最小可复现实验项目
创建可丢弃的 IntegrationProbe 项目/副本，不在 B/C 正式工程做破坏性实验。准备：
- GUI 手动创建的原生 Cube。
- 同一源文件导出的 1m / 2m / 4m GLB Cube。
- 带明显 +X 方向标记的非对称 GLB。
- 带 BaseColor/Normal 贴图的 GLB（可用时）。
- 最小 WPRE：原生几何体、Collider、Trigger、脚本绑定、一个 GLB 引用。
每个资产记录 SHA-256、bounds、导出工具/参数。

### A2. GLB 尺寸与坐标矩阵
分别测试团队当前 CLI 导入路径；若 GUI 存在独立导入路径，单独测试。
- 源尺寸：1m、2m、4m。
- 导入后：读回 position/rotation/scale。
- 运行时：与原生 Cube/标尺对照真实世界尺寸。
- 坐标：非对称标记检查 X/Y/Z 方向。
- 至少重复 3 个尺寸；记录每条导入路径。

**禁止直接把 B 的 actual=source×longestEdge 或 sqrt(T) 当成全局公式。** 只有 A/C 用同一测试资产复测后，才能发布为公共规则；否则标注为 B 当前路径的局部适配经验。

交付：reports/day-03/A/GLB-IMPORT-MATRIX.md。

### A3. Collider 诊断矩阵（P0）
分开检查数据层、渲染层、运行层。

| Case | 几何 | Collider | 测试 |
|---|---|---|---|
| P1 | GUI 手动原生 Cube | 原生默认 | 正面撞、从上方落下 |
| P2 | 脚本/CLI 原生 Primitive（若支持） | 原生默认 | 同 P1 |
| P3 | GLB | 导入后默认/自动 Collider | 正面撞、落下 |
| P4 | GLB | 手动添加 Collider（若支持） | 正面撞、落下 |
| P5 | WPRE | 随包 Collider | 导入后重新运行、撞击 |
| P6 | Terrain | 地形自身 | 边界、洞、坡面 |

必须做：
- A 亲自完成 P1 GUI 手动原生 Cube 测试并录屏。
- B 在同一工程、同一出生点、同一运行模式对照 P1/P3/P4。
- 记录玩家坐标、障碍位置、是否穿透、是否绕行。
- 关闭实例、重开后复测。
- 若可用，单独对比 Preview 与 Published。
- enableCollision=true 但运行时穿透必须判 FAIL。
- 墙“有阴影但看不到实体”是渲染问题，和碰撞问题分开诊断。

分支判断：
- P1 能挡、P3 不能挡：查 GLB 导入/Collider 生成。
- P1/P3 都不能挡：查工程模板、运行时、玩家碰撞层或预览状态。
- P1/P3 都能挡：复查 B 的原始复现条件，定位差异，不要直接否定 B。

交付：reports/day-03/A/COLLISION-MATRIX.md + 复现工程/截图/录屏。

### A4. WPRE 跨成员交接
A 将最小 WPRE 交给 B 或 C。接收方在自己的项目/账号环境导入（如共用账号必须明确写明，不得称为跨账号）。
检查层级、外部 URI、材质、Collider、Trigger、脚本绑定、参数和真实运行。
跨账号无法测试则 NOT TESTED，并提供裸 GLB + 贴图 + Manifest 兜底。

交付：reports/day-03/A/WPRE-HANDOFF-MATRIX.md。

### A5. World Interface Contract v0.2
更新 A 分支的接口契约：
- world_id / world_version / source_commit。
- anchor_id / role / world position。
- spawn_position / spawn_yaw / safe_zone_radius。
- trigger_size / return_target。
- 依赖资源和交付文件清单。
- 玩家碰撞体实测值及适用版本/角色配置。
- GLB 坐标、尺寸、材质和 Collider 规则，只写复测支持的结论。
- WPRE 外部 URI 风险与裸 GLB 兜底。
- Trigger 与脚本节点关系、Trigger 局部坐标等已实测限制。
所有字段标记 CONFIRMED / PROPOSED / TO-VERIFY。

### A6. 不等待技术探针的工作
继续列车 Hub、云海尽头白盒：
- Hub 入口/出口提示、出生点、靠墙相机。
- 终点实际可走路线、视线遮挡与最终视野释放。
- 暂不做最终美术，不改 B/C 世界。

A 交付：
reports/day-03/A/PLAN.md
GLB-IMPORT-MATRIX.md
COLLISION-MATRIX.md
WPRE-HANDOFF-MATRIX.md
WORLD-INTERFACE-CONTRACT.md v0.2
HUB-AND-TERMINUS-UPDATE.md
EVIDENCE.md / BLOCKERS.md / HANDOFF.md

## B｜书桌站《桌面以下》负责人（DSH 主控）

C4「竖直断裂 + 尺子坡道」是候选方案，不是总设计师批准的最终设计。其优点是绕开连续地形假裂口和高台软锁；其前提是障碍确实能阻挡、尺子坡道确实可走。

**GLB 碰撞未解决前，不得批量生成 C4 精细模型。**

### B1. 配合 A 做碰撞复现
在 B 当前工程完成：
- 手动 GUI 原生 Cube。
- 同尺寸 GLB Cube。
- GLB 手动添加 Collider（若可用）。
- 同一出生点、同一运行模式、同一移动方向。
- 记录玩家坐标和碰撞结果。

同时分别确认墙体可见性、Renderer/材质字段、Collider 字段。不要把“墙不可见”和“玩家穿透”合并成一个原因。

### B2. C4 玩法闭环
先用可确认可见且有实体碰撞的原生几何体验证，不依赖问题 GLB。
闭环：
1. 入口能看见被阻断的通道和铅笔盒小镇。
2. 玩家观察尺子的 resting pose 和支撑关系。
3. 玩家理解尺子可以改作坡道。
4. 玩家动作导致 REST → RAMP 状态变化（可用预设状态，具体实现自主决定）。
5. 玩家实际沿坡道通过。
6. 到达小镇获得环境反馈。
7. 可返回列车/出口，失败可恢复。

测试：不操作尺子是否确实无法通过；是否能从墙边绕行；坡道角度/宽度/碰撞；状态能否恢复；是否有合理替代解法。
**场景里预先摆两把不同姿态的尺子，不等于玩家完成了状态切换。**

### B3. 空间与镜头
比较低矮书页峡谷 + 远景巨书剪影，与立式巨书峡谷。以玩家视角检查目标可见性，不用俯视图代替。

### B4. Tripo 放行条件
本阶段只更新 Asset Card 和提示词，不批量建模。申请放行前必须明确：碰撞基线、玩法闭环、尺寸/朝向/原点、面数预算、材质路径、分件要求。

B 交付：
reports/day-03/B/PLAN.md
COLLISION-REPRO.md
C4-PLAYABLE-LOOP.md（失败则附替代方案）
PLAYER-VIEW-COMPARISON.md
UPDATED-ASSET-CARDS.md
EVIDENCE.md / BLOCKERS.md / HANDOFF.md

## C｜失重花园负责人（DSH 主控）

### C1. 不扩图
保留入口浮岛 → 根系通道 → 倒悬温室 → 花冠观景点。不要新增大量浮岛或第二套机关。

### C2. 配合 A 复测
使用同一组共享 GLB：X 轴方向、尺寸、贴图；原生 Cube 与 GLB Cube 碰撞对照；_BaseColor / _BaseTex 数据读回与真实渲染分别检查；根系、台阶、屋顶平台 Collider 运行测试。
记录导出设置和源文件 SHA，不把 C 的一次发现直接推广到所有 GLB。

### C3. 路线发现盲测
至少 2 名未参与设计的试玩者；暂时找不到则先做无提示自测并标明样本不足。
- 从入口出生，不给口头提示。
- 记录是否看见温室目标。
- 记录首次发现根系可走路径的时间。
- 记录误走、停顿、坠落、求助。
- 验证能否抵达温室屋顶和花冠观景点。
- 验证终点是否形成视野奖励。
制作成员自己知道路线，不算盲测。

### C4. 恢复与可读性
测试根系、台阶、屋顶边缘坠落后的恢复；入口/出口不能放在必须完成谜题才能到达的位置。先解决路线、碰撞、软锁，再精细化材质和装饰。

C 交付：
reports/day-03/C/PLAN.md
GLB-COMPATIBILITY-RETEST.md
BLIND-PLAYTEST.md
FALL-RECOVERY.md
ENTRY-EXIT.md
EVIDENCE.md / BLOCKERS.md / HANDOFF.md

## 公共交接与所有权

必须完成：
1. A → B/C：发布碰撞/GLB 测试矩阵初稿和接口 v0.2。
2. B/C → A：提供实际 Entry/Exit 字段和一个临时世界快照。
3. B ↔ C：互相做一次玩家视角/路线可读性 Review，不修改对方场景。

共享测试资产由 A 生成并发布：probe-cube-1m.glb、probe-cube-2m.glb、probe-axis-marker.glb、probe-textured-cube.glb、probe-minimal.wprefab。每个资产附 SHA-256、源文件和预期尺寸/朝向。B/C 必须使用同一份资产。

文件所有权：
- A：公共测试资产、技术规范、接口、Hub、云海尽头。
- B：书桌站场景与 reports/day-03/B。
- C：花园场景与 reports/day-03/C。
- 总设计师：World Bible、设计决策和 Gate。
同一原生场景/二进制文件只有一个主要写入者。

## Gate D3

技术：
- 尺寸至少 3 个样本，源/导入/运行时三方对照。
- 坐标至少 2 个非对称方向标记。
- 材质带贴图模型真实渲染可见。
- 碰撞至少原生 Cube、GLB Cube 有真实玩家行为证据。
- WPRE 至少一次真实跨成员导入；否则 NOT TESTED。
- B/C 各自提交 Entry/Exit 与安全落脚区。

玩法：
- B：尺子状态变化真实改变通路，玩家实际通过；否则提交经总设计审批的替代玩法。
- C：无口头提示发现核心路线，抵达观景点。
- A：Hub 与两个世界占位入口/出口至少完成一次往返连接。

APPROVE：技术风险有明确边界，两个玩法闭环可体验，接口可集成。
REVISE：方向正确但局部需修复。
REJECT：核心玩法被技术限制破坏且无合理降级，或世界职责重复。
BLOCKED：编辑器/账号/依赖无法验证，必须继续独立工作并提供替代路线。

**本阶段不要求精美美术。没有真实运行证据，不进入 Day 4 批量精细资产生产。**

## 研究与参考边界
项目第一手证据优先：
- A：reports/day-01/A/RESULTS.md、WORLD-INTERFACE-CONTRACT.md、BLOCKERS.md。
- B：reports/day-02/B/SPATIAL-FINDINGS.md、reports/day-03/B/C4-DESIGN-AND-BLOCKER.md。
- C：reports/day-01/C/PROBE-RESULTS.md、HANDOFF.md。
公开编辑器教程只有在确认产品/版本一致时才可当作官方规格；通用 Unity/Godot 碰撞流程只能作方法参考。

**现在开始：先提交 PLAN 和测试矩阵，再立即操作编辑器。不要只回复计划。**