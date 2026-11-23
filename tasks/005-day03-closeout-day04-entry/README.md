# TASK PACK 005｜Day 3 收尾 → Day 4 入场

> 项目：《天空列车的最后一站》  
> 阶段：Day 3 Closeout → Day 4 Entry  
> 任务状态：READY FOR EXECUTION（按本包执行；最终 Gate 仍由总设计师判定）  
> 适用成员：A 技术与集成、B 书桌站、C 失重花园  
> 目标：关闭当前 P0 体验缺口，完成跨成员资产交接，确定是否允许进入 Day 4 的单个代表性 Tripo 资产验证。

## 1. 本包为什么是新的

本包根据 2026-11-23 远端最新证据重写，不沿用已经过时的判断。

### 最新事实基线

| 成员 | 最新已核对状态 | 本轮真正要做的事 |
|---|---|---|
| A | PR #12，HEAD b11bfdc；已形成 GLB、WPRE、Trigger/Lua、音频技术参考；WPRE 跨成员导入仍未得到回执；115m 连续路线仍 INCONCLUSIVE | 修正并实测 C4 通用门禁示例；完成 B/C 资产交接；更新接口契约和集成方案；音频做真实听感验证 |
| B | PR #10，HEAD a53c627；最新提交已解决玩家视角渲染问题，根因是物体超出相机可见角度，不是引擎不渲染 | 不再重复渲染排查；完成 REST→RAMP 玩家主动交互、六段坡道切换、路线状态门禁、实际通过和小镇反馈 |
| C | PR #11，HEAD 692e547；Plan C 空间白盒、路线和多项技术探针已有证据；观景点来路视线仍未稳定通过，盲测未完成 | 不扩图；完成观景点、正常 Look-back、两名独立试玩、45 秒 Backup Cue、坠落恢复和接口交接 |

注意：
- B 的玩家视角渲染当前标记为 PASS；不得再把“引擎不渲染几何体”作为当前事实。
- B 的物理阻挡仍不可依赖；渲染通过不等于物理碰撞通过。
- A 的 API 接受播放命令不等于人耳确认播放成功。
- C 的技术探针通过不等于玩家能够无提示发现路线。
- Agent 自检不等于总设计师 Gate 通过。

## 2. 必读入口

开始前依次阅读：
1. 根目录 AGENTS.md
2. production/DESIGN-DIRECTOR-DECISIONS-2026-11-22.md
3. production/prompts/DAY-03-REVISION-AND-DAY-04-ENTRY-GATE.md
4. production/EDITOR-TECHNICAL-FINDINGS.md
5. production/TEAM-ROLES.md
6. production/INTEGRATION-CONTRACT.md
7. 本目录 COMMON-ACCEPTANCE.md
8. 自己对应的 PROMPT-A.md / PROMPT-B.md / PROMPT-C.md
9. 自己的原始世界任务包和视觉参考板

## 3. 三份 Agent 提示词

- [A｜技术集成与共享交付](./PROMPT-A.md)
- [B｜书桌站可玩闭环](./PROMPT-B.md)
- [C｜失重花园体验验收](./PROMPT-C.md)

每份提示词均可整段复制到对应成员的 Agent。提示词不是让 Agent 代替人操作编辑器：凡涉及 GUI、真实运行、真实试听、真人试玩，必须由成员本人完成并提交证据。

## 4. 参考设计板

- [统一参考设计与空间示意](./VISUAL-REFERENCE-BOARDS.md)
- [A 原有视觉参考图库与空间方向](../../tasks/002-a-train-core/ART-DIRECTION.md) · [成熟项目参考](../../tasks/002-a-train-core/REFERENCES.md)
- [B 书桌站模块级视觉参考板](../../tasks/003-b-desk-world/VISUAL-REFERENCE-BOARD.md)
- [C 失重花园模块级视觉参考板](../../tasks/004-c-floating-garden/VISUAL-REFERENCE-BOARD.md)

这些图是设计研究和构图参考，不是让 Agent 复制他人作品，也不是可直接导入的生产模型。

## 5. 执行顺序

1. A 先修正 C4 门禁示例，并把可复用版本交给 B。
2. B 在最新 C4 可见场景上完成真实玩家闭环。
3. C 同时完成观景点、Backup Cue、盲测准备和接口交付。
4. A 与 B/C 并行完成 GLB/WPRE 跨成员交接；A 收敛 World Interface Contract。
5. 三人提交证据后，由总设计师按 COMMON-ACCEPTANCE 进行 Review。

依赖阻塞时必须局部化：例如 B 等 A 的脚本时，可先完成 GUI 交互绑定探针、节点命名和 REST/RAMP 视觉准备；C 等测试者时，可继续修正视线、计时器和 Entry/Exit，但不能把未做的盲测标成 PASS。

## 6. Day 4 的权限边界

本包通过不等于允许批量 Tripo 生产。

Day 4 只允许：
- 由总设计师批准一个代表性 Hero Asset。
- 完成一次真实 Tripo 导出。
- Blender 检查和造世界导入验证。
- 形成视觉/材质/比例/文件体积基线。

代表性资产通过总设计师 Review 后，才批准同类资产批量生产。



> **状态更新（2026-11-23）：** 本任务包是 Day 3 基线与初版 Gate；《桌面以下》成熟资产复用和 A/B/C 最新剩余工作，以 [TASK PACK 006](../006-below-the-desk-asset-reuse/README.md) 为当前执行依据。两者冲突时，以 TASK PACK 006 的最新资产结构和验收口径为准，尤其不再强制要求尺子桥必须拆成 6 个独立坡道节点。
