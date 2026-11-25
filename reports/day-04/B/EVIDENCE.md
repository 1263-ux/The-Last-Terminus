# B｜证据索引（Day 4）

所有图片为真实引擎运行时截图（`douyin-world runtime screenshot`），
非渲染图、非概念图。路径：`evidence/day-04/B/`

---

## 1. B-07 定位错误的核心证据

| 文件 | 内容 | 关键读数 |
|---|---|---|
| `01-imported-glb-in-runtime.png` | 导入 GLB 在运行时**确实渲染** | 蓝色阴影带 + 角色 |
| `02-ruler-bridge-object.png` | 尺子桥完整 6 部件 | 桥面 / 立柱 / 托架全在 |
| `03-ruler-numerals-closeup.png` | 刻度近景 | 数字与刻度线可见 |
| `05-ruler-topdown.png` | **俯视 80°，强制验收项** | 可读出 `10 20 30 40 50 60 70`，无镜像 |

**运行时层级读数（lua 探针）：**

```
previewGameRoot 子节点：Env / 地图 / 出生点 / ruler-bridge-full-v01 / deskworld
previewGameRoot 全量：totalNodes=111, meshRenderers=42
SM_bridge_ruler  mat=EnvLit_AI_Mat  c=(119.74,81.14,95.00)  s=(8.00,0.13,0.90)
```

---

## 2. 摆放问题（真正的根因）

| 文件 | 内容 | 关键读数 |
|---|---|---|
| `06-aligned-player-view.png` | 手动把地图/桥移到玩家脚下后 | 场景出现，证明数据完好 |
| `08-player-eye.png` | 未修正的玩家视角 | 只有地形与远景色带 |
| `09-v3-player-view.png` | 摆放修正中途 | 场景在脚下但仍有偏移 |

**关键测量：**

```
玩家脚底 y = 77.905
桥面顶部 y = 81.208      差值 3.303 m   <- 悬空
deskworld  pos = (0,0,0)  玩家 (119.74,77.91,88.64)  <- 120 m 偏移
```

---

## 3. 修正后的场景

| 文件 | 内容 |
|---|---|
| `18-final-start.png` | **最终起始画面**：纸面 / 书谷 / 小镇 / 备用尺同框 |
| `12-clean-start.png` | 干净状态（无重复实例） |

**运行时层级（干净）：**

```
ruler-rest              active=true
desk-ruler-rest         active=true
ruler-bridge-full-v01   active=false    <- 门禁：默认收起
Environment             active=true     children=48
```

---

## 4. 玩法闭环

| 文件 | 环节 | 关键读数 |
|---|---|---|
| `18-final-start.png` | 起点 | `z=88.64 y=79.41`，桥 `active=false` |
| `19-gate-fired.png` | **门禁触发** | `z=96.33`，桥 `active=true`，宿主 `active=false` |
| `16-crossed-to-town.png` | **过桥中** | `z=108.18 y=79.41`（未掉落） |
| `17-town-arrival.png` | 到达小镇 | `z=120.07 y=79.41` |
| `21-windows-lit-proof.png` | 暖窗反馈 | 6 扇窗颜色变化 |

---

## 5. 反证（负控制）

| 文件 | 内容 | 关键读数 |
|---|---|---|
| `15-fell-into-chasm.png` | 关掉桥与门禁后同路线前进 | `z=104.48 y=77.98` —— **掉进断口** |

**同一路线、唯一变量是有没有桥 → 因果闭合。**

---

## 6. 暖窗颜色实测

```
触发前：Node-210..220  rgba=(0.55,0.40,0.10,1.00)   ×6
写回验证：found=6, changed=6
触发后：暖亮色（见 21-windows-lit-proof.png）
```

> 边界：这是**颜色变化**，不是自发光。`MAT_window_glow` 的自发光在运行时不生效。

---

## 7. 未包含的证据（我没有）

- ❌ 一镜到底录屏（本机离屏实例无录屏能力，只有帧截图）
- ❌ 真人试玩记录
- ❌ 音频试听
- ❌ 昼夜三种光照同机位
