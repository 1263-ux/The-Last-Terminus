# 失重花园｜Day 4 关键资产需求卡（巨花 / 倒悬温室 · Tripo 候选）

> Owner：成员 C（需求卡）／生成：总设计师（Tripo）／导入适配：成员 C
> 依据：`tasks/004-c-floating-garden/ASSET-BRIEFS.md`、`tasks/005-day03-closeout-day04-entry/VISUAL-REFERENCE-BOARDS.md`（C-02/C-03/C-04）
> **本文件不包含任何已生成模型。** 按 `AGENTS.md` §9，关键 Tripo 模型由总设计师实际生成。本轮只给候选方向与验收口径，供总设计师决定生成哪一个。

## 0. 共通约束（沿用 Day 1 §0.2/§0.3，未变）

| 项 | 值 | 依据 |
|---|---|---|
| 单位 / 上方向 / 前向 | 米 / `+Y` / `+Z` | 编辑器 + Three.js 作者规范 |
| 玩家可跨越台阶 | 实测上限 ∈ **[0.45, 0.50) m**，工程取 **0.45 m** | T-17 |
| **本轮新实测：0.56 m 台沿已挡住玩家** | 花冠台沿 `m3@76.56` vs 台面 `76.00` → 走路不可入 | `reports/day-04/C/CLEAN-SCENE-RETEST.md` §4 |
| 贴图格式 | KTX2（PNG 内嵌 GLB 在 runtime 导入失败） | T-08b |
| 贴图通道取舍 | albedo / emissive / 透明保留；**normal / ORM 丢弃** | T-19 |
| 颜色 | 一律 `_BaseColor`，不靠 GLB 内嵌颜色 | T-08 |
| 分件 | 必须分件（合并后按材质打包，颜色仍由 `_BaseColor` 决定） | §0.3 |

**硬红线（本轮事故直接相关）**：
1. 可走面的边界必须是 **≤0.45 m 的台阶**或**连续坡道**；**不允许**用 0.56 m 以上的台沿把可走面围起来。
2. 可走面正中央不得有任何 0.25 m 以上的装饰体（`SpawnMarker` 事故）。
3. 观景点不得被栏杆/装饰遮挡；栏杆必须低于玩家视线或留出缺口。

---

## GARDEN-001｜主巨型花朵（花冠层锚点 + 可站立平台）

### 玩家用途
花冠层的空间锚点、最终观景站立面。玩家要能**从台阶顶走（或一小跳）站上花瓣**，在花瓣上转身回望来路与倒悬温室。

### 尺度（建议，供最终确认）
- 总高 **12–14 m**，花冠直径 **7–8 m**（明显高于温室 ~5 m，形成上重下轻）
- 可站立外瓣：单瓣**顶面宽 ≥ 2.2 m、长 ≥ 3 m、坡度 ≤ 8°**
- 花心凹陷直径 1.2 m（视觉焦点，不承载玩法）
- 茎直径 0.5 m，向下 4–6 m 接根系

### 候选方向（总设计师三选一）

| 候选 | 剪影 / 结构 | 优点 | 风险 |
|---|---|---|---|
| **A｜厚瓣托盘花**（推荐） | 6 片厚外瓣向下翻，形成一圈连续托盘；内 4 片小瓣上卷；花心发光 | 可走面最大、最稳；剪影一眼是"花"；与温室体量差明显 | 花瓣太"厚"会像蘑菇，需要靠分瓣刻线拉开 |
| B｜悬垂钟形花 | 花朵整体倒挂，瓣尖向下垂，玩家站在瓣背（朝上的外表面） | 倒挂感最强，符合"反向生长"主题 | 可走面是凸起的瓣背，坡度易超 8°；碰撞面难做平 |
| C｜多层莲座花 | 3 层同心瓣，最外层平展成环台，玩家站在环台上 | 层次多、远景剪影丰富 | 分件多、面数高；环台与台沿容易形成 >0.45 m 高差 |

### 分件 / 材质槽（三候选通用）

| 分件 | 材质语义 | 备注 |
|---|---|---|
| `Petal_Walkable` | 不透明、粗糙、浅色 | **唯一可走面语义**；顶面平整 ≤8° |
| `Petal_Decor` | 半透明 / 渐变 | 装饰瓣，不得占据可走面顶面 |
| `Flower_Core` | 自发光（emissive 保留） | 视觉焦点 |
| `Stem_Root` | 不透明深色 | 与根系材质衔接 |

