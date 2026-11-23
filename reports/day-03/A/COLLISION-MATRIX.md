# reports/day-03/A/COLLISION-MATRIX.md

> Owner：成员 A
> 阶段：Day-3 A3（P0）
> 引擎：造世界编辑器 1.0.104
> 原则（DAY-03）：**数据层 / 渲染层 / 运行层必须分开**，字段存在不等于运行时生效。

---

## 0. 结论

**玩家是 `NetworkActor` 运动学刚体（isKinematic=true, velocity=0），场景物体不可能阻挡。**
B 的根因分析在 A 的工程里完全复现（`A3-player-full-stack.json`）。

**A 的 P3"精确阻挡"是误判**——玩家在 4 秒短距离测试中碰巧停在 z=89.34，
但 6 秒长距离测试中直接穿过立方体（z=85→102.89，经过 z=90 的立方体无阻挡）。
**碰撞机制对玩家无效，任何依赖"物体挡路"的玩法设计都不成立。**

---

## 1. 已验证矩阵

| Case | 几何 | Collider 数据 | 运行时 Collider | 判定 |
|---|---|---|---|---|
| **P3-GLB 自动** | `probe-cube-1m.glb`（1 m 立方） | GLB 自带 MeshCollider(isTrigger=false) | 存在 | **FAIL**（玩家穿过，6 秒测试 z=85→102.89） |
| **P3-GLB 大墙** | `wall-24x4x1.glb`（24×4×1） | GLB 自带 MeshCollider(isTrigger=false) | 存在 | **FAIL**（同上，B 也确认） |
| **A3-空节点** | 无 Mesh 空节点 | `physicsColliderData.enableCollision=true` | **无 Collider** | **FAIL**（不生成） |
| **A3-Trigger 对照** | 无 Mesh 空节点 | `triggerData` box | **BoxCollider isTrigger=true** | **PASS**（Trigger 有效） |
| **玩家刚体** | — | — | **isKinematic=true, velocity=0** | **根因确认** |

### 1.1 关键对照：`triggerData` 生成 Collider，`physicsColliderData` 不生成

| 组件 | 写入位置 | 运行时结果 |
|---|---|---|
| `triggerData = [{shape:"box", center, size, enabled:true}]` | Day-1 P05 锚点节点 | 运行时 `BoxCollider isTrigger=true enabled=true` |
| `physicsColliderData = {enableCollision:true, ...}` | Day-3 A3_Wall_Solid 节点 | 运行时 `Collider=false, BoxCollider=false, MeshCollider=false` |

**这两条是同类节点（都是空节点、都没有 Mesh），唯一差别是组件类型。**
→ 结论：`triggerData` 会生成 BoxCollider；**`physicsColliderData` 单独不会**。

> 可能原因：`physicsColliderData` 需要配合 Mesh / `glbSliceData` / `aigcModelData`
> 才能附着 Collider 形状。这是 HYPOTHESIS，需 P4（GLB + 手动 Collider）验证。

### 1.2 查询方法（避免假阴性）

我先用基类 `puer.$typeof(CS.UnityEngine.Collider)` 查询得 false，
再用具体类型 `BoxCollider` / `MeshCollider` 复查仍为 false（`A3-wall-inspect.json`、
`A3-wall-inspect2.json`），排除了 Day-1 曾遇到过的"PuerTS 类型转换错误导致的假阴性"。

---

## 2. 跨成员对照（A vs B）—— 根因已确认

| 测试 | A（工程 fb583637） | B（工程 006822bc） |
|---|---|---|
| GLB 1m 立方 | **FAIL**（穿入，6s 测试 z=85→102.89） | — |
| GLB 24×4×1 墙 | **FAIL**（同上） | **FAIL**（穿透） |
| 原生 Cube | 未测 | **FAIL**（3 次 1 挡 2 穿，第 1 次为时序巧合） |
| 空节点 + physicsColliderData | **FAIL**（不生成 Collider） | 未测 |
| triggerData → BoxCollider(isTrigger) | **PASS** | 未测 |
| **玩家刚体状态** | **isKinematic=true, velocity=0** | **isKinematic=true, velocity=0** |

**根因（B 发现，A 独立复现）**：玩家是 `NetworkActor` 运动学刚体，
位移由脚本写 `transform`，`Rigidbody.velocity` 恒 0，物理求解器不参与。
**场景物体（GLB、原生 Cube、任何 Layer）都不可能阻挡玩家。**

