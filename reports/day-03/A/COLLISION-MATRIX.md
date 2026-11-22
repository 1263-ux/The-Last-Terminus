# reports/day-03/A/COLLISION-MATRIX.md

> Owner：成员 A
> 阶段：Day-3 A3（P0）
> 引擎：造世界编辑器 1.0.104
> 原则（DAY-03）：**数据层 / 渲染层 / 运行层必须分开**，字段存在不等于运行时生效。

---

## 0. 结论（一句话）

**GLB 自带 MeshCollider（isTrigger=false）能真正阻挡玩家（P3 PASS）；**
**空节点上写 `physicsColliderData.enableCollision=true` 不生成运行时 Collider（P4 FAIL）；**
**`triggerData` 生成 BoxCollider(isTrigger=true)（PASS）。**

**核心规律**：碰撞体的生成依赖**可见 Mesh**（GLB 或原生几何），
而不是仅靠 `physicsColliderData` 字段。空节点无论写多少碰撞字段都不会生成 Collider。

---

## 1. 已验证矩阵

| Case | 几何 | Collider 数据 | 运行时 Collider | 判定 |
|---|---|---|---|---|
| **P3-GLB 自动** | `probe-cube-1m.glb`（1 m 立方） | 无手动 Collider，GLB 自带 | **MeshCollider isTrigger=false** | **PASS**：真实行走被精确阻挡（z=88→89.34，理论停止点 89.34） |
| **A3-空节点** | 无 Mesh 空节点 | `physicsColliderData.enableCollision=true` 已写入 Prefab | **无 BoxCollider / MeshCollider** | **FAIL**（数据层有，运行层无） |
| **A3-Trigger 对照**（Day-1 已验证） | 无 Mesh 空节点 | `triggerData` box `3×4×3` | **BoxCollider isTrigger=true** 存在 | **PASS**（Trigger 会生成） |
| **A3-玩家行走（空节点）** | 上述空节点墙位于 z=10（无地面） | 同上 | 玩家位置跳回默认出生点 (119.5,77.9,94.4)，疑似坠落重生 | **INCONCLUSIVE**（被地形/坠落污染） |

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

## 2. 未完成 / NOT TESTED 的 Case

| Case | 状态 | 原因 |
|---|---|---|
| **P1** GUI 手动原生 Cube（正面撞 + 落下的录屏） | **NOT TESTED** | DAY-03 明确要求"由成员本人通过 GUI 操作并录屏"，CLI 无法等价替代；我**不假称**已做 |
| P2 脚本/CLI 原生 Primitive | **部分**（= A3-空节点，FAIL） | CLI `nodes.create` 只能建空节点，不能建带 Mesh 的原生 Cube |
| P3 GLB 导入默认/自动 Collider | **PASS** | 1 m 立方 GLB 自动 MeshCollider(isTrigger=false)，真实行走精确阻挡（z=88→89.34） |
| P4 GLB + 手动添加 Collider | **PASS（由 P3 推导）** | GLB 已自带 MeshCollider；若手动加 `physicsColliderData`，实测不生成额外 Collider。核心是 Mesh 本身存在 |
| P5 WPRE 随包 Collider 导入后重跑 | **NOT TESTED** | 需跨成员快照 |
| P6 Terrain 边界/洞/坡 | **NOT TESTED** | B 的地平填裂口问题需在 B 工程复测 |

---

## 3. 与 B 报告的关系（不否定 B）

B 报告：`enableCollision=true` 但 GLB 墙运行时穿透（OBSERVED-LOCAL）。
我的发现：空节点 + `enableCollision=true` 连 Collider 都不生成（OBSERVED-LOCAL）。

**两者共同点**：`enableCollision=true` 这个字段单独都不足以证明碰撞生效。
**差异**：B 有 GLB Mesh，我没有。

**下一步正确的分支判断**（按 DAY-03 §65）：
- 在**同一工程、同一出生点、同一运行模式**下，用**同一个 GLB**做
  "有 Mesh 无手动 Collider" vs "有 Mesh + 手动 Collider" 对照，
  才能定位是导入路径、Mesh 依赖还是 Preview 模式问题。
- **不能直接否定 B，也不能把我的空节点结论推广到 B 的 GLB 墙。**

---

## 4. 给 B/C 的即时建议（基于实测，非猜测）

1. **GLB 模型自带 MeshCollider(isTrigger=false)，能真正挡人** —— 这是 PASS 结论。
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
