# reports/day-03/A/WPRE-HANDOFF-MATRIX.md

> Owner：成员 A
> 阶段：Day-3 A4
> 依据：Day-1 Probe 03 + Probe 06 实测；总设计师 `EDITOR-TECHNICAL-FINDINGS.md`

---

## 0. 结论（一句话）

**同账号 / 同机 / 同版本跨工程导入：PASS（REPRODUCED-LOCAL）。**
**跨成员 / 跨账号 / 跨机器：NOT TESTED** —— 这是当前最重要的未决交接风险。

---

## 1. 已验证矩阵

| 维度 | 结果 | 证据 | 等级 |
|---|---|---|---|
| `prefab export` 生成单文件 `.wprefab` | **PASS** | Probe 03：21244 B，ZIP 容器 | OBSERVED-LOCAL |
| WPRE 内部结构 | **PASS** | 3 条目：`SerializePcgData.json`(100910) / `asset-metadata.json`(143) / `ai-author/meta.json`(63) | OBSERVED-LOCAL |
| 层级保留（12 节点） | **PASS** | Probe 03 + 06 | OBSERVED-LOCAL |
| 碰撞配置保留（数据层） | **PASS** | `physics.physicsColliderData` 完整 | OBSERVED-LOCAL |
| 运行时碰撞生效 | **FAIL / INCONCLUSIVE** | 见 `COLLISION-MATRIX.md`：`triggerData` 会生成 BoxCollider，`physicsColliderData` 单独不会 | OBSERVED-LOCAL |
| 脚本绑定保留 | **PASS** | 2 条 binding，运行时 attached | OBSERVED-LOCAL |
| 脚本参数按节点隔离 | **PASS** | A/B 分别读回不同值 | OBSERVED-LOCAL |
| **跨工程导入**（同账号同机同版本） | **PASS** | Probe 06：新工程导入同一 URI，层级/碰撞/脚本/参数/传送全部保留 | **REPRODUCED-LOCAL** |
| 外部 URI 在另一成员账号解析 | **NOT TESTED** | 无第二账号环境 | — |
| 外部 URI 在另一台机器解析 | **NOT TESTED** | 同一台机器 | — |
| 跨编辑器版本 | **NOT TESTED** | 只有一个版本 1.0.104 | — |

---

## 2. 交接包标准（必须同时给，不能只给 WPRE）

Day-3 与总设计师一致要求：

```
world-package/
├── <name>.wprefab            # 层级 + 组件配置 + 外部 URI 引用
├── <name>/                   # 裸 GLB（全部）
├── textures/                 # 贴图源文件
├── ASSET-MANIFEST.csv        # 资产 → 用途 → 来源 → SHA-256
├── ENTRY-EXIT.md             # 接口字段
└── KNOWN-ISSUES.md
```

**原因**：我实测 `.wprefab` 的 `resourceRefs` 是**空数组**，模型全部通过
`glbSliceData.sourceUri = "hamlet-ugc/..."` 外部引用。
跨账号若无法解析，只能靠裸 GLB 重新 `resource model import` 重建。

---

## 3. 给 B/C 的交接请求（A4 的下一步）

按 DAY-03 §184「WPRE 至少一次真实跨成员导入；否则 NOT TESTED」：

- **请求**：B 或 C 用**自己的项目 / 账号环境**导入我归档的最小 WPRE
  （`A探针_世界接口传送锚点`，URI 见 `day-01/A/EVIDENCE.md` §6），
  回报：层级、外部 URI 是否解析、材质、运行时脚本与截图。
- **若用同一账号**：必须明确写明"同账号"，**不得称为跨账号**。
- **若没有第二账号**：保持 NOT TESTED，不伪造 PASS；A 继续提供裸 GLB + 贴图兜底。

**本文件当前状态：等待 B/C 接收方回执。未收到前 A4 保持 NOT TESTED（跨账号部分）。**
