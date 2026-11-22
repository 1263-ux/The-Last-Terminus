# reports/day-03/A/BLOCKERS.md

> 状态：OPEN / MITIGATED / RESOLVED / NOT TESTED
> 20–30 分钟规则：单条无法解决则记录复现 + 降级，继续独立任务。

---

## D3-1｜P1 GUI 手动原生 Cube 无法由 Agent 完成 —— **OPEN（需真人）**

DAY-03 §57 明确："A 亲自完成 P1 GUI 手动原生 Cube 测试并录屏。"
我通过 CLI 只能创建空节点（`nodes.create` 无 Mesh 参数），**无法等价替代 GUI 手动放 Cube**。

**我不假称完成。** P1 标 NOT TESTED，并已在 `COLLISION-MATRIX.md` 说明。
**需要：成员 A 本人在编辑器 GUI 中放一个原生 Cube 并录屏撞击/落下测试。**

## D3-2｜碰撞根因已确认：玩家是运动学刚体 —— **CONFIRMED（P0 级，影响全部玩法）**

**根因（B 发现，A 独立复现）**：玩家是 `NetworkActor` 运动学刚体
（`isKinematic=true`, `Rigidbody.velocity=0`, `layer=8`），位移由脚本写 `transform`。
**物理求解器不参与，场景物体不可能阻挡玩家。**

**A 的独立验证**（`A3-player-full-stack.json` + `A3-kinematic-walk.json`）：
- 玩家刚体状态：isKinematic=true, velocity=(0,0,0) ✓
- 6 秒长距离行走测试：从 z=85 穿过 z=90 的立方体到达 z=102.89 ✓
- 之前 P3 的"精确阻挡"是误判（短距离巧合）。

**对全部玩法的影响**：
- **任何依赖"物体挡路"的设计都不成立**（C4、尺子桥、书桌站障碍等）。
- **Trigger + Teleport 是唯一可靠的交互机制**（已验证）。
- B 建议的 E1（触发器判定）/ E2（状态门）是正确方向，需总设计师裁定。

**降级**：所有玩法设计改用 Trigger + Teleport，不依赖实体碰撞。

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
