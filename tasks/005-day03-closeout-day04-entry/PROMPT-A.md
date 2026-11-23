# PROMPT A｜技术集成与公共交付负责人

> 复制本文件全文给成员 A 的 Claude 主控 Agent。GPT 可作为独立 Red Team，但不得同时写入同一个项目/场景。

---

你是《天空列车的最后一站》（The Last Terminus）的成员 A：技术集成与公共交付负责人。你的工具条件是 Claude + GPT + 新版造世界 AI 编辑器 + 本地 Git。

你的任务不是继续无限探索工具，而是把已经验证的能力收敛成 B/C 真正能复用的交付，并完成公共接口准备。

## 0. 先读取，不要立刻修改

按顺序读取：
1. 根目录 AGENTS.md
2. README.md
3. production/DESIGN-DIRECTOR-DECISIONS-2026-11-22.md
4. production/prompts/DAY-03-REVISION-AND-DAY-04-ENTRY-GATE.md
5. production/EDITOR-TECHNICAL-FINDINGS.md
6. production/TEAM-ROLES.md
7. production/INTEGRATION-CONTRACT.md
8. tasks/002-a-train-core/README.md 及全部相关设计文件
9. tasks/005-day03-closeout-day04-entry/COMMON-ACCEPTANCE.md
10. 本文件。

先向我输出：
- 你理解的 A 本轮目标。
- 现有成果中哪些可以直接复用。
- 哪些结论仍是 NOT TESTED / INCONCLUSIVE。
- 预计修改的文件和验证顺序。

不要先创建新工具、不要重做已经通过的探针。

## 1. Git 安全与项目保护

1. 检查当前分支，必须是 feature/train-core。
2. 执行 git status --short --branch，检查是否存在未提交内容。
3. 检查 origin/main 与当前分支差异：git fetch origin 后查看 ahead/behind 和分叉。
4. 不得使用 reset --hard、git clean -fd、force push 或破坏性 rebase。
5. 工作区不干净时先保护并报告，不得覆盖。
6. 如需同步 main，先审查差异，使用安全 merge；冲突不确定就停止并提交冲突清单。

## 2. A1｜修正 C4 门禁示例

现有文件：tools/c4_complete_gate.js。

先阅读该文件和 B 最新 reports/day-03/B/C4-PLAYABLE-LOOP.md。B 的最新证据已经解决玩家视角渲染问题，根因是可见角度预算，不要再把问题归因于引擎不渲染。

当前示例有至少三个需要检查的风险：
- UNLOCK_Z=90，但 B 正常出生位置约为 z=88.64；必须验证正常出生不会自动解锁。
- 返回点 z=88 是 A 测试坐标，不得直接用于 B 工程。
- 示例只切换 C4_RAMP_1，但 B 的坡道有 C4_RAMP_1..6 六段。

### 操作步骤

1. 检查 B 最新场景的节点树/命名/实际坐标；如果你没有访问 B 工程权限，向 B 请求最小结构快照，不要猜。
2. 设计参数化接口，至少支持：
   - Unlock region / gate region 的运行时边界。
   - Return position + yaw。
   - REST 节点名。
   - RAMP 六个节点名，或一个已确认的共同父节点。
   - Cooldown / debounce。
3. 保持状态在同一绑定脚本实例内，不依赖跨脚本 _G 或未验证的全局同步。
4. 正常出生时 activated=false，除非玩家真正进入交互区域并执行交互。
5. 交互触发后一次性完成 REST 隐藏、六段 RAMP 显示和状态解锁。
6. 未解锁进入门禁区时回到安全点；已解锁时放行。
7. 增加调试日志，能明确看到：当前玩家位置、状态、触发原因、是否传送、当前可见节点。
8. 先在 A 的最小测试工程验证，再交给 B 在自己的工程复测。

### 必须测试

- 正常出生：没有自动解锁。
- 未交互进入门禁：回安全点。
- 主动交互：REST 消失，RAMP 1..6 全部出现。
- 交互后进入门禁：允许通过。
- 快速重复进入触发区：不会反复传送/重复切换。
- 保存、关闭、重新打开：绑定和节点状态初始化正确。

### 交付

- 修订后的 tools/c4_complete_gate.js。
- 参数说明和节点层级要求。
- 最小 WPRE/脚本绑定示例。
- 测试矩阵和真实运行录屏。
- 不适用 B 当前工程的地方必须标注，不得称为“B 已集成”。

## 3. A2｜技术报告收敛

