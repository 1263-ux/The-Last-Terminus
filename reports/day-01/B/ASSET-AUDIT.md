# DAY 01｜B｜书桌站现有资产审计

审计执行者：主控（DSH），经成员 B 本机实例
审计时间：2026-11-22
审计方法：**实际解析文件**，不是读文件名猜内容。工具为本仓库 `tools/` 下三个脚本（可复现）：

| 脚本 | 作用 |
|---|---|
| `tools/audit_glb.py` | 解析 GLB 容器 → JSON chunk，输出节点/网格/材质/贴图/动画/包围盒/三角面数 |
| `tools/glb_preview.py` | 用 numpy+Pillow 自写光栅器把 GLB 渲染成三视角 PNG，**用于识别没有任何命名信息的资产** |
| `tools/inspect_wprefab.py` | `.wprefab` 实为 ZIP，解包读 `SerializePcgData.json` 与 `asset-metadata.json` |

> 未实际检查的字段一律写 **NOT TESTED**，不写"应该是"。

---

## 0. 一句话结论

> **本机没有任何一件可用于书桌站的现有资产。**
>
> 工程里唯一的项目是「我的项目」（空白 avatar 场景），`asset-cache` 中的 7 个 GLB / 4 个 WPREFAB 全部属于车队、秋千、中式建筑、山体等**无关内容**。任务包与 Day-01 Prompt 反复强调的「审计现有《桌面以下》GLB/WPRE、避免重复制作」，**其前置假设不成立**：这些资产从未落到本机。

这条结论比"审计通过"更重要——它把 Day 2 的资产路径从"复用"改成"自建 + 定向 Tripo"，并直接说明为什么 `ASSET-BRIEFS.md` 的 P0 清单需要总设计师尽快拍板。

---

## 1. 审计范围与位置

