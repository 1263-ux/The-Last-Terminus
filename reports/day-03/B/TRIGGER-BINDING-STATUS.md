# B｜玩家主动交互：脚本已写好，但绑定路径不匹配

分支：`feature/desk-world` · 编辑器 1.0.104
日期：2026-11-24
脚本：`reports/day-03/B/desk_trigger.lua`（已按官方规范编写）

---

## 0. 进展与边界

**闭环机制已全部跑通**（`LOOP-V2-PHYSICAL-GATE.md`），唯一剩的缺口是：
激活目前由 `lua eval` 命令触发，不是玩家在游戏里按键/进入触发区。

本轮把这个缺口从"没有方案"推进到"脚本已写好，卡在绑定路径"。

---

## 1. 已找到正确的绑定机制（来自 C 的实战配方）

`reports/day-03/C/REVISION.md` 与 `guide platform` 确认：

```
authoring prefab files write <Lua> --prefab <id> --path scripts/<name>.lua
authoring prefab execute <id> --file <JS>
  → scene.scripts.create({path:"..."})
  → scene.scripts.bind({nodes:[handle], script:scriptHandle, params:{...}})
prefab validate → build → export → asset import → scene import
```

**触发回调**（`guide reference scripting/README.md`）：

| 回调 | 用途 |
|---|---|
| `OnPlayerTriggerEnter(player)` / `OnPlayerTriggerExit(player)` | 玩家进入/离开触发区 |
| `OnActorTriggerEnter(actor)` | Actor 进入 |
| `OnFocus(handType)` / `OnInteract(actor)` | 聚焦/交互按钮 |

**已排除的捷径：**

| 尝试 | 结果 |
|---|---|
| `runtime lua eval --binding <key>` | `runtime targets` 返回 `[]`，无现成绑定可用 |
| 运行时给 `U3dObjectTrigger` 挂脚本 | `_douyinScriptList = nil`，CLI 无法注册 |
| 内置脚本直接绑定 | `scripts.builtins` 里无 Trigger 类，唯一 bindable 是同步脚本 |

**结论：必须走完整 prefab 绑定流程，没有 CLI 捷径。**

---

## 2. 已按官方规范写好脚本

`desk_trigger.lua` 严格遵循 `guide reference scripting/README.md`：

- ✅ `---@displayName 尺子桥交互`（第一行可执行代码之前，且只声明一次）
- ✅ `---@start` / `---@end` 单块参数区
- ✅ 参数用 `---@var {name}:{type}={default}` + `---@name {中文名}`
- ✅ `require("official.core.runtime_scope")`（不是猜 `CS.Douyin...`）
- ✅ chunk 顶层调用一次 `RuntimeScope.from(self)`，回调里复用
- ✅ 用 `scope:GetGameObjectByPath(path)` 查节点（官方 API）
- ✅ `OnPlayerTriggerEnter` 里一次性激活（`activated` 去抖）
- ✅ 三节点同时切换：桥体显示、静止尺隐藏、物理门移除
- ✅ 不写 `---@id` / `---@referenceName`（由 SDK 生成）

---

## 3. 但绑定卡在一个真实问题上：节点路径不匹配

我读回导出的 WPrefab 层级（44 节点）：

```
1   map-desk
2   └─ Environment
3      ├─ world_visual_form → world_surface → world_collider → Node-4
7      ├─ world_visual_form → world_surface → world_collider → Node-8
11     ├─ world_material → Node-10
...
```

**节点名是通用的 `world_visual_form` / `Node-N`，不是我脚本里写的
`ruler-ramp` / `ruler-rest` / `gate`。**

### 3.1 为什么

`generate-map-assembly` 把 SCAD 的 `world_visual_form(id="ruler-rest")`
导入后，**id 没有变成节点名**——所有 visual form 都叫同一个名字。

这意味着：
- 脚本无法通过 `GetGameObjectByPath` 定位具体道具
- 需要在 SCAD 或装配阶段给节点设置稳定名称

### 3.2 还没验证的解决方向

| 方向 | 做法 | 状态 |
|---|---|---|
| A. 查完整路径 | 按层级序号拼路径（如 `Environment/world_visual_form[24]`） | 未测，且不稳定 |
| B. 拆分独立 Model | 把尺子/门做成单独 GLB，attach 成有名字的节点 | 未测 |
| C. 用参数传句柄 | `scripts.bind` 的 params 传节点引用 | 未测 |
| D. 不依赖节点 | 脚本直接控制自己的宿主节点（门/尺子各自绑一个脚本） | 最有希望 |

**方向 D 最干净**：分别给门节点、尺子节点绑定各自的脚本，
每个脚本只操作 `self.gameObject`，不需要跨节点查找。

---

## 4. 下一步（按优先级）

1. **验证方向 D**：为门单独写一个 `self.gameObject:SetActive(false)` 脚本，
   绑定到触发区节点，确认 `OnPlayerTriggerEnter` 能驱动
2. 若 D 成立，扩展到三节点各自脚本，完成真交互
3. 若 D 也不行，回报总设计师：当前工程无法做玩家主动交互，
   申请用"位置轮询 + 可见提示"降级

---

## 5. 诚实边界

| 项 | 状态 |
|---|---|
| 触发回调 API 已确认 | ✅ |
| 绑定命令链已确认（C 配方） | ✅ |
| 脚本已按规范写好 | ✅ |
| **脚本已绑定到运行场景** | ❌ **未做** |
| **玩家按键/进入触发区激活** | ❌ **未做** |

**不声称交互已实现。** 本轮交付的是"方案确定 + 脚本就绪 + 精确卡点定位"。
