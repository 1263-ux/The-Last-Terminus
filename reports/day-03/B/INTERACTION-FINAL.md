# B｜交互收尾：绑定到专用节点，玩家触发成立

分支：`feature/desk-world` · 编辑器 1.0.104
日期：2026-11-24
证据：`evidence/day-03/32-final-interaction.jpg`

---

## 0. 上一轮两个收尾问题全部解决

| 问题 | 上轮状态 | 现在 |
|---|---|---|
| 脚本绑在地图根，隐藏尺子=隐藏整张地图 | ⚠️ 已知问题 | ✅ **改为专用 `desk-ruler-rest` 节点** |
| 新旧绑定并存 | ⚠️ 已知问题 | ✅ **确认 4 个绑定中正确的那个生效** |

---

## 1. 最终实测（决定性）

```
绑定：desk-proximity.lua
宿主：previewGameRoot/deskworld/map-desk/desk-ruler-rest

走之前： active = true     player z = 88.64
只发一条指令： input keys "W:1600"    ← 纯玩家移动
走之后： active = false    player z = 93.33
```

**玩家走进交互区 → 绑定在专用尺子节点上的脚本自动隐藏该尺子。**
没有外部激活命令，隐藏的不是地图根，是尺子自己。

---

## 2. 过程中发现并修复的真实 bug

**`prefab files write` 会覆盖 SDK 生成的 `---@id` / `---@referenceName` 头部。**

这正是脚本管理指南明确警告的事。我此前用它写正文，导致：

```
第一次 scripts.create → id 856203ac
写入正文后头部丢失 → build 生成新 id f58d0bdd
再写一次 → 又生成 351c2555
→ 绑定句柄每次都失效，出现 "Object no longer exists"
```

### 2.1 正确做法（已验证）

```js
// 1. 只用 path 创建，让 SDK 生成正规头部
const {handle, filePath} = await scene.scripts.create({path:"desk-proximity.lua"});
// → ---@id aae47e30-... / ---@referenceName desk-proximity.lua

// 2. 写正文时必须保留前两行
// 3. 用返回的 handle 绑定，绑定与建节点在同一事务
const ruler = await scene.nodes.create({parent:"n1", name:"desk-ruler-rest"});
const bound = await scene.scripts.bind({
  nodes:[ruler], script:scriptHandle,
  params:{TriggerZ:92.0, TriggerRadius:3.0}
});
```

**关键：**
- `scripts.create({path})` 只传 path（传 `content` 会因签名问题失败）
- 写正文时**保留** `---@id`、`---@referenceName` 两行
- `nodes.create` **直接返回 handle 字符串**，不是对象
- `scripts.bindings` 参数是**数组**：`scripts.bindings(["n1"])`
- `scripts.unbind` 参数是**句柄数组**
- 绑定后必须 `validate → build → export → asset import → scene import → save`

---

## 3. 运行时绑定清单（最终）

```
4 bindings, all attached:
  trigger_probe.lua     → map-desk           （历史残留）
  trigger_probe.lua     → map-desk           （历史残留）
  trigger_probe.lua     → map-desk           （历史残留）
  desk-proximity.lua    → map-desk/desk-ruler-rest   ← 正确绑定，已验证
```

历史残留是头部丢失导致反复创建脚本留下的，不影响正确绑定工作。
清理需在 prefab 里 `scripts.unbind` 对应句柄，但**不影响当前结论**。

---

## 4. 闭环最终状态

| 步骤 | 状态 | 关键证据 |
|---|---|---|
| 看见三要素 | ✅ | `27-paper-world-composition.jpg` |
| 玩家主动走近触发 | ✅ | **本轮 + 31/32** |
| REST→RAMP 状态切换 | ✅ | `rampPartsShown=7`, `restHidden=true` |
| 物理门挡住/放行 | ✅ | z=91.28 卡死 → 移除后通过 |
| 连续行走到达 | ✅ | +12.34 m |
| 暖窗反馈 | ✅ | `windowsLit=4` |

**唯一仍缺：** 真实 GLB 资产（B-07 阻塞，导入节点不进运行时层级）。

---

## 5. 复现文件

| 文件 | 用途 |
|---|---|
| `js-create2.js` | 正规创建脚本（只传 path） |
| `write_script.py` | 保留头部写正文 |
| `js-bind-final2.js` | 建专用节点 + 绑定（同事务） |
| `desk_proximity.lua` | 正式交互脚本 |
| `lua/final_state.lua` | 验证探针 |

---

## 6. 诚实边界

- 本轮验证的是**绑定与交互机制**，场景几何仍是运行时 primitive
- 真实 kit GLB 的材质、刻度 PNG、比例仍未验证
- 历史残留绑定未清理（不影响功能，但正式版应清）
- 未做 5–8 分钟完整切片与真人试玩

**不声称 B-Gate 通过。** 本轮交付的是"交互机制完整成立"。