### 碰撞与验收
- 可走外瓣必须有独立碰撞面，实测"站上去 → 转身 → 走下去"全程不卡。
- 花瓣外缘到台沿的高差 **≤0.45 m**，禁止再用 0.56 m 台沿围边。
- 三角面预算：≤ 18k tris（单株）；贴图 ≤ 2 张 2048 KTX2。
- 验收截图：入口岛远眺（40–55 m）、平台接近（12–20 m）、玩家站花瓣（0–5 m）各一张。

### Tripo 提示词草案（候选 A）
```
A giant stylized flower, 13m tall, 7.5m crown diameter, six thick downward-curving outer petals
forming a continuous walkable tray, four smaller inner petals curling up, glowing concave core,
thick dark stem descending into roots, low-poly clean topology, flat shaded, no normal maps,
albedo + emissive only, readable silhouette from 50m, stylized low-poly game art
```

### 参考
- `tasks/004-c-floating-garden/VISUAL-REFERENCE-BOARD.md`
- `tasks/005-day03-closeout-day04-entry/VISUAL-REFERENCE-BOARDS.md` C-02 / C-03

---

## GARDEN-002｜倒悬温室（主地标）

### 玩家用途
路线中段的主地标与可走屋顶。玩家从根系下坡走到屋顶，再沿台阶上花冠；屋顶本身是"温室是倒的"这一核心线索。

### 尺度
- 温室体量 **~5 m 高 × 8 m × 10 m**（白盒 `material_7`/`_6` 围合范围）
- 屋顶可走面：`(116.48, 66.50, 123.66)` 附近，面积 ≥ 6×6 m
- 玻璃面板厚 ≥ 0.04 m，边框 ≥ 0.08 m（透明靠几何，不靠法线）

### 候选方向（总设计师三选一）

| 候选 | 结构 | 优点 | 风险 |
|---|---|---|---|
| **A｜倒置桁架玻璃房**（推荐） | 屋架朝天、玻璃面朝下、天窗朝地；立柱从"屋顶"向下插进根系 | 方向线索最强（檐口朝上/天窗朝下），白盒已按此做 | 玻璃反面在逆光下容易读成"破洞"，需要边框加强 |
| B｜半埋玻璃穹顶 | 穹顶半球倒扣在根系里，只露下半 | 体量柔和、与浮岛融合 | 倒悬线索弱，玩家可能读成普通穹顶 |
| C｜竖直玻璃塔（无倒置） | 常规温室塔 | 建造简单 | **不符合"反向生长"设计基线**，不建议 |

### 分件 / 材质槽

| 分件 | 材质语义 | 备注 |
|---|---|---|
| `Roof_Walkable` | 不透明、粗糙、深青蓝 | 可走面（对应白盒 `76.00` 层） |
| `Glass_Panel` | `alphaMode:BLEND` 半透明 | KTX2 albedo；**不要 normal/ORM** |
| `Frame_Metal` | 不透明、金属感靠 `_BaseColor` 明度 | 边框、桁架 |
| `Column_Root` | 不透明深色 | 立柱与根系衔接 |

### 碰撞与验收
- 屋顶可走面必须整片连通，**实测台阶顶 → 屋顶 → 台阶底全程可走**（本轮已复测：`(116.48,66.50,123.66)` 可站）。
- 玻璃不得有突出 0.25 m 以上的装饰挡住屋顶边缘。
- 三角面预算：≤ 12k tris；贴图 ≤ 2 张 2048 KTX2。
- 验收截图：入口岛远眺（看清"倒"）、根系下坡接近、屋顶站立三张。

### Tripo 提示词草案（候选 A）
```
An upside-down glass greenhouse: structural trusses point up, glass panels face down,
skylights open toward the ground, metal columns grow downward into roots,
5m tall 8m wide 10m long, stylized low-poly, glass panels semi-transparent with thick frames,
flat shaded, albedo only (no normal/roughness maps), readable inverted silhouette from 50m
```

### 参考
- 白盒现状：`reports/day-04/C/c02-03-stair-top.png`、`c02-04-vista.png`
- `tasks/005-day03-closeout-day04-entry/VISUAL-REFERENCE-BOARDS.md` C-03「倒悬温室」行

---

## 交付状态

| 项 | 状态 |
|---|---|
| 需求卡（本文件） | ✅ 已提交 |
| Tripo 生成 | ❌ 未生成（总设计师执行） |
| 候选选择 | ❌ 待总设计决策（A/B/C） |
| 导入验收 | ❌ 未开始（无模型） |

> 导入验收前必须先解决 **B-02 花冠台沿 0.56 m / 北槽** 与 **B-01 全局出生点** 两项阻塞，否则再好的资产也进不了可玩路线。