检查并修订：
- reports/day-03/A/REVISION.md
- COLLISION-MATRIX.md
- BLOCKERS.md
- DAY3-SUMMARY.md
- WORLD-INTERFACE-CONTRACT.md
- HANDOFF.md
- TECHNICAL-REFERENCE.md

统一规则：
- 普通场景 Collider 不能被当作阻挡运动学 NetworkActor 的可靠手段。
- 115m 路线：8 张传送截图只能证明关键点视觉布局，连续完整行走仍 INCONCLUSIVE。
- 音频：区分资源导入、参数绑定、API 接受播放命令、人耳实际听到四个层级。
- MP3 如果只有文档声明、没有真实导入测试，标 NOT TESTED。
- WPRE 跨成员导入没有接收方回执前保持 NOT TESTED。
- 保留历史错误观察，但明确标记为已被后续证据推翻。

不要为了让报告整齐而删除失败历史。

## 4. A3｜Integration Kit 跨成员交接

使用已有共享资产，不重复制作：
- probe-cube-1m.glb
- probe-cube-2m.glb
- probe-cube-4m.glb
- probe-axis-marker.glb
- probe-textured-cube.glb
- probeminimal.wprefab
- ASSET-MANIFEST.csv

操作：
1. 检查文件是否存在、SHA 是否与清单一致。
2. 把导入说明、编辑器版本、坐标/镜像、材质限制、已知缺陷写清。
3. 请求 B 和 C 分别在自己的项目中导入并运行至少一个 GLB 和最小 WPRE。
4. 接收方必须回传导入前后层级、运行截图/录屏、文件 SHA 和结果。
5. A 汇总跨成员矩阵；发送方自测不能替代接收方测试。

## 5. A4｜World Interface Contract

更新 WORLD-INTERFACE-CONTRACT.md，为 Desk / Garden 各保留一行正式接口：

- Entry position (runtime world coordinates)
- Entry spawn yaw
- Exit position
- Safe zone
- Return target
- Coordinate convention / unit
- Editor version / project version
- Handoff asset URI or local package path
- Status and evidence

坐标必须来自 B/C 当前运行时实测，不可从 Three.js 作者源坐标直接推导；注意已验证的 X 镜像问题。

如果 B/C 还没提供坐标，明确标 WAITING FOR OWNER，不要自行填数。

## 6. A5｜音频真实播放验证

A 已有 WAV 导入/绑定/播放技术探针。现在需要确认实际听感：
1. 使用一段非测试正弦音频，优先选有许可的短环境音。
2. 在真实造世界运行环境播放。
3. 由成员本人确认能听到，记录输出设备、音量、持续时间、循环和重复触发。
4. 录制能证明播放状态的运行视频；视频无声时另附人工试听记录。
5. 如果 Agent/远程环境无法听到，必须标 NOT TESTED，不得用 play=true 代替。

## 7. A6｜集成准备，不扩张场景

- 整理 Hub → Desk → Hub/下一站 → Garden → Terminus 的可执行流程。
- 为每个转场定义入口、出口、冷却和安全返回。
- 不要求无缝加载；可靠的短传送/门/过场优先。
- 不继续扩建终点站，不增加大型列车系统。
- 115m 路线仍 INCONCLUSIVE 时，提出短而稳定的可走观景路线降级提案，交总设计师批准；不得擅自把视觉截图改判为完整行走 PASS。

## 8. Agent 团队组织

Claude 主控：
- Producer：拆分 A1–A6、管理依赖。
- Technical Researcher：查现有接口/文档，不重复探针。
- Code Reviewer：审查门禁脚本边界条件。
- QA Agent：检查报告一致性和测试矩阵。
- GPT Red Team：独立找假设、状态误标、跨成员缺口。

只有 A 本人可以操作需要人工 GUI/真实声音验证的步骤。不同 Agent 不得同时改同一脚本或同一场景。

## 9. 最终交付路径

在当前分支提交：
- reports/day-03/A/REVISION.md
- reports/day-03/A/INTEGRATION-KIT-HANDOFF.md
- reports/day-03/A/WORLD-INTERFACE-CONTRACT-UPDATE.md 或更新原契约
- 相关脚本/资产清单/证据
- reports/day-03/A/EVIDENCE.md
- reports/day-03/A/BLOCKERS.md

每个结论标 PASS / FAIL / NOT TESTED / INCONCLUSIVE。
最后在 PR #12 留言：Commit SHA、交付路径、跨成员请求、未关闭事项。

## 10. A 的完成定义

A-01 至 A-08 见 COMMON-ACCEPTANCE。A 不得自行宣布 Day 4 Gate 通过；提交证据后等待总设计师 Review。
