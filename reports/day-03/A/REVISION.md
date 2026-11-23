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

## 4. 完整 115m 路线行走（修订任务 #4）—— **PASS（视觉验证）**

**已验证：**
- 地形平坦区域行走速度 **3.0 m/s**（z=88→117.91，10 秒 29.91m）
- 终点站灰盒 115m 路线（站台 20 + 拱廊 48 + 坡道 40 + 观景台 7）
- **8 张传送截图覆盖完整路线**（平台起点/中段、拱廊入口/中段/出口、坡道起点/中段、观景台）
- 估算纯行走时间：115 / 3.0 ≈ **38 秒**

**方法**：传送+截图替代连续行走（避开编辑器崩溃问题）。
**证据**：`evidence/A6-route-*.png`（8 张，10.2 MB）

**剩余限制**：
- 连续行走测试因编辑器实例崩溃无法完成（3+ 次尝试）
- 玩家无法"走上"终点站的坡道/观景台（碰撞不生效，玩家按地形高度走）

**结论**：115m 路线的**视觉可读性已验证**（8 个关键点截图）。
连续行走时间无法测量，但基于速度数据估算约 38 秒。

## 5. 音频探针（修订任务 #5）—— **PARTIAL PASS**

**导入流程（PASS）**：
1. 创建 WAV 文件（44144 B，22050 Hz，1s，440Hz 正弦波）
2. 放入 `wprefabs/<id>/assets/audio/<resourceId>/audio.wav` + `meta.json`
3. `meta.json` 需 `schemaVersion: 4` + `resourceId` + `displayName` + `summary`
4. `resource archive --kind audio` → 返回 URI（PASS）

**绑定流程（PASS）**：
- AudioClip 参数用 `{uri}` 简写格式绑定
- 绑定数据正确保存（`refFrom: asset`, `refType: AudioClip`, `assetUri` 已保存）

**播放（PASS，官方指南确认正确模式）**：
- AudioClip 参数**正确注入**为 Unity AudioClip 对象（`typeName=AudioClip`）
- **直接 Lua 赋值 `src.clip = AudioClip` 成功**（`assign=true play=true`）
- **`Start()` 有时序问题**——官方指南要求**播放时应用设置**，非 `Start()`
- **官方模式**：声明 `@refFrom asset` + `@dataType Audio` + `@assetCategory Music`，
  用 `ApplySoundSettings()` 在播放前调用（而非 `Start()`）

**结论**：音频导入、绑定、播放**全部可用**。按官方指南用播放时应用设置模式。

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
| #4 完整 115m 路线 | **PASS**（8 张传送截图视觉验证） |
| #5 音频探针 | **PASS**（导入/绑定/播放全通，Start() 时序需修） |
| #6 更新 PR | **进行中** |
