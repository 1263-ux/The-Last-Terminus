# reports/day-03/A/BLOCKERS.md

> 状态：OPEN / MITIGATED / RESOLVED / NOT TESTED
> 20–30 分钟规则：单条无法解决则记录复现 + 降级，继续独立任务。

---

## D3-1｜P1 GUI 手动原生 Cube 无法由 Agent 完成 —— **OPEN（需真人）**

DAY-03 §57 明确："A 亲自完成 P1 GUI 手动原生 Cube 测试并录屏。"
我通过 CLI 只能创建空节点（`nodes.create` 无 Mesh 参数），**无法等价替代 GUI 手动放 Cube**。

**我不假称完成。** P1 标 NOT TESTED，并已在 `COLLISION-MATRIX.md` 说明。
**需要：成员 A 本人在编辑器 GUI 中放一个原生 Cube 并录屏撞击/落下测试。**

## D3-2｜`physicsColliderData` 不生成运行时 Collider —— **OPEN（已定位到现象）**

现象：空节点写 `physicsColliderData.enableCollision=true` 并保存，运行时无 Box/Mesh Collider
（用 `puer.$typeof` 具体类型复查，`A3-wall-inspect2.json`）。
对照：`triggerData` 会生成 `BoxCollider isTrigger=true`。

**已做最小验证**：确认不是 PuerTS 类型转换假阴性（具体类型复查仍 false）。
**降级**：碰撞判定一律以运行时 `GetComponent` + 真实行走为准，不看数据层字段。
**未决**：是否需要 Mesh 共存才能生成实体 Collider（P4 未完成，见 D3-3）。

## D3-3｜P4（GLB + 手动 Collider）未完成 —— **NOT TESTED**

尝试给空节点手填 `glbSliceData` 时被占位 URI 阻断；改用 `prefab attach` 正规路径又涉及
追加新实例，与"同一节点加 Collider"的目标不一致。按 20–30 分钟规则停止深挖。
下一步：在干净 Prefab 中 attach 一个 GLB cube，再对该节点 `components.add(physicsColliderData)`，
重新 build/import 并用 `a3_inspect_wall2.js` 复查。

## D3-4｜真实行走撞击测试被地形/坠落污染 —— **INCONCLUSIVE**

从 z=5 走向 z=10 的空节点墙，玩家最终跳回默认出生点 (119.5,77.9,94.4)，
疑似坠落触发 respawn（墙在 y=1，地面在 y≈77.9 的平台之外）。
**不能单凭此判碰撞**。下一步需在已确认有地面的平台上重复，或把墙放到出生点平台内。

## D3-5｜WPRE 跨账号未测 —— **NOT TESTED（保持）**

无第二账号 / 第二机器环境。同机同账号跨工程 PASS（REPRODUCED-LOCAL）。
**需要**：B 或 C 用自己账号导入最小 WPRE 并回执，否则按总设计师要求保持 NOT TESTED + 裸 GLB 兜底。

## D3-6｜B/C 的 `spawn_yaw` 数值未回填 —— **OPEN（阻塞集成串联）**

B/C 的 HANDOFF 都只给了文字朝向（"面向 -Z 暖窗" / "面向 +X 温室"），没给度数。
`INTEGRATION-RESPONSE.md` 已请求。**不等待**：先继续白盒与文档，数值到达后直接填 Anchor。

## D3-7｜Git push 时好时坏 —— **MITIGATED**

`github.com:443` git 传输在本机频繁 `Recv failure: Connection was reset`；
`api.github.com` 稳定。最终用 Git Data API（`base_tree` 方案）成功推送了最后一个 commit
到 PR #12，并把本地 reset 到远端 hash（`a393ed8`）保持一致。
经验已写入 `day-01/A/BLOCKERS.md` B-1。后续 push 优先普通 git，失败则 API 兜底。

## D3-8｜当前模型不支持读图 —— **MITIGATED**

我无法用 `read_image` 人眼确认截图。对最终视野帧改用 PIL 数值指标
（水平梯度 / 列均值标准差）与已知干净帧、条纹帧对照。
**结论标为"基于数值，未做人眼确认"**，留给总设计师 Review 时目视判定。
