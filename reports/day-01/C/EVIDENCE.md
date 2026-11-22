# 失重花园｜Day 01 证据索引

> Owner：成员 C
> 分支：`feature/floating-garden`
> 本文件只记录**当天真实存在的证据**。没有截到的、没有跑通的，一律写"未取得"，不用描述代替。

---

## 1. 证据清单

所有截图位于 `evidence/day-01/C/`。

| 文件 | 内容 | 对应结论 | 状态 |
|---|---|---|---|
| `01-scad-terrain-probe-overview.png` | SCAD 地图离线渲染总览（浮岛示意 + 根系连接） | T-02 SCAD 可渲染 | 实拍 |
| `02-entry-player-view.png` | 玩家站在入口浮岛上的实际视角 | 目标可见性 | 实拍 |
| `03-under-greenhouse.png` | 玩家走通根系通道后抵达温室下方平台 | T-05 可走性 | 实拍 |
| `04-three-layers-overview.png` | 白盒三层结构环绕总览（1600×1600） | 三层垂直关系 | 实拍 |
| `05-crown-vista-player.png` | 玩家站在花冠观景点，护栏与远景可见 | 终点存在 | 实拍 |
| `06-greenhouse-from-below.png` | 从下方看倒悬温室（**此帧玩家已坠落，不作为通过证据**） | — | 失败留档 |
| `07-walk-start.png` | 真实按键行走前的起点 | 输入验证 | 实拍 |
| `08-walk-after-W.png` | 真实 W 键行走后的位置 | 真实输入有效 | 实拍 |
| `09-facing-greenhouse.png` | 面向温室方向（角色转向后正对相机） | 朝向验证 | 实拍 |
| `10-persisted-after-restart.png` | 关闭实例、重开后白盒仍在 | T-09 持久化 | 实拍 |

**关于 `06-greenhouse-from-below.png` 的诚实说明**：这一帧本想取得"从下往上看倒悬温室"的关键构图，但玩家在实际下落过程中被拍到了半空（`y` 从 64 掉到 28）。它证明的是**该位置没有可站立面**，不能当作空间方案通过的证据。真正的"倒悬温室从下方可见"还需要 Day 2 补拍。保留这一帧是因为它记录了一个真实的空间缺陷：**从根系层平台到温室层之间目前没有任何可走连接**，这是方案 C 必须解决的问题。

---

## 2. 关键实测数据（可复算）

### 2.1 根系通行走通（T-05）

真实 `MoveContinuously`，逐帧采样，起点 `(134.00, 60.00, 120.00)`：

```
130.67 / 60.15
129.32 / 60.15
127.58 / 60.30
126.26 / 60.55
125.81 / 60.55
…
终点 117.60 / 61.50 / 120.00
```

`y` 单调上升 1.50 m，全程落地，无坠落、无卡死。

### 2.2 修正前的失败点（T-05，用于说明为什么必须实测）

| 版本 | 挡住的 x | 原因 |
|---|---|---|
| v1：圆管桥抬到 y=1.2 | `130.00` | 1.2 m 垂直台阶，角色上不去 |
| v2：改 7 级方块台阶 | `128.70` | 圆管半径 0.55、管心与走面同高，管顶高出 0.4 m |
| v3：圆管下沉至 y=−0.55 | **走通** | 管顶低于可走面 |

### 2.3 程序驱动平台载人（T-07）

```
平台 y: 74.75 → 80.55  (+5.80)
玩家 y: 74.90 → 78.09
carried: true
```

### 2.4 场景重开保留（T-09）

关闭实例 → 新实例 / 新 profile → `runtime start`：

```
GameObject.Find('garden-whitebox') → present: true, pos (120, 60, 120)
走位复测: 134.00 → 127.90，y 60.00 → 60.30
```

### 2.5 材质被覆盖的运行时证据（T-08）

遍历 `MeshRenderer.sharedMaterial.name`：

```
__optimized_merged_material_0, 1, 3, 5, 6, 7  → EnvLit_AI_Mat
__optimized_merged_material_4                 → EnvLit_AlphaBlend_AI_Mat
EntryIsland, UnderGreenhousePad, RootCorridor_Y0,
Greenhouse_Y9, CrownZone_Y18                  → Standard (Instance)
```

Three.js 源里写的 7 种 `MeshStandardMaterial` 全部消失。

---

## 3. 工程与文件位置

| 项 | 值 |
|---|---|
| 文档仓库 | `D:\wow-land\competition\The-Last-Terminus` |
| 分支 | `feature/floating-garden`（基于 `origin/main` @ `d6361a3`） |
| 编辑器版本 | 造世界编辑器 1.0.105 |
| 项目 | `失重花园白盒` / `project-8e9f55c1-590c-4ffa-9dc7-403b8759d19a` |
| 工作区 | `workspace_ihycinrp` |
| WPrefab | `garden-whitebox` |
| 模型资源 | `model-garden-whitebox`（Three.js 作者源，63 节点） |
| 白盒作者源 | `ai-sessions/workspace_ihycinrp/wprefabs/garden-whitebox/assets/models/model-garden-whitebox/static/preview-module.js` |

**注意**：造世界编辑器的原生工程**不在本仓库内**。本仓库只保存文档、报告与截图证据，符合 `START-HERE-FOR-MEMBERS.md` §5「文档仓库和编辑器原生工程先分开」。

---

## 4. 未取得的证据（不得当作已通过）

| 缺什么 | 为什么 | 什么时候补 |
|---|---|---|
| 玩家视角**录屏**（连续动作） | 当天只有逐帧截图，没有编码成视频 | Day 2 用连续输入 + 多帧截图序列代替，或确认 CLI 是否能导出视频 |
| 「从下往上看倒悬温室」的成立构图 | 该位置无可站立面，玩家坠落（见 `06`） | Day 2 补可走连接后重拍 |
| 分层配色的灰度「哪些能走」测试 | 材质被覆盖，现在做不出有意义的灰度图（T-08） | 解决 B-02 之后 |
| 无声引导下的路线发现 | 白盒路线目前还能一眼看穿，需要方案 C 重建 | Day 2–Day 3 |
| AI 地形的可用产物 | 卡在参考图确认（T-12） | 待 CLI 格式明确或 A 提供方法 |
| Trigger 驱动玩法的实际效果 | 只验证了组件存在 | Day 3 前 |

---

## 5. 证据强度自评

按 `PRODUCTION-OPERATING-SYSTEM.md` §6 的 0–3 打分口径，C-G1 相关维度：

| 维度 | 分 | 理由 |
|---|---|---|
| 方向一致性 | 3 | 三种拓扑都保留"目标可见 + 空间错位 + 路线发现 + 视野奖励"，与书桌站职责不重叠 |
| 空间可读性 | 1 | 白盒结构成立，但**分层配色失败**，玩家现在看不出三层（T-08） |
| 玩法/展示体验 | 1 | 路线可走通已证，但"原来这里也能走"的发现尚未在无引导下验证 |
| 视觉品质 | 0 | Day 1 不做美术，不评分 |
| 技术稳定/可恢复性 | 3 | 保存、重开、跨实例复现全部通过 |
| 证据完整性 | 2 | 截图齐、数据齐；缺录屏与关键构图 |

**自评结论：C-G1 方向部分成立，空间可读性未达标（材质问题），玩法发现未验证。不主张 Gate 通过，建议 REVISE。** Gate 由总设计师判定，Agent 自检不等于通过。