A 的 P3"精确阻挡"是**误判**：4 秒短距离测试中玩家碰巧停在 z=89.34（地形/斜坡影响），
6 秒长距离测试中直接穿过。**不能把单次巧合当作碰撞可用的证据。**

---

## 3. 未完成 / NOT TESTED 的 Case

| Case | 状态 | 原因 |
|---|---|---|
| **P1** GUI 手动原生 Cube（正面撞 + 落下的录屏） | **NOT TESTED** | DAY-03 明确要求"由成员本人通过 GUI 操作并录屏"，CLI 无法等价替代；我**不假称**已做 |
| P2 脚本/CLI 原生 Primitive | **部分**（= A3-空节点，FAIL） | CLI `nodes.create` 只能建空节点，不能建带 Mesh 的原生 Cube |
| P3 GLB 导入默认/自动 Collider | **FAIL** | GLB 自动 MeshCollider 存在，但玩家是运动学刚体，**不被阻挡**。早期"精确阻挡"是误判（见 §2 超级注释） |
| P4 GLB + 手动添加 Collider | **FAIL** | 同 P3——碰撞体存在但对运动学玩家无效；空节点 + physicsColliderData 也不生成 Collider |
| P5 WPRE 随包 Collider 导入后重跑 | **NOT TESTED** | 需跨成员快照 |
| P6 Terrain 边界/洞/坡 | **NOT TESTED** | B 的地平填裂口问题需在 B 工程复测 |

---

## 3. 与 B 报告的关系（跨成员对照）

B 的 Day-3 `COLLISION-REPRO.md`（feature/desk-world）结论：
- 原生 Cube 3 次测试 1 挡 2 穿，**碰撞不稳定**；
- GLB 墙（24×4×1）穿透；
- 数据层 BoxCollider 都在；
- 渲染层"有影无面"是独立缺陷。

**A 与 B 的根因一致**：玩家是运动学刚体（`isKinematic=true`, `velocity=0`），
场景物体（GLB、原生 Cube、任何 Layer）都不可能阻挡玩家。
A 的早期"精确阻挡"是短距离测试的误判，已被 6 秒长距离穿入测试推翻。

**下一步正确的分支判断**（按 DAY-03 §65）：
- **走第二条**（P1/P3 都不能挡 → 查工程模板/运行时/玩家碰撞层）：
  根因已定位：运动学刚体 + transform 驱动。
- **所有玩法改用 Trigger + Teleport**，不依赖实体碰撞。

---

## 4. 给 B/C 的即时建议（基于实测，非猜测）

1. **场景物体（GLB、原生 Cube）不能阻挡玩家** —— 玩家是运动学刚体，这是根因。
2. **空节点 + `physicsColliderData` 不会生成 Collider** —— 不要只写字段，要有 Mesh。
3. **`triggerData` 会生成 BoxCollider(isTrigger=true)** —— 触发器走独立路径。
4. 墙"有阴影但看不到实体"是**渲染问题**（查 NORMAL），与碰撞分开诊断。
5. **碰撞判定请用运行时 `GetComponent` + 真实行走，不看数据层字段。**

---

## 5. 附录：可复现命令

```powershell
# 建空节点 + 实体 collider 数据
douyin-world authoring prefab execute day3matrix --file a3_make_wall.js --instance <I> --workspace-id <W>

# 构建并导入场景
douyin-world authoring prefab build day3matrix --workspace-id <W> --instance <I>
douyin-world authoring result archive day3matrix --workspace-id <W> --instance <I> --name "..."
douyin-world scene import --instance <I> --uri <uri> --name "A3墙"

# 运行时查 collider（注意用 puer.$typeof 具体类型）
douyin-world runtime js eval --file a3_inspect_wall2.js --instance <I> --runtime-id <R>
# → {Collider:false, BoxCollider:false, MeshCollider:false}

# 对照：Day-1 的 triggerData 锚点
douyin-world runtime js eval --file check_collider2.js --instance <I> --runtime-id <R>
# → {BoxCollider, isTrigger:true}
```

证据文件：`evidence/A3-make-wall.json`、`A3-scene-import.json`、
`A3-wall-inspect.json`、`A3-wall-inspect2.json`、`A3-walk-result.json`。
