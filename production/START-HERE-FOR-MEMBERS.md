# START HERE｜成员初始化入口

> 本文件只负责仓库初始化和分支建立。完成后，不要把这段提示词永久挂在 Agent 上；每个阶段使用独立的 Day Prompt。

## 1. 仓库与分支
- Git 地址：`https://github.com/1263-ux/The-Last-Terminus.git`
- 基础分支：`main`

| 成员 | 工作分支 |
|---|---|
| A | `feature/train-core` |
| B | `feature/desk-world` |
| C | `feature/floating-garden` |

## 2. 推荐方式：直接使用成员专属提示词

不要把一条通用启动提示词发给三个人。每个人直接打开并复制自己对应的文件，它已经包含仓库初始化、专属分支、角色责任、Agent 组织、Day 1 工作和跨团队协作要求：

- [A｜列车与集成](prompts/ROLE-A-TRAIN-INTEGRATION.md)
- [B｜书桌站](prompts/ROLE-B-DESK-WORLD.md)
- [C｜失重花园](prompts/ROLE-C-FLOATING-GARDEN.md)

每份只发给对应成员的主控 Agent。发送后让 Agent 在本地完成 clone/fetch/branch 初始化，并开始 Day 1。不要把三个角色提示词混发给同一个 Agent。

## 3. 仅初始化、不立即开工时的通用提示词

如果你只想先初始化仓库、不立即启动 Day 1，才使用下面的通用提示词：

~~~text
请初始化 The Last Terminus 项目文档仓库。

Repository: https://github.com/1263-ux/The-Last-Terminus.git
Base branch: main
Owner: <A / B / C>
Work branch: <对应 feature 分支>

检查本地仓库是否存在。若不存在，克隆到独立工作目录，然后从 origin/main 创建我的工作分支。若已存在，先检查 git status 并保护所有未提交修改，再 fetch origin；检查目标分支是否存在、是否有自己的提交、是否落后于 origin/main。不要擅自 reset、clean、force push、覆盖或重写历史；遇到分支分歧先报告。

确认当前分支、工作区状态、远端跟踪关系和 push 权限。阅读 README.md、AGENTS.md、production/START-HERE-FOR-MEMBERS.md 和 production/prompts/README.md。告诉我初始化结果、我的任务包入口和今天应使用的阶段提示词。

本轮只做仓库初始化和项目认知，不开始场景制作，不批量生成模型，不修改造世界编辑器原生工程，不向 main 推送。
~~~

## 4. 命令参考

首次克隆后创建分支：

~~~powershell
git clone https://github.com/1263-ux/The-Last-Terminus.git
cd The-Last-Terminus
git fetch origin
git switch -c feature/your-workstream origin/main
git status
git push -u origin feature/your-workstream
~~~

已有仓库时先检查：

~~~powershell
git status
git fetch origin
git branch --show-current
git branch -vv
~~~

如果目标分支不存在，从 `origin/main` 创建；如果已存在，先检查其与 `origin/main` 的差异，不要盲目 pull/rebase。工作区不干净时先保护和提交/备份用户修改。

## 5. 原生工程安全
当前仓库主要保存设计文档、生产规范和阶段报告，**不等于造世界编辑器的完整原生工程**。
- 文档仓库和编辑器原生工程先分开。
- 不要把文档仓库克隆到原生工程目录中。
- 不要移动、重命名或覆盖原生工程文件。
- A 完成项目目录、保存恢复、Git 和 GLB/WPRE 探针后，再决定工程文件如何纳入版本管理。

## 6. 初始化后
按 `production/prompts/README.md` 使用当天阶段提示词。不要长期使用一条总提示词，也不要在 Gate 未通过时机械跳到下一阶段。
