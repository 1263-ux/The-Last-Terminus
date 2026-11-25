# 花冠观景台入口修复提案（B-02）

> 状态：**PROPOSAL — 未改几何，等批准**
> 依据：`reports/day-04/C/CLEAN-SCENE-RETEST.md` §4（台沿 0.56 m 挡人、北槽坠落到台下卡死）
> 源码：`wprefabs/garden-whitebox/assets/models/model-garden-whitebox/static/preview-module.js`（Three.js 白盒生成脚本）

## 1. 根因（已在源码里定位到具体行）

观景台 `CrownVista`（圆岛，`y=26.0`，`z=20.0`）用三段 **0.55 m** 高的围栏围住：

```js
474  addBox(crownZone, 'VistaRail_Left',  0.14, 0.55, 6.0,  -4.0, 26.28, 21.5, matFrame);
475  addBox(crownZone, 'VistaRail_Right', 0.14, 0.55, 6.0,   4.0, 26.28, 21.5, matFrame);
476  addBox(crownZone, 'VistaRail_Back',  8.2,  0.55, 0.14,  0,    26.28, 24.5, matFrame);
```

- 围栏中心 `y=26.28`、高 `0.55` → 顶面 `26.555`，比台面 `26.00` 高 **0.555 m**；
- 实测世界坐标 `m3@76.56` 与源码完全对上（白盒宿主 `y=50`）；
- 玩家可跨越台阶上限实测 ∈ **[0.45, 0.50) m**（T-17，工程取 0.45）→ **0.555 m 直接把人挡在外面**。

也就是说：**不是"没有入口"，而是三段围栏把唯一入口封死了**（左/右/后三面各一段，前面是圆岛边缘悬空）。

### 1.1 源码注释揭示的"设计意图入口"——北侧走廊，但它同时踩了两处坑（本轮新发现）

源码里回走通道与围栏的注释是：

```js
// 从回转段到观景台的回走通道（沿 -Z），保持 y=26 同高
for (let i = 0; i < 4; i++) {
  const z = 25.0 - 1.4 * (i + 1);
  addBox(crownZone, 'VistaReturn_' + (i + 1), 3.0, 0.30, 1.8, 0, 26.0 - 0.15, z, matWalkCrown);
}
// 护栏：只围左右与【+Z】后方，朝 -Z（来路/温室方向）完全开口
```

换算成世界坐标（`world.x = 120 − local.x`，`world.z = 115 + local.z`）：

| 构件 | local | world |
|---|---|---|
| `VistaTurnAcross_1..4`（回转横移排） | x 3.75→0，z 26.2，2.2×2.0 | x 115.2–121.1，**z 140.2–142.2**，y 26.0 |
| **`VistaReturn_1..4`（回走走廊）** | x 0，z 23.6/22.2/20.8/19.4，3.0×1.8 | **x 118.5–121.5**，z 137.7–139.5 / 136.3–138.1 / 134.9–136.7 / 133.5–135.3 |
| `VistaRail_Back` | z 24.5，x −4.1…4.1 | **z 139.5**，x 115.9–124.1，顶 76.56 |

于是"设计意图入口"是：**回转排（z 140.2–142.2）→ 沿 x≈120 向南 → 回走走廊（z 137.7→133.5）→ 观景台中心**。
但中间同时有两处坑：

1. **0.7 m 空隙**：回走走廊最北端到 `z=139.5` 为止，回转排从 `z=140.2` 才开始 → `z 139.5–140.2` 是空的（实测 `z=140` 在 `x≥117.5` 全 MISS）；
2. **后围栏横在走廊上**：`VistaRail_Back` 正好在 `z=139.5`、横跨 `x 115.9–124.1`，把 `x 118.5–121.5` 的走廊口完全挡住，而且它高 0.55 m。

所以正确修法不是"把三段围栏都降低"（那会让左右两侧失去护栏），而是**给后围栏在走廊处开一个缺口 + 补上那 0.7 m 空隙**。

另外 `VistaTurnAcross_1..N`（`z=26.2`，世界 141.2）之间留有缝隙，射线在 `z=140, x≥117.5` 是 MISS ——玩家从北条带横向走会掉进缝隙，落到圆岛下方的结构缝（实测 `(119,73.93,134.9)`，且**不触发云垫复位**）。

