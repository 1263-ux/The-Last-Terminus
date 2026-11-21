# Production System｜生产体系入口

本目录定义团队角色、Agent 执行方式、资产交接、集成规则和 Review 流程。它是制作管理规范，不替代 `docs/` 下的世界观与游戏设计。

## 阅读顺序

1. `TEAM-ROLES.md`：谁负责什么、谁有决策权。
2. `EXECUTION-PROTOCOL.md`：Claude/GPT/DSH 如何接收任务、操作编辑器、汇报和停止。
3. `INTEGRATION-CONTRACT.md`：Git、GLB、WPRE、场景交接和集成边界。
4. `TASK-PACKAGE-TEMPLATE.md`：每个具体任务如何写成可执行任务包。
5. `DAILY-REVIEW-TEMPLATE.md`：每日提交什么证据、如何验收。

## 当前团队事实

- 总设计师：负责设计与控制，不操作新版造世界编辑器。
- 成员 A：拥有 Claude、GPT 和新版造世界 AI 编辑器，负责公共列车与集成。
- 成员 B：使用 DSH 和新版造世界 AI 编辑器，负责书桌站。
- 成员 C：使用 DSH 和新版造世界 AI 编辑器，负责失重花园。
- 团队已确认新版造世界 AI 编辑器支持导入 GLB 与 WPRE；项目按本地工作流使用 Git 协作。场景文件是否可安全文本合并、完整工程迁移是否无损，仍按集成验证结果处理。

## 当前阶段

本目录先建立生产地基。具体 A/B/C 制作任务包、资产参考板、模型提示词和逐日任务尚未在本次提交中预设，下一阶段由总设计师逐项设计并评审。
