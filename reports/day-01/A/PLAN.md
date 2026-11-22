# reports/day-01/A/PLAN.md

> Owner：成员 A（Train Core & Integration Lead）
> 分支：`feature/train-core`（基于 `origin/main`）
> 阶段：Day-01 Orientation / Research / Probes
> 状态：PLAN 已执行，执行结果见 `RESULTS.md`

---

## 1. 今日目标（按 ROLE-A 与 DAY-01 Prompt 拆解）

| # | 目标 | 验收物 | 依赖 |
|---|---|---|---|
| G1 | 仓库初始化、分支、远端可读性、push 权限探明 | 分支建立 + 权限结论 | 无 |
| G2 | 读完必读文档，区分 CONFIRMED / PROPOSED / TO-VERIFY | 认知摘要 | 无 |
| G3 | Probe 01：项目保存 / 关闭 / 重开 / 目录结构 / 恢复 | 截图 + 文件字节证据 | 编辑器实例 |
| G4 | Probe 02：GLB 最小导入 + 逐项属性保留 | 读回 JSON + 截图 | G3 |
| G5 | Probe 03：WPRE 交接 + 属性保留 + 依赖检查 | 解包结构 + 结论 | G4 |
| G6 | Probe 05：世界连接（传送 / 场景切换）最小验证 | 真实输入 + 坐标变化证据 | G4 |
| G7 | World Interface Contract v0.1 | 独立文档 | G4/G6 |
| G8 | 列车 Hub 方向草案 + 云海尽头主地标方案 | 参考分析 + 方案 | 无 |
| G9 | B/C 可直接转发的 HANDOFF | 文本 | G7 |
| G10 | 五份日报 + push | 本目录 | 全部 |

## 2. 明确不做（本轮边界）

- 不替 B 做书桌站，不替 C 做失重花园。
- 不把云海尽头扩展成大型城市 / NPC 模拟。
- 不在 Day-01 批量生成高成本 Tripo 资产（Gate D1 未通过前禁止）。
- 不伪造 PASS；未验证一律写 NOT TESTED。

## 3. 并行分工（动态 Agent 团队）

按 `tasks/002-a-train-core/AGENT-TEAM.md` 的"按需组建"原则，本轮实际启动：

| 角色 | 承担者 | 本轮任务 |
|---|---|---|
| 主控 / Producer | Claude（本 Agent） | 目标拆解、依赖管理、文档产出、Git |
| Reference Researcher | 独立 subagent（上下文隔离） | 列车 Hub + 云海尽头成熟参考分析 |
| Editor Operator | A 本人（经 `douyin-world` CLI 操作真实编辑器） | 全部技术探针 |
| QA / Red Team | 待独立上下文执行 | 找未验证假设与集成风险 |

**未启动的角色及原因：** 本轮不需要 Asset Analyst（Gate D1 前不产出定制资产）；
不需要 Audio Researcher（音频探针排在 GLB/WPRE 之后，本轮只做最小能力确认）。

## 4. 依赖与阻塞策略

- **硬依赖**：造世界编辑器实例（本机已装 1.0.104）。
- **外部依赖**：B/C 的 Entry/Exit 数据 —— 不等待，先用占位 Anchor 验证机制。
- **已知风险**：GitHub 直连不可达 → 已用国内镜像 `ghfast.top` 克隆。
- 阻塞处理遵循 `production/COORDINATION-PROTOCOL.md` §5：局部冻结 + 最小验证 + 降级方案 + 继续他项。

## 5. 完成定义

1. G1–G8 每项都有 PASS / FAIL / NOT TESTED 结论与证据路径。
2. 所有 PASS 都有可复现命令与真实截图 / 化数据，不接受"我觉得可以"。
3. 接口契约能让 B/C 在不看 A 工程的情况下填出 §2 字段。
4. 日报本身不出现未标注的断言。
