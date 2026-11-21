# START HERE｜成员启动指南

> 给 A/B/C 的实际使用说明。先按本文件启动，不需要把整个仓库复制进聊天窗口。

## 1. 先理解仓库是什么

当前 GitHub 仓库主要存放：
- 世界观与设计基线（`docs/`）
- 团队生产规则（`production/`）
- A/B/C 任务包（`tasks/`）

**当前仓库还没有放入造世界编辑器的原生工程目录。** 不要把这个仓库误认为已经包含可直接打开的完整游戏工程。

每位成员先把本仓库克隆到自己的工作目录，用 Agent 阅读文档；造世界编辑器继续打开自己当前实际使用的本地工程。不要把仓库克隆到现有工程目录里，不要移动/覆盖原生项目文件。A 完成项目结构、保存恢复和 Git 安全性探针后，再决定哪些工程文件可以纳入版本管理。

## 2. 获取仓库

每个人在自己的电脑上执行一次：

```powershell
git clone https://github.com/1263-ux/The-Last-Terminus.git
cd The-Last-Terminus
git pull --ff-only origin main
```

然后按角色创建自己的分支：

| 成员 | 分支 |
|---|---|
| A | `feature/train-core` |
| B | `feature/desk-world` |
| C | `feature/floating-garden` |

例如 B：

```powershell
git switch -c feature/desk-world
git status
```

如果已经克隆过，不要重复 clone；先检查 `git status`，确认没有未提交改动，再拉取 main 并创建自己的分支。

## 3. 所有人先读的文件

1. `README.md`
2. `AGENTS.md`
3. `docs/00-PROJECT-CORE.md`
4. `docs/01-WORLD-BIBLE.md`
5. `docs/05-ART-AND-AUDIO.md`
6. `docs/06-ONE-WEEK-SCOPE.md`
7. `production/PRODUCTION-OPERATING-SYSTEM.md`
8. `production/TEAM-ROLES.md`
9. `production/EXECUTION-PROTOCOL.md`
10. `production/INTEGRATION-CONTRACT.md`
11. 自己任务目录的 `README.md`、`TASK.md`、`AGENT-TEAM.md`，再按需阅读参考板、资产需求和验收文件。

不用把所有文件全文粘贴进 Agent。让 Agent 在本地仓库目录中读取文件，并在执行过程中回查。

## 4. 统一启动提示词

把下面这段发给自己的主控 Agent：

> 你现在参与 The Last Terminus 项目。当前工作目录是本地克隆的项目文档仓库。请先检查 git status 和当前分支，再阅读 README.md、AGENTS.md、production/PRODUCTION-OPERATING-SYSTEM.md、production/TEAM-ROLES.md、production/EXECUTION-PROTOCOL.md、production/INTEGRATION-CONTRACT.md，以及我负责的任务包。
>
> 不要立刻开始大规模制作。先用自己的话总结：项目核心、我的责任边界、当前任务目标、不能偏离的设计、可自主探索的部分、当前阶段 Gate、需要验证的工具能力。
>
> 然后按任务包的 AGENT-TEAM.md 动态组织 Agent：只启动当前阶段真正需要的角色，不为凑人数而启动 Agent。并行任务不能写入同一个场景或同一个二进制文件。
>
> 现在只执行 Day 1。先提交执行计划、风险/依赖和首日交付清单，再开始研究或低成本技术探针。任务包状态为 DESIGN BRIEF：可以研究、比较方案、做技术探针和低成本白盒；未经 Review 不得批量生成高成本 Tripo 模型或大规模精修。
>
> 所有结论区分 CONFIRMED、PROPOSED、TO-VERIFY。不要假定造世界编辑器具备未实测的功能。关键 Tripo 模型由总设计师生成，我负责提交 Asset Card、提示词草案和导入验证。完成必须提供真实截图、录屏、项目文件或可复现的测试记录，不能只汇报文字。

## 5. 各成员首轮任务

### A｜列车与集成（Claude 主控，GPT 独立审查）

任务入口：`tasks/002-a-train-core/`

把下面的补充指令接在统一提示词后：

