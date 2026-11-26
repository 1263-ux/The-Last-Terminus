# reports/day-03/A/BLOCKERS.md

> 状态：OPEN / MITIGATED / RESOLVED / NOT TESTED
> 20–30 分钟规则：单条无法解决则记录复现 + 降级，继续独立任务。

---

## D3-1｜P1 GUI 手动原生 Cube 无法由 Agent 完成 —— **OPEN（需真人）**

DAY-03 §57 明确："A 亲自完成 P1 GUI 手动原生 Cube 测试并录屏。"
我通过 CLI 只能创建空节点（`nodes.create` 无 Mesh 参数），**无法等价替代 GUI 手动放 Cube**。

**我不假称完成。** P1 标 NOT TESTED，并已在 `COLLISION-MATRIX.md` 说明。
**需要：成员 A 本人在编辑器 GUI 中放一个原生 Cube 并录屏撞击/落下测试。**

## D3-2｜碰撞根因已确认：玩家是运动学刚体 —— **已修正（B 2026-11-24）**

**⚠ 重大更正**：B 推翻了"物体无法阻挡玩家"的结论。**物体可以阻挡玩家！**

**B 的反证（毫米级几何吻合）**：
```
墙启用   z: 100.99 → 107.53 → 107.53 → 107.53   （三次推进纹丝不动）
墙禁用   z: 107.53 → 113.42                      （前进 5.89 m）

墙前表面 96.391 − 胶囊半径 0.160 = 理论 96.231
实测 96.230（连续三次不动）
```

**根因**：控制器**没有 step-up**——0.20m 矮台平推穿过，1.20m 平台挡住。这解释了早期观察矛盾。

**对全部玩法的影响**：
- **物理碰撞门禁可行**（B 已验证）
- 设计总监 §3.2 否决 C4 的依据失效，需重新裁定
- GLB 导入资产是否能挡住仍未验证（运行时节点数为 0）

## D3-3｜P4（GLB + 手动 Collider）—— **RESOLVED**

P3/GLB 自动 MeshCollider 早期误判为 PASS（短距离巧合），已推翻：
6 秒长距离测试中玩家穿过立方体（z=85→102.89）。**碰撞对运动学玩家无效。**
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
