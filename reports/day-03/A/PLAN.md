# reports/day-03/A/PLAN.md

> Owner：成员 A（Train Core & Integration Lead）
> 分支：`feature/train-core`（PR #12）
> 阶段：Day-3 公共技术基线与玩法闭环
> 依据：`production/prompts/DAY-03-TECHNICAL-BASELINE-AND-CLOSED-LOOPS.md`、
> `production/EDITOR-TECHNICAL-FINDINGS.md`（总设计师发布）

---

## 1. 本阶段目标（按 DAY-03 A 段逐条）

| 项 | 目标 | 交付物 |
|---|---|---|
| A1 | 可丢弃的 IntegrationProbe 项目 + 5 类共享测试资产（含 SHA-256 / bounds / 导出参数） | 资产 + `ASSET-MANIFEST.csv` |
| A2 | GLB 尺寸与坐标矩阵（1/2/4 m 三样本 + 非对称方向标记 + 贴图） | `GLB-IMPORT-MATRIX.md` |
| A3 | Collider 诊断矩阵 P1–P6（数据层/渲染层/运行层分离） | `COLLISION-MATRIX.md` |
| A4 | WPRE 跨成员交接（能测则测，不能则 NOT TESTED + 兜底） | `WPRE-HANDOFF-MATRIX.md` |
| A5 | World Interface Contract v0.2（字段标 CONFIRMED/PROPOSED/TO-VERIFY） | `WORLD-INTERFACE-CONTRACT.md` |
| A6 | 不等待探针：列车 Hub / 云海尽头白盒继续推进 | `HUB-AND-TERMINUS-UPDATE.md` |

公共交接：
- A → B/C：发布碰撞/GLB 测试矩阵初稿 + 接口 v0.2；
- 提供 B/C 必须使用的**同一份**共享 GLB（Day-3 提示 §188）。

## 2. 我进入本阶段时已有的证据（复用，不重复劳动）

来自 `reports/day-01/A/`：

| 已有结论 | 可用于 |
|---|---|
| 玩家胶囊实测 r=0.16 / h=0.90 / 中心 0.45（`P07`） | A5 契约 v0.2 的碰撞体字段 |
| GLB X 轴镜像（+2→−2，Z 不变，`P02-axis-readback`） | A2 坐标矩阵的一条初始证据 |
| 材质属性为 `_BaseColor` / `_BaseTex`（`P08-base-props`） | A2 材质矩阵 |
| A 的导入链路 `resource model import → archive → prefab → scene import` **不**二次放大（`P18-01`：12×0.3×7 实测仍 12×0.3×7，scale=1） | **关键**：证明 B 的 `sqrt(T)` 是路径局部经验，不能升为全局公式 |
| WPRE 同机同账号跨工程导入成功（`P06`） | A4 基线；跨账号仍 NOT TESTED |
| Trigger + Lua Teleport 端到端跑通（`P05`） | A6 Hub 入口/出口连接 |
| 相机有碰撞避让（`CAMERA-REPORT.md` A/B） | A6 靠墙相机结论 |
| 云海尽头 v2 拱廊 + 分层云验证（`TERMINUS-WHITEBOX.md`） | A6 白盒更新 |

总设计师的 `EDITOR-TECHNICAL-FINDINGS.md` 把这些结论按证据等级收录，并要求
**"不发布未经复现的全局换算公式"** —— 我的 A2 矩阵正是为此补齐 3 样本 + 跨路径复测。

## 3. 关键边界（来自 DAY-03 与总设计师文档）

1. **每次只改变一个变量**（不同时换工程/GLB/碰撞形状/运行模式）。
2. 状态只允许 PASS / FAIL / NOT TESTED / INCONCLUSIVE。
3. 每个测试记录：编辑器版本、项目、导入路径、源文件 SHA-256、步骤、运行时结果、截图/录屏。
4. **P1（GUI 手动原生 Cube）必须由 A 本人操作并录屏** —— Agent 不得假称。
   → 我需要如实评估自己能否通过 CLI 等价完成；若不能，标 NOT TESTED 并请求用户本人操作。
5. 20–30 分钟无法解决的阻塞：记录复现 + 降级，继续独立任务。
6. 本阶段不批量生成 Tripo 资产，不改 B/C 世界。

## 4. 并行/串行安排

- **串行依赖**：A1 资产 → A2 矩阵 → A5 契约（数值依赖复测结果）。
- **可并行**：A3 碰撞矩阵（与 A2 不同变量）、A6 白盒（完全独立）。
- **外部依赖**：A4 跨成员导入需 B/C 配合 —— 不等待，先准备交接包并发布，接收结果到达后补测。

## 5. 完成定义

1. A1 五个共享资产存在，SHA-256 / bounds / 导出参数齐全，B/C 可直接使用。
2. A2 至少 3 个尺寸样本 + 2 个非对称方向标记，源/导入/运行时三方对照，明确"哪些规则跨路径成立"。
3. A3 P1–P6 每个 case 有数据层/渲染层/运行层三层结论，`enableCollision=true` 但穿透判 FAIL。
4. A4 WPRE 交接矩阵完成或明确 NOT TESTED + 兜底清单。
5. A5 契约 v0.2 所有字段带 CONFIRMED/PROPOSED/TO-VERIFY 标记。
6. A6 Hub/终点白盒有可复现更新，不依赖技术探针结果。
7. 所有产物提交到 `feature/train-core` 并同步到 PR #12。
