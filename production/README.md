# Production System｜生产体系入口

本目录定义团队角色、Agent 执行方式、资产交接、集成规则和 Review 流程。它是制作管理规范，不替代 `docs/` 下的世界观与游戏设计。

## 阅读顺序

1. `TEAM-ROLES.md`：谁负责什么、谁有决策权。
2. `EXECUTION-PROTOCOL.md`：Claude/GPT/DSH 如何接收任务、操作编辑器、汇报和停止。
3. `INTEGRATION-CONTRACT.md`：Git、GLB、WPRE、场景交接和集成边界。
4. `TASK-PACKAGE-TEMPLATE.md`：每个具体任务如何写成可执行任务包。
5. `DAILY-REVIEW-TEMPLATE.md`：每日提交什么证据、如何验收。
6. `PRODUCTION-OPERATING-SYSTEM.md`：七天生产节奏、Agent 团队、阶段 Gate 和交付闭环。

## 成员启动

首次接手任务，请先阅读 [START-HERE-FOR-MEMBERS.md](START-HERE-FOR-MEMBERS.md)，按角色创建独立分支并使用其中的启动指令。当前任务包状态为 DESIGN BRIEF，先完成研究、技术探针和白盒，不直接批量生产高成本资产。

## 当前团队事实

- 总设计师：负责设计与控制，不操作新版造世界编辑器。
- 成员 A：拥有 Claude、GPT 和新版造世界 AI 编辑器，负责公共列车与集成。
- 成员 B：使用 DSH 和新版造世界 AI 编辑器，负责书桌站。
- 成员 C：使用 DSH 和新版造世界 AI 编辑器，负责失重花园。
- 团队已确认新版造世界 AI 编辑器支持导入 GLB 与 WPRE；项目按本地工作流使用 Git 协作。场景文件是否可安全文本合并、完整工程迁移是否无损，仍按集成验证结果处理。

## 当前阶段

当前已建立 A-01、B 书桌站、C 失重花园任务包。具体执行以各任务包和 Production Operating System 为准；任务包定义体验目标与验收，Agent 自主探索实现。
