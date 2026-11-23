# C 组 Day 3 修订报告｜失重花园

> 依据：`production/prompts/DAY-03-REVISION-AND-DAY-04-ENTRY-GATE.md`（C 段 7 项）
> 与 `production/DESIGN-DIRECTOR-DECISIONS-2026-11-22.md` §4。
> 分支 `feature/floating-garden`，已非破坏性合并 `origin/main`（`d6dbb5f`）。
> **本报告不主张 Gate PASS。**

---

## 0. 首先说清楚一件事：我上一轮的方向被裁决否掉了

Day 1–2 我花了两轮试图用**布局**让"来路与下一个目标同框"，
最后又做了 `vista_camera.lua` 用 `DouyinCameraService.SetYaw(180)` **脚本强制转相机**。

设计总监 §4.1 已明确：

> Withdraw the requirement that approach path and next destination must appear in the same static camera frame.
> …No forced camera cut, forced yaw, or scripted camera takeover is required.
> If the editor does not provide usable free-look, design a physical viewing position / short turn-around path that reveals the route **without camera scripting**.

**所以脚本强制相机是明确不被要求、也不应作为方案的做法。**
本轮已把 `vista_camera.lua` 与其 trigger 节点 `C_VistaZone` 从 WPrefab 中移除（`scripts.unbind` + `nodes.remove`）。

---

## 1. 新验收口径下的实测（替代原"同框"要求）

新口径拆成两条，我分别验证：

### 1.1 「到达时下一个目标在默认视角可见」— ✅ 通过

全新 runtime、无任何脚本相机、默认相机 `yaw=0, pitch=18`、玩家站上花冠台
`(120, 78.31, 135)`：

| 目标 | 屏幕位置（宽%, 高%） | 是否入画 |
|---|---|---|
| Far2（远景岛 x=148,z=171） | (91.2, 31.1) | ✅ |
| Far3（远景岛 x=126,z=183） | (57.6, 84.1) | ✅ |
| Far1（x=90,z=165） | (−5.1, 46.0) | ❌ 左侧出画 |
| 入口岛（−Z 来路） | (49.7, 146.3) | ❌ 背后 |
| 温室 | (49.2, 543.1) | ❌ 背后 |

**两座远景岛在默认到达视角内**，满足"下一个目标/地平线奖励可见"。
证据：`evidence/day-03/C/01-arrival-default.png`

### 1.2 「正常 look 输入下 3 秒内能认出来路」— ⚠️ 部分验证

用 `DouyinCameraService.SetYaw` 模拟 look 输入扫过 5 个朝向：

| yaw | 入口岛入画 | 温室入画 |
|---|---|---|
| 0 | ❌ | ❌ |
| 90 | ❌ | ❌ |
| 135 | ❌ | ❌ |
| **180** | **✅** | ❌ |
| 225 | ❌ | ❌ |

**只有正后方 180° 能看到入口岛**（默认 pitch 18 下温室因俯角过陡不在画内）。
证据：`evidence/day-03/C/02-lookback-origin.png`（该截图用 SetYaw 生成，
**仅用于证明"转到该角度能看见来路"，不代表已实现游戏内自由 look**）

**这不是 PASS**：`SetYaw` 是 API 调用，不等于玩家真的能用鼠标/摇杆转视角。
Day 3 任务 3 要求的是 **Human GUI test**，必须由成员 C 本人在编辑器里做。
我作为 Agent 无法替代，标记 **NOT TESTED**。

---

## 2. 任务 6｜Entry / Exit 世界坐标（运行时实测，非 Three.js 源坐标）

按要求用**真实落地**测得，不是读源坐标（源坐标里 `CrownVista` 节点还写着 z=141.5，
那是父级变换，实际平台已移到 z=135——只认落地值）：

| 锚点 | 世界坐标（运行时实测落地） | 说明 |
|---|---|---|
| **Entry（入口岛站立点）** | `(120.00, 70.00, 105.00)` | 出生后向 +Z 走到断桥前的安全面 |
| 温室屋顶 | `(120.00, 66.30, 123.00)` | 中段可走面 |
| **Exit / Vista（花冠观景台）** | `(120.00, 78.31, 135.00)` | 全图最高点，视野奖励点 |
| WPrefab 宿主根 | `(120.00, 50.00, 115.00)` | scene import 位置 |
| 运行时出生点 | `(119.74, 77.91, 88.64)` | 玩家初始位置 |

