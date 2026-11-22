# reports/day-01/A/BLOCKERS.md

> 只冻结受影响的子任务，其余继续推进。每条含：现象 / 复现 / 已做的尝试 / 降级方案 / 需要谁。
> 状态：**OPEN** = 仍阻塞 / **MITIGATED** = 有可用替代 / **RESOLVED** = 已解决

---

## B-1｜Git push 无凭据 —— **OPEN**

**影响子任务：** 仅"推送分支与开 PR"。不影响任何制作与探针。

**现象：**

```
$ git push -u origin feature/train-core --dry-run
fatal: could not read Username for 'https://ghfast.top': terminal prompts disabled
```

**已尝试：**
1. 检查环境变量 `GIT_*` / `GITHUB_*` / `GH_TOKEN` —— 无。
2. `git config --global credential.helper` —— 空。
3. `~/.git-credentials` —— 不存在。
4. `gh` CLI —— 未安装。
5. `~/.ssh` —— 只有 `known_hosts`，无密钥。

**结论：** 本机**没有任何 GitHub 凭据**。这不是命令写错，而是权限缺失。

**降级方案：**
- 全部产物已在本地分支 `feature/train-core` 提交完毕，`git log` 可查。
- 提供 `git bundle` 单文件，可由有凭据的机器直接 `git fetch` 导入。
- 提供补丁包 `git format-patch origin/main`，可逐个 `git am`。

**需要谁：** 用户提供一个可用凭据，二选一：
- 在该仓库有写权限的 **Personal Access Token**（`repo` 范围），或
- 为本机添加 **SSH 公钥**（`ssh-keygen -t ed25519` 后把公钥加到 GitHub 账号）。

**临时镜像说明：** 克隆走的是 `https://ghfast.top/...` 镜像。即使拿到凭据，
**push 也应改回官方地址**（`git remote set-url origin https://github.com/1263-ux/The-Last-Terminus.git`），
不要假设镜像支持写入。

---

## B-2｜编辑器单实例锁 —— **RESOLVED**

**现象：** `douyin-world instance start --project <TrainCore_A>` 失败：

```
✗ Creator 在发布实例入口前退出；检查启动日志与项目占用。
```

启动日志：`Creator bootstrap failed: 独立实例登录状态准备失败，请确认认证源可用或改用新的独立 profile`

**根因（已定位）：** 机器上已有一个前台编辑器实例（PID 31792）绑定到旧空白项目，持有单实例锁；
CLI 无法再为另一个项目启动独立实例。CLI 源码逻辑：子进程 `exitCode !== null` 即报此错。

**已尝试且无效：**
- `--mode offscreen` / `--mode foreground` 均失败。
- `--profile <已有登录态目录>` 失败。
- 复制 `Cookies` / `Local State` 到 automation profile 失败（被占用 + 认证源路径不符）。
- 新建空 profile 失败（无登录态）。

**解法（经用户同意）：** 关闭已有编辑器窗口后重新 `instance start`，一次成功。

**经验（写给 B/C）：**
> 用 CLI 操作项目前，先关掉所有已经打开的编辑器窗口。
> 需要同时看界面时，用 `instance start --mode foreground` 启动**自己项目的**实例，
> 不要再手动双击打开另一个项目。

---

## B-3｜`scene.data` 无法 Git 文本合并 —— **MITIGATED**

**影响子任务：** 多人同时改同一工程。

**现象：** `scene.data` 是 ZIP 二进制（内部 `SerializePcgData.json` 才是文本），
Git 只能按二进制处理 → 冲突不可合并。

**降级方案（已写入接口契约）：**
1. 一个 `scene.data` 同时只有**一个写入者**。
2. 世界级协作优先用 **WPrefab（.wprefab）** 或 **GLB** 做单元交付，而不是共享工程。
3. 集成由 A 在单一工程内完成，B/C 不直接写 A 的工程。

**残余风险：** `.wprefab` 依赖外部 URI，跨账号可能失效（见 B-4）。

---

## B-4｜`.wprefab` 不内嵌模型二进制 —— **MITIGATED**

**影响子任务：** B/C 的世界包能否在 A 的机器上完整还原。

**现象：** 解包 `.wprefab` 后 `resourceRefs` 为空数组；
模型仅以 `glbSliceData.sourceUri = "hamlet-ugc/..."` 形式引用外部对象。

**含义：** WPRE 是"层级 + 组件 + 外部资源引用"的清单，**不是**自包含包。

**降级方案：**
1. 交接时 **`.wprefab` + 裸 GLB + 贴图 + `ASSET-MANIFEST.csv` 一起交付**。
2. A 侧若 URI 失效，用裸 GLB 重新 `resource model import` → `archive` → `attach` 重建引用。
3. 交互与碰撞本来就要在编辑器内重建，因此这一步不是额外损失。

**需要谁：** B/C 在每个世界包里附上全部裸 GLB 源文件。

---

## B-5｜GLB 导入 X 轴镜像 —— **MITIGATED（需 B/C 遵守）**

**影响子任务：** 非对称资产的朝向正确性。

**现象：** 作者 +X → 编辑器 −X；Z 不变。见 `EVIDENCE.md` §3 与 `P02-axis-readback.json`。

**降级方案（三选一，B/C 自选但必须记录）：**
1. 导出 GLB 前在 Blender 内对 X 预镜像，使导入后朝向正确。
2. 导入后在编辑器内加 180° Y 旋转并记录在 `SCENE-STRUCTURE.md`。
3. 让资产尽量**左右对称**，把方向性交给场景摆放而非模型本身。

**必须做的事：** 任何带方向性的资产（门、箭头、单向装置、有正反面的招牌）
导入后**必须在编辑器里肉眼确认朝向**，不能凭 Blender 视图判断。

---

## B-6｜GLB 动画不会自动变成引擎动画 —— **OPEN（低优先级）**

**影响子任务：** 任何需要动画的交付物（本轮非 P0）。

**现象：** 带 glTF node animation 的 GLB 导入后，节点存在但
`animatorData` / `ugcAnimatorData` 组件**未生成**。

**当前判断：** 动画需要通过编辑器的动画配置流程单独接入，不能指望 GLB 自带。
**本轮不阻塞**：列车 Hub 与云海尽头以静态为主，动画非必需。

**需要谁：** 若 B/C 需要动态物件（旋转齿轮、摇摆枝干），
先各自做 20 分钟最小验证并回报，避免集成期才发现。

---

## B-7｜`DouyinWorldPortal` 语义未验证 —— **OPEN**

**影响子任务：** 是否需要真正的跨场景加载（而非同场景分区）。

**现状：** 类型在运行时存在（`CS.DouyinWorldPortal != null`），但成员枚举受 PuerTS 限制，
未找到可用属性/方法，也未找到它的编辑器配置入口。

**降级方案（已采用）：** 用 **Trigger + Lua Teleport + 同场景分区** 完成旅程串联，
接口字段（Entry/Exit Anchor）保持不变。若后续验证出 Portal 用法，可**无痛替换**实现，
契约不变。

**不阻塞：** 当前方案已实测可完成"列车 ↔ 世界"的往返。

---

## B-8｜`--args` JSON 在 PowerShell 下需转义 —— **RESOLVED（记录用）**

CLI 的 `--args` 在 PowerShell 里直接传 `'{"a":1}'` 会报「JSON 参数解析失败」，
需写成 `'{\"a\":1}'`。同理，以负号开头的值（如 `--object -559066459`）
必须用等号形式 `--object=-559066459`。

**这条不是项目阻塞，但会浪费大量调试时间，写下来给 B/C 省时间。**
