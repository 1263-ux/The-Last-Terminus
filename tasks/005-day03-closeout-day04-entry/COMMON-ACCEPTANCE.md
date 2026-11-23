# COMMON ACCEPTANCE｜Day 3 收尾与 Day 4 入场验收

> B 的最新资产结构和完整垂直切片要求，以 [TASK PACK 006](../006-below-the-desk-asset-reuse/README.md)、[设计基线](../006-below-the-desk-asset-reuse/BELOWTHEDESK-DESIGN-BASIS.md) 和 [TASK-ACCEPTANCE](../006-below-the-desk-asset-reuse/TASK-ACCEPTANCE.md) 为准。尺子桥可以是一个 GLB root 或多个子节点，不强制六段独立节点。

## 0. 状态标签

每项只能使用：
- PASS：按指定运行模式真实复测通过，证据可复现。
- FAIL：真实复测失败。
- NOT TESTED：尚未执行，不能推断。
- INCONCLUSIVE：执行过，但证据不足或测试中断。
- WAIVED：总设计师明确书面豁免，并记录风险。

“代码存在”“API 返回成功”“编辑器视口截图”“Agent 自评”都不能自动等于玩家体验 PASS。

## 1. A｜技术集成验收

| ID | 验收项 | PASS 标准 |
|---|---|---|
| A-01 | C4 门禁示例 | 支持完整 GLB root 或显式节点列表；参数化场景区域/返回点/yaw；不出生自动解锁 |
| A-02 | 状态门禁 | 未解锁越界安全返回；主动交互后完整桥体显示；已解锁可通过；去抖/冷却有效 |
| A-03 | 技术报告 | 碰撞、路线、音频、WPRE 状态一致；115m 连续行走保持 INCONCLUSIVE，除非重测 |
| A-04 | GLB 跨成员 | 接收方在自己工程导入、保存、重开并运行 |
| A-05 | WPRE 跨成员 | 接收方在自己工程导入，检查层级/依赖/脚本/交互并运行 |
| A-06 | World Interface Contract | Desk/Garden Entry、Exit、spawn_yaw、安全区和 return target 均为运行时实测 |
| A-07 | Garden 全局出生点 | 修复场景出生点与入口岛错位；新 runtime 出生在安全可走面 |
| A-08 | 音频 | 区分导入、绑定、API play 与人耳实际听到 |
| A-09 | 集成方案 | Hub → Desk → Garden → Terminus 的进入/离开/恢复方案可执行，不宣称未验证无缝切换 |

## 2. B｜书桌站

B 的完整验收以 [TASK PACK 006 TASK-ACCEPTANCE.md](../006-below-the-desk-asset-reuse/TASK-ACCEPTANCE.md) 为准，包含：
- 7 个精选资产的 SHA 和目标编辑器导入矩阵；
- 玩家视角可见；
- REST → 完整桥体主动状态切换；
- 连续玩家通行到小镇；
- 世界反馈、恢复和保存重开；
- 5–8 分钟完整垂直切片及未参与设计者试玩。

不得再把“六段独立坡道节点”作为硬性要求。

## 3. C｜失重花园

保持 Plan C，不扩图：
入口浮岛 → 断桥/路线线索 → 根系路线 → 倒悬温室屋顶 → 花冠观景点。

当前剩余验收：
- 清理重复 garden-whitebox、重叠云垫和重复 Trigger，并保存重开验证；
- 清洁场景全路线连续实走；
- 默认到达视角看到下一目标；
- 真人 GUI 正常 Look-back 后 3 秒内识别来路；无自由 Look 时用物理回转方案；
- 至少两名独立玩家无口头提示盲测；
- 清洁场景下重新验证 45 秒 Backup Cue、one-shot/debounce 和重开恢复；
- 提供真实 Entry/Exit、spawn_yaw、安全区和 return target。

技术探针或 Agent 自测不能替代 GUI 和真人试玩。

## 4. Day 4 Go / No-Go

GO 仅允许进入一个代表性资产/样板场景精修，必须同时满足：
- [ ] B 核心桥体在目标编辑器导入，贴图/材质/玩家视角通过；
- [ ] B REST → 完整桥体 → 连续通行 → 小镇反馈闭环通过；
- [ ] B 完整 5–8 分钟垂直切片由未参与设计者试玩并记录真实用时；
- [ ] A 的共享脚本/资产交接约束稳定，Garden 场景级出生点修正通过；
- [ ] C 清洁场景路线和观景点真实 GUI 验收通过；
- [ ] C 两人盲测通过，或总设计师书面批准仅先做单个代表性资产样板；
- [ ] 至少一次跨成员资产导入成功。

不通过时只修局部，不推翻整个项目；未测试项必须如实标注。
