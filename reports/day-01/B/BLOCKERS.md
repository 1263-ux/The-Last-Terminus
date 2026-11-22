# DAY 01｜B｜阻塞、复现与降级

按 `COORDINATION-PROTOCOL.md` §5 的六步处理：**说明被阻塞的子任务 → 20–30 分钟最小验证 → 记录复现 → 提最低成本降级 → 向具体依赖方请求 → 冻结受影响子任务、继续其他工作**。

**原则：** 任何一条阻塞都不允许扩大成"B 全线停止"。下面每条都写清了 **仍可继续的工作**。

---

## 阻塞总览

| ID | 阻塞 | 严重度 | 冻结的子任务 | 仍可继续 |
|---|---|---|---|---|
| B-01 | 运行实例卡 `loading` | **P1 → 已解** | — | 已找到 `instance stop/start` 稳定恢复法 |
| B-02 | CLI 无录屏命令 | **P1** | 玩家视角录屏（Gate D2 硬要求） | 截图、节点定向截图、`input` 注入 |
| B-03 | CLI 无节点变换/锚点吸附 API | **P1（已降级）** | 尺子桥"自由摆放" | 预设状态方案 + 缩短尺子（见下） |
| B-04 | 无书桌站既有资产 | **P0（对资产）** | 复用路线 | 白盒、Tripo 需求卡 |
| B-05 | Blender 未安装 | **P2** | 模型修整 | 参数化几何已证明可行 |
| B-06 | `git` 无法直连 github.com | **P2（已绕过）** | — | 已用 Git Data API 解决 |

> **本轮状态变化：** B-01 从"P1 阻塞"降为"已解决"；B-03 从"P0"降为"P1"，因为已有一个不依赖锚点 API 的可行方案（见 B-03 §降级 L0）。

---

## B-01｜运行实例反复卡在 `status=loading` ★ 已找到稳定解法

### 现象
`runtime start` 返回 `running` 后，若紧接着写入场景/环境参数，下一次 `runtime status` 会长时间停在 `loading`；此时任何 `screenshot` / `logs` 都报：

```
✗ runtime-not-running
✗ runtime-generation-conflict      （提示：先用 runtime status 读取最新 runtimeId）
✗ scene-edit-preview-active        （写场景被拒）
```

### 根因定位（本轮解决）
1. **窗口失焦会被挂起**：`suspendReasons` 出现 `hidden-runtime-canvas`。用 `SetForegroundWindow`（需 `AttachThreadInput` 绕过前台窃取限制）把编辑器窗口拉回前台可解。
2. **运行中改场景会让代次重建失败**：这是真正的卡死来源。一旦在 `running` 状态下写入 `scene import/remove/environment`，下一次 `status` 就永久停在 `loading`，且 `runtime stop` 也会超时。
3. **干净恢复方式**：`instance stop` + `instance start --project <路径> --mode foreground`。本轮用过 3 次，每次都成功恢复。

### 稳定工作流（已验证，请 A/C 照用）
```
stop → 做完所有场景/环境写入 → scene save → start → 立刻连续截图
中途不再改动场景。要改就回到第一步。
```

### 若仍卡死
`instance stop` → `instance start --project <projectRoot> --mode foreground --startup-timeout 180`。
注意 `instance stop` 会返回 `{"stopping":true,"stopped":false}`，稍等 10 秒再 start。

### 24 分钟最小验证记录
| 尝试 | 操作 | 结果 |
|---|---|---|
| 1 | `stop` → `start` → 立即截图 | ✅ 成功 |
| 2 | 还原最小化窗口 | 挂起原因消失，但状态仍 `loading` |
| 3 | 用最新 `runtimeId` 重试 | `runtime-generation-conflict` |
| 4 | 等待 20–40 秒 | 仍 `loading` |
| 5 | `instance stop/start` | ✅ **稳定恢复** |

---

## B-02｜CLI 无录屏命令（影响 Gate D2）

### 现象
`douyin-world runtime --help` 的全部子命令为：
`start|reload|status|stop|logs|screenshot|snapshot|input|probe|lua|js|targets|replace|verifyNoTempHooks`

**没有 record / capture / video。**

### 为什么这是问题
`production/PRODUCTION-OPERATING-SYSTEM.md` Day 2 Gate 与 `GATES-AND-ACCEPTANCE.md` B-G2 都要求"**玩家视角录屏**"。而 `AGENTS.md` §4.8 明确"不接受纯文字已完成"，截图不能替代录屏来证明"可走通"。

### 最小验证
1. 通读 `runtime --help` 全部子命令 → 确认无录屏；
2. `runtime input` 可注入键盘（`W:1200` 等）→ 说明**能脚本化驱动行走**，只是不能记录；
3. 系统级 `CopyFromScreen` 已实测可截取编辑器窗口。

