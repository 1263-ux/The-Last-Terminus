# B｜GUI 运行入口诊断：B-07 是一次定位错误，不是加载失败

**分支：** `work/b-desk-slice-1124`（本文从 main `9c839ba` 起）
**编辑器：** 造世界 1.0.104（Windows，offscreen 实例）
**日期：** 2026-11-25
**证据目录：** `evidence/day-04/B/`

---

## 0. 一句话

**B-07「运行时不加载导入资产」不成立。** 导入的 GLB 在运行时正常实例化、正常渲染，
连尺子刻度 PNG 都正确解码（可读出 `10 20 30 40 50 60 70`）。
我此前查的是 `WorldRoot`，而导入物实际挂在 `previewGameRoot` 下——**查错了根节点**。

真正的问题是**摆放**，不是**加载**：

| 现象 | 真实原因 |
|---|---|
| 场景"看不见" | SCAD 里的 `translate([-119.74,-88.64,0])` 在 WPrefab 导出时被"内容根变换归一化"抹掉，地图落回原点，离玩家 120 m |
| 尺子桥"悬空" | 实例 `scale=8`，桥面顶部比玩家脚底高 3.30 m |

---

## 1. 这次是怎么确认的（可复现）

### 1.1 枚举运行时真实根节点

`runtime start` 之后，Unity 只有一个场景 `HamletPreview`，根节点 12 个：

```
Previewer(0)  WorldRoot(0)  TPCameraAvatar(1)  NetworkActorInteractionManager(0)
NetworkMasterManager(0)  FestoonedVehicleSpawner(Clone)(0)  NPCSpawner(Clone)(0)
Player_1(1)  AvatarHeaderBarRoot(1)  Player(Clone)(0)  InputManager(Clone)(0)
ActorAudioGroup(Clone)(0)
```

`WorldRoot` 子节点确实是 0 —— **这就是旧结论的来源**。
但场景内容根本不在 `WorldRoot` 下，而是在 `previewGameRoot`：

```
previewGameRoot
  Env
  地图
  出生点                     pos=(119.74, 80.00, 88.64)
  ruler-bridge-full-v01      pos=(119.74, 80.00, 95.00)  scale=8   <- 导入的 GLB
  deskworld                  pos=(0.00, 0.00, 0.00)                <- SCAD 地图（位置是错的）
```

### 1.2 导入资产确实实例化且有渲染器

对 `previewGameRoot` 全量遍历（111 节点）：

```
totalNodes = 111
meshRenderers = 42
```

其中包括真实 kit 资产的 6 个 mesh 与正确的材质名：

```
SM_bridge_ruler      mat=EnvLit_AI_Mat  c=(119.74, 81.14, 95.00)  s=(8.00, 0.13, 0.90)
SM_bridge_numerals   mat=EnvLit_AI_Mat  c=(119.74, 81.20, 95.00)  s=(8.00, 0.00, 0.90)
SM_bridge_post_l/r   mat=EnvLit_AI_Mat  ...
SM_bridge_bracket_l/r mat=EnvLit_AI_Mat ...
出生点               mat=SpawnPoint01_mat02
地形块               mat=NewTerrainLitAdd
```

### 1.3 刻度 PNG 解码正常（强制验收项）

`evidence/day-04/B/05-ruler-topdown.png`：俯视 80°，尺面可清楚读出
**`10 20 30 40 50 60 70`**，刻度线与数字方向正确、无镜像。
判定方法：把相机放到尺子上方 9 m 俯视，直接读像素。

**结论：`MAT_ruler_numerals` 的 4,069 B PNG 在运行时正常解码并正确贴图。**

---

## 2. 真正的问题：摆放

### 2.1 地图落回原点（120 m 偏移）

SCAD 源码里写了：

```scad
map_origin_x = -119.74;
map_origin_y = -88.64;
translate([map_origin_x, map_origin_y, 0]) { ... }
```

