# Day-3 A 总结报告

> Owner：成员 A
> 分支：`feature/train-core`（PR #12）
> 日期：2026-11-22

---

## 1. 今日完成

| 项 | 状态 | 核心发现 |
|---|---|---|
| A1 共享测试资产 | **PASS** | 5 个 GLB（1/2/4m Cube + 轴标 + 贴图），SHA-256 齐全 |
| A2 GLB 导入矩阵 | **PASS** | A 路径 1:1 保留；X 轴镜像 REPRODUCED；B 的 sqrt(T) 是路径局部经验 |
| A3 Collider 矩阵 | **CONFIRMED** | **玩家是运动学刚体，场景物体不可能挡人** |
| A4 WPRE 交接 | **NOT TESTED** | 同机同账号 PASS；跨账号需 B/C 配合 |
| A5 接口契约 v0.2 | **PASS** | 全部字段带 CONFIRMED/PROPOSED/TO-VERIFY |
| A6 Hub/终点白盒 | **PASS** | 入口/出口提示、占位往返、终点视野 |
| Gate D3 占位往返 | **PASS** | HubEntry↔TerminusExit Trigger+Teleport 端到端 |

## 2. 今日最重要的发现

### 2.1 碰撞根因（B 发现，A 独立复现）

**玩家是 `NetworkActor` 运动学刚体**（`isKinematic=true`, `Rigidbody.velocity=0`, `layer=8`），
位移由脚本写 `transform`，物理求解器不参与。**任何场景物体都不可能阻挡玩家。**

A 的独立验证：
- 玩家刚体状态确认（`A3-player-full-stack.json`）
- 6 秒穿入测试：z=85→102.89，穿过 z=90 的立方体（`A3-kinematic-walk.json`）
- 之前 P3 的"精确阻挡"是误判（短距离巧合）

**影响**：所有依赖"物体挡路"的玩法设计不成立。Trigger + Teleport 是唯一可靠机制。

### 2.2 渲染限制（B 发现）

`CreatePrimitive` 创建的对象只参与阴影渲染，不参与主渲染。
GLB 模型正常渲染（A 有 6 个资产的截图证据）。
**建议：场景视觉用 GLB，primitive 只做逻辑探针。**

### 2.3 GLB 导入尺寸规则

A 的导入路径（`resource model import → archive → prefab → scene import`）**1:1 保留**。
B 的 `sqrt(T)` 是直接 `scene import` 裸 GLB 路径的局部经验，**不能升为全局公式**。

## 3. 给总设计师的决策请求

1. **碰撞不可用** → B 建议的 E1（触发器判定）/ E2（状态门）是否接受？
2. **渲染限制** → 是否接受"GLB 做视觉、primitive 做逻辑"的方案？
3. **Gate D3** → A 的技术矩阵 + 占位往返 + 接口 v0.2 是否满足要求？

## 4. 给 B/C 的即时可用结论

1. **GLB 渲染正常**（6 个资产截图证据），请改用 GLB 做场景视觉。
2. **碰撞对玩家无效**，请用 Trigger + Teleport 实现门禁/传送。
3. **共享测试资产**在 `reports/day-03/A/shared-assets/`，请使用同一份。
4. **接口契约 v0.2** 在 `WORLD-INTERFACE-CONTRACT.md`，请回填 `spawn_yaw` 数值。

## 5. 状态

- **远端** `8a205b1`，23 commits
- **PR #12** OPEN，181+ files
- **编辑器** 已停止
- **所有 Day-3 A 交付物** 已推送
