# 需要 GUI 会话才能做的三件事（操作清单）

> 背景：`garden_layer_tint` 解绑、全局出生点、围栏几何这三项，CLI 没有对应 API（`scene` 只有 import/remove/save/environment），
> 必须有**真实 GUI 会话**的人来做。本文件把要做的事、步骤和验收写死，交给有 GUI 的成员或总设计执行；
> 每一项做完我都能用 `tools/c-garden-verify.js` + 读数复核。

---

## 1. 全局出生点：`出生点` 节点 → `(120, 70, 105)`

**为什么**：现在 `出生点` 在 `(119.7, 80, 88.6)`，玩家落在**地形顶** `(119.74, 78.38, 88.64)`；
花园白盒在**地形面以下**（路线 `y 66–76`，地形顶 `77.90–78.31`，全图无地形洞），从出生点**走不到入口岛**。
（Day 3 §6.6 已报，A 也确认无法在无 GUI 下修。）

**步骤**
1. 打开工程 `project-8e9f55c1`（主场景）。
2. 在层级里选中 `出生点` 节点（id `-235524988`）。
3. 把它的 Transform 位置改成 **`(120, 70, 105)`**（贴着入口岛可走面 `y=70.05`）。
4. `scene save`（或 GUI 保存）。
5. 关闭实例 → 重开 → 新 runtime。

**验收（必须做）**
- 新 runtime 出生后 `Player_1` 位置 ≈ `(120.00, 70.00, 105.00)`（不是 78.x）；
- 出生后**不传送**、连续按 W 能走上入口岛并越过断桥（`x≈117` 车道）；
- 复用命令：`douyin-world runtime js eval --file tools/c-garden-verify.js`，`scene.gardenWhiteboxCount=1`、出生点读数正确。

> 注意：**不要**只改 WPrefab 局部坐标；这是场景级节点。

---

## 2. 解绑 `garden_layer_tint.lua`（恢复 9 色分层）

**为什么**：脚本按 `renderer.bounds.center.y` 分层，但合并网格后 bounds 跨层（y 44–78），
所有网格被压到 3 个颜色档；Day 3 §6.0b 已判定应改用 GLB 原生材质（当时是 9 色）。

**现状证据**：`Model` 节点 `-1628462626` 上绑定 `garden_layer_tint.lua`（`enabled=true`）；
runtime 读 `_BaseColor` 只有 3 色（`#71,122,76` / `#51,107,140` / `#122,92,158`）。

**步骤**
1. 选中 `garden-whitebox` 下的 `Model` 节点（`-1628462626`）。
2. 在脚本/绑定面板里**解绑（unbind）** `garden_layer_tint.lua`（保留 `backup_cue`、`fall_respawn` 不动）。
3. 保存 → 关闭 → 重开 → 新 runtime。

**验收**
- runtime `_BaseColor` 去重后颜色数 **≥ 6**（Day 3 原生为 9）；
- 从入口岛内看：根层绿 / 温室层青蓝 / 花冠层紫 三层可读；
- 截图前后各一张，存 `evidence/day-04/C/`。

---

## 3. 花冠观景台入口（需总设计先批准方案）

**为什么**：`VistaRail_Left/Right/Back` 高 `0.55 m`（顶面 `26.555`，台面 `26.00`，高差 **0.555 m** > 0.45 m 跨越上限），
三面围死 → 观景台**没有步行入口**。另外北侧 `z=140, x≥117.5` 有 0.5 m 深槽、西缘 `x116.5–117.5` 有缺口。

**推荐的方案 A（`reports/day-04/C/CROWN-ENTRY-FIX-PROPOSAL.md` §2）**
- 围栏 `h 0.55 → 0.25`、中心 `y 26.28 → 26.125`；
- 补 `VistaEdgeFill`（西缘）与 `VistaSlotFill`（北槽）两块地板；
- （可选兜底）台下加 `C_CrownUnderZone` 复位体，复用 `fall_respawn.lua`。

**批准后谁做**：
- 有 GUI 的人：直接在编辑器里改 `Model` 白盒几何并保存；
- 或让 C 做：C 已探明重建链路（`workspace_ihycinrp` / `garden-whitebox` / `model-garden-whitebox`），
  改 `static/preview-module.js` → `resource model check/archive` → `prefab attach/build` → `scene import/remove/save` → 重开复验。

**验收**：`tools/c-garden-verify.js` 输出 `crownVerdict: "PASS"` 且 `overall: "PASS"`；
再从台阶顶连续走到观景台（不跳跃、无坠落）并重拍四方向。

---

## 附：做完任一项后请回一句，我会跑
1. `tools/c-garden-verify.js`（场景数 / 台沿 / 缺口 / 关键地面）；
2. `GetState()` / `GetCueState()`（坠落复位 / 45 s Cue 是否仍归零正常）；
3. 连续行走复测 + 截图。