### 降级方案（三级，按成本排序）
| 级别 | 做法 | 能证明什么 | 成本 |
|---|---|---|---|
| **L1** | `runtime input` 注入连续按键 + 每 200 ms 调 `screenshot` → 用 ffmpeg 合成 mp4 | **真实行走轨迹**（等价录屏） | 低，1–2 小时 |
| **L2** | PowerShell `CopyFromScreen` 定时抓帧（已验证可用） | 真实画面序列 | 低 |
| **L3** | Windows 自带 `Win+Alt+R`（Xbox Game Bar）手动录 | 完整录屏 | 需人工，最稳 |

> **推荐 L1**：它由脚本驱动、可复现、且证明的是引擎真实输出，比手动录屏更适合作验收证据。

### 需要谁做什么
向 A 同步这个结论——**A 做完整旅程录屏时会遇到同一限制**，越早统一方案越好（见 `HANDOFF.md`）。

---

## B-03｜CLI 无节点变换 / 锚点吸附 API ★ 对玩法最关键

### 现象
本版 CLI 的 `scene` 只有：
```
scene import | remove | save | operation | cancel | environment get|set | player-animation clear
```
**没有**：移动/旋转/缩放已有节点、没有锚点（anchor/snap）定义、没有交互绑定、没有触发器。

### 后果（严重）
`docs/worlds/01-DESK-WORLD.md` §4 `[CONFIRMED]` 要求尺子桥通过「**锚点、能力标签和关卡白名单**」实现受约束的摆放。当前 CLI **没有任何一条命令能创建锚点或绑定交互**。

→ **尺子桥的核心机制目前无法通过 CLI 验证。**

### 最小验证（已做）
| 检查 | 结果 |
|---|---|
| `scene --help` 全子命令 | 无 transform / anchor / interact |
| `scene import --help` | 仅支持落点 `--position`，不支持姿态或吸附目标 |
| `.wprefab` 是否携带交互 | ✅ 携带（`40468ecd` 有 **16 个 `runtimeScripts`**）→ **格式层支持脚本** |
| CLI 能否配置那些脚本 | ❌ 无对应命令 |

**关键区分（不能混淆）：**
> `.wprefab` **能承载**交互脚本 ⇒ 引擎有能力。
> `douyin-world` CLI **不能配置**交互脚本 ⇒ 自动化不能建。
>
> 也就是说：**这条路可能是"手工点编辑器"能走、但"CLI 自动化"走不通"**。这决定了 B 是否必须亲自在 GUI 里搭，而不是交给 Agent。

### 降级方案（保留核心体验，不动摇"玩家改变通路并亲自通过"）

| 级别 | 方案 | 保留了什么 | 丢掉了什么 |
|---|---|---|---|
| **L0（本轮新增，推荐）** | **缩短尺子 + 双预设状态 + 两个 WPrefab 变体**：把尺子从 30 m 缩到 **12 m**（裂口 10 m），做 `ruler_rest`（横躺在近岸）与 `ruler_spanning`（已跨开裂口）两个变体；玩家触发后切换到 spanning 变体 | ✅ 玩家动作 → 通路可见改变 → 亲自走过；**且不需要锚点 API**，只需"替换/切换实例" | 仍然没有"自由摆放"的手感 |
| **L1** | 预设状态 + 组合资产（切换 WPrefab 变体） | ✅ 同上 | 同上 |
| **L2** | 物理摆放直通（运行时抓取/拖拽） | ✅ 最接近自由 | 可能不稳；世界文档 `[CONFIRMED]` 反对任意物理沙盒 |
| **L3** | 玩家操作环境代替操作物件（推倒书让书脊落进裂口） | ✅ 完整闭环 | **弱化"物件用途重构"**，接近"按开关" |

> **L3 仍是红线。** 一旦降到 L3，"物件用途重构"就退化成"选择/触发"。**必须上报总设计，不得自行采用。**

**为什么 L0 可行（本轮实测的新论据）：**
尺子 30 m 对 10 m 裂口 → 必然悬空 20 m，"拖动对准"在物理上不成立。
但如果尺子是 **12 m**（仍是玩家身高 7 倍，识别度不受影响），它就**恰好搭住裂口两端**，
此时"切换到的 spanning 变体"在视觉上完全可信，玩家不会觉得是作弊。
→ 这把 B-03 从"玩法做不出来"降级为"手感略降"。详见 `WHITEBOX-FIX.md` §5 R1。

> **L3 是红线。** 一旦降到 L3，"物件用途重构"就退化成"选择/触发"，等于玩法降级为普通机关。**必须上报总设计，不得自行采用。**

