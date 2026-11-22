# Phase Prompts｜阶段提示词系统

角色提示词定义长期职责；任务包定义世界目标与质量边界；阶段提示词定义本轮执行重点。Gate 未通过时留在当前阶段 REVISE，不机械跳转。

- 成员启动提示词：ROLE-A/B/C。
- 阶段执行提示词：DAY-01 至 DAY-07。
- 当前专项阶段：[DAY-03｜公共技术基线与玩法闭环](DAY-03-TECHNICAL-BASELINE-AND-CLOSED-LOOPS.md)。
- 技术发现索引：[EDITOR-TECHNICAL-FINDINGS.md](../EDITOR-TECHNICAL-FINDINGS.md)。

## 成员专属提示词
- [A｜列车与集成](ROLE-A-TRAIN-INTEGRATION.md)
- [B｜书桌站](ROLE-B-DESK-WORLD.md)
- [C｜失重花园](ROLE-C-FLOATING-GARDEN.md)

## 阶段顺序
| 文件 | 用途 |
|---|---|
| 00-BOOTSTRAP | 初始化仓库 |
| DAY-01 | 研究、资产审计、技术探针 |
| DAY-02 | 白盒、空间路线、接口 |
| DAY-03 | 公共技术基线与玩法闭环 |
| DAY-04 | 关键美术与声音样板 |
| DAY-05 | 跨世界集成 |
| DAY-06 | 盲测与修复 |
| DAY-07 | 最终验收 |

## 通用执行协议
1. 检查 Git 状态与最新 main，保护未提交工作。
2. 阅读项目基线、对应任务包和当前阶段提示词。
3. 动态组建最小有效 Agent 团队，明确 Owner/产物/验收。
4. 先做最小可验证成果。
5. 阻塞局部化：最小验证、记录证据、降级并继续独立任务。
6. 不伪造完成状态；占位/降级必须标明。
7. 阶段交付真实截图、录屏、Commit 和问题清单。
8. Gate 由总设计师/指定 Review 决定，Agent 自检不等于通过。

## 协作
- A 维护公共接口和集成协调；B/C 维护各自世界。
- B/C 尽早提交 Entry/Exit、出生朝向、安全落脚区和临时快照。
- 二进制/原生场景同一时刻只有一个主要写入者。
- 没有团队聊天工具时，使用 PR 评论交接，给出报告路径和 Commit。
- 阶段报告放 reports/day-XX/OWNER/，大型录屏放共享存储并留链接。

## 阶段状态
- APPROVE：通过。
- REVISE：修订后复审。
- REJECT：方向错误，回到方案/白盒。
- BLOCKED：局部冻结，继续独立工作。
