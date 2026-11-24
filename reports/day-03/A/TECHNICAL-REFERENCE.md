# 技术快速参考（B/C 一站式手册）

> Owner：成员 A
> 更新：2026-11-22
> 基于 Day-3 全部实测验证

---

## 1. 碰撞：不可用

**玩家是 `NetworkActor` 运动学刚体**（`isKinematic=true`, `velocity=0`, `layer=8`）。
场景物体（GLB、原生 Cube、任何 Layer）**不能阻挡玩家**。

**所有玩法必须用 Trigger + Teleport，不依赖实体碰撞。**

---

## 2. GLB 导入：1:1 保留

```
resource model import → archive → prefab attach → build → result archive → scene import
```

| 尺寸 | 结果 |
|---|---|
| 1×1×1 m | 1:1 |
| 2×2×2 m | 1:1 |
| 4×4×4 m | 1:1 |

**7 个坑**（详见 `GLB-RECIPE.md`）：
1. X 轴镜像（+X→−X）
2. `prefab attach` 是追加
3. 材质用 `_BaseColor`/`_BaseTex`
4. NORMAL 必带
5. 空节点不生成 Collider
6. 顶点色存 `glbSliceData`，不进材质
7. `Start()` 有时序问题，用 `OnEnable()`

---

## 3. 门禁：已验证（节点位置状态存储）

**方案**：单触发器 + `Update()` 轮询 + **节点位置存储状态**（不用 Lua 变量）

```lua
-- 状态存储：用节点位置，不用 Lua 变量（local activated 不跨帧持久化）
local function isUnlocked()
  local m = CS.UnityEngine.GameObject.Find('GateStateMarker')
  if m == nil then return false end
  return m.transform.position.z > 0.5
end

local function setUnlocked()
  local m = CS.UnityEngine.GameObject.Find('GateStateMarker')
  if m ~= nil then
    local pos = m.transform.position
    m.transform.position = CS.UnityEngine.Vector3(pos.x, pos.y, 1)
  end
end

function Update()
  local actor = CS.DouyinActorService.GetLocalActor()
  if actor == nil then return end
  local z = actor.position.z
  if z < 90 then
    if not isUnlocked() then setUnlocked() end
    return
  end
  if z >= 93 and not isUnlocked() then
    actor:Teleport(返回点)
  end
end
```

**验证（6 轮测试）**：
- 未解锁走到门禁区 → 传送回 ✓
- 节点位置状态存储 → **PASS**（标记 z=1 确认）
- `local activated` 跨帧持久化 → **FAIL**（引擎限制）
- `OnActorTriggerEnter` 在 Teleport 时触发 → **FAIL**

**关键**：
1. 必须用 `Update()`，不能用 `OnActorTriggerEnter`（Teleport 时不触发）
2. **必须用节点位置存储状态**，不能用 `local activated`（不跨帧持久化）
3. 单场景单门禁（多实例互相干扰）
4. 详见 `GATE-STATE-SHARING.md` 和 `tools/gate_ns2.js`

---

## 4. 音频：官方模式

**声明**：
```lua
---@var MySound:UnityEngine.AudioClip=nil
---@refFrom asset
---@assetCategory Music
---@dataType Audio
---@var MySoundVolume:number=1
---@var MySoundMaxDistance:number=5
```

**播放**（`ApplySoundSettings()` 在播放时调用）：
```lua
audioSource.volume = math.max(0, math.min(1, MySoundVolume))
audioSource.minDistance = math.min(1, distance * 0.1)
audioSource.maxDistance = distance
audioSource.rolloffMode = CS.UnityEngine.AudioRolloffMode.Linear
audioSource.spatialBlend = 1
```

**导入**：WAV + `meta.json`（schemaVersion 4）→ `resource archive --kind audio`

---

## 5. 共享资产

| 资产 | 用途 | SHA-256（前16） |
|---|---|---|
| `probe-cube-1m.glb` | 尺寸基准 | `fb0021dcc17077f5` |
| `probe-cube-2m.glb` | 尺寸基准 | `6cf8c379f819b8b8` |
| `probe-cube-4m.glb` | 尺寸基准 | `6e4024a19f122c3b` |
| `probe-axis-marker.glb` | 方向验证 | `ac6202d573aac7dd` |
| `probe-textured-cube.glb` | 贴图验证 | `6896c47f6241b001` |
| `probeminimal.wprefab` | WPRE 交接 | `b6be6dd314e65654` |

位置：`reports/day-03/A/shared-assets/`

---

## 6. 常用命令

```powershell
# 创建 Prefab
douyin-world authoring prefab create myworld --instance <I> --workspace-id <W>

# 导入 GLB
douyin-world authoring resource model import model-xxx --prefab myworld --workspace-id <W> --instance <I> --glb .\my.glb

# 归档
douyin-world authoring resource archive model-xxx --kind model --prefab myworld --workspace-id <W> --instance <I>

# 构建 + 导出
douyin-world authoring prefab build myworld --workspace-id <W> --instance <I>
douyin-world authoring result archive myworld --workspace-id <W> --instance <I> --name "交付物"

# 导入场景
douyin-world scene import --instance <I> --uri <wprefab-uri> --name "名称" --position x,y,z
douyin-world scene save --instance <I> --request-id save-1
```
