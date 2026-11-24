# TASK PACK 006｜《桌面以下》成熟资产复用与 A/B/C 当前 Gate

> 版本：v1.1 · 2026-11-23  
> Owner：A 公共技术 / B 书桌站 / C 失重花园  
> 设计决策权：总设计师  
> 本轮目标：将《桌面以下》成熟资产与源设计基线接入造世界编辑器生产流程，同时关闭 A/B/C 当前剩余 P0 验收项。

## 1. 重要判断

用户提供的精简档案足以显著解决 B 的成熟美术资产供给问题，尤其是完整尺子桥、铅笔盒小镇街区、单体店铺、杯岸港口和台灯。

它不是完整的造世界编辑器工程，也不代表所有 GLB 已在新版造世界编辑器通过导入。Blender 独立评审是资产生产验收，不是目标编辑器的运行时验收。

本轮执行以以下文档为准：
- [源设计基线与编辑器适配](BELOWTHEDESK-DESIGN-BASIS.md)
- [目标编辑器资产导入清单](ASSET-IMPORT-MANIFEST.md)
- [逐项验收与 Day 4 Gate](TASK-ACCEPTANCE.md)
- [A 提示词](PROMPT-A.md) · [B 提示词](PROMPT-B.md) · [C 提示词](PROMPT-C.md)

## 2. 资产交接包

**文件名：** BelowTheDesk-造世界编辑器资产交接包-v1.0.zip

- 大小：6,170,533 bytes
- SHA-256：ec1ed090612f7a070c83bd7034457f2e9f07cd94c24900d4ab7cae12437d362a
- 内容：7 个精选 GLB、两张原始视觉参考板、源设计文档、资产来源/评审记录、SHA 清单和 Web 原型验证说明。
- 下载：由总设计师在团队执行消息中附交接包。

开始 B 任务前，必须把 ZIP 放入 B 的本地工作区。找不到 ZIP 时，报告 BLOCKED: ASSET_KIT_NOT_PRESENT，不要自己重新建模或从网络找同名模型替代。

## 3. 必读

1. 根目录 AGENTS.md
2. production/DESIGN-DIRECTOR-DECISIONS-2026-11-22.md
3. production/prompts/DAY-03-REVISION-AND-DAY-04-ENTRY-GATE.md
4. production/INTEGRATION-CONTRACT.md
5. tasks/005-day03-closeout-day04-entry/COMMON-ACCEPTANCE.md
6. 本目录 BELOWTHEDESK-DESIGN-BASIS.md、ASSET-IMPORT-MANIFEST.md、TASK-ACCEPTANCE.md
7. 自己的专属提示词 PROMPT-A.md / PROMPT-B.md / PROMPT-C.md
8. 原世界任务包和最新主线报告

## 4. 当前远端基线（已合并 PR）

| PR | 内容 | 当前结论 |
|---|---|---|
| #15 | Day 3 收尾 / Day 4 入场任务包 | 已合并 |
| #12 | A 技术探针、Hub/Terminus 白盒、接口和音频发现 | 已合并；部分技术结论仍 INCONCLUSIVE / NOT TESTED |
| #10 | B 书桌站资产审计、白盒、玩家视角可见性修复、C4 状态逻辑 | 已合并；玩家视角渲染问题已解决，完整玩家闭环仍未通过 |
| #11 | C Plan C、路线实走、Backup Cue 和复位证据 | 已合并；重复实例清理、真人 GUI free-look 和两名独立玩家盲测仍待完成 |
| #16 | BelowTheDesk 资产复用与 A/B/C 最新 Gate | 已合并 |

合并表示把有效成果纳入 main，不代表成员 Gate 自动通过。

## 5. 三人本轮责任

- **A：公共技术和集成支持。** 修正 C4 状态切换示例，使其支持单个完整 GLB 根节点或多子节点组；提供目标编辑器 GLB 导入检查；修正 Garden 场景级出生点/入口契约；整理坐标、材质/贴图和跨成员交接边界。
- **B：书桌站资产集成与可玩闭环。** 复用精选资产，不从零建模；在造世界编辑器实测导入、适配和玩家视角；按源 GDD 完成约 5–8 分钟垂直切片，核心是尺子改造、实际过桥和小镇反馈。
- **C：失重花园最终体验验收。** 不扩图；清理重复白盒/重叠云垫/重复 Trigger 实例；在干净场景复测路线、45 秒提示和坠落恢复；完成真人 GUI free-look 与两人盲测。

## 6. 生产顺序

1. B 收到 ZIP 后先核 SHA 并做 GLB 导入烟雾测试；优先测试无纹理的 town-row-v02 / shopfront-v02，再测带嵌入 PNG 的 ruler-bridge-full-v01。
2. A 审查 B 的导入结果、轴向和状态脚本；不把 A 自己工程的导入结果冒充 B 的跨成员结果。
3. B 将可用资产放进实际玩家场景，完成主动交互、连续通行和完整切片。
4. A 修复 Garden 场景级出生点错位并更新 World Interface Contract。
5. C 清理重复实例后完成真实 GUI 和真人体验验收。
6. 总设计师依据 TASK-ACCEPTANCE.md 进行 Day 4 Go/No-Go。

## 7. Day 4 资产生产边界

本轮先复用现成资产，禁止大规模重新生成 Tripo 模型。允许资产导入、缩放、旋转、分组和轻量摆位；允许为编辑器创建独立的碰撞代理/交互 Trigger；允许经 Review 后制作必要的适配副本。

不允许未经批准重建整套书桌资产、覆盖原始 GLB、未验证贴图解码就宣布资产可交付，或以自由视角漂亮截图代替玩家视角验证。

最终只在确实缺少的关键 Hero Asset 上提出新 Tripo 需求卡。
