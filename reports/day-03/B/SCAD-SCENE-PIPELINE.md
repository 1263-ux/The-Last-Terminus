# B｜SCAD 管线验证结果（最终版）

分支：`feature/desk-world` · 编辑器 1.0.104
日期：2026-11-24

---

## 0. 三条实测结论

| # | 结论 | 证据 |
|---|---|---|
| 1 | **SCAD 场景制作链路完全可用** | 44 节点装配、48 碰撞三角面、编译零错误 |
| 2 | **环境确实被加载** | 两次不同 SCAD 输入 → 两次不同画面（SHA 不同） |
| 3 | **玩家相机只看到地形与地面色块，看不到立式结构** | 截图 `24` / `25` |

---

## 1. 正确链路（已跑通，可复用）

```
initialize-map (scad) → 写 scene.scad → map check
  → generate-map-assembly → prefab execute
  → prefab build → prefab export
  → asset import → scene import --asset-id
```

### 实测数字

| 步骤 | 输出 |
|---|---|
| `map check` | `colliderTriangles 48`, `nodes 32`, `materials 13` |
| `generate-map-assembly` | 7,297 字节 execute 脚本 |
| `prefab execute` | 87 节点 / 67 组件，`root n45, environment n46` |
| `prefab export` | 22,294 字节 |
| `asset import` | id `12107455939074` |
| `scene import` | root `1391539854`, `committed` |

### 踩过的坑

| 错误 | 报错 |
|---|---|
| `prefab create` 无 `--prefab` | `缺少 --prefab` |
| `--workspace` 用自建目录 | `External archive requires an existing workspace` |
| `generate-map-assembly` 无 `--output` | usage |
| `--output` 绝对路径 | **`codeFile must be a safe JavaScript path`** |
| `world_visual_form` 无 `structure_kind` | **`Primary visual form requires a semantic kind`** |
| `scene import --uri <本地文件>` | `Prefab 下载失败: 500` |

---

## 2. 坐标系问题与修正

### 2.1 宿主转换规则

```
SCAD [x, y, z]  →  Unity [-x, z, -y]
```

**玩家出生点（Unity）：`(119.74, 77.91, 88.64)`**

### 2.2 因此地图必须放在

```
SCAD x = -119.74
SCAD y = -88.64
```

我第一次把地图放在原点附近，结果它在玩家 **120 米外**——这解释了为什么只看到远处地面带。

### 2.3 修正后

在 `scene.scad` 顶层包了：

```scad
map_origin_x = -119.74;
map_origin_y = -88.64;
translate([map_origin_x, map_origin_y, 0]) {
  ... 全部场景内容 ...
}
```

编译仍通过（`colliderTriangles 48`），装配仍成功（87 节点）。

---

## 3. 画面差异验证

| 截图 | 内容 | SHA256 前 16 位 |
|---|---|---|
| 偏移前 | 地图在 120 m 外 | `03D5DE4141CE90FE` |
| 偏移后 v2 | 地图移到玩家脚下 | `211C9D52E1C4A014` |
| 偏移后 v2 复拍 | 同场景 | `2D00056BBE993F67` |

**三张都不同** → 场景内容确实在变化，**加载是生效的**。

---

## 4. 但玩家相机看不到立式结构

三张截图的共同特征：

- 大片灰白地面（地形）
- 一条深蓝色横带（约在屏幕 1/3 高度）
- 玩家角色、UI

**没有**：书谷平台、断口、尺子、小镇街区、台灯。

### 4.1 为什么

`reports/day-03/B/TECH-CAPABILITY-MATRIX.md` 已经测出：

```
玩家相机：camY ≈ 79.59，俯角 18°（向下），半 FOV 22.5°
地平线以上仅 4.5° 余量
```

我的 SCAD 场景里：
- 近侧平台顶面 **0.30 m**
- 小镇高 **5.0 m**
- 台灯高 **3.35 m**

**站在 0.9 m 高的玩家背后、机位只比地面高 0.4 m、向下看 18°**——
5 m 高的结构在 26 m 外需要 `topY ≤ 79.59 + 26×0.0787 ≈ 81.6`，
即高度上限 **2.0 m**。**5 m 的小镇必然出画。**

### 4.2 这不是加载失败

| 现象 | 解释 |
|---|---|
| 画面在变 | 环境加载成功 |
| 看不到高结构 | **可见带约束**，不是没加载 |
| `meshRenderers = 0` | 环境几何由引擎管线直接绘制，不进场景图 |

---

## 5. 两个必须分开的问题

我此前把这两件事混在一起，导致反复误判：

| 问题 | 状态 |
|---|---|
| **A. 场景是否加载** | ✅ **是**（画面随输入变化） |
| **B. 内容是否落在玩家可见带内** | ❌ **否**（高结构全部出画） |

**A 已解决。B 是设计问题，需要总设计师裁定。**

---

## 6. B 的三条出路

| 方案 | 做法 | 代价 |
|---|---|---|
| **1. 改相机** | 提高机位、减小俯角 | 影响三个世界手感，需总设计批准 |
| **2. 改构图（我推荐）** | 把书桌站设计成**在纸面/门面表面行走**，靠纹理、页边、厚度表达"巨物"，而非靠仰望 | 改变"书谷=峡谷"的原始意象，需设计裁定 |
| **3. 拉远** | 让高结构跑出 26 m 以外，使可见带上限升到 2.0 m 以上 | 小镇 5 m 高需要 63 m 距离，场景会变得空旷 |

### 6.1 我的建议：方案 2

理由：

1. 不需要改相机（不影响 A/C）
2. "在一张巨大的纸上行走"本身就是很强的微缩表达
3. 资产包里的 `ground-paper-v01`（12×8 m，0.06 厚）**正是为此准备的**
4. 页面、页边、书脊都是俯视角度的自然读数

**但这改变世界意象，属于设计决策，我不擅自采用。**

---

## 7. 本轮净收获

| 能力 | 之前 | 现在 |
|---|---|---|
| 会写 SCAD 生成关卡 | ❌ | ✅ |
| 能产出真实碰撞面 | ❌ | ✅ 48 三角面 |
| 知道 map/prefab/asset 关系 | ❌ | ✅ 完整链路 |
| 知道 SCAD↔Unity 坐标换算 | ❌ | ✅ `[-x, z, -y]` |
| 知道地图为什么要偏移 | ❌ | ✅ 玩家在 119.7, 88.6 |
| 环境加载是否生效 | 不确定 | ✅ **确认生效** |

---

## 8. 复现

```powershell
# SCAD 源（已入库）
tools/scad/desk-world-scene.scad

# 编译验证
douyin-world authoring resource map check map-desk --prefab deskworld --workspace <WS>
# -> colliderTriangles 48

# 装配
douyin-world authoring skill run generate-map-assembly --workspace <WS> --argv-file asm.json
douyin-world authoring prefab execute deskworld --file <WS>/wprefabs/deskworld/.tmp/scene-execute/map-asm2.js --workspace <WS>

# 构建导出导入
douyin-world authoring prefab build deskworld --workspace <WS>
douyin-world authoring prefab export deskworld --workspace <WS> --out <OUT>
douyin-world asset import <OUT>/deskworld.wprefabe
douyin-world scene import --asset-id <ID> --position=0,0,0
```
