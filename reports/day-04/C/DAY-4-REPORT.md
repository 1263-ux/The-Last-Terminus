# C｜Day 4 收尾报告（Issue #23 P0-2/P0-3/P0-5）

> 分支：`work/c-garden-closeout-1124`（基于 `main` @ `9c839ba`）
> 实例：`awc-a386001a-0356-42d8-a00f-b5b3382f8bf8`（offscreen，`--idle 240`）
> Runtime：`5d758f64`（路线/Cue）→ `59ded821`（重启复位）→ `6ff93ba8`（点光硬读数）
> 时间：2026-11-25 13:20–14:10（Asia/Shanghai）
> 源码基线：`main` = `9c839ba`（无新上游提交）

---

## 1. 本轮目标

按 Issue #23：**先把重复实例持久清理并重开复验，再在清洁场景复测路线 / 45 s Cue / 坠落恢复，交出花园 Entry/Exit 接口数据与美术资产需求卡**；不扩图、不重复已通过的基础探针。

## 2. 已完成内容（附证据）

### 2.1 持久清理（C-01，PASS）
- `scene remove` 四个重复根 + `scene save`（committed），场景 187 → **44 节点 / 4 根 / `garden-whitebox ×1`**；
- 3 个 Lua 绑定：`fall_respawn` / `backup_cue` / `garden_layer_tint`；旧 `trigger_probe` = 0；`vista_camera` 未绑定（符合"禁止脚本接管镜头"）；
- 关闭 → 重开 → 新 runtime 复验：`previewGameRoot children=4, whitebox=1`。
- 证据：`AFTER-ROOTS.md`、`after-dedup.png`、`CLEAN-SCENE-RETEST.md §1`。

### 2.2 清洁场景路线复测（C-02，**部分 FAIL**）
- **PASS 段**：入口岛 → 断桥 → 根系下坡 → 温室屋顶 → 34 级台阶 → 花冠前平台 `(115.09,76.01,139.14)`，全程连续输入、无坠落；
- **FAIL 段**：花冠观景台步行入口被 **0.56 m 台沿**（三段围栏顶面 76.56）+ 北侧 0.5 m 深槽封死，连续走路进不去；
- 证据：`walk-log.jsonl`（25 段坐标）、`c02-03-stair-top.png`、`c02-04-vista.png`、`crown-plan-section.png`。

### 2.3 45 s Backup Cue（C-07，PASS）
- 新 runtime `6ff93ba8`：`C_LightProbe` **0.15 → 8.00**，`armed=true, cues=1/3, last=light+time`（真实等待 46 s）；
- 第二个 45 s 间隔才 +1；离开区域 `armed=false`；达到上限 `cues=3/3` 不再触发；重启后 `0/3`。
- 证据：`c02-01b`、`c02-02`、`c02-11`、`CLEAN-SCENE-RETEST.md §2/§2.1`。

### 2.4 坠落恢复（PASS）
- 6 个失败点逐个实测（入口岛边缘 / 断桥缺口 / 屋顶西缘 / 台阶西侧 / 花冠台下口袋 / 云垫直落），**全部回到 `(120,70,107)`**；
- 连续四次坠落得到 `1→2→3→4`，**每次只 +1**（无旧实例的 3 连击）；
- 重启后：`0:none → 1:respawned` 仍正常。
- 证据：`CLEAN-SCENE-RETEST.md §5/§5.1`、`c02-07`。

### 2.5 接口数据（C-08，PASS）
- 机器可读：`A-INTERFACE.json`（Entry `(120,70,105)` / spawn_yaw 0°(+Z) / Exit `(120,76.01,135)` / 安全区云垫 / return target `(120,70,107)` / 路线锚点 / 阻塞）；
- A 已在 `reports/day-03/A/WORLD-INTERFACE-CONTRACT.md`（其分支 `bf95fe2`）回填并标 **CONFIRMED**（entry/return），exit 标 PARTIAL FAIL；
- 双方数值一致，双向引用已建立。

### 2.6 美术资产需求卡（P0-5）
- `ASSET-CARDS-DAY4.md`：巨花 / 倒悬温室各 3 个 Tripo 候选方向（推荐巨花 A 厚瓣托盘花、温室 A 倒置桁架玻璃房），含尺度、分件材质槽、碰撞验收、面数/贴图预算、提示词草案；
- 新增硬约束：**可跨越台阶 ≤0.45 m**、可走面中央禁 ≥0.25 m 装饰、观景点护栏须低于视线或留缺口。