但 WPrefab 导出时**内容根的局部变换会被归一化**（见 CLI 文档：
"WPrefab 内容根的位移会在导入时清零"）。所以这个 `translate` 被抹掉，
地图在运行时位于 `(0,0,0)`，而玩家在 `(119.74, 77.91, 88.64)`。

**这就是"只看到远处地面带"的真正原因**——不是加载失败，是地图在 120 m 外。

### 2.2 尺子桥悬空 3.30 m

```
玩家脚底 y = 77.905
桥面顶部 y = 81.208
差值       = 3.303 m
```

`scale=8` 时桥面顶部相对实例根是 +1.208，而实例根被放在了 y=80.0。
正确的放置是让桥面顶与纸面齐平。

---

## 3. 修正后的结果

### 3.1 摆放修正

- SCAD 内改用绝对坐标书写（新增 `ubox()` / `uplace()` 助手，直接用 Unity 地面坐标）
- 用 `scene import --position 119.741669,77.905,88.64061` 把根放到玩家脚下
- 尺子桥实例改为 `position.y = +0.292`，使 `+1.208` 的桥面顶正好落在 `+1.5` 的纸面

修正后运行时层级（干净、无重复）：

```
ruler-rest              active=true
desk-ruler-rest         active=true
ruler-bridge-full-v01   active=false   <- 门禁：默认收起
Environment             active=true   children=48
```

### 3.2 场景现在真的在玩家脚下

`evidence/day-04/B/18-final-start.png`：纸面铺满前景，左右书谷低矮书列，
远处铅笔盒小镇与暖窗，侧前方平放着备用尺。**三要素同框，全部在可见带内。**

---

## 4. 可见带：确认了硬约束，并按它重新设计

实测相机与视场：

```
相机 y = 79.59（玩家脚底 +1.68）
俯角 18°，垂直半 FOV 22.5°
地平线以上余量 = 22.5 - 18 = 4.5°
可见高度上限 ≈ 1.68 + 0.0787·d
   d=10m -> 2.47m
   d=20m -> 3.25m
   d=30m -> 4.04m
```

所以按总设计师 §2「低矮书页/书脊 + 纸面混合构图」重新设计：

- 书体一律 **0.84–1.90 m**（相对纸面），全部落在可见带内
- `town-row` 5 m 只作远景剪影，**不压扁、不改源模型**
- 纸面抬到 +1.5 m 形成真实断口，让"过不去"是物理事实而非规则

---

## 5. 玩法闭环（这一轮真的跑通了）

### 5.1 断口是真的

纸面顶面 +1.5 m，断口处不放纸面，露出下方引擎地形。
**控制器没有 step-up**（1.20 m 就挡住），所以 1.5 m 的断口走不过去。

### 5.2 门禁由玩家移动触发

`desk-proximity.lua` 挂在专用宿主节点 `desk-ruler-rest` 上：

```lua
function Start()
  -- 出生时桥体收起
  local bridge = findNode("ruler-bridge-full-v01")
  if bridge ~= nil then bridge:SetActive(false) end
end

function Update()
  local pos = findPlayer().transform.position
  if not activated and math.abs(pos.z - TriggerZ) <= TriggerRadius then
    activate()   -- 桥体 SetActive(true) + 藏起侧躺的尺子
  end
  if not arrived and pos.z >= ArriveZ then
    arrived = true
    lightTown()  -- 暖窗调亮
  end
end
```

**不是外部 lua 命令，不是按钮，是玩家自己走过去触发的。**

### 5.3 实测数据（同一轮运行内）

| 步骤 | 玩家位置 | 状态 |
|---|---|---|
| 出生 | `z=88.64, y=79.41` | 桥 `active=false` |
| 前进 2.6 s | `z=96.33, y=79.41` | **门禁触发**：桥 `active=true`，宿主 `active=false` |
| 继续前进 4.0 s | `z=108.18, y=79.41` | 在桥面/远段纸面上，**没有掉落** |
| 再前进 4.0 s | `z=120.07, y=79.41` | 到达小镇平台 |

