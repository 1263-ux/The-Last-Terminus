# DAY 01｜B｜书桌站《桌面以下》计划

Owner：成员 B（Desk World Lead）
分支：`feature/desk-world`（自 `origin/main` @ `d6361a3` 创建）
阶段：Day 1 — 方向理解、参考研究、资产审计、空间/玩法方案、技术探针
状态：**REVISE 候选**（玩法方案待总设计批准；见 §5 未决事项）

---

## 1. 本轮目标（Definition of Done）

Day 1 不追求美术，只追求**把错误假设挖出来**。本轮的四件事：

| # | 目标 | 通过判据 |
|---|---|---|
| 1 | 资产审计 | 每个现有 GLB/WPRE 有来源、版本、比例、材质、层级、碰撞、可用性结论；未实测字段标 `NOT TESTED` |
| 2 | 参考研究 | 4 款参考各有「具体场景 → 解决的问题 → 迁移方法 → 不能照搬」四段，不是简介 |
| 3 | 空间/玩法方案 | 1–2 个**明显不同**的布局；各自回答入口、第一眼目标、尺度参照、谜题四要素、小镇可达性、支路价值、远景暗示 |
| 4 | 真实编辑器证据 | 真实截图 + 可重开场景 + Commit，而不是文字声称 |

**本轮明确不做：** 批量 Tripo 生成、精细材质、第二张子地图（杯岸港口只做远景）、完整基地系统。

---

## 2. 当前最小 Agent 团队

按 `AGENT-TEAM.md` 的按需原则组建，**不机械启动全部角色**。Day 1 实际启动 3 个，其余在 Day 2–3 视需要拉起。

| 角色 | 本阶段 Owner | 输入 | 产物 | 验收方式 |
|---|---|---|---|---|
| Producer / Orchestrator | 主控（DSH） | 任务包、Day-01 Prompt、production 协议 | 本 PLAN、依赖表、证据台账 | Gate D1 逐项对照 |
| Reference Researcher | 子 Agent（独立上下文） | `tasks/003-b-desk-world/REFERENCES.md`、`VISUAL-REFERENCE-BOARD.md` | `REFERENCE-STUDY.md`（427 行、18 条来源） | 每条来源可点开；结论可迁移到 6 个模块 |
| Asset Auditor | 主控 + `tools/audit_glb.py`、`tools/glb_preview.py` | 本机 asset-cache、工程目录 | `ASSET-AUDIT.md` + 渲染预览图 | 每个字段可复现；未测项标 `NOT TESTED` |
| Level / Puzzle Designer | 主控 | 世界文档 §3/§4/§5、参考研究结论 | `DESIGN-PROPOSAL.md`（方案 A/B、Asset Card） | 总设计批准或驳回 |
| Art / Asset Analyst | 主控（合并进 Level Designer，Day 1 人力不足） | 视觉参考板 | Asset Card 的材质/分件/提示词段 | 总设计确认后可投 Tripo |
| Editor Operator | **成员 B 本人** | — | 真实场景、截图、录屏 | 见 `EVIDENCE.md` |
| QA / Red Team | **Day 2 启动**（Day 1 无白盒可测） | — | 缺陷清单 | Gate D2 |

> **诚实声明：** Agent 没有、也不能代替成员 B 操作造世界编辑器。本报告中的场景导入、环境参数、截图全部由主控通过 `douyin-world` CLI 在成员 B 的本机实例上实际执行并留有回执；凡未实测的能力一律标 `TO-VERIFY` 或 `NOT TESTED`。

---

## 3. 工作分解与依赖

```
[读取基线] ──┐
             ├─→ [资产审计] ──→ (阻塞：无书桌站资产) ──→ 提 Asset Card，等总设计生成
[参考研究] ──┘                                                      │
             └─→ [空间/玩法方案 A/B] ──→ Gate D1 评审 ──→ [Day 2 白盒]
                          │                                          ↑
                          └─→ [技术探针：尺度/环境/导入] ─────────────┘
```

**可并行：** 参考研究、资产审计、方案撰写、技术探针（互不写同一文件）。
**必须串行：** 方案批准 → 关键 Tripo 生成 → 导入验收；白盒通过 → 精细美术。
**不等待：** 不等 A 的列车完成，不等 C 的资产完成（见 `HANDOFF.md`）。

---

## 4. 本轮已执行的编辑器探针

| 探针 | 目的 | 结果 | 证据 |
|---|---|---|---|
| P-01 实例发现 | 确认编辑器可用 | ✅ 实例 `e96ad682…`，编辑器 1.0.104 | `EVIDENCE.md` §1 |
| P-02 GLB 入库 | 确认 GLB 可进入资产库 | ✅ 9 个自建 GLB 全部 `successCount=9/9` | `EVIDENCE.md` §2 |
| P-03 场景实例化 | 确认资产可进入主场景 | ✅ 10 个对象 `status=committed` | `EVIDENCE.md` §3 |
| P-04 场景保存/重开 | 确认工程可恢复 | ✅ `hasUnsavedChanges=false`，重开后节点仍在 | `EVIDENCE.md` §4 |
| P-05 环境参数 | 确认「台灯暖光 + 窗外冷蓝」可做 | ✅ 44 个字段全部可写，含夜晚/星空 skybox | `EVIDENCE.md` §5 |
| P-06 节点定向截图 | 确认可出远/中/近景 | ✅ `--object/--yaw/--pitch/--distance` 可用 | `EVIDENCE.md` §6 |
| P-07 缩放/锚点吸附 | 尺子桥玩法核心 | ⛔ **未验证**（CLI 无变换/锚点 API） | `BLOCKERS.md` B-03 |

---

## 5. 需要总设计裁定的未决事项

1. **铅笔盒小镇是入口还是终点？** `docs/worlds/01-DESK-WORLD.md` §3 写"站点入口"，`TASK.md` 写"可达目标"，§5 里它又是桥的反馈方。我在 `DESIGN-PROPOSAL.md` 提议**把小镇一分为二（近岸/对岸，同一件铅笔盒被裂口分开）**，让三种说法同时成立。需确认。
2. **布料坡面在世界文档中不存在。** 任务包列为主模块，`01-DESK-WORLD.md` §3 没有它。我按 `[PROPOSED]` 处理，请补入或裁掉。
3. **列车与书桌的尺度关系**（世界文档 §7 明确"不要擅自决定"）：列车是被缩放到书桌世界，还是站台被放大？Day 1 未触碰，见 `HANDOFF.md` 给 A 的接口草案。
4. **本轮尺度基准**：我以"物件变巨"而非"玩家变小"实现微缩（编辑器默认角色约 1.7 m，实测 `jumpMaxHeight=1.0`）。这是一个方向选择，需确认。

---

## 6. 下一阶段入口条件（Gate D1 → Day 2）

| 条件 | 当前 |
|---|---|
| 能复述项目核心与 B 的边界 | ✅ |
| 书桌站与失重花园玩法差异明确 | ✅（书桌=物件用途重构；花园=空间方向发现） |
| 关键工具未知与资产依赖已暴露 | ✅（见 `BLOCKERS.md`） |
| 有可执行的白盒方向 | ✅（方案 A/B，见 `DESIGN-PROPOSAL.md`） |
| 真实编辑器证据 | ✅ 部分（尺度白盒已进场景；缺运行录屏） |

**已知缺口（不隐瞒）：** 无玩家视角**录屏**。运行实例在 Day 1 后半段反复卡在 `status=loading`（见 `BLOCKERS.md` B-01），只有静态截图与节点定向截图。Day 2 首要任务补录屏。