### 2.7 视觉问题定位（P1）
- `TINT-AUDIT.md`：`garden_layer_tint.lua` 把三层**涂反**——入口岛被涂成屋顶青蓝（`m0` localY 19.54）、温室屋顶被涂成根绿（`m6` localY 15.75）、楼梯/屋顶/花冠共用一色（`m7` 跨 y 66–79.2）；
- 脚本源码内嵌在 `scene.data`，只改工程 `.lua` 无效 → 必须 GUI 解绑。

### 2.8 其它
- 路线计时：已知路线移动 ≈21 s / 墙钟 ≈31 s（`CLEAN-SCENE-RETEST.md §3.2`）；
- 两个裸露边界精确定位：断桥缺口斜向（`x=115, z 108.5–110.3`）、北条带北缘 `z≈142.2`；
- 可复跑自检工具 `tools/c-garden-verify.js`（一条命令输出场景数/台沿/缺口/关键地面/`overall PASS|FAIL`）。

## 3. 与设计基线的偏差

| 偏差 | 说明 |
|---|---|
| 花冠观景台步行不可达 | Day 3 `REVISION §6.1` 声称"U 形回转→观景台"走过的结论，在清洁场景**不可复现**（当时多实例污染，见 Day 3 §6.4） |
| 观景点视线 | 到达朝向 −Z，唯一地平线奖励（倒置浮空平台）在 +Z 背后；倒悬温室被花冠岛倒锥遮挡 → C-03 即使修好入口也大概率不成立 |
| 分层配色 | Day 3 §6.0b 的"解绑 tint"修复**回退**了，且是涂错层而非少色 |
| 全局出生点 | 仍在 `(119.7,80,88.6)`（地形顶），白盒在地形下、无洞 → 出生→入口不可走（Day 3 §6.6 至今未修） |

## 4. 编辑器能力 / 资产依赖

| 能力 | 结论 |
|---|---|
| CLI `scene` | 只有 import/remove/save/operation/environment —— **没有节点移动、没有脚本解绑**，出生点与 tint 只能 GUI |
| CLI `authoring` | Scene SDK 含 `nodes.*/transforms.*/scripts.*`，但作用于 **WPrefab**，不作用于主场景 |
| WPrefab 重建链路 | 已探明并只读验证：`workspace_ihycinrp` / `garden-whitebox` / `model-garden-whitebox`（threejs 源），`prefab validate` 干净（revision `d5e5b82f…`），`resource model check` = `modelType 2, nodeCount 153` |
| Tripo | 未生成（按 AGENTS.md §9 由总设计师生成）；候选方向已给 |

## 5. 阻塞与风险

见 `BLOCKERS.md`（B-01 出生点、B-02 花冠入口、B-03 配色、B-04 真人项、B-05 视线；R-01…R-06）。

## 6. 下一步建议

1. **总设计裁决**：花冠围栏方案 A（0.55→0.25 + 补西缘/北槽）与 C-03 三选一（建议 a：远景奖励移到 −Z）——批准后 C 一轮内完成重建 + 复走 + 重拍。
2. **GUI 会话**：按 `GUI-OPERATOR-CHECKLIST.md` 做三项（出生点节点、tint 解绑、或直接改花冠几何）。
3. **真人**：按 `BLIND-PLAYTEST.md` 执行卡做 1–2 名盲测 + Look-back；没有真人则维持 NOT TESTED。

---

## 附件索引

| 文件 | 用途 |
|---|---|
| `CLEAN-SCENE-RETEST.md` | 主报告（场景/路线/Cue/坠落/接口/Gate） |
| `TINT-AUDIT.md` | 分层配色逐渲染器审计 |
| `ASSET-CARDS-DAY4.md` | 巨花 / 温室 Tripo 候选需求卡 |
| `CROWN-ENTRY-FIX-PROPOSAL.md` | 花冠入口根因 + 方案 + 可执行重建命令 |
| `GUI-OPERATOR-CHECKLIST.md` | 只能 GUI 做的三项操作清单 |
| `BLIND-PLAYTEST.md` | 盲测执行卡（NOT TESTED） |
| `BLOCKERS.md` / `EVIDENCE.md` | 阻塞 / 证据索引 |
| `walk-log.jsonl` / `crown-plan-section.png` | 逐段坐标 / 决策图 |
| `AFTER-ROOTS.md` / `after-dedup.png` | 持久清理前后 |
| `evidence/day-04/C/c02-01…c02-11` | 11 张真实 runtime 截图 |
