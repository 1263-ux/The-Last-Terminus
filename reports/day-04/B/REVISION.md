# B｜Day 4 修订记录：推翻 B-07「运行时不加载资产」

**分支：** `work/b-desk-slice-1124` · **日期：** 2026-11-25

---

## 1. 我推翻的结论

| 我此前上报的 | 实际 |
|---|---|
| 运行时 `WorldRoot` 0 子节点 → 导入资产不加载 | **查错了根节点**。导入物在 `previewGameRoot` 下，有 100+ 节点、42+ MeshRenderer |
| `scene.data` 完整但"加载器不在" | 加载器在，数据也加载了；是**摆放**错了 |
| 尺子刻度 PNG 无法验证 | 已读出 `10 20 30 40 50 60 70`，方向与镜像正确 |
| 只能用运行时 primitive 验证机制 | 已恢复使用导入的 `ruler-bridge-full-v01.glb` |

---

## 2. 我错在哪（值得留下来的部分）

### 2.1 我把"某个根节点是空的"当成"整个场景没加载"

`WorldRoot` 确实是 `childCount = 0`。这个读数没错。
但我没有继续枚举**其它**根节点就下了结论。Unity 有 12 个根节点，
`previewGameRoot` 里什么都有。

**教训：一个父节点是空的，不等于它的兄弟节点也是空的。枚举全部根节点再下结论。**

### 2.2 我用"画面看不到"反推"数据没加载"

实际画面看不到的原因有两个，都跟加载无关：
1. 地图在 120 m 外（WPrefab 归一化抹掉了 SCAD 根位移）
2. 尺子悬空 3.30 m

**教训：画面不对时，先量位置，再怀疑加载。**

### 2.3 我被"导出的日志看起来很像原因"说服了

`SwitchGameStateByEntryType` / `HamletWorldGame` 这段日志确实存在，
它确实是"预览入口"。但**预览入口依然会实例化导入的 prefab**。
我把"这是预览世界"错误地等同于"预览世界不加载我的内容"。

---

## 3. 本轮踩到的新坑（已写进源码注释）

| 坑 | 表现 | 解法 |
|---|---|---|
| **WPrefab 归一化内容根变换** | SCAD 里的 `translate` 被抹掉，地图落回原点 | 用 `scene import --position` 定位，不要在 SCAD 里写大位移 |
| **`scene.nodes.query` 单页 100 上限** | 反复"删不掉重复节点"，每次只删掉第一页里的 | 必须按 `nextCursor` 翻页 |
| **prefab 里残留重复实例** | 场景里出现两个 `ruler-bridge-full-v01` | 每次重建后读 `prefab.json` 确认直接子节点数量 |
| **脚本参数改名后旧值残留** | `INVALID_SCRIPT_PARAMS: Unknown Lua parameter /TriggerZ` | 先 `scripts.setParams` 用旧 schema 覆盖，或保留旧参数名 |
| **`scripts.create` 前不能手写脚本文件** | `UNREGISTERED_SCRIPT` | 脚本文件必须由 `scripts.create` 登记 |
| **`scene remove` 需要先停预览** | `scene-edit-preview-active` | 先 `runtime stop` 再删 |
| **一个 `world_visual_form` 只吃一个 `world_material`** | 同一 form 内多次 `world_material`，整本书被刷成最后一种颜色（实测 rgba 全为 0） | 想分段上色必须拆成多个 `world_visual_form`；但拆分会触发 id 拼接问题（见下） |
| **`world_visual_form(id=...)` 不接受动态拼接的 id** | `Visual form id is invalid`（`concat` 对字符串无效） | id 必须是字面量，不能由 module 参数拼出来 |
| **prefab 节点数增长后 `execute` 会超限** | `Scene output byte limit exceeded`（667 节点时） | 删除/新增要按显式 handle 逐条做，不要一次查全树再批量删 |

---

## 4. 现在成立的事实

| 项 | 状态 |
|---|---|
| 导入 GLB 在运行时可渲染 | ✅ 实测 |
| 刻度 PNG 运行时解码 | ✅ 实测（可读数） |
| WPrefab 归一化根位移 | ✅ 实测（120 m 偏移的具体成因） |
| 控制器无 step-up，1.5 m 断口挡得住 | ✅ 实测 + 反证 |
| 门禁由玩家移动触发（非外部命令） | ✅ 实测（桥 active 翻转） |
| 过桥连续通行 | ✅ 实测（y 稳定 79.41） |
| 暖窗颜色反馈 | ✅ 实测（6 扇，颜色写回成功） |
| 自发光 | ❌ 仍不生效 |

---

## 5. 我没有声称的

- B-Gate 通过
- 5–8 分钟完整体验（当前 1.5–2 分钟）
- 真人试玩（NOT TESTED）
- town-row / shopfront 已集成到玩家视角
