# reports/day-01/A/EVIDENCE.md

> 所有 PASS 都可在本机用下列命令复现。编辑器版本 **1.0.104**，CLI `douyin-world 1.0.104`。
> 证据文件相对路径基址：`reports/day-01/A/evidence/`

---

## 0. 环境事实

| 项 | 值 |
|---|---|
| 编辑器 | 造世界编辑器 1.0.104，`D:\WOW-LAND\造世界编辑器\造世界编辑器.exe` |
| CLI | `C:\Users\zjx\.local\bin\douyin-world.cmd` |
| 项目 | `TrainCore_A` → `...\projects\project-fb583637-ca72-4350-8ff2-e6066aa03481` |
| 实例 | 多次重建；关键一次 `awc-80e60d75-...` / `awc-085842da-...` |
| 账号 | 已登录（`config.json` 中 uid `7514250895997486139`） |
| 屏幕/Mode | `offscreen` |

---

## 1. Git 证据

```powershell
git clone https://ghfast.top/https://github.com/1263-ux/The-Last-Terminus.git D:\zjx\projects\The-Last-Terminus
cd D:\zjx\projects\The-Last-Terminus
git log --oneline -1          # d6361a3 docs: add A/B/C role-specific startup prompts
git checkout -b feature/train-core origin/main
git push -u origin feature/train-core --dry-run   # → FAIL：无凭据
```

镜像可用性探测（同次会话）：

| 镜像 | `info/refs` 结果 |
|---|---|
| `ghfast.top` | **200**（1792 B） |
| `gh-proxy.net` | 200（3084 B） |
| `gh-proxy.com` | 200（网页），但 git 协议 403 |
| `kkgithub.com` / `bgithub.xyz` / `gitclone.com` / `moyy` | 超时 |

---

## 2. Probe 01 证据

```powershell
# 保存（必须先停预览）
douyin-world runtime stop --instance <I>
douyin-world scene save --instance <I> --request-id p01-save-2
# → {"status":"committed","hasUnsavedChanges":false}
```

| 文件 | 说明 |
|---|---|
| `P01-01-initial-scene.png` | 新建项目初始场景（2133×1142） |
| `P01-02-reopened-scene.png` | 关闭实例后重开的同一场景 |
| `P01-scene-before-close.data` | 关闭前 `scene.data` 快照（779578 B） |

`scene.data` 字节变化：`758476 → 779578`（保存后）；关闭后未回退。

解包命令（只读）：

```powershell
Add-Type -AssemblyName System.IO.Compression.FileSystem
$z=[System.IO.Compression.ZipFile]::OpenRead("<projectRoot>\scene.data")
$z.Entries | Select FullName,Length
```

结果：`HeightMap_*.data` / `SplatMap_*_0.png` / `SplatMap_*_1.png` / `MatCoverTex_*.png` / `SerializePcgData.json`

---

## 3. Probe 02 证据（GLB）

生成探针资产（可重放）：

```powershell
& <python> D:\zjx\projects\probe-assets\make_glb.py     # 3 个 GLB
& <python> D:\zjx\projects\probe-assets\make_axes.py    # 轴向测试 GLB
```

导入：

```powershell
douyin-world authoring resource inspect .\out\probe-textured-cube.glb --instance <I>
# → 「资产导入限制 30000 面 / 10485760 字节」，min/max ±0.5

douyin-world authoring resource model import model-probe-cube --prefab probeA --workspace-id <W> --glb .\out\probe-textured-cube.glb
douyin-world authoring resource model check model-probe-cube --prefab probeA --workspace-id <W>
douyin-world authoring resource archive model-probe-cube --kind model --prefab probeA --workspace-id <W>
douyin-world authoring prefab attach probeA --workspace-id <W> --kind model --uri <uri>
douyin-world authoring prefab build probeA --workspace-id <W>
douyin-world authoring result archive probeA --workspace-id <W> --name "A探针_GLB四件套"
douyin-world scene import --instance <I> --uri <wprefab-uri> --request-id <id>
```

读回（Scene SDK）：

```powershell
douyin-world authoring prefab execute probeA --file readback.js --workspace-id <W> --json
```

| 文件 | 内容 |
|---|---|
| `P02-02-glb-object-closeup.png` | 贴图立方体特写（棋盘 + 红角标） |
| `P02-03-four-probes.png` | 四件套合体（层级/透明/动画/贴图） |
| `P02-04-transparent.png` | 半透明面板 |
| `P02-glb-property-readback.json` | 全节点 transform + 组件读回 |
| `P02-axis-readback.json` | ★ X 轴镜像直接证据 |
| `P02-05-axis-test-front.png` / `P02-06-axis-test-side.png` | 轴向可视化 |

`P02-axis-readback.json` 关键内容：

```json
[{"handle":"n8","name":"AxisTestPx","localPosition":{"x":-2,"y":0,"z":0}},
 {"handle":"n9","name":"AxisTestNx","localPosition":{"x":2,"y":0,"z":0}},
 {"handle":"n10","name":"AxisTestPz","localPosition":{"x":0,"y":0,"z":2}},
 {"handle":"n11","name":"AxisTestNz","localPosition":{"x":0,"y":0,"z":-2}}]
```

---

## 4. Probe 03 证据（WPRE）

```powershell
douyin-world authoring prefab export probeA --workspace-id <W> --out D:\zjx\projects\wpre-handoff
# → probeA.wprefab 21244 B, sha256 46ca197c...

douyin-world authoring resource inspect D:\zjx\projects\wpre-handoff\probeA.wprefab --instance <I>
# → 「模型节点 12 · 脚本 9 · 绑定 0 · 实际依赖 5 · 作者条目 1」
```

