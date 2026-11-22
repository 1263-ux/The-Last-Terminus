# reports/day-03/A/EVIDENCE.md

> 环境：造世界编辑器 1.0.104 / CLI douyin-world 1.0.104
> 项目：`TrainCore_A`（project-fb583637-...），实例 awc-f18c475b-...
> 分支：`feature/train-core`；Day-3 报告在 `reports/day-03/A/`

## 1. 共享资产（A1）

`shared-assets/glb/` 5 个 GLB + `ASSET-MANIFEST.csv`（含完整 SHA-256）。
均由 `make_day3_assets.py` 生成，每个 primitive 带 POSITION+NORMAL+TEXCOORD_0。

`resource inspect` 读回的作者 bounds：

| 资产 | min | max | 三角面 |
|---|---|---|---|
| probe-cube-1m | −0.5 | +0.5 | 12 |
| probe-cube-2m | −1 | +1 | 12 |
| probe-cube-4m | −2 | +2 | 12 |
| probe-axis-marker | (−0.2, 0, −0.2) | (2, 0.8, 1) | 48 |
| probe-textured-cube | −0.5 | +0.5 | 12，内嵌 885 B PNG |

> 过程记录：第一版 `build_size_cube` 把 cube 挂在空 root 的 children=[] 中，
> 导致 GLB 无有效几何（inspect 报"空几何"）。已修复为直接把 cube 作为根节点。

## 2. GLB 导入矩阵（A2）

- `evidence/A2-prefab-scales.json`：8 个节点全部 scale=(1,1,1)；
  `AxisPlusX_RED` 作者 +1 → 导入 −1。
- `evidence/A2-scene-import.json`：rootIDs ["-949277278"]。
- `evidence/A2-runtime-bounds.json`：运行时真实包围盒 1×1×1 / 2×2×2 / 4×4×4，
  轴标 +X 臂几何 2 m 且节点 x=−1，+Z 臂 z=+0.5，+Y 臂 y=+0.3。

```powershell
douyin-world authoring resource model import model-d3-cube1 --prefab day3matrix `
  --workspace-id <W> --glb shared-assets/glb/probe-cube-1m.glb
douyin-world authoring resource archive model-d3-cube1 --kind model --prefab day3matrix ...
douyin-world authoring prefab attach day3matrix --kind model --uri <uri> ...
douyin-world authoring prefab build day3matrix ...
douyin-world scene import --uri <wprefab-uri> --name "A_Day3_GLB矩阵"
douyin-world runtime js eval --file measure_day3_bounds.js --runtime-id <R>
```

> 过程记录：初次运行脚本时 attach/build 仍指向 Day-1 的 `probeA`，
> 导致 `day3matrix` 为空（nodes=0）。已改用独立 `day3matrix` 并重新 attach。

## 3. Collider 矩阵（A3）

- `evidence/A3-caps.json`：仅能创建空节点，无原生 primitive。
- `evidence/A3-make-wall.json`：`A3_Wall_Solid` 写入 `physicsColliderData.enableCollision=true`。
- `evidence/A3-scene-import.json`：导入场景。
- `evidence/A3-wall-inspect.json` + `A3-wall-inspect2.json`：运行时
  `Collider=false, BoxCollider=false, MeshCollider=false`（用 `puer.$typeof` 具体类型复查）。
- `evidence/A3-walk-result.json`：真实按 W 4 s 后位置跳回默认出生点（被坠落污染，判 INCONCLUSIVE）。
- 对照：Day-1 `check_collider2.js` 显示 `triggerData` 锚点有 `BoxCollider isTrigger=true`。

## 4. WPRE 交接（A4）

沿用 Day-1 `P06-*`：同机同账号跨工程导入 PASS（层级/碰撞数据/脚本/参数/传送）。
跨账号 / 跨机器 **NOT TESTED**（无第二环境）。
`EDITOR-TECHNICAL-FINDINGS.md` 将该结论收录为 REPRODUCED-LOCAL。

## 5. 接口契约（A5）

`WORLD-INTERFACE-CONTRACT.md` v0.2，字段带 CONFIRMED / PROPOSED / TO-VERIFY。
B/C 的 Entry/Exit 草案来自其 PR #10 / #11 的 HANDOFF.md（通过 GitHub API 读取，
保存在 `D:\zjx\projects\evidence-tmp\bc-handoff\`）。

## 6. Hub 与终点（A6）

- `shared-assets/` 外的终点资源：`make_terminus_day3.py` → `out/terminus-day3.glb`
  （186 KB、103 网格、8 跨肋、115 m 路线、3 条低云带）。
- `evidence/A6-terminus-import.json`：rootIDs ["-338074180"]。
- `evidence/A6-01-final-vista.png`：观景台朝 +Z 的最终视野。
  数值：水平梯度 0.957（低于 Day-1 干净帧 1.35 与条纹帧 1.525）；
  列均值标准差 28.8（画面含真实结构，非高频条纹）。
  **注意：此判断基于数值指标，当前模型未做人眼确认。**
- `evidence/A6-walk-result.json`：真实按 W 6 s，玩家从 z=−5 到 z=12.16，
  穿过 z=3 / z=9 两道肋拱，y 落至甲板 0.002，**通行 PASS**。

## 7. 复现命令速查

```powershell
# 启动实例
douyin-world instance start --project <TrainCore_A> --mode offscreen
douyin-world runtime start --instance <I>

# A2 尺寸
douyin-world runtime js eval --file measure_day3_bounds.js --instance <I> --runtime-id <R>

# A3 碰撞
douyin-world runtime js eval --file a3_inspect_wall2.js --instance <I> --runtime-id <R>

# A6 行走
douyin-world runtime lua eval --file a6_walk_start.lua --instance <I> --runtime-id <R> --global
douyin-world runtime input keys "W:6000" --instance <I> --runtime-id <R>
douyin-world runtime lua eval --file player_pos.lua --instance <I> --runtime-id <R> --global
```
