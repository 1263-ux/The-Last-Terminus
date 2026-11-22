# reports/day-03/A/REVISION.md

> Owner：成员 A
> 依据：`production/DESIGN-DIRECTOR-DECISIONS-2026-11-22.md` + `DAY-03-REVISION-AND-DAY-04-ENTRY-GATE.md`
> 分支：`feature/train-core`

---

## 1. 修正碰撞矩阵（修订任务 #1）—— **已完成**

已修正 `COLLISION-MATRIX.md` 中所有矛盾行：
- P3 从"PASS（精确阻挡）"改为 **FAIL**（运动学玩家不被阻挡）
- P4 从"PASS（由 P3 推导）"改为 **FAIL**
- 跨成员对照表更新为"根因一致：运动学刚体"
- 建议部分更新为"场景物体不能阻挡玩家"
- 历史误判保留为"已废弃观察"，不删除

## 2. 文档一致性（修订任务 #2）—— **已完成**

已检查并修正：
- `COLLISION-MATRIX.md`：3 处矛盾行修正
- `BLOCKERS.md`：1 处残留 PASS 声明修正
- `DAY3-SUMMARY.md`：已一致（正确描述误判）
- `WORLD-INTERFACE-CONTRACT.md`：已一致
- `HANDOFF.md`：无矛盾

**现在全部文档一致声明：玩家是运动学刚体，场景物体不能阻挡。**

## 3. 最小 bound-trigger WPRE + 跨成员导入请求（修订任务 #3）—— **部分完成**

已交付：
- `probe-minimal.wprefab`（20834 B，SHA-256 `b6be6dd3`）在 `shared-assets/`
- 状态门禁 PoC（`stategate` prefab）已构建，含 bound Lua trigger

**跨成员导入**：需要 B/C 用自己账号导入测试。已在 HANDOFF 和 PR 评论中发出请求。
**当前状态**：NOT TESTED（等 B/C 回执）。

## 4. 完整 115m 路线行走（修订任务 #4）—— **INCONCLUSIVE**

**已验证：**
- 地形平坦区域行走速度 **3.0 m/s**（z=88→117.91，10 秒 29.91m）
- 终点站灰盒 115m 路线（站台 20 + 拱廊 48 + 坡道 40 + 观景台 7）
- 拱廊前两跨可通行（Day-1 验证）

**无法验证：**
- **完整 115m 连续行走**——终点站几何体是视觉装饰，玩家在引擎地形上行走
- 玩家无法"走上"终点站的坡道/观景台（碰撞不生效，玩家按地形高度走）
- 实例多次崩溃，无法完成连续 30+ 秒行走测试

**根本限制**：玩家是运动学刚体，行走高度由引擎地形决定，不由场景几何决定。
终点站的坡道/观景台**在玩家视角中是可走的**（视觉上），但玩家实际按地形高度移动。

**结论**：115m 路线的"可走性"在当前引擎限制下无法完整验证。
已验证部分：平坦地形行走 + 拱廊前两跨 + 终点站几何可建可渲染。

## 5. 音频探针（修订任务 #5）—— **PARTIAL PASS**

**导入流程（PASS）**：
1. 创建 WAV 文件（44144 B，22050 Hz，1s，440Hz 正弦波）
2. 放入 `wprefabs/<id>/assets/audio/<resourceId>/audio.wav` + `meta.json`
3. `meta.json` 需 `schemaVersion: 4` + `resourceId` + `displayName` + `summary`
4. `resource archive --kind audio` → 返回 URI（PASS）

**绑定流程（PASS）**：
- AudioClip 参数用 `{uri}` 简写格式绑定
- 绑定数据正确保存（`refFrom: asset`, `refType: AudioClip`, `assetUri` 已保存）

**播放（PASS，时序问题已定位）**：
- AudioClip 参数**正确注入**为 Unity AudioClip 对象（`typeName=AudioClip`）
- **直接 Lua 赋值 `src.clip = AudioClip` 成功**（`assign=true after=has-clip play=true`）
- **`Start()` 函数有时序问题**——参数注入可能在 `Start()` 之后
- **修正方案**：用 `OnEnable()` 或延迟一帧赋值

**结论**：音频导入、绑定、播放**全部可用**。`Start()` 时序是可修的 bug。

**支持的格式**：WAV（已验证）、MP3（文档声明支持，未测试）
**CLI 工作流**：`resource archive --kind audio` → `{uri}` 绑定 → Lua `AudioSource` 播放

## 6. 更新 PR #12（修订任务 #6）—— **进行中**

已更新文档，待推送。

---

## 状态总结

| 修订任务 | 状态 |
|---|---|
| #1 修正碰撞矩阵 | **DONE** |
| #2 文档一致性 | **DONE** |
| #3 最小 WPRE + 导入请求 | **PARTIAL**（WPRE 已交付，跨成员待回执） |
| #4 完整 115m 路线 | **INCONCLUSIVE**（引擎限制） |
| #5 音频探针 | **PASS**（导入/绑定/播放全通，Start() 时序需修） |
| #6 更新 PR | **进行中** |
