# C｜Garden Entry / Exit 接口数据（Issue #20 交付）

> 时间：2026-11-25（Asia/Shanghai）｜实例 `awc-a386001a`，runtime `5d758f64` → restart `59ded821` → cue `6ff93ba8`
> 来源：**运行时实测**（Teleport 落定 + 连续行走 + 射线网格），非源码换算
> 机器可读版：`reports/day-04/C/A-INTERFACE.json`（schema `garden-interface/v1`）
> 坐标系：Unity world space（左手系，+Y 向上，模型 forward = +Z），单位米
> A 侧回填：`reports/day-03/A/WORLD-INTERFACE-CONTRACT.md`（分支 `bf95fe2`），entry/return 标 **CONFIRMED**

---

## 1. 核心接口值（A 集成直接用这组）

| 项 | 世界坐标 / 值 | 状态 | 依据 |
|---|---|---|---|
| **Entry（入口岛安全落脚点）** | `(120.00, 70.00, 105.00)` | ✅ A CONFIRMED | Teleport 落定 + 行走起点 |
| **spawn_yaw** | `0°`（`+Z`，`player.forward ≈ (0,0,1)`，相机俯角约 18°） | ✅ A CONFIRMED | DouyinCameraService yaw 0 == +Z |
| **Exit / Vista（观景台面）** | `(120.00, 76.01, 135.00)` | ⚠️ A 标 PARTIAL FAIL | 台面存在（射线 `m7@76.00–76.01`，`x 116.5–123.5, z 131–138`）；**步行入口被挡**（见 §3） |
| **Return target（坠落复位点）** | `(120.00, 70.00, 107.00)` | ✅ A CONFIRMED | `fall_respawn.lua` 本地 `(0,21,-8)`；云垫实测 `0:none → 1:respawned → 落 (120,70,107)` |
| **安全区（fallback，云垫）** | 中心 `(120, 55, 127)`，size `(60, 4, 70)`，`y 53–57`（`x 90–150, z 92–162`） | ✅ A CONFIRMED | `C_TriggerProbe` 区域实测 |
| **全局 Spawn（场景 `出生点` 节点）** | `(119.7, 80, 88.6)`，落点 `(119.74, 78.38, 88.64)` — **白盒外、地形顶** | ❌ **待 A 修（B-01）** | 地形扫描 `x 100–170 × z 80–170` 全平（77.9–78.3），无洞，走不到入口岛 |

## 2. 宿主位置与坐标变换

| 项 | 值 |
|---|---|
| 白盒宿主 `garden-whitebox` | `(120, 50, 115)`（scene import 位置） |
| 变换 | `world = (120 − local.x, 50 + local.y, 115 + local.z)`（宿主旋转 0，缩放 1） |
| 验证 | 源码 `VistaRail_Back` local `(0,26.28,24.5)` → world `(120, 76.28, 139.5)`，与实测 `m3@76.56` 对齐 |
| 场景节点数 | 44 节点 / 4 根：`Env`、`地图`、`出生点`、`garden-whitebox ×1`（持久清理后，重开复验） |

## 3. Exit/Vista 的步行可达性（A 侧标 PARTIAL FAIL 的原因）

- 台面四周 **0.56 m 台沿**（`x=116` / `x=124` / `z=139.5`，`m3@76.56`）> 可跨越上限 **0.45 m**；
- 北侧 `z=140, x≥117.5` 为 **0.5 m 深槽**（射线 MISS）；
- 根因在白盒源码：设计好的入口走廊 `VistaReturn`（world `x 118.5–121.5`）被 **0.7 m 空隙（z 139.5–140.2）+ 后围栏 `VistaRail_Back`** 同时挡住；
- 修复方案 **A′**（后围栏开 3.4 m 缺口 + 补 `VistaCorridorFill`）已 runtime 模拟走通到台心 `(120,76.01,134.97)`，补丁与执行脚本就绪，**等总设计批准**：
  `reports/day-04/C/CROWN-ENTRY-FIX-PROPOSAL.md`、`reports/day-04/C/crown-fix-A-prime.patch`、`tools/c-crown-fix-apply.ps1`。

## 4. 路线锚点（A 集成参考；连续行走实测）

| 路点 | 坐标 | 备注 |
|---|---|---|
| 入口岛 → 断桥 | `(120,70,105)` → `(116.48,70,109.33)` | 断桥**唯一稳定车道 `x=117` 列**：`x≈115` 在 `z 108.5–110.3` 缺失（斜向缺口） |
| 根系下坡起点 | `(116.48, 69.45, 113.77)` | 连续下行 |
| 根系下坡终点 | `(116.48, 67.20, 121.64)` | — |
| 温室屋顶 | `(116.48, 66.50, 123.66)` | 屋顶可走面 |
| 34 级台阶顶（花冠前平台） | `(115.09, 76.01, 139.14)` | 与 Day 3 一致（`+8.24 m` 上行） |
| 花冠北条带 | `(119.00, 76.01, 141.20)` | 北缘 `z≈142.2` 后无地面（R-05 裸露边界） |
| **Exit / Vista 台心** | `(120.00, 76.01, 135.00)` | 当前只能 Teleport 到达（步行入口 FAIL） |

## 5. ⚠️ 场景内 `RouteAnchors` 有 3 个过时 —— 不要用于集成

`Model/RouteAnchors` 下 10 个 `ANCHOR_*` 空节点是**搬台阶之前**的旧布局，以下 3 个已失效：

- ❌ `ANCHOR_STAIR_BASE (120,66.4,125)` — 落在屋顶，真实台阶在 `x=115`；
- ❌ `ANCHOR_CROWN_VISTA (120,76.4,141.5)` — 是北条带，不是观景台（台心 `z=135`）；
- ❌ `ANCHOR_VISTA_LOOKBACK (120,76.4,139.6)` — 悬在 0.7 m 空隙上（射线 MISS）。

**集成一律使用本文件 §1/§4 与 `A-INTERFACE.json` 的实测值。**（详见 `CLEAN-SCENE-RETEST.md §6.1`、`BLOCKERS.md R-07`）

## 6. 已知阻塞（给 A / 总设计）

| 编号 | 项 | 需要谁 |
|---|---|---|
| **B-01** | 全局出生点在地形顶 `(119.7,80,88.6)`，白盒在地形下（`y 66–76`），地形无洞 → **出生→入口永远走不通**；必须改到 `(120,70,105)` 或开正规入口 | A（**需 GUI**，CLI 无节点移动 API） |
| **B-02** | Exit/Vista 步行入口被挡（A′ 方案待批准） | 总设计批准 → C 执行 |
| R-05 | 花冠北条带北缘 `z≈142.2` 裸露（过冲踏空，云垫可复位） | 建议加 0.25 m 挡边，不阻塞 |

## 7. 双向一致性核对

- 我方 `A-INTERFACE.json` 与 A 的 `WORLD-INTERFACE-CONTRACT.md`（`bf95fe2`）**数值一致、无冲突**；
- A 已标：`garden.entry` **CONFIRMED**、`garden.return` **CONFIRMED**、`garden.exit/vista` **PARTIAL FAIL**、安全区云垫 **CONFIRMED**、可跨越台阶 `≤0.45 m` **CONFIRMED**；
- A 侧同样记录"无 GUI 会话，不做 CLI teleport 冒充"——B-01 仍待 GUI 操作者。
