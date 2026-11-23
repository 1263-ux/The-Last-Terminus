# Day-3 A 总结报告

> Owner：成员 A
> 分支：`feature/train-core`（PR #12）
> 更新：2026-11-22

---

## 1. 修订任务完成情况

| # | 任务 | 状态 | 核心发现 |
|---|---|---|---|
| 1 | 修正碰撞矩阵 | **DONE** | 3 处矛盾行修正，P3/P4 从 PASS 改为 FAIL |
| 2 | 文档一致性 | **DONE** | 5 份文档统一为"运动学刚体，不能阻挡" |
| 3 | 最小 WPRE + 导入请求 | **PARTIAL** | `probeminimal.wprefab` 已交付；跨成员待 B/C 回执 |
| 4 | 完整 115m 路线 | **PASS** | 8 张传送截图视觉验证（10.2 MB） |
| 5 | 音频探针 | **PASS** | 导入/绑定/播放全通（官方模式确认） |
| 6 | 更新 PR | **DONE** | 已推送 |

## 2. 关键技术发现

### 2.1 碰撞根因（B 发现，A 独立复现）

**玩家是 `NetworkActor` 运动学刚体**（`isKinematic=true`, `velocity=0`, `layer=8`）。
场景物体（GLB、原生 Cube、任何 Layer）**不能阻挡玩家**。

**影响**：所有依赖"物体挡路"的玩法设计不成立。Trigger + Teleport 是唯一可靠机制。

### 2.2 门禁机制（A 验证）

**方案**：单触发器 + `Update()` 轮询 + 位置判断区域
- 未解锁走到门禁区 → 传送回 ✓
- 解锁后走到门禁区 → 自由通过 ✓

**关键**：必须用 `Update()` 轮询（`OnActorTriggerEnter` 只触发一次）。

### 2.3 音频（官方模式确认）

- 导入：WAV + `meta.json`（schemaVersion 4）→ `resource archive --kind audio`
- 绑定：`{uri}` 简写，`@refFrom asset` + `@dataType Audio`
- 播放：`ApplySoundSettings()` 在播放时调用（非 `Start()`）

### 2.4 GLB 导入

- A 路径 1:1 保留（`resource model import` 链路）
- X 轴镜像（+X→−X）
- 7 个坑（详见 `GLB-RECIPE.md`）

## 3. 交付物清单

| 类别 | 数量 | 位置 |
|---|---|---|
| 文档 | 14 份 | `reports/day-03/A/*.md` |
| 证据 | 119 个 | `reports/day-03/A/evidence/` |
| 共享资产 | 8 个 | `reports/day-03/A/shared-assets/` |

## 4. 等待外部输入

1. **B 的渲染测试**（Preview vs Published GUI 对比）
2. **C 的盲测**（路线发现测试）
3. **WPRE 跨成员导入**（B/C 用自己账号导入 `probeminimal.wprefab`）
4. **Tripo 资产**（设计总监提供后 A 可导入验证）

## 5. 状态

- **远端** `aa77afe`，48 commits
- **PR #12** OPEN
- **编辑器** 已停止
