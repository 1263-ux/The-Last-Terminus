# A｜造世界 1.0.104 编辑器 AI/PCG 能力入口清单

> Owner：成员 A（全项目技术集成）
> 日期：2026-11-24
> 依据：Issue #18 §6 / Issue #23 §6（A 主责的生产能力审计）
> 原则：**DOCUMENTED / TESTED-1.0.104 / PARTIAL / FAILED / NOT TESTED 分开标注**；
> **不得把 MCP 适配器参数当成 1.0.104 编辑器原生容量上限**；
> **不得把 CLI 能力当成 GUI 原生菜单入口**。

---

## 0. 一句话

本轮只完成**只读探测**：确认本机安装的是团队实际版本 1.0.104，CLI 暴露了哪些能力入口。
**GUI 原生菜单、真实容量上限、AI 生成实际产出与扣费均未完成实测**——编辑器 Creator 自动化服务未启动，
需要人类在 GUI 中操作。以下每条都明确标注状态，不把 DOCUMENTED 冒充 TESTED。

---

## 1. 环境与版本（TESTED-1.0.104）

| 项 | 结果 | 证据 |
|---|---|---|
| CLI 版本 | **1.0.104** | `douyin-world --version` |
| 编辑器本体 | `D:\WOW-LAND\造世界编辑器\造世界编辑器.exe`，1.0.104 | `douyin-world doctor` |
| CLI 入口 | `resources\addon\awc-cli\dist\cli.mjs` | doctor |
| 已装 skill | DeepSeek Harness（编辑器顶部「AI Agent」或 `setup skill install`） | doctor |
| 随包指南 | workflow / visual / asset / generation / map / prefab / platform / debug / quality / reference / skill / adapter | doctor + kit manifest |
| 项目模板 | `resources\addon\awc-cli\dist\templates` | doctor |

**CLI 业务域**（`douyin-world --help`，TESTED）：`instance` / `project` / `asset` / `authoring` /
`generation` / `starlight` / `scene` / `runtime`；本机 `setup`；辅助 `doctor` / `guide`。

---

## 2. AI / PCG 生成入口（CLI 侧 DOCUMENTED，GUI 原生 NOT TESTED）

来源：`douyin-world generation --help`（只读命令帮助，非 MCP README）。

| 能力 | CLI 入口 | 状态 | 说明 |
|---|---|---|---|
| 单体模型生成 | `generation start model` | **DOCUMENTED / NOT TESTED** | 复用工作台完整 Direct Model 流程；参考图不会跳过生图；成功后返回正式工作区产物 |
| 绑骨 | `generation start rig` | **DOCUMENTED / NOT TESTED** | 未实际调用 |
| 地图/地形 PCG | `generation start map` + `map update/list/get/apply/terrain/status/cancel` | **DOCUMENTED / NOT TESTED** | `map apply/terrain` 需 `--pcg-session-id` + `--operation-id`；`--height-scale 0..1`；**完成返回不代表后台模型全部生成完毕** |
| 生成任务恢复 | `generation status/answer/cancel <taskId>` | DOCUMENTED | `start` 默认异步返回 taskId；`--wait <秒>` 仅等待原任务；中断/超时不自动重提交 |
| 场景导入 | `scene import --uri ... --request-id ...` | DOCUMENTED | 不隐式制作/入库/保存/运行；重试保留同一 request-id |
| 场景环境 | `scene environment get/set` | DOCUMENTED | get 返回真实资源候选（外部制作参数） |
| 素材召回 / 非生成资产 | `asset` 公共/个人/收藏库 + 动作库 | DOCUMENTED | 不消耗星光 |
| 源码制作（UI/SCAD/Three.js/Blender） | `authoring` + `guide prefab` | DOCUMENTED | 自有模型和源码不消耗星光 |

**关键澄清**（对齐 Issue #18 §B）：
- CLI 提供的是 `generation start model|rig|map`，**没有**一个已证实的"单次 prompt 自动生成完整可玩游戏"的通用入口。
- `map apply/terrain` 明确"完成不代表后台模型全部生成完毕"，不能把激活回执当成 PCG 完整完成。
- 以上均为**适配器/CLI 命令**，不等于 GUI 原生菜单；GUI 入口路径 **NOT TESTED**。