**出生朝向**：相机 `forward = (0, −0.309, 0.951)`，即**朝向 +Z、略俯视 18°**。
出口回收点即 Entry。

> ⚠️ 需要 A 注意：这些值随 `scene import --position` 变化。
> 本轮宿主放在 `(120,50,115)`，若 A 移动宿主，所有锚点要按差值重算。

---

## 3. 任务 5｜Backup Cue 45 秒实测 — ❌ 未通过（被场景残留污染）

把 `trigger_probe.lua` 的 `CUE_AFTER_SECONDS` 从探针的 3.0 改为**正式值 45.0** 并加了
`cueFireCount` 计数。但实测**无法得到可信结论**，原因是新发现的真实工程债（见 §4）：

```
t≈0s   : tick=260, span=13.05, cue=true   ← 45s 阈值下不该触发
t≈5s后 : tick=524, span=26.25, cue=true
```

`cue=true` 在 13 秒就出现，与 45 s 阈值矛盾。根因不是脚本逻辑，而是**场景里存在多个
重叠的白盒实例，各自还挂着旧的 3 s 版 `trigger_probe.lua` 绑定**，
读数被旧实例污染。

**标记 NOT TESTED**，不给假 PASS。清理场景后需重测。

---

## 4. 本轮最重要的发现：场景残留 5 个重叠白盒

排查计时器异常时发现 `previewGameRoot` 下有 **5 个同名 `garden-whitebox` 节点**，
全部叠在 `(120, 50, 115)`：

```
Env / 地图 / 出生点 / garden-whitebox ×5
```

**成因**：前几轮我每次 `scene import` 新版本后都调 `scene remove <rootIDs>` 清理旧版，
但编辑器实例多次在 remove 前失联（`CONNECTION_FAILED`，本会话反复出现），
remove 没执行成功，于是每轮都留下一个。累积到 5 个。

**它造成的具体危害（都是我踩过的）**：

1. **Lua 绑定成倍重复**：同一节点上 `garden_layer_tint.lua` 出现 3 份、
   `fall_respawn.lua` 出现 3 份、旧 `trigger_probe.lua` 仍在。
   `runtime targets` 返回 7 个绑定，用 `Where-Object` 取值会拼成两个 ID
   → `lua-binding-not-found`（T-20 已记录过一半，这里是完整成因）。
2. **计时器读数错乱**：旧实例的 3 s cue 先触发，让人误判 45 s 逻辑有问题。
3. **相机朝向测量自相矛盾**：不同实例的绑定在不同帧更新，同一落点两次测出
   +Z / −Z 两个结果——这正是我上一轮"假阳性"的技术根因（T-24b）。

**结论：在清理干净之前，任何依赖 Lua 状态/计时的读数都不可信。**
这是必须写进交接的硬约束，A/B 也会踩。

**未解决**：`scene remove` 需要精确 root id，而 CLI 没有枚举场景节点的子命令
（`scene --help` 只有 `import|remove|save|operation|cancel`）。
我试过历史上所有 `import` 返回过的 rootIDs，只有 1 个能被移除，其余报
`scene-node-not-found`。剩余 4 个需要**成员 C 在 GUI 里手动删除**，或找到
枚举 root 的正式入口。已列入 BLOCKERS。

---

## 5. 任务 1/2/4｜其余项的诚实状态

| Day-3 任务 | 状态 | 说明 |
|---|---|---|
| 1. 保持 Plan C、不扩图 | ✅ | 本轮只删了脚本相机节点，未加任何新区域 |
| 2. 应用 vista 新口径 | ⚠️ 部分 | 1.1 通过；1.2 需真人 GUI 测试 |
| 3. Human GUI test free-look | ❌ **NOT TESTED** | Agent 无法做 GUI 测试，必须成员 C 本人；本轮已给出"若不可用→物理转身平台"的判断依据 |
| 4. 两个无引导玩家路线发现测试 | ❌ **NOT TESTED** | 需要真人。可提供内部 dry run（见下） |
| 5. Backup Cue 45s / 一次性 / 重启后复位 | ❌ **NOT TESTED** | 被 §4 场景残留污染，清理后需重测 |
| 6. Entry/Exit 精确世界坐标 | ✅ | 见 §2，全部为运行时实测落地值 |
| 7. 更新 PR #11 与 QA-AUDIT | ✅ | 本文件 + `QA-AUDIT.md` 增补 |