| 位置 | 内容 | 与书桌站关系 |
|---|---|---|
| `%APPDATA%\AI World Creator\asset-cache\files\` | 7× `.glb`、4× `.wprefab`、2× `.unity3d`、3× 音频、10× 图片 | 全部无关（逐件见 §2/§3） |
| `%APPDATA%\AI World Creator\projects\project-006822bc…\` | 唯一项目「我的项目」，`scene.data` 为 ZIP 内含 `SerializePcgData.json` | 空白底图，无书桌站内容 |
| `D:\wow-land\造世界编辑器\...\assets\*.glb` | 7 个编辑器安装包自带 GLB（1002/2001/3002/4002/4044/5003/5005） | 编辑器 UI 图标/预设，非世界资产 |
| 全盘检索 `桌面 / desk / ruler / 尺子 / pencil / 铅笔 / 书谷` 的 `.glb/.gltf/.wprefab/.fbx/.blend` | **0 命中** | — |

---

## 2. GLB 资产逐件结论

7 件全部**无命名**（节点名统一是 `model` 或 Tripo 的 UUID），因此必须靠渲染识别。
预览图见本仓库 `evidence/asset-previews/`（`glb_preview.py` 生成，三视角）。

| # | 文件（asset-cache） | 渲染识别 | 三角面 | 尺寸 XYZ (m) | 生成器 | 材质/贴图 | 用途判定 |
|---|---|---|---|---|---|---|---|
| 1 | `01f7909d…ae52.glb` | 低多边形**热带椰树小岛** | 2 000 | 1.88 × 1.32 × 1.89 | Blender I/O 4.0.43 | 1 mat / 2 PNG(base_color+1) | ❌ 不可用 |
| 2 | `0c81fefd…db3.glb` | **中式硬山顶小屋**（带门廊台阶） | 9 500 | 1.00 × 0.77 × 0.84 | glTF-Transform 4.3.0 | 1 mat / 2 KTX2 | ❌ 不可用 |
| 3 | `24ef9bb6…ebf.glb` | 低多边形**岩石/洞窟** | 1 999 | 1.83 × 1.88 × 1.69 | Blender I/O 4.0.43 | 1 mat / 2 PNG | ❌ 不可用 |
| 4 | `2d84de77…eec.glb` | **低多边形山体地形块**（带针叶树点缀） | 14 558 | 0.99 × 0.39 × 1.00 | glTF-Transform 4.3.0（**Tripo**） | 1 mat / 3 KTX2(base+normal+ORM) | ❌ 不可用 |
| 5 | `6c71d0d6…94bf.glb` | **卡通树**（`CartoonTree01`，双节点 Leaves/Trunk） | 4 729 | 0.66 × 1.00 × 0.67 | Blender I/O 4.4.56 | **2 mat**，其一 `alphaMode=BLEND` | ❌ 不可用（但**分件与 BLEND 叶片是良好技术样例**） |
| 6 | `7d3dcb97…3fa.glb` | **低多边形小木船**（含绳结、护边） | 2 028 | 1.00 × 0.24 × 0.50 | glTF-Transform 4.3.0（**Tripo**） | 1 mat / 3 KTX2 | ⚠️ 唯一有间接价值者，见下 |
| 7 | `ce4f2ee2…110.glb` | **中式重檐楼阁**（双层屋檐、匾额、石阶） | 19 997 | 1.64 × 1.88 × 1.78 | Blender I/O 4.0.43 | 1 mat / 2 PNG | ❌ 不可用 |

### 2.1 对书桌站唯一的间接价值

`7d3dcb97…3fa.glb`（小木船）**不是**书桌站资产，但它证明了：

- 该机器上的编辑器**支持 Tripo 产线 GLB**（`glTF-Transform` + `KHR_texture_basisu` + KTX2 贴图）正常入库；
- 入库后 `faceCount=2028`、`capacity=2228` 被正确解析（实测，见 `EVIDENCE.md` §2）。

这意味着未来 Tripo 生成的 P0 模型走的是**同一条已验证通路**，Day 4 不必再冒格式风险。这是一个正面结论，但它证明的是**管线可用**，不是**资产可用**。

### 2.2 共同技术特征（可用于给 Tripo 定规格）

| 特征 | 观察值 | 对书桌站的约束 |
|---|---|---|
| 单位 | 全部按"最大边 ≈ 1.0–1.9 m"归一 | Tripo 默认输出约 1 unit，导入后必须**显式缩放**；书桌站的书本需 ≈ 7–9 m（见 `DESIGN-PROPOSAL.md` §3） |
| 朝向 | `+Y` 向上，`-Z` 为前（Blender 标准导出） | 与编辑器一致，**无需修正朝向** |
| 原点 | 多数在几何中心；`.wprefab` 记录 `logicalCenter` | 桥梁/坡道类**必须原点在底面中心**，否则吸附会浮空 |
| 材质 | 单材质 + base_color（+normal/ORM）为主 | 尺子/纸张需要**分段材质**（刻度区、磨损边、木头区），单材质不够 |
| 透明度 | `6c71d0d6` 用了 `BLEND` | 布料/纸页可用，但**大面积 BLEND 会拖性能**，需实测 |
| 双面 | 全部 `doubleSided=true` | 书页/纸坡沿用；但会**翻倍面数**，远景应改单面 |
| 动画 | 7 件全部 `animations=0`、`skins=0` | 无骨骼可复用；主角需另定（世界文档 §8 未决） |
| 碰撞 | **NOT TESTED**（GLB 内无碰撞数据；编辑器是否自动生成碰撞未验证） | 见 `BLOCKERS.md` B-04 |

---

## 3. WPREFAB 资产逐件结论

`.wprefab` 是 **ZIP 容器**，内含 `SerializePcgData.json`（场景/预制体数据）、可选 `asset-metadata.json`、可选 `textures/`、可选 `preview.png`。
**重要发现：** `.wprefab` 的 `SerializePcgData.json` 顶层结构与本项目的 `scene.data` **完全同构**（同样有 `moveMaxSpeed`、`jumpMaxHeight`、`spawnPointData`、`envParamJson`、`runtimeScripts`）。这说明 WPRE/WPrefab 携带的是**场景级配置**，不只是几何。与 `INTEGRATION-CONTRACT.md` §6 的谨慎表述一致：**不能假定它等同于完整工程**，但它确实可能带玩家参数与脚本。

| # | 文件 | 内容识别 | 节点数 | 脚本 | 元数据 | 判定 |
|---|---|---|---|---|---|---|
| 1 | `40468ecd…872` | **复古敞篷车**（`VintageConvertibleBody`/`ChromeGrille`/`WheelFL`…） | 99 | **16** | `capacity=27468 faceCount=7352 rigged=false` | ❌ 不可用；**是最佳技术样例**（见 §3.1） |
| 2 | `b6bd1a52…214` | **双人摇椅秋千**（`Canopy`/`CanopyCloth`/`LeftSideBrace`…） | 162 | **13** | `capacity=43604 faceCount=11484 rigged=false` | ❌ 不可用；结构样例 |
| 3 | `2d9843cb…81a` | **烟花环境特效**（`VFX_Ambient_Firework02` + `ParticleSphere`×2） | 3 | 0 | 无 | ❌ 不可用；**VFX 参数可复用**到台灯光晕 |
| 4 | `6f3d30ee…0b8` | **花朵环境特效**（`VFX_Ambient_Flower` + `ParticleGroup`） | 2 | 0 | 无 | ❌ 不可用；同上 |

### 3.1 为什么 `40468ecd` 值得留档

它带 16 个 `runtimeScripts` 和 99 个具名节点（车轮有 `WheelFL` + `WheelFLDisplay` 成对结构）。这给 Day 3 的尺子桥提供了一个**已验证的存在性证明**：

> 该编辑器的 WPREFAB 生产线**能够承载"多处交互脚本 + 分件层次"**。

也就是说，"尺子桥需要脚本驱动状态机"这件事在**格式层**不是死路。但**这不等于**"CLI 能配置交互"——`douyin-world` 当前暴露的命令里没有交互/脚本绑定接口（见 `BLOCKERS.md` B-03）。这是关键区别，不能混为一谈。

### 3.2 一个必须纠正的误读风险

`asset-metadata.json` 里的 `capacity` **不是**"承载能力"或"玩家容量"，而是编辑器内部的**资源容量预算**（与场景顶部容量条 `207/4000` 同量纲）。审计时不要把它当成物理属性。
→ **NOT TESTED：** `capacity` 的确切计算口径（面数？显存？），未在官方文档中找到定义。

---

## 4. 可用性汇总

| 状态 | 数量 | 明细 |
|---|---|---|
| ✅ **可直接使用** | **0** | — |
| ⚠️ **需修复后可用**（仅技术样例价值，非内容） | 2 | `6c71d0d6`（BLEND 叶片分件样例）、`40468ecd`（脚本+层次样例） |
| ❌ **不可用**（内容无关） | 9 | 其余全部 |
| ❓ **待验证** | 3 类 | GLB 碰撞是否自动生成；`capacity` 口径；`.wprefab` 跨项目导入后引用是否稳定 |
| 🔁 **重复制作风险** | **无** | 因为没有既有资产，不存在重复制作——但反过来意味着 **P0 全部要新建** |

---

## 5. 对 `ASSET-BRIEFS.md` P0 清单的影响

任务包列了 8 个候选（DESK-001…008）。基于本审计，建议：

| ID | 任务包原定 | 审计后建议 | 理由 |
|---|---|---|---|
| DESK-001 书谷/巨书 | P0 | **P0，优先 Tripo** | 无既有，且是尺度参照基石 |
| DESK-002 木尺 | P0 | **P0，但建议 Blender 手工建** | 尺子靠**精确刻度与倒角**识别，AI 生成难保证等距刻度；这是规则几何体 |
| DESK-003 尺子支点 | P0 | **降为 P1 / 白盒先行** | 支点是玩法锚点，先用几何体验证吸附，再决定要不要美术 |
| DESK-004 铅笔盒小镇入口 | P0 | **P0，Tripo** | 拉链/隔层/圆角是主要识别特征 |
| DESK-005 铅笔/橡皮/回形针 | P1 | **P1 不变**；铅笔/橡皮可用参数化几何 | 规则体，不值得花 Tripo 额度 |
| DESK-006 布料坡面 | P1 | **暂缓**，待总设计确认该模块是否存在 | 世界文档未列（见 `PLAN.md` §5.2） |
| DESK-007 陶瓷杯港口 | P1 | **P1，只要低模远景** | 明确不做第二张地图；远景不需要近景面数 |
| DESK-008 台灯 | P1 | **P1**，但优先做**灯光**而非模型 | 台灯的价值是"太阳"，环境参数已可完全控制（实测 44 字段） |

> 结论：**Day 2 前只需要总设计拍板 DESK-001 / 004 两件 Tripo**，其余可以白盒或参数化几何顶住。这是本轮最重要的排期建议。

---

## 6. 复现方式

```powershell
# 1) GLB 结构审计（节点/材质/包围盒/面数）
python tools/audit_glb.py <glb...>

# 2) GLB 渲染识别（资产没有名字时唯一可靠手段）
python tools/glb_preview.py <输出目录> <glb...>

# 3) WPREFAB 解包（本质是 ZIP）与内容统计
python tools/inspect_wprefab.py <%APPDATA%\AI World Creator\asset-cache\files>
```

审计原始输出留档：`evidence/asset-audit.json`、`evidence/asset-previews/`。
