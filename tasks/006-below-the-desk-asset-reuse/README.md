# TASK PACK 006｜《桌面以下》成熟资产复用与 A/B/C 当前 Gate

> 版本：v1.0 · 2026-11-23  
> Owner：A 公共技术 / B 书桌站 / C 失重花园  
> 设计决策权：总设计师  
> 本轮目标：将《桌面以下》精简档案中的已验收 GLB 资产转入造世界编辑器生产流程，同时关闭 A/B/C 当前剩余 P0 验收项。

## 1. 重要判断

用户提供的 `BelowTheDesk-精简档案-2026-11-20` **足以显著解决 B 的成熟美术资产供给问题**，尤其是：
- 完整尺子桥；
- 铅笔盒小镇街区；
- 单体店铺；
- 杯岸港口；
- 台灯；
- 已经通过独立评审的桌面场景组合。

它**不是完整的造世界编辑器工程**，也不代表所有 GLB 已在新版造世界编辑器通过导入。Blender 的 ACCEPTED 是资产生产验收，不是目标编辑器的运行时验收。

本任务包将资产复用和编辑器验收明确拆开，避免重新从 0 建模，也避免把“GLB 文件存在”当成“游戏已经完成”。

## 2. 资产交接包

总设计师已整理独立交接包：

**`BelowTheDesk-造世界编辑器资产交接包-v1.0.zip`**

该包包含 7 个精选 GLB、两张原始参考板、SHA-256 清单和独立评审/来源记录。它通过本次对话另行交给团队；**当前 Git PR 只提交任务和清单，不包含二进制 GLB**。\n\n- ZIP 大小：6,129,570 bytes\n- ZIP SHA-256：`01d072018c241158049b7ac8566f6f6107e488e43953f56b04e21a0ac2e7183b`\n- 下载：由总设计师在对话中另行提供 `BelowTheDesk-造世界编辑器资产交接包-v1.0.zip`。

开始 B 任务前，必须把 ZIP 放入 B 的本地工作区。找不到 ZIP 时，报告 `BLOCKED: ASSET_KIT_NOT_PRESENT`，不要自己重新建模或从网络找同名模型替代。

## 3. 必读

1. 根目录 `AGENTS.md`
2. `production/DESIGN-DIRECTOR-DECISIONS-2026-11-22.md`
3. `production/prompts/DAY-03-REVISION-AND-DAY-04-ENTRY-GATE.md`
4. `production/INTEGRATION-CONTRACT.md`
5. `tasks/005-day03-closeout-day04-entry/COMMON-ACCEPTANCE.md`
6. 本目录 `ASSET-IMPORT-MANIFEST.md`、`TASK-ACCEPTANCE.md`
7. 自己的专属提示词 `PROMPT-A.md`、`PROMPT-B.md` 或 `PROMPT-C.md`
8. 原世界任务包和最新主线报告。

## 4. 当前远端基线（已合并 PR）

| PR | 内容 | 当前结论 |
|---|---|---|
| #15 | Day 3 收尾 / Day 4 入场任务包 | 已合并 |
| #12 | A 技术探针、Hub/Terminus 白盒、接口和音频发现 | 已合并；部分技术结论仍 INCONCLUSIVE / NOT TESTED |
| #10 | B 书桌站资产审计、白盒、玩家视角可见性修复、C4 状态逻辑 | 已合并；玩家视角完整闭环仍未通过 |
| #11 | C Plan C、路线实走、Backup Cue 和复位证据 | 已合并；真人 GUI free-look 和两名独立玩家盲测仍 NOT TESTED |

合并表示把有效成果纳入 main，不代表成员 Gate 自动通过。

## 5. 三人本轮责任

- **A：公共技术和集成支持。** 修正 C4 状态切换示例，使其支持单个完整 GLB 根节点或多子节点组；提供目标编辑器 GLB 导入检查；整理坐标、材质/贴图和跨成员交接边界。
- **B：书桌站资产集成与可玩闭环。** 复用精选资产，不从零建模；在造世界编辑器实测导入、适配和玩家视角；完成尺子 REST → RAMP → 小镇的主动交互闭环。
- **C：失重花园最终体验验收。** 不扩图；清理重复白盒/重叠 Trigger 实例；在干净场景复测路线、45 秒提示和坠落恢复；完成真人 GUI free-look 与两人盲测。

详细执行见各自提示词：[A](PROMPT-A.md) · [B](PROMPT-B.md) · [C](PROMPT-C.md)。

## 6. 生产顺序

1. B 收到 ZIP 后先核 SHA 并做 GLB 导入烟雾测试；优先测试无纹理的 `town-row-v02` / `shopfront-v02`，再测带嵌入 PNG 的 `ruler-bridge-full-v01`。
2. A 审查 B 的导入结果、轴向和状态脚本；不把 A 自己工程的导入结果冒充 B 的跨成员结果。
3. B 将可用资产放进实际玩家场景，完成主动交互和连续通行。
4. C 清理重复实例后完成真人体验验收。
5. 总设计师依据 `TASK-ACCEPTANCE.md` 进行 Day 4 Go/No-Go。

## 7. Day 4 资产生产边界

本轮先复用现成资产，禁止大规模重新生成 Tripo 模型。允许：
- 资产导入、缩放、旋转、分组和轻量摆位；
- 为编辑器创建独立的碰撞代理/交互 Trigger；
- 经过 Review 后对现有 GLB 做必要的适配副本。

不允许：
- 未经批准重建整套书桌资产；
- 覆盖或修改原始 GLB；
- 未验证贴图解码就宣布资产可交付；
- 以自由视角漂亮截图代替玩家视角验证。

最终只在确实缺少的关键 Hero Asset 上提出新 Tripo 需求卡。