**关键：y 全程稳定在 79.41**（纸面顶面），没有掉到 77.98（地形）——
说明玩家确实是**走在桥面上过去的**，不是被传送。

### 5.4 反证：去掉桥就过不去

同一场景、同一位置，把桥和门禁宿主都关掉后：

```
起点 z=88.64 y=79.41
前进 6.0 s  ->  z=104.48  y=77.98   <- 掉进断口，站在地形上
```

**同一路线、唯一变量是桥 → 因果闭合。**

### 5.5 暖窗反馈

到达 `z>=118` 后，6 扇窗颜色从 `(0.55,0.40,0.10)` 提升到暖亮色
（`evidence/day-04/B/21-windows-lit-proof.png`）。
脚本写材质的路径单独验证过：`found=6, changed=6`。

> 诚实边界：`MAT_window_glow` 的**自发光**在运行时不生效（Day 3 已记录），
> 所以这里用**颜色变化**做反馈。这不等于"自发光验收通过"。

---

## 6. 与旧结论的对照

| 旧结论 | 现在 |
|---|---|
| 运行时 `WorldRoot` 0 子节点 → 不加载资产 | ❌ 查错根节点。`previewGameRoot` 有 100+ 节点、42+ MeshRenderer |
| 启动 `HamletWorldGame` → 不进关卡 | ❌ 入口没变，但场景内容是导入后由预览管线绘制的，确实在 |
| 尺子刻度 PNG 无法验证 | ❌ 已读数 `10…70`，方向与镜像都正确 |
| 本轮只能用运行时 primitive | ❌ 恢复使用导入的 ruler-bridge GLB（6 mesh，真实材质） |
| 真正的问题 | ✅ **摆放**（WPrefab 归一化抹掉根位移 + 实例悬空），已修正 |

---

## 7. 仍然成立的技术事实

- **WPrefab 导出会归一化内容根的局部变换**。地图不要靠 SCAD 内 `translate` 定位，
  要用 `scene import --position`。这一条写进源码注释，避免下一轮再踩。
- **`scene.nodes.query` 单页上限 100**。此前多次"删不掉重复节点"就是因为只拿到第一页，
  后续整棵树全在第二页里。脚本必须翻页。
- **控制器 step-up 上限在 0.20–1.20 m 之间**，1.5 m 断口必然挡住，0.19 m 台阶可以爬。
- **玩家 transform 每帧被控制器覆写**，teleport 不生效（会被拉回）。所以复位必须靠几何，不能靠脚本传送。

---

## 8. 我没有声称的

- ❌ 不声称 B-Gate 通过
- ❌ 不声称 `MAT_window_glow` 自发光可用（只验证了颜色）
- ❌ 不声称 town-row / shopfront 已集成到玩家视角（本轮用的是 SCAD 灰盒体量）
- ❌ 不声称真人试玩（NOT TESTED）
- ❌ 不声称这是 5–8 分钟的完整体验（当前是核心闭环，时长待测）

---

## 9. 复现

```powershell
# 1. 实例（本项目已存在）
douyin-world instance start --project "<DeskWorldProbe 目录>" --mode offscreen

# 2. 编译 + 归档地图
$ws = "<项目>/ai-sessions/workspace_deskworld"
douyin-world authoring resource map check  map-desk --prefab deskworld --workspace $ws
douyin-world authoring resource archive map-desk --kind map --prefab deskworld --workspace $ws

# 3. 构建 + 导出 + 入库
douyin-world authoring prefab build   deskworld --workspace $ws
douyin-world authoring prefab export  deskworld --workspace $ws --out ./deskw-day04
douyin-world asset import ./deskw-day04/deskworld.wprefab

# 4. 放到玩家脚下（关键：不要靠 SCAD translate）
douyin-world scene import --asset-id <ID> --position 119.741669,77.905,88.64061
douyin-world scene save --request-id <ID>

# 5. 跑
douyin-world runtime start
douyin-world runtime input keys "W:2600"     # 走到门禁
douyin-world runtime input keys "W:8000"     # 过桥到小镇
```
