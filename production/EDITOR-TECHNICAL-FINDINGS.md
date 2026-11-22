# Editor Technical Findings｜技术发现与验证边界

> 本文件是团队证据索引，不是编辑器官方规格。每条结论必须记录适用版本、项目、导入路径、样本和证据。

## 证据等级
- OBSERVED-LOCAL：成员在指定版本/项目/路径下观察到。
- REPRODUCED：重复实验或独立复测。
- CROSS-MEMBER：另一成员在其项目/账号环境复测。
- OFFICIAL-DOC：官方文档明确说明。
- HYPOTHESIS：待验证。
- NOT-TESTED：无证据，不得推断。

## 当前项目内观察

| 主题 | 发现 | 等级 | 缺口 |
|---|---|---|---|
| 玩家胶囊 | 直径约 0.32m，高约 0.90m | OBSERVED-LOCAL | 角色/配置/版本变化需复测 |
| GLB X轴 | 作者 +X 导入后出现镜像 | OBSERVED-LOCAL | 需共享测试资产交叉复测 |
| GLB 材质 | A 读到 _BaseColor/_BaseTex；C 报告某路径运行时材质被覆盖 | OBSERVED-LOCAL | 统一资产和真实渲染对照 |
| GLB 尺寸 | B 报告 scene import 缩放与源最长边有关 | OBSERVED-LOCAL | A/C 未复测；sqrt(T) 仅为 B 局部经验 |
| WPRE | A 同机同账号同版本跨项目成功导入层级/碰撞/脚本/参数 | REPRODUCED-LOCAL | 跨成员/跨账号/跨机器未知 |
| Collider | B 报告 enableCollision=true 但 GLB 墙运行时穿透 | OBSERVED-LOCAL | 原生 GUI Cube 对照未完成 |
| Terrain | B 报告连续地形填平桌面裂口 | OBSERVED-LOCAL | 适用于 B 的工程模板/配置，需复测 |
| 保存/重开 | A/B/C 各自有项目保存重开证据 | OBSERVED-LOCAL | 不等于跨机器目录无损迁移 |

## 三层状态必须分开
1. 数据层：节点、变换、材质字段、Collider 字段、资源引用。
2. 渲染层：模型可见、材质/贴图完整、朝向/尺度正确。
3. 运行层：玩家能否碰撞、站立、触发脚本、走通路径、重开后仍工作。

enableCollision=true 不能单独证明运行时有碰撞；材质字段存在也不能单独证明运行时显示正确。

## 当前未决问题
- scene import 尺寸行为是否跨资产/路径成立。
- X 轴镜像由导出设置、导入路径还是节点变换导致。
- A/C 材质结果差异来自路径、配置还是运行时覆盖。
- B 的 Collider 穿透是模板、形状、导入路径或 Preview 模式问题。
- WPRE 外部 URI 能否在另一成员账号/机器解析。
- 原生工程、WPRE 和场景数据的依赖边界。

## 当前生产决策
- 统一矩阵未通过前，不批量生产关键 Tripo 资产。
- 白盒继续使用已实测有效的原生几何体/参数化代理。
- 视觉网格与碰撞代理可以分离，但必须实测。
- 世界包暂时同时保留 WPRE、裸 GLB、贴图和 ASSET-MANIFEST.csv。
- 不发布未经复现的全局换算公式。
