# B｜最终清理：绑定干净 + 交互确认

分支：`feature/desk-world` · 编辑器 1.0.104
日期：2026-11-24

---

## 0. 最终状态

**运行时只剩 1 个绑定，且玩家交互实测成立。**

```
runtime targets (清理后):
  desk-proximity.lua → previewGameRoot/deskworld/map-desk/desk-ruler-rest
  bindings = 1

走之前: active=true,  player z=88.64
只发 W:1600
走之后: active=false, player z=93.33
```

---

## 1. 清理了什么

### 1.1 问题

每次 `scene import` 都会往 `scene.data` 添加一个新的 `deskworld` 根节点，
旧根连同其脚本绑定继续存在：

```
9 个场景根，其中 6 个叫 deskworld
运行时 5 个绑定（4 个是历史叠加）
```

### 1.2 处理

```powershell
# prefab 侧解绑 3 个历史脚本（header-loss 事故残留）
scene.scripts.bindings([...all nodes])
→ 解绑 856203ac / f58d0bdd / 351c2555
→ prefab 里只剩 bootstrap + desk-proximity

# 场景侧删除 5 个重复根
douyin-world scene remove -1429749754 ...
douyin-world scene remove  1391539854 ...
douyin-world scene remove -296015757 ...
douyin-world scene remove  2084497431 ...
douyin-world scene remove -1148654941 ...
douyin-world scene save
```

### 1.3 结果

```
bindings: 5 → 1
唯一绑定: desk-proximity.lua on desk-ruler-rest
交互复测: 通过（active true → false）
```

---

## 2. 踩坑记录

| 现象 | 原因 | 处理 |
|---|---|---|
| 解绑只清掉 1 个 | 其余绑定不在 `n1`，在历史场景根 | 全节点 `scripts.bindings` 查询 |
| 运行时绑定越积越多 | 每次 scene import 叠加新根 | `scene remove` 旧根 |
| `scene remove` 后绑定仍在 | 需先解绑 prefab 侧，再重建导入 | 两步都做 |

---

## 3. 当前 B 线完整状态

### 已验证成立

| 能力 | 证据 |
|---|---|
| 资产包 SHA 7/7 | `ASSET-IMPORT-REPORT.md` |
| 碰撞几何证明 | `CORRECTION-COLLISION-WORKS.md` |
| SCAD 场景制作 | `SCAD-SCENE-PIPELINE.md` |
| 玩家交互绑定 | `BINDING-WORKS.md` |
| 玩家走近自动激活 | `PROXIMITY-INTERACTION.md` |
| 专用节点正确绑定 | `INTERACTION-FINAL.md` |
| 保存重开 | `RESTART-VERIFICATION.md` |
| 干净绑定状态 | **本文件** |
| 物理门 + 通行 + 反馈 | `LOOP-V2-PHYSICAL-GATE.md` |

### 仍未解决

| 项 | 状态 |
|---|---|
| 真实 kit GLB 进运行时 | ⛔ B-07 |
| 5–8 分钟切片 + 真人试玩 | ❌ 未做 |
| B-Gate | ❌ **不声称通过** |

---

## 4. 一句话

**书桌站的玩法机制层已经做完、验证完、清理干净。**
剩下的不是"我还差几步"，而是**三个必须由人决定的外部问题**：

1. GUI 点「运行/预览」确认导入资产是否出现（解 B-07）
2. 裁定尺子尺寸与"纸面世界"意象
3. 安排真人试玩

在此之前，不把机制验证包装成资产验收，不声称 B-Gate 通过。