---

## 3. 星光与扣费（BLOCKED：Creator 服务未启动）

| 项 | 命令 | 状态 |
|---|---|---|
| 余额 | `starlight balance` | **BLOCKED** — `✗ 无法访问 Creator 自动化服务` |
| 模型单价 | `starlight price model --vendor tripo` | **BLOCKED** — 同上 |
| 地图单价 | `starlight price map` | **BLOCKED** — 同上 |

澄清：
- `price` 返回是否收费、单次 `amount`、`unit`、`condition`；地图按实际阶段扣费，`freezeAmount` 仅发起时预冻结，**不能当实际扣费**。
- `task <taskId>` 查询实际扣费；`ended` 但缺 `amount` 表示平台尚未返回，不能当 0。
- 完整流水以编辑器顶部「我的星光」为准（GUI，需人类查看）。
- **本轮未调用任何消耗服务**，因此无 task 扣费可报告。

---

## 4. 世界容量 / 导入上限（明确 NOT TESTED，不引用适配器参数当上限）

Issue #18 §D 列出的均为**社区 MCP v0.6.0（已验证 1.0.82）适配器参数**，
**不是团队实际 1.0.104 编辑器原生上限**，本轮不做任何实测推断：

| 参考项（适配器） | 值 | 本轮结论 |
|---|---|---|
| `canvas_import_glb` 上传上限 | 20 MiB | 适配器参数，**NOT TESTED** 为 1.0.104 GUI 上限 |
| `canvas_scene(allNodes)` 读取上限 | 1000 descendants | 查询返回上限，非场景对象数上限 |
| `pcg_select` 批量选择上限 | 100 | 接口参数，非地图容量 |
| `canvas_terrain` 采样点 | 200 | 查询参数，非地形范围 |
| `publish_prepare.capacity` schema | 1–30 | 未确认代表发布/玩家容量，非世界尺寸 |

**未做**：隔离工程容量破坏测试（需启动编辑器 + 复制工程）。**不猜测**任何"世界最多 N 对象"的数字。
按 Issue #23 §6，交付目标是"当前项目安全预算 + 已验证导入链 + 明确 NOT TESTED"，非理论最大值。

---

## 5. GLB / WPRE 端到端导入（NOT TESTED，运行时入口仍 BLOCKED）

- 已有证据（B，PR #21 / main `9c839ba`）：ZIP + 7/7 GLB SHA + 资产库导入 + `scene.data` 层级 **PASS**。
- 真实 GLB 进入玩家运行时 **BLOCKED**（HamletWorldGame 为角色世界，运行层级 MeshRenderer 0）。
- 本轮无 GUI 操作权限，未新增导入实测。**GLB MeshCollider 能否阻挡玩家：NOT TESTED**。
- WPRE 原生 GUI 导入/实例化流程：**NOT TESTED**。

---

## 6. 本轮状态汇总

| 项 | 状态 |
|---|---|
| 编辑器真实版本 1.0.104 | **TESTED-1.0.104** |
| CLI 能力入口清单 | **TESTED**（命令帮助只读） |
| GUI 原生菜单/AI 入口 | **NOT TESTED**（需人类 GUI 操作） |
| AI/PCG 实际生成 + 扣费 | **BLOCKED**（Creator 服务未启动） |
| 世界容量上限 | **NOT TESTED**（本轮未做隔离工程破坏测试） |
| GLB 运行时可见性 / MeshCollider 阻挡 | **BLOCKED / NOT TESTED** |
| WPRE GUI 导入 | **NOT TESTED** |

---

## 7. 下一步（需人类操作，A 不越权）

1. 由 B/C 在各自 GUI 亲自点击 Run/Preview，记录菜单路径、项目类型、运行画面、日志（Issue #23 §3/§4）。
2. A 在获得 GUI 会话后补做：1.0.104 真实容量基准（隔离工程）、AI/PCG 小型样板（先查价再生成）、
   一份 GLB 从文件→玩家视角的完整导入链。
3. 在 Gate 通过前，不消耗 Tripo 积分；按 Issue #23 §5 优先复用现有 GLB / Blender / PCG。
