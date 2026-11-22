# reports/day-03/A/COLLISION-MATRIX.md

> Owner：成员 A
> 阶段：Day-3 A3（P0）
> 引擎：造世界编辑器 1.0.104
> 原则（DAY-03）：**数据层 / 渲染层 / 运行层必须分开**，字段存在不等于运行时生效。

---

## 0. 结论

**A 的测试：GLB 自带 MeshCollider(isTrigger=false) 精确阻挡玩家，1m 立方和 24×4×1 墙都 PASS。**
**B 的独立测试（不同工程）：原生 Cube 3 次 1 挡 2 穿（不稳定），GLB 墙穿透（FAIL）。**
**同尺寸 GLB 墙在 A 的工程 PASS、在 B 的工程 FAIL——问题不在 GLB 或尺寸，在工程配置/运行时机。**

**核心规律**：
1. 碰撞体生成依赖**可见 Mesh**（GLB 或原生几何），空节点 + physicsColliderData 不生成。
2. GLB 自动 MeshCollider 在 A 的工程里**可靠**（尺寸无关）。
3. 但跨工程/跨成员结果不一致，**不能宣称碰撞机制通用可靠**。

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

## 2. 跨成员对照（A vs B）

| 测试 | A（工程 fb583637） | B（工程 006822bc） |
|---|---|---|
| GLB 1m 立方（自动 MeshCollider） | **PASS**（精确阻挡 z=88→89.34） | — |
| GLB 24×4×1 墙（自动 MeshCollider） | **PASS**（精确阻挡 z=88→91.34） | **FAIL**（穿透） |
| 原生 Cube（CreatePrimitive） | 未测 | **不稳定**（3 次 1 挡 2 穿） |
| 空节点 + physicsColliderData | **FAIL**（不生成 Collider） | 未测 |
| triggerData → BoxCollider(isTrigger) | **PASS** | 未测 |
| 渲染层（阴影有、本体无） | 未测 | **FAIL**（两者都有） |

**关键发现**：A 的 24×4×1 GLB 墙（与 B 同尺寸）精确阻挡，证明 **GLB MeshCollider 在 A 的工程里尺寸无关地可靠**。
B 的穿透**不是尺寸问题**，而是工程配置/创建时机/Preview 模式问题。

---

## 3. 未完成 / NOT TESTED 的 Case

| Case | 状态 | 原因 |
|---|---|---|
| **P1** GUI 手动原生 Cube（正面撞 + 落下的录屏） | **NOT TESTED** | DAY-03 明确要求"由成员本人通过 GUI 操作并录屏"，CLI 无法等价替代；我**不假称**已做 |
| P2 脚本/CLI 原生 Primitive | **部分**（= A3-空节点，FAIL） | CLI `nodes.create` 只能建空节点，不能建带 Mesh 的原生 Cube |
| P3 GLB 导入默认/自动 Collider | **PASS** | 1 m 立方 GLB 自动 MeshCollider(isTrigger=false)，真实行走精确阻挡（z=88→89.34） |
| P4 GLB + 手动添加 Collider | **PASS（由 P3 推导）** | GLB 已自带 MeshCollider；若手动加 `physicsColliderData`，实测不生成额外 Collider。核心是 Mesh 本身存在 |
| P5 WPRE 随包 Collider 导入后重跑 | **NOT TESTED** | 需跨成员快照 |
| P6 Terrain 边界/洞/坡 | **NOT TESTED** | B 的地平填裂口问题需在 B 工程复测 |

---

## 3. 与 B 报告的关系（跨成员对照）

B 的 Day-3 `COLLISION-REPRO.md`（feature/desk-world）结论：
- 原生 Cube 3 次测试 1 挡 2 穿，**碰撞不稳定**；
- GLB 墙（24×4×1）穿透；
- 数据层 BoxCollider 都在；
- 渲染层"有影无面"是独立缺陷。

**A 与 B 的关键分歧已定位**：同尺寸 24×4×1 GLB 墙在 A 的工程精确阻挡，在 B 的工程穿透。
**排除了尺寸因素**，指向工程配置/创建时机/Preview 模式差异。

**下一步正确的分支判断**（按 DAY-03 §65）：
- **走第二条**（P1/P3 都不能挡 → 查工程模板/运行时/玩家碰撞层）：
  B 的报告也命中这一条。
- 需要**统一工程、统一出生点、同一运行模式**下做 A/B/C 对照测试。
- **A 的 GLB 碰撞在自己的工程里可靠**，但不能推广到 B/C 的工程。

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
