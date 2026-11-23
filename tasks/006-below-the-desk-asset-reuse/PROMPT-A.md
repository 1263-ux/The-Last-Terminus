# PROMPT A｜公共技术与资产集成支持

你是《天空列车的最后一站》的 A：Train & Integration Lead。你负责公共技术、跨成员 GLB/WPRE 交接、世界接口与最终集成。PR #12 已合并；不要重复已有探针。

## 必读
- AGENTS.md
- production/DESIGN-DIRECTOR-DECISIONS-2026-11-22.md
- production/EDITOR-TECHNICAL-FINDINGS.md
- production/INTEGRATION-CONTRACT.md
- tasks/005-day03-closeout-day04-entry/COMMON-ACCEPTANCE.md
- tasks/006-below-the-desk-asset-reuse/BELOWTHEDESK-DESIGN-BASIS.md
- tasks/006-below-the-desk-asset-reuse/ASSET-IMPORT-MANIFEST.md
- tasks/006-below-the-desk-asset-reuse/TASK-ACCEPTANCE.md
- 本文件

## A1｜修订 C4 通用状态门禁示例

当前 tools/c4_complete_gate.js 是技术示例，不能直接给 B 用。

1. 阅读 B 当前 reports/day-03/B/C4-PLAYABLE-LOOP.md 和最新节点表。
2. 参数化场景配置，不写死 A 的出生点/解锁区/门禁区。
3. 支持一个完整 GLB root（内部多个 mesh children）或显式多个 RAMP_NODE_NAMES。
4. REST 与完整桥体互斥显示；激活后确保桥体所有 mesh 显示。
5. 正常出生 activated=false，不得出生自动解锁。
6. 未解锁越界回安全点，已解锁可通过；冷却/去抖防止连续传送。
7. 状态在同一个已验证脚本实例内管理。
8. 交互入口优先复用 C 已验证的 GUI Trigger + Lua 绑定流程。
9. A 自己工程 PASS 后交给 B 在 Desk 工程复测；A 的 PASS 不能替代 B 接收方 PASS。

## A2｜BelowTheDesk 资产包导入支持

总设计师另行交付 BelowTheDesk-造世界编辑器资产交接包-v1.0.zip。按 ASSET-IMPORT-MANIFEST.md 核验 SHA，不要重导或覆盖原文件。

帮助 B 确认：
- Blender Z-up 到目标 Y-up 的转换；
- GLB X 镜像、原点、尺寸和旋转；
- town-row 的 44 部件层级；
- ruler-bridge 的 6 mesh 和嵌入 PNG 刻度；
- cup-harbor 的嵌入 PNG；
- 材质槽、透明度、emissive 在目标运行时是否保留。

不要将 Three.js/Blender 加载成功当成造世界编辑器加载成功。

## A3｜修正 Garden 场景级出生点错位（P0）

C 的 reports/day-03/C/REVISION.md 记录：
- 场景级出生点约 (119.7, 80, 88.6)；
- Garden 白盒宿主约 (120, 50, 115)；
- 入口岛可走面约 (120, 70, 105)；
- 玩家出生在白盒前方并高于可走面，落地后很快走到空区。

这是场景级集成问题，不是 C 的 WPrefab 内部坐标问题。

操作：
1. 在当前 Garden 项目 GUI/runtime 复核实际出生点、白盒入口岛可走面和朝向。
2. 与 C 确认入口岛安全落脚点和出生 yaw。
3. 修正全局 Spawn/Entry anchor，使玩家从新 runtime 启动就落在安全入口岛，不在空中、不需要 CLI 传送。
4. 保存、关闭、重新打开后再测。
5. 连续从出生点走出入口岛，确认不会在几米后掉空。
6. 更新 World Interface Contract 的 Garden Entry、spawn_yaw、safe zone、return target。
7. 不得直接照抄报告坐标；先复测当前场景是否已改变。

## A4｜技术报告和接口

- 115m 连续行走保持 INCONCLUSIVE，除非真实连续走通。
- 音频导入/绑定/API play 与人耳听到分层记录。
- WPRE 跨成员未完成前保持 NOT TESTED。
- Desk/Garden Entry、Exit、spawn_yaw、安全区和 return target 必须是运行时实测值。
- 若 B 的桥体是单 GLB root，按 root 切换，不要求拆成 6 个独立坡道段。

## A5｜交付

在 feature/train-core 继续：
- tools/c4_complete_gate.js 修订版；
- reports/day-03/A/REVISION.md；
- reports/day-03/A/INTEGRATION-KIT-HANDOFF.md；
- reports/day-03/A/WORLD-INTERFACE-CONTRACT.md 更新；
- Garden 场景级出生点修正前后证据；
- GLB/WPRE 导入矩阵和真实证据；
- Commit SHA、未决事项和给 B/C 的交接。

所有结果标 PASS / FAIL / NOT TESTED / INCONCLUSIVE。不要宣布总 Gate 通过。
