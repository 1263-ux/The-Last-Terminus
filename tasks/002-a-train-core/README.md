# TASK PACK A-01｜天空列车公共空间与终点站

> Owner：成员 A  
> Workstream：Train Core / World Transition / Final Terminus / Integration  
> Toolchain：Claude + GPT + 新版造世界 AI 编辑器 + Git；GLB / WPRE；Blender 作为资产检查与修整工具  
> Design Authority：总设计师  
> Status：READY FOR DESIGN REVIEW；精细模型生产须等待视觉方向批准

## 1. 本任务包的目标

成员 A 负责把《天空列车的最后一站》的共同载体和旅程终点做成可运行、可交接、可集成的模块：

1. 证明本地项目、Git、GLB、WPRE 的团队交接链路。
2. 建立一节有辨识度的列车公共空间，作为三个世界之间的共同归属空间。
3. 建立旅程路线图和统一的世界入口/出口接口。
4. 建立三个世界的连接流程，优先采用“列车公共空间 → 站点 → 返回列车 → 下一站”的连续旅程。
5. 制作纯展示世界“云海尽头 / 最后一站”。
6. 接入列车与三个世界的统一音频体验。
7. 持续集成 B、C 的世界交付，并完成最终旅程验收准备。

**A 的第一责任是公共接口、项目可交接性和最终集成，不是把所有场景都自己做完。** 终点站必须有品质，但范围严格限制为一个到站平台、一个主建筑地标、一条观景路线和一个云海远景。

## 2. 本任务不做什么

- 不制作真实列车驾驶模拟、复杂轨道物理或长距离动态载具系统。
- 不替 B 制作书桌站，不替 C 制作失重花园。
- 不擅自决定列车起源、云隙本体、最后一站真相。
- 不将《崩坏：星穹铁道》的列车造型、车厢、UI、专有名词或标志性设计照搬进项目。
- 不在视觉方向批准前让总设计师批量生成 Tripo 资产。
- 不假定传送门、场景切换、移动平台、音频混音等功能已经可用；先实测。
- 不将 WPRE 直接等同于完整工程或完整场景；必须检查依赖和属性保留。

## 3. 阅读顺序

1. 根目录 `AGENTS.md`
2. `production/TEAM-ROLES.md`
3. `production/EXECUTION-PROTOCOL.md`
4. `production/INTEGRATION-CONTRACT.md`
5. `docs/00-PROJECT-CORE.md`
6. `docs/01-WORLD-BIBLE.md`
7. `docs/02-TRAIN-DESIGN.md`
8. `docs/worlds/03-LAST-TERMINUS.md`
9. 本目录 `TASK.md`、`AGENT-TEAM.md`、`SPATIAL-DESIGN.md`、`ART-DIRECTION.md`、`ASSET-BRIEFS.md`、`EDITOR-PLAYBOOK.md`、`REFERENCES.md`、`GATES-AND-ACCEPTANCE.md`

## 4. 任务文件索引

| 文件 | 用途 |
|---|---|
| `TASK.md` | 总目标、边界、依赖、生产顺序 |
| `AGENT-TEAM.md` | Claude/GPT 及辅助 Agent 的分工和提示词 |
| `SPATIAL-DESIGN.md` | 列车车厢、站点接口、终点站空间划分 |
| `ART-DIRECTION.md` | 视觉基线、构图、材质、灯光、质量标准 |
| `ASSET-BRIEFS.md` | 模块清单、Asset ID、交给总设计师的 Tripo 建模需求 |
| `EDITOR-PLAYBOOK.md` | 新版造世界 AI 编辑器的已知工作方式与待验证操作 |
| `REFERENCES.md` | 成熟项目研究、学习点、截图采集清单 |
| `GATES-AND-ACCEPTANCE.md` | 阶段 Gate、时间盒、交付证据和验收表 |

## 5. 关键协作边界

- **总设计师负责 Tripo 建模。** A 负责提出清晰的资产需求卡、尺寸比例、结构拆分、参考图需求和提示词；总设计师生成 GLB；A 负责 Blender 检查、导入、场景适配和质量反馈。
- A 可以使用造世界编辑器内的官方资产库、AI 地形生成和场景摆放能力；不得把 AI 生成的地形或模型直接视为已验收。
- A 对公共列车和终点站场景文件拥有唯一主要写入权。
- B/C 通过入口/出口接口和 World Package 与 A 集成；不要让三人同时编辑同一个公共场景。
- 任何核心视觉方向、列车外形或终点站地标的变更，必须先由总设计师批准。

## 6. 本任务完成的最终状态

- 团队可以用 Git 安全地共享/恢复项目或使用已验证的 WPRE/GLB 降级交接方式。
- 列车公共空间可重新打开、可运行，有旅程地图和明确站点入口。
- 三个世界的入口/出口接口已定义并通过至少一次真实连接测试。
- 云海尽头有明确的到站位置、主地标、观景路线和视觉终点。
- 音频资源有来源/许可记录，并在编辑器中完成实际试听验证。
- A 已将 B/C 的交付集成到统一版本，完整旅程可以从头到尾体验。
