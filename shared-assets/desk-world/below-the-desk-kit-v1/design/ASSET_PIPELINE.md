# 素材来源、资产生产与许可证管理 v0.2

## 推荐来源

  ------------------------------------------------------------------------------------------------------------------------------------
  来源                                      用途                      许可                    项目策略
  ----------------------------------------- ------------------------- ----------------------- ----------------------------------------
  [Poly Haven](https://polyhaven.com/)      HDRI、PBR材质、部分模型   官方资产 CC0            主要用于材质和环境光，模型需统一风格

  [ambientCG](https://ambientcg.com/)       PBR材质、纹理、HDRI       官方资产 CC0 1.0        调整纹理尺度、色调、粗糙度后使用

  [Kenney](https://kenney.nl/)              原型资产、UI、音效        官方说明资产页资源      用于原型和辅助资产，不强行混入核心场景
                                                                      CC0，检查包内许可文件   

  [OpenGameArt](https://opengameart.org/)   音乐、音效、游戏资源      每项资源单独标注        逐项审核，优先 CC0

  [Freesound](https://freesound.org/)       物件录音、环境声、脚步    CC0/CC-BY/CC-BY-NC 等   逐条审核，排除 NC
  ------------------------------------------------------------------------------------------------------------------------------------

## 资产生产

-   核心资产：定制建模或深度改造。
-   模块资产：统一尺寸网格和连接规则。
-   装饰资产：优先复用、实例化。
-   材质：从 CC0 PBR 库获取后做风格化调整。
-   音频：先用 CC0 候选，试听和混音通过后采用。

## 资产目录

``` text
assets/
├── core/
├── modular/
├── dressing/
├── materials/
├── textures/
├── lighting/
├── animations/
├── audio/{music,ambience,foley,ui}/
├── ui/
└── license/{ASSET_REGISTER.csv,THIRD_PARTY_NOTICES.md}
```

## 登记字段

asset_id、asset_name、author、source_url、license、download_date、original_filename、modifications、used_in、review_status、evidence_path。保存原始下载文件和许可页面/文本。

## 官方许可说明链接

-   Poly Haven License: https://polyhaven.com/license
-   ambientCG License: https://docs.ambientcg.com/license/
-   Kenney Support: https://kenney.nl/support
-   Freesound FAQ: https://freesound.org/help/faq/
-   OpenGameArt: https://opengameart.org/（逐项核对具体资源页）

不把搜索摘要当最终授权依据；正式发布前重新核对具体资源页。
