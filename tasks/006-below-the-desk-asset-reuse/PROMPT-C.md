# PROMPT C｜失重花园清洁场景与真人体验验收

你是《天空列车的最后一站》的 C：Floating Garden Lead。当前 Plan C 的空间路线、技术走通、45 秒 Backup Cue 和重启后坠落复位已有真实证据。不要重复做已经通过的基础探针，也不要扩图。

## 0. 必读
- AGENTS.md
- production/DESIGN-DIRECTOR-DECISIONS-2026-11-22.md
- tasks/004-c-floating-garden/ 全部文件
- reports/day-03/C/REVISION.md
- reports/day-03/C/QA-AUDIT.md
- tasks/005-day03-closeout-day04-entry/COMMON-ACCEPTANCE.md
- tasks/006-below-the-desk-asset-reuse/TASK-ACCEPTANCE.md
- 本文件

## 1. 先清理重复实例（最高优先级）

当前报告已记录：
- 多个重叠 garden-whitebox 实例；
- 多份重复 Lua 绑定；
- 重叠云垫同时响应，导致坠落复位计数为 3；
- 旧 Trigger 绑定可能污染 Backup Cue 和相机测量。

操作：
1. 备份当前工程/场景。
2. 在 GUI 或已验证运行时方式下枚举场景根节点。
3. 只保留一份正式 garden-whitebox。
4. 删除重复云垫、旧 trigger_probe、重复 fall_respawn / tint / BackupCue 绑定。
5. 保存、关闭、重新打开，重新枚举节点和绑定。
6. 提交清理前后节点树截图和数量差异。

不要在无法确认 root ID 时批量删除未知节点；先导出清单。

## 2. 清洁场景复测

- 从全新 runtime 出生，连续走入口→根系下坡→温室屋顶→上行台阶→U 形回转→观景台。
- 记录坐标、耗时、坠落和异常停顿。
- 确认只有一个云垫响应一次，玩家复位后能继续。
- 重新等待完整 45 秒，确认正式 Backup Cue 只触发一次，不被旧实例提前触发。
- 重启 runtime 再验证一次状态归零、计时和复位。

原有轮 22/23 的证据保留为历史 PASS；清洁场景复测用于证明重复实例污染已真正解除。

## 3. 真人 GUI free-look 与观景点

- 默认到达视角必须看到下一个目标/地平线奖励。
- 成员 C 本人使用真实鼠标/摇杆 Look 输入回望。
- 3 秒内能识别来路。
- 禁止 Lua SetYaw、脚本强制旋转或相机接管。
- 若 GUI 确认没有可用自由 Look，设计物理回转平台/短 U 形路线，让玩家自己转身后看见来路，并录制全程。

## 4. 两名独立玩家盲测

找至少两名未参与设计的试玩者。只给一句中性任务：“从入口探索花园，找到可以继续旅程的地方。”
不告诉他们根系路线、温室屋顶或隐藏路径。

记录：
- 注意到温室的时间；
- 发现根系路线的时间；
- 错误路线次数；
- 坠落次数；
- 求助次数；
- 完成时间；
- 是否理解倒悬空间；
- 自由反馈。

如果没有真人测试者，标 NOT TESTED，不要把 Agent dry run 写成盲测通过。

## 5. Entry/Exit 和交付

提交运行时实测：
- Entry xyz；
- Entry spawn_yaw；
- Exit xyz；
- Safe zone；
- Return target；
- 坐标单位/坐标系；
- 编辑器版本/工程版本。

更新：
- reports/day-03/C/REVISION.md
- reports/day-03/C/QA-AUDIT.md
- reports/day-03/C/EVIDENCE.md
- reports/day-03/C/BLOCKERS.md
- 新增 CLEAN-SCENE-RETEST.md 和 BLIND-PLAYTEST.md

本轮完成标准见 TASK-ACCEPTANCE.md。Agent 自测不能代替 GUI 和真人试玩。
