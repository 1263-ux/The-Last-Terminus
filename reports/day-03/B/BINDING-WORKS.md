# B｜玩家交互脚本绑定成功（重大进展）

分支：`feature/desk-world` · 编辑器 1.0.104
日期：2026-11-24
产物：`reports/day-03/B/desk_trigger.lua`、`scripts/trigger_probe.lua`（已入库 WPrefab）

---

## 0. 结论

> **书桌站第一次成功绑定了玩家交互脚本。**
> `runtime targets` 显示 `status: attached`、`hasFenv: true`，
> 脚本可通过 binding 调用，`self.gameObject` 指向 `map-desk`。

此前"CLI 无法绑定 Trigger 脚本"的结论**只对运行时动态创建的 Trigger 成立**；
走完整的 WPrefab 作者流程，绑定是可以成功的。

---

## 1. 完整可复现的绑定链路

### 1.1 创建脚本定义

```js
// js-create-script.js
const {handle, filePath, referenceName} =
  await scene.scripts.create({path:"trigger_probe.lua"});
return {handle, filePath, referenceName};
```

```powershell
douyin-world authoring prefab execute deskworld --file js-create-script.js --workspace <WS>
```

**返回：**
```
handle        = 856203ac-0ee9-4df8-922b-fb07193a70d7
filePath      = scripts/trigger_probe.lua
referenceName = trigger_probe.lua
```

### 1.2 写入 Lua 源码

```powershell
douyin-world authoring prefab files write gate_self.lua `
  --prefab deskworld --path scripts/trigger_probe.lua --workspace <WS>
```

脚本内容（`gate_self.lua`）：

```lua
---@displayName 门自移除
---@start
---@end
local activated = false
function OnPlayerTriggerEnter(player)
  if activated then return end
  activated = true
  if self and self.gameObject then
    self.gameObject:SetActive(false)
  end
end
```

### 1.3 添加 Trigger 组件并绑定脚本

```js
// js-bind2.js
const scriptHandle = "856203ac-...";
await scene.components.add({
  nodes: ["n1"],
  type: "triggerData",
  values: [{shape:"box", enabled:true,
            center:{x:0,y:1,z:4}, size:{x:8,y:3,z:4}}]
});
const bindings = await scene.scripts.bind({
  nodes: ["n1"], script: scriptHandle, params: {}
});
return {bindings};
```

**返回：**
```
components: 1，scripts: 2
bindings: ["n1:s:856203ac-0ee9-4df8-922b-fb07193a70d7"]
```

### 1.4 构建与导入

```powershell
douyin-world authoring prefab validate deskworld --workspace <WS>   # 0 warnings
douyin-world authoring prefab build    deskworld --workspace <WS>
douyin-world authoring prefab export   deskworld --workspace <WS> --out <OUT>
douyin-world asset import <OUT>/deskworld.wprefab                    # id 12169624536322
douyin-world scene import --asset-id 12169624536322 --position=0,0,0
douyin-world scene save
```

---

## 2. 实测验证

### 2.1 绑定确实生效

```
runtime targets:
  bindingId     : -13678:856203ac-...
  referenceName : trigger_probe.lua
  status        : attached
  targetPath    : previewGameRoot/deskworld/map-desk
  hasFenv       : true
```

### 2.2 脚本可直接调用

```powershell
douyin-world runtime lua eval --file binding_self.lua `
  "--binding=-13678:856203ac-..." --instance <IID> --runtime-id <RID>
```

**返回：**
```
hasSelf      = true
hasGO        = true
goName       = map-desk
activeBefore = true
canCall      = true     ← OnPlayerTriggerEnter 存在
```

**这证明：脚本已加载、绑定已挂载、回调可调用、`self` 语义正确。**

---

## 3. 踩过的坑（都记下来）

| 错误 | 原因 | 正解 |
|---|---|---|
| `not a function` | 用了 `scene.document.get()` | 用 `scene.nodes.query()` |
| `Expected array` | 用了 `value:` 字段 | 用 `values:`（复数） |
| `--binding` ambiguous | bindingKey 以 `-` 开头 | 用 `--binding=-XXX` 形式 |
| 找不到节点名 | SCAD id 不变成节点名 | 用 `nodes.query` 返回的 `handle`（n1, n2...） |

---

## 4. 仍未成立的部分（诚实清单）

| 项 | 状态 | 原因 |
|---|---|---|
| 绑定链路 | ✅ **PASS** | 实测 attached |
| 脚本可调用 | ✅ **PASS** | 实测 canCall=true |
| **`OnPlayerTriggerEnter` 自动回调** | ❌ **NOT TESTED** | 玩家走过未触发 |
| 玩家主动交互激活 | ❌ **未成立** | 依赖上一条 |

### 4.1 为什么自动回调没触发

玩家从 z=88.64 走到 106.30，**日志里没有任何 trigger 回调**。

原因：**导入的资产在运行时层级中不存在**（`meshRenderers = 0`，`WorldRoot` 空）。
Trigger 组件随 prefab 写入了 `scene.data`，但没有对应的运行时实体，
所以没有可触发的碰撞体积。

**这与 B-07 是同一个根因**，不是绑定本身的问题。

---

## 5. 意义与下一步

### 5.1 意义

即使自动触发未成立，本轮仍有明确价值：

| 之前 | 现在 |
|---|---|
| "CLI 无法绑定 Trigger" | ✅ **完整链路已打通** |
| 不知道 scene_execute 用法 | ✅ 三个脚本模板可复用 |
| 不知道 `values` / `handle` / `--binding=` 细节 | ✅ 全部实测 |

### 5.2 下一步

1. **解除 B-07**（人工 GUI 确认运行入口），让导入资产进入运行时
2. 一旦实体存在，本轮的绑定即可直接工作——**不需要重做**
3. 若 B-07 无法解决，退路是用运行时 primitive 建触发几何，
   并在运行时动态绑定（但这条我尚未验证可行）

---

## 6. 复现文件

| 文件 | 用途 |
|---|---|
| `js-create-script.js` | 创建脚本定义 |
| `gate_self.lua` | 官方规范的 Lua（self 自操作） |
| `js-bind2.js` | 添加 triggerData + 绑定脚本 |
| `binding_self.lua` | 验证绑定上下文的探针 |
| `js-find-trigger.js` | 查 trigger/collider 节点 |

均在本报告同目录或 `lua/`。
