# 00｜Bootstrap Prompt

这份提示词只用于首次初始化，不用于后续阶段制作。

**Repository:** `https://github.com/1263-ux/The-Last-Terminus.git`  
**Base branch:** `main`

| Owner | Work branch |
|---|---|
| A | `feature/train-core` |
| B | `feature/desk-world` |
| C | `feature/floating-garden`

复制后只替换 Owner 和 Work branch：

```text
请初始化 The Last Terminus 项目文档仓库。

Repository: https://github.com/1263-ux/The-Last-Terminus.git
Owner: <A / B / C>
Work branch: <feature/train-core / feature/desk-world / feature/floating-garden>
Base branch: main

检查本地仓库是否存在。不存在则克隆到独立目录；存在则先检查 git status，保护未提交工作，再 fetch origin。创建或切换到指定工作分支，检查与 origin/main 的关系，确认可以正常提交和 push。

阅读 README.md、AGENTS.md、production/START-HERE-FOR-MEMBERS.md 和 production/prompts/README.md。确认仓库初始化、当前分支、工作区状态和原生造世界工程安全边界。

本轮只完成仓库初始化和项目认知，不开始世界制作、不批量生成模型、不覆盖原生工程、不向 main 推送。最后告诉我应从哪份 Day Prompt 开始。
```
