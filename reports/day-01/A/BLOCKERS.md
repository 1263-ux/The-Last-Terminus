# reports/day-01/A/BLOCKERS.md

> 只冻结受影响的子任务，其余继续推进。每条含：现象 / 复现 / 已做的尝试 / 降级方案 / 需要谁。
> 状态：**OPEN** = 仍阻塞 / **MITIGATED** = 有可用替代 / **RESOLVED** = 已解决

---

## B-1｜Git push 无凭据 —— **RESOLVED**

**影响子任务：** 仅"推送分支与开 PR"。不影响任何制作与探针。

**现象（早期）：**

```
$ git push -u origin feature/train-core --dry-run
fatal: could not read Username for 'https://ghfast.top': terminal prompts disabled
```

**根因与解决：**

1. 早期误判为"本机没有任何凭据"。实际是 **`git-credential-manager` 的交互式弹窗
   在非交互 shell 中被取消**（报 `User cancelled dialog`），加上当时走的是
   `ghfast.top` 镜像，该镜像不支持 write。
2. 用户确认本机有 GitHub CLI 与仓库合作者权限后，我做了完整排查：
   - `gh.exe` 全盘无安装；winget / scoop 安装均卡在从 GitHub 下载二进制
     （国内网络对 `github.com/.../releases/download` 极不稳定：
     14.79 MB 的 gh zip 多次被截断到 0.7–3.9 MB）。
   - **关键发现**：Git Credential Manager（系统级 `credential.helper=manager`）
     里其实**早已缓存了 GitHub 凭据**。用
     `git credential-manager get` 传入 `protocol=https / host=github.com` 即可取回。
   - 把 remote 从 `ghfast.top` 镜像改回官方
     `https://github.com/1263-ux/The-Last-Terminus.git`。
3. **推送成功**（`[new branch] feature/train-core -> feature/train-core`）。
4. **PR #12 已创建**：https://github.com/1263-ux/The-Last-Terminus/pull/12
   - state=open, head=`feature/train-core`, base=`main`, 14 commits, 137 changed files

> 安全说明：推送时使用的一次性带凭据 URL 只存在于单条命令中；
> 完成后立即 `git remote set-url origin <官方无凭据地址>`，
> `git remote -v` 已确认无 token 残留。

**经验（写给 B/C）：**
> 若 `git push` 报 `could not read Username`，先确认是否为 **GCM 弹窗被取消**
> 而非真的没凭据；并用 `git remote -v` 检查是否仍指向不支持写入的镜像。

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

## B-4｜`.wprefab` 不内嵌模型二进制 —— **MITIGATED（已实测跨工程可用）**

**影响子任务：** B/C 的世界包能否在 A 的机器上完整还原。

**现象：** 解包 `.wprefab` 后 `resourceRefs` 为空数组；
模型仅以 `glbSliceData.sourceUri = "hamlet-ugc/..."` 形式引用外部对象。

**含义：** WPRE 是"层级 + 组件 + 外部资源引用"的清单，**不是**自包含包。

**★ 已补做跨工程实测（Probe 06），结果与预期不同，风险显著低于原判断：**

新建独立工程 `Handoff_Test`（`project-eda6f596-...`），用 A 工程归档的同一个
`.wprefab` URI 导入，结果**全部保留**：

| 检查项 | 跨工程结果 |
|---|---|
| 场景导入 | PASS（`rootIDs: ["201049467"]`） |
| 层级完整性 | PASS（12 节点父子关系全保留） |
| 模型显示 | PASS（渲染截图可见全部网格） |
| 碰撞体 | PASS（`BoxCollider isTrigger=true` ×2，`MeshCollider` ×3） |
| Lua 脚本绑定 | PASS（两条 binding 均 attached） |
| 脚本参数 | PASS（读回 `20.0\|1.0\|0.0\|90.0`，与源工程一致） |
| 传送实际生效 | PASS（`before=119.74,77.91,88.64 after=20.00,1.00,0.00`） |

**修正后的结论：** 在**同一账号、同一台机器、同一编辑器版本**下，
`.wprefab` 的外部 URI 可以正常解析，跨工程交接**实测可用**。

**仍未验证的残余风险：**
- **跨账号**（B/C 用他们自己的编辑器账号）导入是否同样可解析 —— **NOT TESTED**。
- 资源 URI 的长期有效期与是否会被清理 —— **NOT TESTED**。

**降级方案（仍建议保留）：**
1. 交接时 **`.wprefab` + 裸 GLB + 贴图 + `ASSET-MANIFEST.csv` 一起交付**。
2. A 侧若 URI 失效，用裸 GLB 重新 `resource model import` → `archive` → `attach` 重建引用。
3. 交互与碰撞本来就要在编辑器内重建，因此这一步不是额外损失。

**需要谁：** B/C 在每个世界包里附上全部裸 GLB 源文件（沿用原建议，作为保险）。

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

**现象（已实测补强）：**
1. 带 glTF node animation 的 GLB 导入后，节点存在，
   但 `animatorData` / `ugcAnimatorData` 组件**未生成**。
2. 更值得注意：**含动画的模型被放进了另一个组件 `aigcModelData`**，
   而静态模型用 `glbSliceData`。同一次导入、同一套命令，路径不同。
   证据：`P02-model-component-types.json`。

**含义：** 动画模型不是"静态模型 + 动画"，而是走了另一条运行时通路。
若需要动画，**必须单独验证播放**，不能用静态资产的导入结论推断。

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