## 2. 方案（推荐 A′：最小改动，保住护栏）

### 方案 A′（**推荐**）：后围栏开口 + 补 0.7 m 空隙

只动 `VistaRail_Back` 与一处补块，左右护栏完全保留：

```js
// 476 行：把 8.2 m 的后围栏拆成两段，中间给回走走廊留 3.4 m 缺口
//   原：addBox(crownZone, 'VistaRail_Back', 8.2, 0.55, 0.14, 0, 26.28, 24.5, matFrame);
addBox(crownZone, 'VistaRail_Back_L', 2.4, 0.55, 0.14, -2.9, 26.28, 24.5, matFrame);
addBox(crownZone, 'VistaRail_Back_R', 2.4, 0.55, 0.14,  2.9, 26.28, 24.5, matFrame);
// → 缺口 local x −1.7…1.7 = world x 118.3–121.7，正好覆盖走廊 118.5–121.5

// 补 0.7 m 空隙（world z 139.5–140.2）：3.0 × 0.30 × 1.2，顶面 26.0
addBox(crownZone, 'VistaCorridorFill', 3.0, 0.30, 1.2, 0, 26.0 - 0.15, 24.85, matWalkCrown);
```

- 改完后路径：回转排（world z 140.2–142.2）→ 补块（139.25–140.45）→ `VistaReturn_1`（137.7–139.5）→ … → 观景台中心，**全程 y=26.0、无台阶、无护栏阻挡**；
- 左右两侧护栏仍保持 0.55 m（观感不变，也不失去防跌落）；
- 改动量：1 行拆 2 行 + 新增 1 行。

### 方案 A（备选）：围栏整体降到 0.25 m + 补缝

如果美术上更希望"低栏"，把三段围栏都降到 0.25 m（顶 26.25 ≤ 0.45 可跨），同时补缝：

```js
// 474-476 改为：h 0.55 → 0.25，中心 y 26.28 → 26.125（底贴台面 26.0，顶 26.25）
addBox(crownZone, 'VistaRail_Left',  0.14, 0.25, 6.0,  -4.0, 26.125, 21.5, matFrame);
addBox(crownZone, 'VistaRail_Right', 0.14, 0.25, 6.0,   4.0, 26.125, 21.5, matFrame);
addBox(crownZone, 'VistaRail_Back',  8.2,  0.25, 0.14,  0,    26.125, 24.5, matFrame);
```

- 台面到围栏顶 = **0.25 m ≤ 0.45 m**，玩家可以直接跨上去再下到圆岛，观感仍是"低栏"
- 视觉上仍能提示边缘（不至于无护栏）

补缝（`VistaTurnAcross` 之间）：

```js
// 现有 2.2 宽、间距 2.2 会留缝；把宽度加到 2.6 并让相邻两段重叠 0.2
addBox(crownZone, 'VistaTurnAcross_' + (i + 1), 2.6, 0.30, 2.0, x, 26.0 - 0.15, 26.2, matWalkCrown);
```

### 方案 B（已被 A′ 取代，保留作记录）：后围栏开 1.6 m 缺口

早期想法是"开一个 1.6 m 缺口就行"。但实测走廊宽 3.0 m（world x 118.5–121.5），1.6 m 缺口会让玩家贴边；
A′ 把缺口做成 3.4 m 并补上 0.7 m 空隙，等价且更稳，故 B 不再单独推荐。

### 方案 C（可选兜底）：圆岛下方加复位体积
- 新增 `C_CrownUnderZone` 触发体（`y 70–74`，`x 114–124`，`z 130–142`），复用 `fall_respawn.lua`，复位到入口 `(120,70,107)`；
- 优点：玩家掉进台下结构口袋时不用自己摸索着往西走出边缘；
- 现状核对：**台下不是硬锁**——实测向西走出结构边缘会掉进云垫并复位（`2:respawned`），所以这一条是"体验兜底"，不是"救命补丁"。

**建议：A′（后围栏开口 + 补 0.7 m 空隙）**，左右护栏不动；C 作为可选兜底（台下口袋已有云垫兜底，不是硬锁）。

### 2.1 只有走 A′ 时才需要的补块

