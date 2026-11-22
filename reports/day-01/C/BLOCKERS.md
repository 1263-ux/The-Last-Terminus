# 失重花园｜Day 01 阻塞与降级

> Owner：成员 C
> 记录规则：每条阻塞必须包含「影响范围 / 已做的最小验证 / 复现步骤 / 最低成本降级 / 需要谁提供什么」。
> 只有受影响的子任务被冻结，其余工作继续（`COORDINATION-PROTOCOL.md` §5）。

**当前状态：B-02 已于当天攻破。剩余阻塞全部局部化，Day 1 主线交付未被阻断。**

| 编号 | 阻塞 | 状态 |
|---|---|---|
| B-01 | 新实例登录状态准备失败 | 已绕过（环境级） |
| B-02 | GLB 材质被统一覆盖 | ✅ **已解决** |
| B-03 | AI 地形不支持浮空岛 | 已降级，待确认 |
| B-04 | PCG 参考图确认无法回答 | 未解决（外部依赖） |
| B-05 | `prefab attach` 是追加不是替换 | 已掌握，非阻塞 |

---

## B-01｜新实例登录状态准备失败

**状态**：已绕过（环境级），未根治
**影响**：所有成员启动新实例都会遇到
**冻结范围**：无（已绕过）

### 现象与复现

```
douyin-world instance start --project <新项目> --mode offscreen
→ ✗ Creator 在发布实例入口前退出
```

profile 目录里只有 `.awc-auth-bootstrap.lease`（0 字节）与 `awc-launch.log`，日志内容（GBK）：

> 独立实例登录状态准备失败，请确认认证源可用或改用新的独立 profile

对比一个 11-21 建好的可用 profile：它有 `config.json`（含 userinfo）、完整的 `session/`（Cookies、Local Storage、IndexedDB 等）。

### 已做的最小验证

1. 新 profile 直接重试 3 次 → 全部同样失败。
2. 对一个历史项目（`晶体收集试炼`）启动 → 同样失败。**说明不是新项目的问题**。
3. 把可用 profile 的 `config.json` + `session/` 复制进新 profile → 仍然失败（缺真正的认证源）。
4. 直接读主编辑器进程的 `Network\Cookies` → 被文件锁占用，读不到。
5. 设 `AWC_CREATOR_AUTH_SOURCE_DIR=<可用 profile>` 后启动 → **成功**。

### 降级 / 绕过

启动时设环境变量 `AWC_CREATOR_AUTH_SOURCE_DIR=<一个已验证可用的 profile 目录>`。这是**进程级环境变量**，不改动任何用户既有 profile，也不改全局配置。

### 需要谁

**A**：A 也要启实例，会撞同一堵墙。请 A 确认是否也有可用 profile，以及是否接受这套绕过；如果 A 的机器上没有任何可用 profile，这会是 P0 级阻塞（谁也起不了实例）。

---

## B-02｜GLB 材质在运行时被统一覆盖 [✅ 已解决]

**状态**：**Day 1 当天已攻破**，可持久化方案已交付并跨实例验证
**影响**：曾阻塞空间可读性 → 现已解除
**冻结范围**：无

### 现象与根因

Three.js 里设的 7 种颜色导入后全部消失，几何被按材质合并成 `__optimized_merged_material_N` 并统一使用 `EnvLit_AI_Mat`。

拉出 shader 属性表后根因明确：

```
shader: Douyin/AI/PBR/EnvLit_AI
颜色属性名是 _BaseColor，不是 Unity 标准的 _Color。
```

`material.color` 访问的是 `_Color`——**这个 shader 根本不读 `_Color`**。所以写入"成功"却毫无变化。

### 三次失败（保留记录，供 A/B 少走弯路）

| # | 做法 | 结果 |
|---|---|---|
| 1 | Three.js 源 `new MeshStandardMaterial({color})` | 运行时失效 |
| 2 | `appearanceData` 组件写 `color` | 无变化，且**重新 attach 后组件丢失** |
| 3 | `mr.sharedMaterial.color = ...` | 无变化（写错属性名） |

### 解决方案（已验证）

```javascript
mr.sharedMaterial.SetColor("_BaseColor", new CS.UnityEngine.Color(r, g, b, 1));
```

A/B 对照确认：只改 `_BaseColor` 即可，**不需要**动 `_UseVertexColor`。

**持久化**：绑定 `scripts/garden_layer_tint.lua`，在 `Start()` 里按**相对本节点原点的局部高度**分三层赋色。用局部高度而不是世界坐标，因为 WPrefab 可被放到任意世界位置/旋转/缩放。

五层颜色与两个高度分界都做成面板参数，可直接调。

### 验证链

1. 手动改 `_BaseColor` → 生效
2. 绑定 Lua → 重新运行自动生效
3. **关闭实例 → 新实例 → 新 profile → 重新运行 → 颜色仍在**
4. 着色后复测行走 `134.00 → 127.40`，可走性未受影响

### 残留风险（转入 R-06，不再是阻塞）

只验证了**纯色**。`_BaseTex` 属性存在说明 shader 支持贴图，但**没有验证导入 GLB 的贴图是否真的被采样**。Day 4 的 Tripo 模型如果依赖贴图细节，必须先补这个探针。**这是 Day 4 之前的必测项**，已写入 R-06。

---

