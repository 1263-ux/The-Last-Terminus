# A｜Hub 中央炉岛：首个可运行候选（真实导入 + 玩家出生实测）

> Owner：成员 A
> 日期：2026-11-26
> 方法：`resource model import → archive → prefab attach → build → export → result archive → scene import --position` → 保存重开 → runtime 验证
> 依据：Issue #23 §2 / 总监 11/26 15:02 裁定（Hub 出生点 + 可运行候选）

---

## 0. 一句话

**中央炉岛 Hub 灰盒已作为真实 GLB 导入到玩家出生点，玩家现在出生在车厢内**
（y 从 78.00 升到 79.17，站在车厢地板上），并在新 runtime 中可连续行走。
这解决了"清场后无 Hub 节点"的问题——**但车厢只走 1.39 m 就被中央炉岛挡住**，
完整 Hub 体验（炉岛绕行、入口/出口提示、四世界连接）仍未完成。

---

## 1. 实测过程（TESTED，2026-11-26 13:45）

### 1.1 源资产
- `train-hub-greybox.glb`（45,804 bytes），26 节点 / 25 mesh / 8 材质；
  bbox 3.8 × 2.35 × 14.0 m；POSITION/NORMAL/TEXCOORD_0 齐全。
- SHA-256（导出 WPrefab）：`c1112da865dd995161b9a3a968d4376d836e0f1f8276af74b150989a33cbf6be`

### 1.2 导入链（按 GLB-RECIPE 验证流程）
```
prefab create hubfinal
resource model import model-hub-greybox --glb train-hub-greybox.glb   (sourceState=topology)
resource archive model-hub-greybox --kind model                        → glb uri
prefab attach hubfinal --kind model --uri <glb uri>                   (26 nodes/26 components)
prefab validate hubfinal  (items=[] 空=通过)
prefab build hubfinal     (hasRuntimeScript=false)
prefab export hubfinal    → hubfinal.wprefab (21,614 bytes)
result archive hubfinal --name "列车Hub中央炉岛"                       → wprefab uri
scene import --uri <wprefab uri> --name "列车Hub中央炉岛" --position 119.74,79.17,88.64
  → status=committed, rootIDs=[-846602940]
scene save  (hasUnsavedChanges=false)
```
证据：`evidence/A-hub-import.json`

### 1.3 关闭 → 重开 → 新 runtime 验证
```
runtime 根：children=6: Env | 地图 | 出生点(119.7,80,88.6) |
           A_终点站_地形级 | A_终点站_路线验证 |
           列车Hub中央炉岛(119.7,79.2,88.6)   ← 新导入
玩家出生：119.74 | 79.17 | 88.64   ← y 从 78.00 升到 79.17，站在车厢地板
```
截图：`evidence/A-hub-inside.png`（386,169 bytes）

### 1.4 车厢内行走实测
| 输入 | 玩家位置 | 说明 |
|---|---|---|
| 出生 | (119.74, 79.17, 88.64) | 车厢内 |
| W 4s | (119.74, 79.19, 90.03) | **前进 1.39 m**，y 稳定 79.19 |
| W 再 5s | (119.75, 79.19, 90.03) | **停住**——中央炉岛挡住去路 |

截图：`evidence/A-hub-walk.png`、`A-hub-walk2.png`

---

## 2. 诚实结论

| 项 | 状态 |
|---|---|
| Hub 中央炉岛 GLB 真实导入 | **PASS** |
| 玩家出生在车厢内（不再落地形顶） | **PASS**（y 78.00→79.17） |
| 保存重开后唯一实例 | **PASS**（6 根，无重复） |
| 车厢内连续行走 | **PARTIAL**（仅 1.39 m，被炉岛挡住） |
| Hub 入口/出口提示、炉岛绕行路线 | **NOT TESTED** |
| Hub → Desk/Garden/Terminus 连接 | **NOT TESTED** |
| 人眼评审 Hub 是否"一眼读出列车" | **NOT TESTED**（本人模型不支持读图，需人眼） |

**注意**：这是"首个可运行候选"，不是 Hub 完成。1.39m 就停说明炉岛确实在路径上——
符合 Scheme 2「中央炉岛」设计，但意味着需要设计绕行/出口路线才能形成完整 Hub 体验。

---

## 3. 下一步（裁定 P0）

1. **人眼评审 Hub 截图**（A-hub-inside.png），确认车厢识别度（我无法读图）。
2. **炉岛绕行**：实测侧向移动（A/D）能否绕过炉岛走向车厢出口；建立入口→炉岛→出口路线。
3. **接线**：Hub 出口 → Desk Entry (119.74,79.41,88.64) / Garden Entry (120,70,105) 的 Trigger。
4. **出生点**：当前出生已靠 Hub 导入位置解决（玩家站在车厢地板）；BornPoint 节点仍是 (119.7,80,88.6)，但玩家实际落点已是 Hub 内，需在 GUI 里正式对齐。

不把"导入 PASS + 出生在车厢内"冒充"Hub 可玩 PASS"或"完整旅程 PASS"。