> 你负责 A-01。Day 1 优先验证当前造世界工程的保存/关闭/重开、项目目录、Git 安全协作、GLB/WPRE 导入和跨成员交接。区分已验证与待验证，不要直接把原生工程目录全部加入 Git。并行研究列车 Hub 与云海尽头的成熟参考，提出一个紧凑车厢 Hub 和终点站的初步空间方案。GPT 或独立上下文负责反向审查技术假设、集成风险和范围膨胀。A 本人操作编辑器并提供真实证据。
>
> Day 1 交付：执行计划、项目/资产探针报告、GLB/WPRE 测试矩阵、列车 Hub 空间草案、技术风险清单。先不要做最终精细列车模型。

### B｜书桌站（DSH 主控）

任务入口：`tasks/003-b-desk-world/`

> 你负责 B-01《桌面以下》。Day 1 优先审计已有 GLB/WPRE 资产，研究 Grounded、Tiny Glade、A Short Hike、The Last Campfire 的具体场景和设计方法。提出 1–2 个书桌站空间布局方案，并说明主路线、尺子桥玩法、隐藏路线和铅笔盒小镇之间的关系。先用低成本白盒验证微缩尺度和目标可见性。
>
> Day 1 交付：资产审计表、标注参考板、两种空间方案（可以是草图/白盒）、尺子桥玩法流程、风险清单。不要批量生成模型；关键 Tripo 需求整理成 Asset Card，交总设计师处理。

### C｜失重花园（DSH 主控）

任务入口：`tasks/004-c-floating-garden/`

> 你负责 C-01 失重花园。Day 1 研究 Sky、Monument Valley、Ori、Journey 的具体环境和空间设计。提出两种空间拓扑方案，明确入口、中央地标、不同高度层、路线发现点、温室和高处观景点。做最小 AI 地形和移动平台/机关能力探针，不要先生成完整花园。
>
> Day 1 交付：标注参考板、两种空间方案、玩法发现流程、AI 地形/移动平台测试记录、风险清单。不要默认需要真实重力反转；关键 Tripo 需求交总设计师处理。

## 6. Day 1 交付位置与提交方式

每位成员在自己的分支建立：

```text
reports/
└── day-01/
    └── A-or-B-or-C/
        ├── PLAN.md
        ├── REFERENCE-STUDY.md
        ├── PROBE-RESULTS.md
        ├── DESIGN-PROPOSAL.md
        └── EVIDENCE.md
```

按角色调整文件内容，不需要为了凑文件而创建空文档。截图可以放在对应目录；较大的录屏放团队约定的共享位置，在 `EVIDENCE.md` 写链接和时间点。不要把编辑器缓存、临时下载或大体积无关文件提交到 Git。

完成后：

```powershell
git status
git add reports/day-01
git commit -m "docs(day-01): submit <owner> kickoff results"
git push -u origin <your-branch>
```

把 Commit/分支链接、截图和录屏发到团队群。阶段成果达到可审阅状态时，再开 PR；不要直接推送 main。

## 7. 每日 Review 与阶段推进

- 每天 09:30：Kickoff，明确今日唯一目标和 Owner。
- 14:00：中途检查，暴露方向风险和阻塞。
- 18:30：整理真实证据，执行自检和独立 QA。
- 19:30–20:15：总设计 Review。
- 20:15：锁定次日目标。

按 `production/PRODUCTION-OPERATING-SYSTEM.md` 执行 Day 1–Day 7。每个 Gate 只允许四种结论：APPROVE、REVISE、REJECT、BLOCKED。

**没有真实截图/录屏/可重开工程，不得判定完成。** 未通过 Gate 不进入下一阶段的大规模投入。

## 8. 集成和文件安全

- A/B/C 各自维护自己的工作分支和场景文件。
- A 负责公共模块和集成；B 只写书桌站；C 只写失重花园。
- 同一场景/二进制文件只能有一个主要写入者。
- A 先验证造世界原生项目如何安全纳入 Git；验证前不要把整个项目目录盲目提交。
- GLB/WPRE 交接必须带依赖说明和导入后截图。
- 大型录屏不直接塞进 Git，使用共享链接并登记。