解包：

```powershell
[System.IO.Compression.ZipFile]::ExtractToDirectory("probeA.wprefab","unpacked")
Get-Content unpacked\asset-metadata.json
# {"schemaVersion":1,"capacity":2556,"faceCount":132,"logicalCenter":[...],"rigged":false}
```

`SerializePcgData.json`：`resourceRefs` = **空数组**；
节点形如 `{"id":8,"basic":{...},"physics":{...},"resource":{"glbSliceData":{"sourceUri":"hamlet-ugc/...glb","slicePath":[0]}}}`。

---

## 5. Probe 05 证据（世界连接）

### 5.1 构建 Anchor

```powershell
douyin-world authoring prefab execute probeA --file build_anchors.js --workspace-id <W> --json
# → {"anchorA":"n14","anchorB":"n15", ...}
douyin-world authoring prefab execute probeA --file fix_trigger.js --workspace-id <W> --json
# → trigger {"center":{"x":0,"y":0.5,"z":0},"size":{"x":3,"y":4,"z":3}}
douyin-world authoring prefab execute probeA --file fix_params.js --workspace-id <W> --json
# → bindings n14:s:<scriptId> TargetX=119.74 TargetZ=103
#            n15:s:<scriptId> TargetX=119.74 TargetZ=86
```

`fix_params.js` 读回（`P05-fix-params.json`）：

```json
{"bindA":"n14:s:fc4dd815-...","bindB":"n15:s:fc4dd815-...",
 "bindings":{"items":[
   {"handle":"n14:s:fc4dd815-...","params":{"TargetX":119.74,"TargetY":79.2,"TargetZ":103,"TargetYaw":180,"CooldownSeconds":2}},
   {"handle":"n15:s:fc4dd815-...","params":{"TargetX":119.74,"TargetY":79.2,"TargetZ":86,"TargetYaw":0,"CooldownSeconds":2}}]}}
```

### 5.2 运行时验证

```powershell
douyin-world runtime lua targets --instance <I> --runtime-id <R>
# → 两条：-22884:fc4dd8... @.../Anchor_A_to_B ; -22894:fc4dd8... @.../Anchor_B_to_A

douyin-world runtime lua eval --file read_params.lua --instance <I> --runtime-id <R> --binding=<A>
# → "20.0|1.0|0.0|90.0"   （早期版本，证明参数按节点隔离）
```

**真实输入触发**：

```powershell
douyin-world runtime lua eval --file player_pos.lua --instance <I> --runtime-id <R> --global
# before → "119.74166870117|77.905349731445|88.640609741211"

douyin-world runtime input keys "W:3000" --instance <I> --runtime-id <R>

douyin-world runtime lua eval --file player_pos.lua --instance <I> --runtime-id <R> --global
# after  → "20.000556945801|-30.228441238403|0.67697632312775"
```

x 由 **119.74 → 20.00**，只可能来自 anchor 脚本的 `Teleport`。

**碰撞体确认**（修正 PuerTS 类型转换后）：

```powershell
douyin-world runtime js eval --file check_collider2.js --instance <I> --runtime-id <R>
```

`P05-collider-recheck.json`：

```json
[{"name":"Anchor_A_to_B","hasCollider":true,"colliderType":"BoxCollider","isTrigger":true},
 {"name":"Anchor_B_to_A","hasCollider":true,"colliderType":"BoxCollider","isTrigger":true},
 {"name":"AxisTestPx","hasCollider":true,"colliderType":"MeshCollider","isTrigger":false}]
```

**几何对照**（证明第 5.3 节的坑）：

```powershell
douyin-world runtime lua eval --file anchor_geometry.lua --instance <I> --runtime-id <R> --global
# 修正前： player=119.74,77.91,88.64 | colliderCenter=119.74,79.90,90.64 | size=2,2,2
#          → 中心高于玩家 2m，永不重叠
# 修正后： player=119.74,77.91,88.64 | colliderCenter=119.74,79.40,90.64 | size=3,4,3
#          → 跨度 77.4–81.4，覆盖玩家
```

**无调试残留**：

```powershell
douyin-world runtime verifyNoTempHooks --instance <I>
# → {"ok":true,"residues":[]}
```

---

## 6. 证据文件索引

| 分组 | 文件 |
|---|---|
| P01 | `P01-01-initial-scene.png`, `P01-02-reopened-scene.png`, `P01-scene-before-close.data` |
| P02 | `P02-01..06*.png`, `P02-glb-property-readback.json`, `P02-axis-readback.json`, `P02-nodes.json`, `P02-snapshot.json`, `P02b/P02c-snapshot.json` |
| P03 | `P03-wpre-inspect.txt`（+ 外部 `D:\zjx\projects\wpre-handoff\`） |
| P05 | `P05-01..04*.png`, `P05-trigger-schema.json`, `P05-builtins.json`, `P05-anchors-build.json`, `P05-fix-trigger.json`, `P05-fix-params.json`, `P05-collider-recheck.json`, `P05-param-readback-a/b.txt`, `P05-invoke-anchor-a/b.txt`, `P05-runtime-logs.json`, `P05-full-tree.json` |

---

## 7. 未采用为证据的内容

- **网络页面**：仅用于参考研究，未作为任何技术 PASS 的依据。
- **`DouyinWorldPortal`**：仅确认类型存在，**未验证**其配置与跨场景语义 → 记为 NOT TESTED。
- **GLB 材质数值**（baseColor/roughness）：编辑器未暴露独立字段，只观察到渲染外观正确，
  不声称"数值被完整保留"。