### 内部 dry run（明确不是玩家测试）

我自己按"只给一句『走到那座玻璃房子』"的顺序走过一遍 Plan C：
出生可见温室 → 断桥阻断直线 → 下坡 17 级 → 温室屋顶（倒置线索：檐口朝上/法兰朝天/天窗朝下）
→ 34 级上行 → U 形回转 → 观景台。全程无坠落。**这是 Agent 自测，不替代真人盲测。**

---

## 6. 本轮技术新增（可复用）

### 6.1 `DouyinCameraService` 存在且可用（重要，纠正旧结论）

编辑器暴露 `CS.DouyinCameraService`，运行时可用：

| 方法 | 实测 |
|---|---|
| `SetYaw(180)` | forward 从 `(0,+0.95)` → `(0,−0.95)`，`GetYaw` 读回 180 ✅ |
| `SetPitch(28)` | 实际改变俯仰 |
| `GetYaw/GetPitch` | 可读 |

**纠正 R-08**：我此前写"相机不跟随角色朝向、无法控制"——不准确。
准确说法：相机**不跟 `actor.rotation`**，但 `DouyinCameraService` 提供**程序化**设置入口，
且相机跟随**移动方向**。这不改变 §4.1 的裁决（仍不该用它做强制定向），
但它是**调试与验收**的有力工具（我这轮的 pitch 扫描就靠它）。

### 6.2 pitch 扫描给出观景构图可用区间

固定 `yaw=180`，扫 pitch（目标为入口岛/温室在屏幕高度的百分比）：

| pitch | 入口岛 sy | 温室 sy |
|---|---|---|
| 10 | 37.6 | −23.1（出画） |
| 18 | 52.8 | −4.7（临界） |
| **24** | 64.2 | **7.7** ✅ |
| **28** | 71.9 | **15.4** ✅ |
| 34 | 83.9 | 26.6 |
| 40 | 96.6 | 37.4 |

**pitch 24–28 是两者同时入画的甜点区。** 这给"若将来确实需要一次构图"提供了
可直接用的参数，但现在按 §4.1 不需要强制使用。

### 6.3 `scripts.unbind` 必须用位置数组

```js
await scene.scripts.unbind(["n34:s:<scriptId>"]);   // ✅
await scene.scripts.unbind({ bindings: [h] });       // ❌ Expected an array of handles
```

与查询方法 `scripts.bindings([nodes])` 的对象参数形式不同，容易踩。

---

## 7. 仍未解决 / 需要他人

| 项 | 谁 | 说明 |
|---|---|---|
| 清理 4 个残留白盒实例 | **成员 C（GUI）** | `scene remove` 无枚举入口，需 GUI 手动删或提供正式 API |
| free-look 是否可用 | **成员 C（GUI）** | Day-3 任务 3 明确要求人做 |
| 45 s cue 重测 | C（清理后） | 被残留污染，不可信 |
| 两个无引导路线发现测试 | 需真人 | 未安排，标 NOT TESTED |
| 音频能力 | A | 影响 backup cue 第三次提示 |
| Tripo 导出格式 | 总设计师 | Day 4 入口条件之一 |

---

## 8. 一句话总结

设计总监的 §4.1 撤回了"同框"要求，我据此删掉了上一轮做的脚本强制相机；
新口径的第一条（到达时下一个目标可见）**实测通过**，第二条（3 秒内回头认出来路）
需要真人 GUI 测试，**标 NOT TESTED 不注水**。
本轮真正的收获不是"通过"，而是**挖出场景里 5 个重叠白盒**这一工程债——
它正是我前两轮假阳性和计时器错乱的共同根因。
