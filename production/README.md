# Production System｜生产体系入口

本目录定义团队职责、Agent 执行方式、Git/资产交接、阶段节奏、跨团队协作和 Review 规则。

## 阅读顺序
1. `TEAM-ROLES.md`：成员职责与决策权。
2. `EXECUTION-PROTOCOL.md`：Agent 执行、验证和停止条件。
3. `INTEGRATION-CONTRACT.md`：Git、GLB、WPRE 和工程交接。
4. `PRODUCTION-OPERATING-SYSTEM.md`：七天节奏、Gate、验收和交付闭环。
5. `COORDINATION-PROTOCOL.md`：A/B/C 协作、交接和阻塞处理。
6. `START-HERE-FOR-MEMBERS.md`：首次仓库初始化。
7. `prompts/README.md`：如何按阶段使用提示词。

## 当前任务包
- A：`tasks/002-a-train-core/`
- B：`tasks/003-b-desk-world/`
- C：`tasks/004-c-floating-garden/`

## 提示词使用方式
首次只使用 `prompts/00-BOOTSTRAP.md` 初始化仓库和分支。后续每个阶段只使用当天的 `DAY-01` 至 `DAY-07` 提示词。阶段提示词定义本轮重点，不替代世界任务包；Agent 可以自主探索实现，但必须满足阶段 Gate。

## 生产状态
当前任务包均为 DESIGN BRIEF：可以开展参考研究、技术探针、方案比较和低成本白盒。关键 Tripo 模型批量生产和大规模精修应等待对应方向/白盒 Review。