**A′ 只需一块**：`VistaCorridorFill`（3.0 × 0.30 × 1.2，local `(0, 25.85, 24.85)`，world x 118.5–121.5 / z 139.25–140.45），
它同时覆盖"0.7 m 空隙"和"走廊口"，见 §2 方案 A′ 代码。

下面两处**只有改成"从西侧上台"时才需要**（当前不建议，因为那会让玩家贴着悬空边走）：

| 位置 | 实测 | 何时需要 |
|---|---|---|
| 台面西缘 `x 116.5–117.5, z 138.5–139.5` | 射线 MISS | 若把 `x=116` 一段围栏也打开、从西侧进台，需补 `VistaEdgeFill`（1.2×0.30×1.4，local `(3.0, 25.85, 24.0)`） |
| 北条带 `z=140, x 117.5–124` 的其余部分 | MISS | 若希望整条北缘都能走，可补 `VistaSlotFill`（6.5×0.30×1.2，local `(-0.75, 25.85, 25.0)`）；A′ 只补走廊 3 m 即可 |

## 3. 影响面与风险

| 项 | 说明 |
|---|---|
| 需要重建 WPrefab 并重新导入 | 白盒几何来自 `preview-module.js` 生成的 GLB；改源码后要重新构建/导入，节点 ID 会变 |
| 重新导入后要复验 | 单实例、3 个 Lua 绑定、断桥车道、根系下坡、台阶、观景点（本报告的 §3/§4 全流程） |
| 与"不扩图"不冲突 | 只是改高度/补缝/加一个触发体，不新增区域 |
| 时间 | 重建+导入约 10–15 min，复走约 10 min，一轮内可完成 |

## 4. 验收清单（改完必测）

1. 从台阶顶 `(115.09,76.01,139.14)` 连续走到观景台 `(120.00,76.01,135.00)`，**全程纯走路、不跳跃、无坠落**；
2. 观景台上四方向截图（对照 `c02-09-vista-yaw*.png`）；
3. 从北条带横向走不再掉进 `z=140` 缝；
4. 台下不再存在"卡住且不复位"的位置（C 兜底生效则 `1:respawned`）；
5. 45 s Cue / 重启复位不受影响（重跑本报告 §2/§5 的读数）。

## 5. 已在 runtime 里模拟验证 A′（结论：走廊走得通）

不重建 WPrefab 也能验证 A′：在 runtime 里用 JS **只改内存**（不保存、不影响场景文件）：

1. 关掉 `__optimized_merged_material_3`（围栏所在的合并网格）的 `MeshCollider` —— 等价于"后围栏开口"；
2. 用 `CreatePrimitive(Cube)` 造一块 `BoxCollider`，位置 `(120, 75.85, 139.85)`、缩放 `(3.0, 0.30, 1.2)`
   —— 与 A′ 的 `VistaCorridorFill` 完全同尺寸同位（world x 118.5–121.5 / z 139.25–140.45 / 顶 76.0）；
3. 从横移排 `(120.00, 76.01, 141.20)` 朝 −Z 连续走：
   - `W:1200` → `(120.00, 76.01, 137.71)`
   - `W:900`  → **`(120.00, 76.01, 134.97)`（观景台中心）**
   - 全程 `y=76.01` 不坠落，`GetState()` 保持 `8:respawned`（没有新增复位）
4. 验证后已恢复：`m3` collider `enabled=true`、删除模拟方块；`tools/c-garden-verify.js` 回到 `crownVerdict: NEEDS-JUMP / overall: FAIL`（未修复状态）。

**结论**：A′ 的两处改动（后围栏在走廊处开口 + 补 0.7 m 空隙）足以让玩家从回转排一路走到观景台，
不需要动左右护栏、也不需要改台面高度。证据截图：`evidence/day-04/C/c02-14-sim-fix-corridor-walk.png`。

> 这是**运行时模拟**，不是已落盘的修复；真正修复仍需按 §7 重建 WPrefab 并重新导入。

## 6. 需要谁批准

- 几何改动（围栏高度/补缝）：**总设计**批准后 C 执行并复验；
- 台下复位体积（新增 trigger + 复用 `fall_respawn.lua`）：属于安全兜底，建议同批批准。

## 7. 批准后的执行路径（已探明，命令可直接跑）

