# 关键资产需求｜交给总设计师的 Tripo 建模需求

## 0. 责任边界

**Tripo 生成由总设计师本人完成。** A 不直接操作 Tripo，不擅自更换模型风格或追加模型。A 的职责是把需求写成可生产的资产卡，提交总设计师确认；模型返回后，A 负责 Blender 检查、导入和场景适配。

每张资产卡必须有：
- Asset ID / 名称 / 所属场景。
- 玩家观察距离和是否可近距离互动。
- 使用位置和比例参照。
- 模型类型：一体铸造 / 模块组装。
- 需要的参考视图。
- 材质目标。
- 预期导出格式：GLB（按已确认支持）。
- 碰撞需求。
- 导入验收标准。

## 1. 资产优先级

| ID | 资产 | 优先级 | 制作方式建议 | 说明 |
|---|---|---|---|---|
| TRN-001 | 列车车头/机车主体 | P0 | Tripo 单体或分件，待测试 | 终点站远中景主视觉 |
| TRN-002 | 乘客车厢外壳 | P0 | Tripo 单体或模块化 | 与车头比例统一 |
| TRN-003 | 车厢内部关键模块组 | P1 | 编辑器/Blender 模块优先 | 不建议让 Tripo 一次生成完整可用室内 |
| TRN-004 | 实体旅程路线图装置 | P1 | Tripo 或 Blender 组合 | Hub 的视觉交互焦点 |
| END-001 | 终点站钟楼/主地标 | P0 | Tripo 概念建模 + Blender 修整 | 先由总设计师批准造型方向 |
| END-002 | 站厅拱门/玻璃穹顶模块 | P1 | 编辑器官方资产 + Blender 组合 | 重复模块优先 |
| END-003 | 观景台灯柱/栏杆模块 | P1 | 官方资产/复用 | 不必全部定制 |
| END-004 | 站牌/时刻表装置 | P2 | Blender/编辑器组合 | 远中景可读即可 |

## 2. TRN-001｜列车车头 / 机车主体

**用途：** 云海尽头站台停靠的列车主视觉；在 Hub 窗外或过场中可重复出现。

**建模建议：**
- 优先生成静态完整外观，不要求车轮动画。
- 车头、锅炉/动力舱、驾驶室、前灯、缓冲器、轮组轮廓清晰。
- 避免过多细小管线、复杂镂空和极薄零件。
- 主体轮廓要在远景中清楚，车灯和车窗可以单独使用发光材质在编辑器中处理。

**Tripo 提示词（初稿，视觉方向待总设计师批准后使用）：**

中文：
一辆原创的复古奇幻天空列车机车头，三分之四前侧视角，完整单体资产，深青绿色哑光金属车身，少量做旧黄铜装饰，暖琥珀色圆形前灯，结构可信的机车前端、驾驶室、缓冲器和轮组，比例优雅而紧凑，具有手工制作的精致细节，风格化高品质 3D 游戏资产，材质清晰、轮廓干净、边缘适度倒角。单独展示在中性背景上，完整物体不裁切，不包含铁轨、站台、人物、文字、徽标、烟雾和复杂环境。

English:
An original vintage-fantasy sky train locomotive, three-quarter front view, a single clean game-ready asset. Deep teal matte metal body, restrained aged brass trims, a warm amber circular headlamp, believable locomotive front, compact driver cabin, buffers and readable wheel assemblies. Elegant compact proportions, handcrafted premium stylized 3D game art, clean silhouette, controlled bevels, readable material separation. Isolated on a neutral background, full object visible, no rails, no platform, no characters, no text, no logo, no smoke, no environment.

**参考视图：** 前视、侧视、后视、顶部、前灯与轮组近景。若 Tripo 只支持单张输入，优先使用三分之四前视主图。

**导入验收：**
- 车头没有明显破面/断裂。
- 轮组没有与车身严重融合成难以修整的形状。
- 车灯位置和驾驶室轮廓可读。
- 缩放后能与玩家 H 比例匹配。
- 若车轮、前灯需要独立交互/动画，必须另行拆分，不要假定单体 GLB 能保留可编辑部件。

## 3. TRN-002｜乘客车厢外壳

**用途：** 列车 Hub 外部识别和终点站停靠画面。

