# PROMPT A｜公共技术与资产集成支持

你是《天空列车的最后一站》的 A：Train & Integration Lead。你负责公共技术、跨成员 GLB/WPRE 交接、世界接口与最终集成。当前 PR #12 已合并；不要继续重复已有探针。

## 必读
- AGENTS.md
- production/DESIGN-DIRECTOR-DECISIONS-2026-11-22.md
- production/EDITOR-TECHNICAL-FINDINGS.md
- production/INTEGRATION-CONTRACT.md
- tasks/005-day03-closeout-day04-entry/COMMON-ACCEPTANCE.md
- tasks/006-below-the-desk-asset-reuse/ASSET-IMPORT-MANIFEST.md
- tasks/006-below-the-desk-asset-reuse/TASK-ACCEPTANCE.md
- 本文件

## A1｜修订 C4 通用状态门禁示例

当前 `tools/c4_complete_gate.js` 只配置 `C4_RAMP_1`，并带有 A 测试坐标和 Z 阈值，不能直接给 B 用。

修订要求：
1. 先阅读 B 当前 `reports/day-03/B/C4-PLAYABLE-LOOP.md` 和 `REVISION.md`。
2. 将参数改为明确的场景配置，不写死 A 的出生点/解锁区/门禁区。
3. 支持两种桥体层级：
   - 一个 `RULER_BRIDGE_ROOT`（GLB 根节点，内部有多个 mesh children）；
   - 多个显式 `RAMP_NODE_NAMES`。
4. REST 与完整桥体做互斥显示；激活后必须确保桥体全部 mesh 显示。
5. 正常出生 `activated=false`，不得出生自动解锁。
6. 未解锁越界回安全点，已解锁可通过；冷却/去抖防止连续传送。
7. 状态必须在同一个已验证脚本实例内管理；不依赖未验证的跨绑定全局变量。
8. 交互入口优先复用 C 已验证的 GUI Trigger + Lua 绑定流程；若 B 项目无法复现，记录精确限制和降级提案。

在 A 自己的最小工程做单元验证后，交给 B 在 Desk 工程实测。A 的测试 PASS 不能替代 B 的接收方 PASS。

## A2｜为 BelowTheDesk 资产包提供导入技术支持

总设计师另行提供 `BelowTheDesk-造世界编辑器资产交接包-v1.0.zip`。按 `ASSET-IMPORT-MANIFEST.md` 核验 SHA，不要自行重新导出/改写原文件。

优先帮助 B 确认：
- Blender GLB 轴向/编辑器 X 镜像；
- 米制尺寸与导入缩放；
- town-row 的 44 部件层级；
- ruler-bridge 的 6 mesh 与嵌入 PNG 刻度；
- cup-harbor 的嵌入 PNG；
- 材质槽/透明度/emissive 在目标运行时是否保留。

不要将 Three.js/Blender 加载成功当成造世界编辑器加载成功。

## A3｜更新技术报告和 World Interface Contract

- 保留 115m 连续行走 INCONCLUSIVE，除非真实连续走通。
- 音频导入/绑定/API play 与人耳听到分层记录。
- WPRE 跨成员未完成前保持 NOT TESTED。
- Desk/Garden Entry、Exit、spawn_yaw、安全区和 return target 必须来自 Owner 的运行时测量；不能从 Three.js 源坐标推算。
- 若 B 的桥体是单 GLB root，接口和脚本按 root 处理，不要求拆成 6 个坡道段。

## A4｜交付

在 `feature/train-core` 继续：
- `tools/c4_complete_gate.js` 修订版；
- `reports/day-03/A/REVISION.md`；
- `reports/day-03/A/INTEGRATION-KIT-HANDOFF.md`；
- `reports/day-03/A/WORLD-INTERFACE-CONTRACT.md` 更新；
- GLB/WPRE 导入矩阵和真实证据；
- Commit SHA、未决事项和给 B 的明确交接。

所有结果标 PASS / FAIL / NOT TESTED / INCONCLUSIVE。不要宣布总 Gate 通过。