### 需要谁做什么
| 对象 | 请求 | 时间点 |
|---|---|---|
| 总设计师 | 确认是否允许 B 在 GUI 手工搭交互（而非 CLI），以及是否接受 L1 | Day 2 前 |
| A（集成） | 确认集成版本里"切换实例"是否可用（A 已验证过 WPRE 导入） | Day 2 |
| 编辑器侧 | `douyin-world guide platform` / `guide prefab` 中是否描述了交互绑定的公开方式 | Day 2 自查 |

### 冻结范围（精确）
- ❌ 冻结：尺子桥的**交互实现**验证
- ✅ 继续：布局、白盒几何（已完成）、Asset Card、替代解法设计、参考研究、资产审计

---

## B-04｜无书桌站既有资产

### 现象
全盘检索 + 逐件渲染识别：**7 个 GLB / 4 个 WPrefab 全部与书桌站无关**（椰树岛、中式楼阁、山体、卡通树、小船、敞篷车、秋千、烟花/花朵特效）。
详见 `ASSET-AUDIT.md`。

### 影响
任务包"先审计现有资产避免重复制作"的前提不成立。**P0 全部要新建。**

### 降级 / 应对
1. ✅ 已用 `tools/make_whitebox.py` 生成 **9 件参数化白盒**（书×2、尺、橡皮、铅笔、铅笔盒、台灯、杯、桌面）→ Day 1–2 的尺度与布局验证**不依赖任何美术资产**；
2. ✅ 已把 Tripo 需求收敛为 **2 件（DESK-001 书、DESK-004 铅笔盒）**，尺子建议 Blender 手工建（刻度是规则几何）；
3. ⚠️ 剩余项全部降级为"参数化几何顶住"。

### 需要谁做什么
**总设计师：Day 2 前拍板 DESK-001 / DESK-004 是否生成。** 这是 B 无法自行解决的依赖。

---

## B-05｜Blender 未安装

### 现象
全盘检索 `C:\Program Files`、`C:\Program Files (x86)`、`D:\` 均无 Blender。

### 影响
`ASSET-BRIEFS.md` 与 `PRODUCTION-OPERATING-SYSTEM.md` 都把"B 负责 Blender 检查、修整、导入"写成职责。**目前这条职责无法履行。**

### 降级
- Day 1–3：用程序化几何（已证明可行，GLB 手写即可入库）；
- Day 4：装 Blender（或改用编辑器内置建模/笔刷）。

### 需要谁做什么
成员 B 本人确认是否装 Blender。**非阻塞**，因为参数化几何已能顶住白盒阶段。

---

## B-06｜`git` 无法直连 github.com（已绕过）

### 现象
```
$ git clone https://github.com/1263-ux/The-Last-Terminus.git
fatal: unable to access '...': Failed to connect to github.com:443 after 21102 ms
```
但：
- `gh api repos/...` ✅ 正常
- `curl https://api.github.com` ✅ 200
- `curl https://codeload.github.com/...` ✅ 200（已成功下载 main 快照）
- TCP 22/443 均可连，但 **github.com:443 的 TLS 握手被重置**

### 判断
当地网络对 `github.com` 的 HTTPS 做了 SNI 级阻断；`api.github.com` / `codeload` 不在拦截列表。

### 已采用的绕过（已验证）
1. 用 `codeload` 下载 main 快照建立本地仓库基线；
2. 用 **GitHub Git Data API**（`tools/gh_push.py`）推送：`blobs → tree → commit → PATCH ref`；
3. `feature/desk-world` 分支已通过 API 从 `main@d6361a3` 创建成功。

**合规性：** 等价于 push；`force: false`（快进语义）；**只写 `feature/desk-world`，从不触碰 `main`**；未使用 reset / clean / force push。

### 需要谁做什么
无。若后续需要 `git pull` 同步他人分支，`codeload` 下载对应分支 tarball 亦可。

---

## 本轮阻塞对 Day 1 Gate 的实际影响

| Gate D1 要求 | 状态 | 说明 |
|---|---|---|
| 能复述项目核心与边界 | ✅ | `PLAN.md` §1 |
| 两个可玩世界玩法差异明确 | ✅ | 书桌＝物件用途重构；花园＝空间方向发现 |
| 关键工具未知与资产依赖被暴露 | ✅ | 本文件（6 条，含 2 条 P0） |
| 有可执行的白盒方向 | ✅ | `DESIGN-PROPOSAL.md` 方案 A/B |
| 真实编辑器证据 | ⚠️ **部分** | 截图✅、场景✅、**录屏❌** |

**结论：Gate D1 可判 REVISE（不是 APPROVE）**，唯一缺口是录屏与交互验证，其余成立。
**建议总设计先裁 D1（铅笔盒一分为二）与 D2（选方案 A）**，因为这两条决定 Day 2 白盒的全部内容。