中文提示词：
一节原创复古奇幻列车乘客车厢，独立完整的静态 3D 游戏资产，深青绿色金属外壳，连续的大型矩形全景窗，窗框使用少量做旧黄铜，车厢比例修长、结构简洁，顶部略有弧度，底部轮组结构清楚，车门位置明确，细节精致但不过度装饰。高品质风格化 3D，手工制作感，哑光金属与玻璃材质区分清晰。中性背景单体展示，不包含机车头、铁轨、站台、人物、文字和环境。

English:
An original vintage-fantasy passenger train carriage, a standalone static 3D game asset. Deep teal metal exterior, a sequence of large panoramic rectangular windows, restrained aged-brass window frames, elegant elongated proportions, gently curved roof, readable undercarriage and wheel assemblies, clearly defined doors. Premium stylized handcrafted 3D art, clean geometry, distinct matte metal and glass materials. Isolated on a neutral background, no locomotive, rails, platform, characters, text or environment.

**参考视图：** 侧视全长、前端连接面、后端连接面、车门和窗框近景。

## 4. TRN-004｜实体旅程路线图装置

**用途：** Hub 内部的核心视觉焦点，展示书桌站、失重花园、云海尽头的顺序。

中文提示词：
一件安装在复古列车车厢墙面上的实体旅程路线图装置，竖向矩形木质底板，做旧黄铜边框，中央有三枚可辨识的站点标记和一条优雅连续的弧形路线，少量暖色玻璃指示灯，整体像精致的古老铁路导航仪器，温暖、克制、具有手工工艺细节。正面清晰、结构简单，适合作为独立 3D 游戏道具，单体展示，中性背景，无可读文字、无商标、无人物、无环境。

English:
A physical journey route-map device mounted on a vintage fantasy train carriage wall. Vertical rectangular walnut board, restrained aged-brass frame, three distinct station markers connected by one elegant continuous curved route, a few warm glass indicator lights, crafted like an antique railway navigation instrument. Warm, understated, handcrafted premium stylized 3D prop, clear front-facing design, simple readable geometry. Isolated asset on neutral background, no readable text, no logo, no characters, no environment.

**注意：** 三个站点的文字和具体图标建议在编辑器中用独立平面/贴图/文本功能制作，不依赖 Tripo 生成可读文字。

## 5. END-001｜终点站钟楼 / 主地标（候选）

**用途：** 云海尽头从站台到观景台都能辨认的主要建筑。

中文提示词：
一座原创的奇幻终点火车站钟楼，风格化高品质 3D 游戏建筑资产，暖白色石材主体，少量做旧黄铜结构线条，顶部有清晰的大型圆形机械钟面，建筑下部带开放式拱门和玻璃站厅入口，轮廓优雅、比例挺拔但不过分繁复，带有温暖灯光和手工建筑细节。建筑主体结构完整，适合放置在云海边缘的终点站，单体建筑展示，中性背景，无人物、无列车、无云海、无周边建筑、无文字。

English:
An original fantasy railway terminal clock tower, a premium stylized 3D game environment landmark. Warm ivory stone architecture with restrained aged-brass structural accents, one large readable circular mechanical clock face near the top, an open arched entrance and a glass station hall at the lower level. Elegant vertical silhouette, refined handcrafted architectural details, warm integrated lanterns, not overly ornate. Standalone complete building asset, neutral background, no characters, no train, no clouds, no surrounding buildings, no readable text.

**关键要求：** 不要把站厅、云海、轨道、周边建筑一起生成。只生成主地标，周边通过模块化搭建。

## 6. 由 A 在编辑器/Blender 中完成的普通模块

以下内容优先复用编辑器官方资产或 Blender 模块，不占用总设计师的 Tripo 额度：
- 车厢地板/墙板/顶板。
- 窗框重复模块。
- 座椅、行李架、灯具。
- 站台地砖、栏杆、路灯、长椅。
- 拱廊立柱和重复拱券。
- 轨道片段、站牌支架。
- 普通云层/远景地形（优先编辑器环境能力）。

## 7. Tripo 资产回传要求

总设计师生成后，回传：
- 原始 Tripo 输出。
- 导出 GLB。
- 资产 ID。
- 使用的提示词和参考图。
- 是否为单体或分件。
- 已知缺陷。

A 接收后必须反馈：
- 导入是否成功。
- 材质/贴图是否保留。
- 比例和原点是否合适。
- 是否需要 Blender 修整。
- 是否适合正式场景。
