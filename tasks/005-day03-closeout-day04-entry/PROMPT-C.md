# PROMPT C｜失重花园体验与路线验收负责人

> 复制本文件全文给成员 C 的 DSH 主控 Agent。C 本人操作造世界 GUI、自由视角和真人试玩。

---

你是《天空列车的最后一站》的成员 C，负责失重花园。你的工具条件是 DSH + 新版造世界 AI 编辑器 + Blender；关键 Tripo 模型由总设计师生成。

本轮不是继续扩展地图，也不是重复技术探针。当前 Plan C 的空间白盒和大量技术能力已经成立；真正未闭合的是观景体验、无提示路线发现、45 秒 Backup Cue 的完整体验以及跨成员交接。

## 0. 先读取

依次读取：
1. 根目录 AGENTS.md
2. README.md
3. production/DESIGN-DIRECTOR-DECISIONS-2026-11-22.md
4. production/prompts/DAY-03-REVISION-AND-DAY-04-ENTRY-GATE.md
5. production/EDITOR-TECHNICAL-FINDINGS.md
6. tasks/004-c-floating-garden/README.md 和全部相关文件
7. tasks/004-c-floating-garden/VISUAL-REFERENCE-BOARD.md
8. reports/day-01/C/PROBE-RESULTS.md
9. reports/day-01/C/PLAN-C-WHITEBOX.md
10. reports/day-01/C/HANDOFF.md
11. tasks/005-day03-closeout-day04-entry/COMMON-ACCEPTANCE.md
12. tasks/005-day03-closeout-day04-entry/VISUAL-REFERENCE-BOARDS.md
13. 本文件

先输出：
- 当前 Plan C 的路线和已验证能力。
- T-24/T-24b 为什么不能算观景点通过。
- 本轮要补的 GUI、盲测、计时、恢复和交接证据。
- 需要总设计师决策的开放问题。

## 1. Git 和工程安全

1. 检查当前分支必须是 feature/floating-garden。
2. 执行 git status --short --branch，保护未提交内容。
3. 不得使用 reset --hard、git clean、force push 或破坏性 rebase。
4. 如需同步 main，先检查分叉、未提交工作和冲突；安全 merge，不确定就停。
5. 不得修改 A 的列车场景或 B 的书桌站场景。

## 2. C1｜固定地图，不扩图

严格保留当前 Plan C：
入口浮岛 → 断桥/路线线索 → 根系路线 → 倒悬温室屋顶 → 花冠观景点。

禁止：
- 增加新岛屿。
- 增加新玩法系统。
- 重做三层拓扑。
- 做真实任意方向重力。
- 为了更宏大而扩大地图。
- 把现有 34 级台阶/根系路线全部推翻，除非真实试玩证明无法使用。

优先修复路线可读性和观景点。

## 3. C2｜观景点真实 GUI 验证

当前已知：
- T-24b 全新 runtime 证明默认相机朝 +Z 时，远景目标可见，来路在背后。
- 之前一次“来路可见”的截图受到历史测试输入转动相机影响，是假阳性，不能继续使用。
- 新验收要求：默认到达视角看见下一个目标；玩家正常 Look-back 后 3 秒内识别来路。

### 操作步骤

1. 由成员 C 本人在造世界 GUI/真实运行中启动一个全新 runtime。
2. 确认没有残留相机状态或上一次测试输入。
3. 从入口沿当前 Plan C 路线真实走到花冠观景点。
4. 不做任何脚本镜头控制，截取默认到达视角。
5. 检查下一目标/地平线奖励是否清楚可见。
6. 使用正常可用的 Look 输入，主动回望。
7. 从开始 Look-back 计时，记录是否在 3 秒内识别来路。
8. 录制完整连续操作，不只提交单张截图。

### 如果没有可用 Look 输入

1. 先确认是 GUI/运行模式本身没有自由 Look，而不是测试者不知道如何操作。
2. 不允许写 Lua 强制 camera yaw，不允许自动镜头接管。
3. 设计一个低成本物理回转方案：
   - 短回转平台；
   - U 形观景步道；
   - 或者一个能自然引导玩家转身的宽阔观景台。
4. 玩家必须自己移动/转身后看见来路。
5. 用全新 runtime 重新测试。

## 4. C3｜两名独立玩家路线盲测

至少找两名未参与失重花园设计的人。测试前不要口头提示路线。

### 测试脚本

只给试玩者一句中性任务：
“从入口出发，探索花园并抵达你认为可以继续旅程的地方。”

不要告诉他们根系是路线，不要指出温室屋顶，不要提示隐藏通道。

每名试玩者记录：
- 首次注意到温室的时间。
- 从断桥开始探索到发现根系路线的时间。
- 走错方向次数。
- 坠落次数。
- 主动求助次数。
- 是否完成路线。
- 抵达观景点后是否理解空间上下关系。
- 玩家自己的简短反馈：哪里困惑、哪里有发现感。

### 判定建议

PASS：
- 两人都能独立完成；
- 至少一人无需任何提示；
- 主要错误路线不会让玩家长时间迷失；
- 没有频繁坠落或软锁。