## B-03｜AI 地形不支持浮空岛

**状态**：已降级，等待确认
**影响**：地形方案
**冻结范围**：PCG 地形生成；**不冻结**空间拓扑与玩法

### 现象

服务在第一个追问直接回复：

> 地图主体是漂浮在空中的浮岛，暂不支持。

### 降级方案

| 方案 | 做法 | 成本 | 风险 |
|---|---|---|---|
| **1（推荐）** | AI 地形只做"台地/谷地"连续地形，浮岛由独立 Model 承担，Map 槽位装配 | 中 | 与 `guide map` 的「Map + 独立 Model 槽位」架构一致，风险低 |
| 2 | 完全用 SCAD / Three.js 手工做浮岛 | 中 | 已证明可行（白盒就是 Three.js 做的） |
| 3 | 放弃地形，纯几何 | 低 | 地面质感会差，但玩法不受影响 |

### 需要谁

**总设计师**：确认是否接受"AI 地形做台地、浮岛由模型承担"的拆法。这会影响 Day 2 白盒的地面处理方式。

---

## B-04｜PCG 参考图确认步骤无法通过 CLI 回答

**状态**：未解决（外部依赖）
**影响**：PCG 地形续轮全部卡住
**冻结范围**：地形生成；**不冻结**白盒与玩法

### 现象

第一问（"浮空岛不支持，你可以选择…"）用 `[["生成相同风格的其他类型地图参考图"]]` 可以答过。第二问（`pcg.kind = reference_image`，带 4 个 `previewArtifactIds`）用任何格式都被拒。

已试 6 种载荷：

```
[{"questionId":"...","optionIndex":0}]  → answers must contain string arrays
[["生成相同风格的其他类型地图参考图"]]   → Invalid PCG question answer
[["确认"]]                              → Invalid PCG question answer
[["preview_yj6wpsy9"]]                  → Invalid PCG question answer
[{"artifactIds":["preview_yj6wpsy9"]}]  → answers must contain string arrays
[["preview_yj6wpsy9","确认"]]            → Invalid PCG question answer
```

CLI 帮助里对 `generation answer` 只写「追问用 generation answer 回答」，没有给出 `pcg` 类型的答案结构。

### 降级方案

放弃 PCG 地形，改用 SCAD / Three.js 手工地形（已证明可行）。**代价只有一个**：失去 AI 地形的自然侵蚀细节，需要美术阶段手工补。

### 需要谁

**A**：A 的终点站也要地形，会撞同一堵墙。建议 A 优先攻这个（可能需要在编辑器 GUI 里手动确认一次，观察它实际发出的请求结构）。如果 A 那边也攻不下来，就全队统一走手工地形，并把这个限制写进最终交付说明。

---

## B-05｜`prefab attach` 是追加，会留重复副本

**状态**：已掌握，非阻塞
**影响**：模型迭代
**冻结范围**：无

第二轮 `prefab attach` 后 `nodes.query` 得到 53 个节点、两套同名 `Model`。场景里两份几何叠加。

**正确流程**：先删旧副本再 attach。
```
scene.nodes.remove({nodes:[<旧 Model 句柄>]})
→ prefab attach --uri <新版本>
→ total 27, modelCount 1
```

**需要谁**：A、B 都要迭代模型。这条写进 `HANDOFF.md`，不要求对方回复。

---

## 风险清单（不是阻塞，但要盯）

| # | 风险 | 触发条件 | 早期信号 | 应对 |
|---|---|---|---|---|
| R-01 | 倒悬温室在自由视角下"倒"得不明显，玩家以为只是歪 | Day 2 白盒 | 玩家第一句话不是"这房子是倒的" | 改用真实倒置几何 + 从下方可站立的入口；必要时让玩家从温室底部穿入 |
| R-02 | 三层高差过大，坠落即重来 | Day 2–3 | 从花冠层掉到根系层 | 在层与层之间加"软着陆"平台；或让坠落回到最近的层而不是入口 |
| R-03 | 根系通道看起来像装饰，玩家找不到入口 | Day 3 | 试玩者原地转圈 | 参考研究硬结论 1：让可走根系用唯一材质语言；根尖做明显的接地斜坡 |
| R-04 | 移动平台程序方案在真实帧率下抖动 | Day 3 | 平台与玩家相对位置漂移 | 退到固定平台 + 触发切换（白盒已证明不需要移动平台也能通关） |
| R-05 | 与书桌站玩法重复 | Day 2 Review | 出现"找三个东西"结构 | 本世界不设收集物，只有空间关系 |
| R-06 | **GLB 贴图可能进不了场景** | Day 4 Tripo 模型导入 | 最小带贴图 GLB 导入失败；去贴图即成功（T-08b） | Day 2 用真实 Blender/Tripo 导出的带贴图 GLB 复测。若仍失败，Tripo 模型改为**分件 + `_BaseColor`**，不依赖贴图 |

---

## 阻塞处置纪律

本轮遵守的三条：

1. **没有因为 B-02 停下几何白盒**，材质问题单独冻结配色测试。
2. **没有因为 B-03 / B-04 停下玩法验证**，地形是表现层，路线是玩法层，已证明二者解耦。
3. **没有把 B-01 当成产品能力结论**，它被明确定性为环境级绕过，避免误导 A/B 以为"新实例不可用"。