**一键脚本**：`tools/c-crown-fix-apply.ps1`（默认 **dry-run**，只打印步骤并做只读的 `git apply --check`；加 `-Execute` 才真正执行）

```powershell
# 先看它准备做什么（不改变任何东西）
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\c-crown-fix-apply.ps1

# 批准后真正执行（archive 会返回 uri，再带 -Uri 跑一次做 attach）
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\c-crown-fix-apply.ps1 -Execute
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\c-crown-fix-apply.ps1 -Execute -Uri <archive返回的uri>
```

脚本包含：备份 → `git apply --check` → 打补丁 → `resource model check`（nodeCount 153→155）→ `archive` → `attach/build/validate/result archive`
→ `runtime stop` → `scene import`/`scene remove`/`scene save` → `runtime start` → `c-garden-verify.js` → 连续实走指针。任一步失败即停。

**补丁**：`reports/day-04/C/crown-fix-A-prime.patch`（把 `VistaRail_Back` 一行拆成五行 + 新增 `VistaCorridorFill`）。
已验证：`git apply --check` 通过、打完补丁后 `node --check` 通过、运行时模拟走通（§5）。

```powershell
# 手工等价操作（工作区根 = wprefabs/garden-whitebox）
git apply reports/day-04/C/crown-fix-A-prime.patch
```

**已确认的目标**：`workspaceId = workspace_ihycinrp`、`prefabId = garden-whitebox`、
模型资源 `resourceId = model-garden-whitebox`、`sourceState = threejs`、
源码 `assets/models/model-garden-whitebox/static/preview-module.js`、产物 `package/model.glb`。

```powershell
# 0) 备份
Copy-Item "<project>\ai-sessions\workspace_ihycinrp\wprefabs\garden-whitebox" "<backup>\garden-whitebox-prefix" -Recurse

# 1) 改源码（A′：打上面的补丁；不要再手工加 VistaEdgeFill / VistaSlotFill）

# 2) 重新准备并归档模型
douyin-world authoring resource model check model-garden-whitebox --prefab garden-whitebox --workspace-id workspace_ihycinrp
douyin-world authoring resource archive model-garden-whitebox --kind model --prefab garden-whitebox --workspace-id workspace_ihycinrp
douyin-world authoring prefab attach garden-whitebox --workspace-id workspace_ihycinrp --uri <上一步返回的 uri>
douyin-world authoring prefab validate garden-whitebox --workspace-id workspace_ihycinrp
douyin-world authoring prefab build garden-whitebox --workspace-id workspace_ihycinrp
douyin-world authoring result archive garden-whitebox --workspace-id workspace_ihycinrp

# 3) 场景替换（旧实例的 root id 会变，先枚举再删）
douyin-world scene import --prefab garden-whitebox --position 120,50,115 --name garden-whitebox --request-id c-crownfix-import
#    记录返回的 rootIDs，确认新实例在 (120,50,115)
douyin-world scene remove <旧 garden-whitebox rootID> --request-id c-crownfix-remove
douyin-world scene save --request-id c-crownfix-save

# 4) 重开 + 复验
douyin-world runtime stop; douyin-world runtime start
douyin-world runtime js eval --file tools/c-garden-verify.js   # 期望 crownVerdict=PASS, overall=PASS
# 再用连续键盘输入走一遍 入口→根系→屋顶→台阶→花冠台（不跳），并重拍四方向
```

**风险**：重新导入会换掉节点 ID，必须重新核对 3 个 Lua 绑定（fall_respawn / backup_cue / tint）与断桥车道；
`scene save` 前不要 stop 实例；全程保留备份。

### 7.1 基线（改之前已跑通的只读检查，供改后对照）

| 检查 | 结果 |
|---|---|
| `authoring prefab validate garden-whitebox` | `items: []`（无问题），revision `d5e5b82fd5ad4b221c6851a40612b6fdfd038d1ac68477519247cc3085ca43b3` |
| `authoring resource model check model-garden-whitebox` | `modelType: 2`（Geometry），`nodeCount: 153`，源文件 `meta.json` + `static/preview-module.js` |

> 改完源码后这两条必须再跑一遍：`validate` 仍应 `items: []`；`nodeCount` 预期 153 → 155（补两块地板）+ 围栏不变（只改尺寸）。
