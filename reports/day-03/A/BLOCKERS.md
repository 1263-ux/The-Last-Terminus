# reports/day-03/A/BLOCKERS.md

> 状态：OPEN / MITIGATED / RESOLVED / NOT TESTED
> 20–30 分钟规则：单条无法解决则记录复现 + 降级，继续独立任务。

---

## D3-1｜P1 GUI 手动原生 Cube 无法由 Agent 完成 —— **OPEN（需真人）**

DAY-03 §57 明确："A 亲自完成 P1 GUI 手动原生 Cube 测试并录屏。"
我通过 CLI 只能创建空节点（`nodes.create` 无 Mesh 参数），**无法等价替代 GUI 手动放 Cube**。

**我不假称完成。** P1 标 NOT TESTED，并已在 `COLLISION-MATRIX.md` 说明。
**需要：成员 A 本人在编辑器 GUI 中放一个原生 Cube 并录屏撞击/落下测试。**

## D3-2｜碰撞不稳定（跨成员确认）—— **OPEN（P0 级）**

A 实测：GLB 1m 立方精确阻挡（PASS）；空节点 + physicsColliderData 不生成 Collider（FAIL）。
B 独立实测（不同工程）：原生 Cube 3 次 1 挡 2 穿（不稳定），GLB 墙穿透（FAIL）。

**碰撞机制跨成员结果不一致，不能宣称可靠。** 这是 Day-3 的 P0 问题。
**降级**：所有玩法设计暂不依赖"实体阻挡"，用 Trigger + Teleport 替代。
**需要**：统一工程/统一配置下的 A/B/C 对照测试（B 的报告 §6 列了 4 条需要人做的验证）。

## D3-3｜P4（GLB + 手动 Collider）—— **RESOLVED**

P3/GLB 自动 MeshCollider 实测 PASS：`probe-cube-1m.glb` 放在出生点平台（119.74, 78.4, 90），
真实行走被精确阻挡（z=88→89.34，理论停止点 89.34）。
**结论**：碰撞体的生成依赖可见 Mesh，GLB 自带 MeshCollider(isTrigger=false) 即可挡人；
空节点 + `physicsColliderData` 不生成 Collider。详见 `COLLISION-MATRIX.md`。

## D3-4｜真实行走撞击测试被地形/坠落污染 —— **INCONCLUSIVE**

从 z=5 走向 z=10 的空节点墙，玩家最终跳回默认出生点 (119.5,77.9,94.4)，
疑似坠落触发 respawn（墙在 y=1，地面在 y≈77.9 的平台之外）。
**不能单凭此判碰撞**。下一步需在已确认有地面的平台上重复，或把墙放到出生点平台内。

## D3-5｜WPRE 跨账号未测 —— **NOT TESTED（保持）**

无第二账号 / 第二机器环境。同机同账号跨工程 PASS（REPRODUCED-LOCAL）。
**需要**：B 或 C 用自己账号导入最小 WPRE 并回执，否则按总设计师要求保持 NOT TESTED + 裸 GLB 兜底。

## D3-6｜B/C 的 `spawn_yaw` 数值未回填 —— **MITIGATED（占位往返已跑通）**

B/C 的 HANDOFF 都只给了文字朝向（"面向 -Z 暖窗" / "面向 +X 温室"），没给度数。
`INTEGRATION-RESPONSE.md` 已请求。**占位往返已跑通**（HubEntry z=88↔TerminusExit z=100），
等数值到位后替换锚点坐标即可。证据：`HUB-AND-TERMINUS-UPDATE.md` §3.5。

## D3-7｜Git push 时好时坏 —— **MITIGATED**

`github.com:443` git 传输在本机频繁 `Recv failure: Connection was reset`；
`api.github.com` 稳定。最终用 Git Data API（`base_tree` 方案）成功推送了最后一个 commit
到 PR #12，并把本地 reset 到远端 hash（`a393ed8`）保持一致。
经验已写入 `day-01/A/BLOCKERS.md` B-1。后续 push 优先普通 git，失败则 API 兜底。

## D3-8｜当前模型不支持读图 —— **MITIGATED**

我无法用 `read_image` 人眼确认截图。对最终视野帧改用 PIL 数值指标
（水平梯度 / 列均值标准差）与已知干净帧、条纹帧对照。
**结论标为"基于数值，未做人眼确认"**，留给总设计师 Review 时目视判定。
