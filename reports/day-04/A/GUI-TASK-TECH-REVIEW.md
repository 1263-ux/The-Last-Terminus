# A｜C 的 GUI 任务：A 侧独立技术核验

> Owner：成员 A（全项目技术集成）
> 日期：2026-11-24
> 依据：Issue #23、C 的 `GUI-OPERATOR-CHECKLIST.md`（`work/c-garden-closeout-1124` @ `263ff6e`）
> 性质：**只读核验 + 技术判断**，不代替 GUI 操作，不修改 C 的场景。

---

## 0. 一句话

C 列出三项只能由有 GUI 的人做的任务。A **独立复核确认 CLI 确实无对应能力**，
并逐项给出技术判断与 A 侧接口影响。三项的**执行权**在 GUI 操作者，A 提供技术依据与复验口径。

---

## 1. CLI 能力边界独立核验（TESTED，2026-11-24）

复核命令：`douyin-world scene --help`、`douyin-world authoring --help`、`douyin-world --help`（1.0.104）。

| 需求 | CLI 是否有能力 | 结论 |
|---|---|---|
| 移动场景级节点 Transform | `scene` 只有 `import/remove/save/operation/cancel/environment get-set/player-animation` | **❌ 无** |
| 脚本解绑 | 无 `unbind` 类命令；`prefab execute` 只作用于**作者 prefab**，非运行场景全局节点 | **❌ 无** |
| 改场景级几何（围栏高度等） | 需走 WPrefab 重建链路（`static/preview-module.js` → check/archive → attach/build → scene import/remove） | ⚠️ 只适用于** prefab 内几何**，非场景原生节点 |
| 保存 / 环境参数 | `scene save` / `scene environment set` | ✅ 有 |

**结论**：C 的判断成立——全局 `出生点` 移动、`garden_layer_tint` 解绑**必须 GUI**；
围栏几何若已封进 WPrefab 可由 C 走重建链路，但若作为场景原生节点则同样需 GUI。

---

## 2. 三项任务 A 侧判断

### 2.1 B-01 全局出生点 → (120,70,105)
- **A 侧确认**：A 自己的工程全局 `出生点` 也在 (119.74,80,88.64)（见 `HUB-ENTRY-BASELINE.md`），
  与 C 报告同坐标族——这是**四个世界共用的初始出生点**，一次修复对 Hub/Desk/Garden/Terminus 连接都有益。
- **技术依据**：Garden 入口岛可走面 y=70.05，玩家落 y=70.00；出生点必须落到该面，不能靠 CLI teleport 冒充。
- **验收口径**（A 认同 C）：新 runtime `≈(120,70,105)`、不传送、按 W 直接上入口岛；保存→关闭→重开复验。
- **A 的额外关注**：修完后要确认从该点能看到正确的 first landmark（spawn_yaw 0°=+Z），供四世界连接接线。

### 2.2 解绑 garden_layer_tint.lua
- **技术依据**：脚本内嵌在 `scene.data` 的 `runtimeScripts`，改工程目录 `.lua` 文件无效，必须 GUI 解绑——A 独立确认此机制与 A 的 Lua 状态研究一致（`runtimeScripts` 与节点绑定分离）。
- **A 侧影响**：配色恢复 9 色后，Desk/Garden 连接的视觉基线更清晰；A 无异议，属 C 的场景内事务。
- **验收**：`_BaseColor` 去重 ≥ 6 色，三层可读，前后截图。

### 2.3 花冠观景台入口（待总设计批准方案 A）
- **A 侧确认硬约束**：可跨越台阶上限 **0.45 m**（C 实测，已回填进 A 的契约 §1 几何判定规则）。
  围栏顶 26.555 与台面 26.00 高差 0.555 m > 0.45 m → 确实挡死，方案 A（0.55→0.25）合理。
- **接口影响**：`garden.exit/vista` 当前 PARTIAL FAIL；修复后需重新验收才能从 PARTIAL 升 CONFIRMED，
  A 的契约该行随之更新。
- **执行权**：有 GUI 的人改场景原生几何，或 C 走 WPrefab 重建链路；A 不介入 C 的场景二进制（Issue #23 §9 禁止多 Agent 同改一场景）。

---

## 3. A 侧结论与下一步

1. **不越权**：三项均不由 A 执行（A 无 GUI 会话，且禁止多 Agent 同改 C 场景）。
2. **技术背书**：A 已独立确认 CLI 限制、出生点同坐标族、0.45 m 跨越上限、runtimeScripts 绑定机制——C 的技术判断与 A 的研究一致。
3. **待 GUI 会话后 A 的动作**：
   - B-01 修复后，A 用 C 的 Entry `(120,70,105)` 接 Hub→Garden 连接（Trigger+Teleport，非 CLI teleport）；
   - 2.3 修复后，A 把契约 `garden.exit/vista` 从 PARTIAL 升 CONFIRMED；
   - 统一在完整旅程 Alpha（11/26 12:00）中复验。

**本轮不修改任何场景**，只做只读核验与技术判断。
