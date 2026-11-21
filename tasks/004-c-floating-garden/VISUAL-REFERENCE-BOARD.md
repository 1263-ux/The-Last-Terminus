# C｜失重花园模块级视觉参考板

> 用途：给 C/DSH、总设计师和 Tripo 建模提供共同视觉语言。以下为官方游戏/开发者页面的研究图，仅用于设计研究，不是可直接使用的游戏资产。
>
> 核心差异：本世界不是普通浮空岛景观集合，而是通过空间方向、层级和路径发现形成可玩的花园。

## 0. 统一视觉基线

- 高品质风格化奇幻植物园。
- 空灵、温馨、唯美，局部神秘。
- 植物结构可信，花瓣、花心、茎、根有清楚层次。
- 玻璃、金属、植物、岩层之间存在材质对比。
- 前中远景分层清晰；视觉奇观不能牺牲路线可读性。

## 1. 浮空岛｜Floating Island

**玩家感受：** 花园漂浮在云海之间，岛屿底部也有结构和生命，而不是简单悬浮方块。

参考图：
- Sky 官方云海区域：[Prairie](https://www.thatskygame.com/f=png/https://a.storyblok.com/f/108104/4800x2700/90a0601dba/2_prairie_7d7846757a.jpeg)
- Sky 官方岛屿环境：[Isle](https://www.thatskygame.com/f=webp/https://a.storyblok.com/f/108104/4800x2700/4056a54ce0/1_isle_3bd558e155.jpeg)
- Sky 官方区域：[Vault](https://www.thatskygame.com/f=png/https://a.storyblok.com/f/108104/4800x2700/049b988cf1/6_vault_113ed76ed9.jpeg)

学习：
- 云层前中远景和岛屿尺度关系。
- 岛屿边缘如何通过岩层、植被和雾建立厚度。
- 远处地标如何吸引玩家视线。

原创转化：
- 浮岛边缘增加岩层、土壤、根系和垂落植物。
- 主岛与远景岛的细节密度要区分。
- 不复制 Sky 的建筑、角色和飞行玩法。

## 2. 巨型花朵｜Giant Flower

**玩家感受：** 花朵不仅是装饰，而是世界的主地标、路线节点，甚至可以成为玩家站立和观察的空间。

参考图：
- Ori 官方媒体截图：[Ori and the Will of the Wisps 01](https://ori-prod.azureedge.net/wp-content/uploads/2021/08/screenshot_wotw_01-1024x576.png)
- Ori 官方媒体截图：[E3 2019 environment](https://ori-prod.azureedge.net/wp-content/uploads/2021/08/screenshot_wotw_E32019_01-1024x576.jpg)
- Ori 官方环境壁纸：[Spirit Tree](https://ori-prod.azureedge.net/wp-content/uploads/2021/08/WotW_WallpaperSpiritTree_1920x1080-1024x576.jpg)

学习：
- 植物主地标的剪影、颜色和环境关系。
- 花/树与周围空间的比例。
- 植物表面细节和光照如何形成生命感。

原创转化：
- 花瓣层次、花心、茎和根必须结构清晰。
- 如果玩家需要站在花瓣上，必须考虑平台宽度、碰撞和安全边缘。
- 不复制 Ori 的具体植物、角色和场景。

## 3. 根系长廊｜Root Corridor

**玩家感受：** 根系既像植物结构，也像自然桥梁和隐藏通道。

参考图：
- Ori 官方环境截图：[Ori environment 02](https://ori-prod.azureedge.net/wp-content/uploads/2021/08/screenshot_wotw_02-1024x576.png)
- Ori 官方环境截图：[Ori environment 04](https://ori-prod.azureedge.net/wp-content/uploads/2021/08/screenshot_wotw_04-1024x576.png)
- Sky 官方岛屿环境：[Isle](https://www.thatskygame.com/f=webp/https://a.storyblok.com/f/108104/4800x2700/4056a54ce0/1_isle_3bd558e155.jpeg)

学习：
- 根系的粗细、分叉、弯曲和连接关系。
- 植物结构如何形成自然路径。
- 可通行区域与纯装饰结构如何区分。

原创转化：
- 主根应形成可读的连续通道，支根提供视觉细节。
- 不能让玩家误把装饰根系当作可走路径。
- 结构需要有合理的连接和受力感，不要像随意摆放的管线。

## 4. 倒悬温室｜Inverted Greenhouse

**玩家感受：** 温室是花园的核心目的地，它的建筑方向和植物生长方向共同制造空间异常。

参考图：
- Tiny Glade 官方建筑截图：[Architecture reference](https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2198150/ss_ed8d49e1bdc02b0c8caadb66e06b6d6ad6218c1f.1920x1080.jpg)
- Monument Valley 开发者官方设计图：[Monument Valley](https://images.ctfassets.net/ve81k805bx04/2BaYj2l8S0kwyKmMkcWyOy/c8ddbd7aa3825519f49b5a3fea8e185c/iPad_01.png?w=1200)

学习：
- 建筑轮廓和结构如何一眼读懂。
- 玻璃、框架、立柱、拱形之间的关系。
- 空间错觉如何通过视角和几何连接实现。

原创转化：
- 温室可以倾斜或倒悬，但入口、可站立面和路径必须清楚。
- 玻璃面积要控制，避免反射/透明材质影响性能和可读性。
- 不复制 Monument Valley 的具体几何或 Tiny Glade 的建筑样式。

## 5. 空中平台｜Floating Platforms

**玩家感受：** 平台不是随意漂浮的方块，而是连接不同高度层的空间结构。

参考图：
- The Last Campfire 官方 Press Kit：[Puzzle environment 0](https://thelastcampfiregame.com/images/presskit/0.png)
- The Last Campfire 官方 Press Kit：[Puzzle environment 2](https://thelastcampfiregame.com/images/presskit/2.png)
- Monument Valley 官方设计文章：[Monument Valley](https://ustwo.com/blog/monument-valley-out-now/)

学习：
- 机关与空间连接的关系。
- 玩家如何理解可通行的结构。
- 平台状态变化如何形成明确反馈。

原创转化：
- 移动平台只是实现手段，真正玩法是玩家发现路径。
- 如果编辑器的移动能力不稳定，优先降级为固定平台、触发式切换或短传送。
- 不以频繁跳跃和坠落惩罚制造难度。

## 6. 高处观景点｜High Vista

**玩家感受：** 玩家抵达高处后，终于看懂之前探索过的空间结构，并获得明显的视野奖励。

参考图：
- Sky 官方日落环境：[Dawn/Cloud environment](https://www.thatskygame.com/f=png/https://a.storyblok.com/f/108104/2560x1440/7226d91fbf/dobl_sunset-wallpaper_s2560x1440_2403.png)
- Sky 官方云海区域：[Prairie](https://www.thatskygame.com/f=png/https://a.storyblok.com/f/108104/4800x2700/90a0601dba/2_prairie_7d7846757a.jpeg)
- Journey 艺术总监作品档案：[Journey art direction](https://mattnava.com/Journey-1)

学习：
- 远景留白、地标轮廓和光线方向。
- 高处视角如何重新组织玩家对空间的理解。
- 终点画面如何形成情绪奖励。

原创转化：
- 观景点应同时看见主花园、温室和部分云海。
- 不要用过度雾效遮住空间结构。
- 让玩家有停留位置，不要把观景点设计成一块狭窄的跳跃平台。

## 7. 交给 C/DSH 的使用方法

1. 先根据空间方案选择参考图，不要把所有图片混成一个提示词。
2. 每张图标注：空间结构、轮廓、材质、路线可读性和光照。
3. 先验证玩家能否走通三层空间，再决定定制模型。
4. 巨花、温室、根系等关键模型提交 Asset Card，由总设计师负责 Tripo 生成。
5. 导入后重点检查结构、碰撞、透明材质、层级和远中近景表现。

**禁止：** 复制 Sky/Ori/Monument Valley 的标志性建筑、角色、配色组合、关卡几何、UI 或音乐；参考图只用于内部设计研究。