如果只有一名测试者，或没有测试者，必须标 NOT TESTED/样本不足。可以做内部自测，但不能称为独立盲测。

## 5. C4｜45 秒 Backup Cue 完整体验

已知技术能力：
- Trigger 回调、Lua 位移、RespawnLocal 已有证据。
- 计时器/一次性提示机制有技术探针。
- 动态点光可用。
- 3 秒探针不等于真实 45 秒体验。

### 操作步骤

1. 明确计时起点：玩家进入花园入口安全区。
2. 玩家在 45 秒内未触发正确路线发现条件时，准备触发 Backup Cue。
3. 真实等待完整 45 秒，不用调短计时来替代验收。
4. 到时触发一次柔和光线提示，指向根系/正确路线。
5. 如果音频链路已经被 A 人耳确认可用，再加入一次短声音提示；如果未确认，先只做光线提示并标记音频 NOT TESTED。
6. 同一轮游玩内重复进入触发区，不应重复触发。
7. 检查 Trigger 去抖和 one-shot。
8. 玩家发现路线后，提示不再持续干扰。
9. 关闭工程/实例后重新打开，再做一次完整 45 秒测试。

### 记录

- 计时开始时间。
- 实际触发时间。
- 提示次数。
- 点光强度/颜色或可见变化。
- 音频是否实际听到。
- 重复进入是否重复触发。
- 重开后行为是否一致。

## 6. C5｜坠落恢复与路线安全

1. 从入口、根系路线、温室屋顶/观景点附近的主要失败区域分别测试坠落。
2. 使用当前已验证的 RespawnLocal/安全复位机制。
3. 真实运行确认玩家落回安全区并可以继续移动。
4. 不得只用 Teleport 命令结果当作落地/可走证据。
5. 复位后检查：
   - 是否还在原触发器内导致循环触发；
   - Backup Cue 是否重复；
   - 是否能重新走路线；
   - 是否存在卡死/无法继续。
6. 关闭并重新打开项目，再复测至少一次。

## 7. C6｜Entry/Exit 运行时接口

提交真实运行时测量值：
- Entry position (x,y,z)
- Entry spawn yaw
- Exit position (x,y,z)
- Safe zone 范围/半径
- Return target
- 运行时坐标系、单位和编辑器版本
- 触发器/传送锚点名称
- 返回列车的恢复方式

注意：
- Three.js 作者源坐标不能直接作为运行时坐标。
- 已知 GLB 导出会发生 X 镜像，必须在运行时测量。
- 不要根据旧报告或图片估算坐标。

## 8. C7｜A 的共享资产交接

从 A 的 Integration Kit 选择：
- probe-cube-1m.glb
- probe-axis-marker.glb
- probe-textured-cube.glb
- probeminimal.wprefab

在 C 自己的项目里实际导入、保存、关闭、重新打开并运行。

检查：
- 尺寸、朝向、X 镜像。
- 材质/贴图。
- 层级。
- Trigger/Lua 是否随 WPRE 保留。
- 依赖是否完整。
- 运行时是否正常。

回传 SHA、编辑器版本、导入前后截图和连续运行证据。只检查压缩包内容不算交接通过。

## 9. C8｜视觉方向收敛

参考板：
tasks/004-c-floating-garden/VISUAL-REFERENCE-BOARD.md

本轮不批量 Tripo，不扩大场景。只检查：
- 浮岛边缘有岩层/土壤/根系厚度，不像悬浮方块。
- 巨型花朵有清楚花瓣层次、花心、茎和根。
- 根系可走部分与装饰部分能区分。
- 倒悬温室的檐口、底座法兰、天窗方向线索清楚。
- 观景点不被栏杆、根系、平台或花瓣遮挡。
- 远景/中景/近景的材质密度合理。

关键模型需求交总设计师审批，不要自行生成大量 Hero Asset。

## 10. 报告和交付

新增：
- reports/day-03/C/REVISION.md
- reports/day-03/C/BLIND-PLAYTEST.md
- reports/day-03/C/VISTA-TEST.md
- reports/day-03/C/BACKUP-CUE-TEST.md
- reports/day-03/C/ENTRY-EXIT.md
- 更新 QA-AUDIT.md、EVIDENCE.md、BLOCKERS.md

每个测试标 PASS / FAIL / NOT TESTED / INCONCLUSIVE。
保留假阳性和失败记录，不得静默覆盖。

## 11. DSH Agent 团队

按需动态组建：
- Producer：管理 C1–C8。
- Level Designer：审查路线和视线。
- Playtest Observer：设计盲测记录表，不替代真人。
- Gameplay Engineer：检查 Trigger、Backup Cue、Respawn。
- QA/Red Team：寻找错误路线、重复触发和软锁。

C 本人必须操作 GUI、正常 Look、真实 45 秒计时和真人试玩安排。Agent 不能替真人盲测，也不能伪造运行证据。

## 12. 完成定义

必须满足 COMMON-ACCEPTANCE 的 C-01 至 C-09。
未完成项诚实标记，不要以“技术能力已验证”替代“玩家体验已通过”。
