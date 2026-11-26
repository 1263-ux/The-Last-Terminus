# A｜统一音频 Manifest 与接入计划

> Owner：成员 A（全项目集成，统一声音接入 Owner）
> 日期：2026-11-24
> 依据：Issue #23 §2（统一声音）/ §8（音乐/环境音实际播放且授权清楚）
> 原则：**音频探针 ≠ 最终音乐完成**；未实际试听、未核验许可的素材一律标 NOT TESTED / 未采用。

---

## 0. 一句话

A 的音频**技术链路已验证**（导入/绑定/播放官方模式），但 Issue #23 要求的
"统一列车主题 + 四空间音乐/环境声 + 实际试听 + 音量平衡 + 授权记录"
**尚未完成**——缺真实音频素材与试听环节。本 Manifest 记录技术基础、素材需求与诚实状态，
不把探针冒充成品。

---

## 1. 已验证的技术链路（TESTED，Day-3 A5）

| 环节 | 状态 | 证据 |
|---|---|---|
| 官方声明模式 | **TESTED** | `@refFrom asset` + `@dataType Audio` + `@assetCategory Music` |
| 三参数绑定 | **TESTED** | AudioClip / Volume / MaxDistance |
| 归档 | **TESTED** | WAV + `meta.json`(schemaVersion 4) → `resource archive --kind audio` |
| `{uri}` 简写绑定 | **TESTED** | `A5-audio-bindings.json` |
| 播放设置 | **TESTED** | `ApplySoundSettings()` 在播放时调用（**不是 `Start()`**——Start 有时序问题） |
| 空间化 | **TESTED** | `spatialBlend=1`, `AudioRolloffMode.Linear`, min/max distance |
| 运行时实际听到 | **NOT TESTED** | 探针只验证参数注入，不等于人耳试听 |
| 音量平衡 / 循环 | **NOT TESTED** | 需实际播放多轨 |

**官方 Lua 模式**（可复用）：
```lua
---@var MySound:UnityEngine.AudioClip=nil
---@refFrom asset
---@assetCategory Music
---@dataType Audio
---@var MySoundVolume:number=1
---@var MySoundMaxDistance:number=5

-- 播放时（非 Start）：
audioSource.volume = math.max(0, math.min(1, MySoundVolume))
audioSource.minDistance = math.min(1, distance * 0.1)
audioSource.maxDistance = distance
audioSource.rolloffMode = CS.UnityEngine.AudioRolloffMode.Linear
audioSource.spatialBlend = 1
```

证据目录：`reports/day-03/A/evidence/A5-audio-*.json`（21 个探针文件）。

---

## 2. 全项目音频需求矩阵（Issue #23 §2）

| 空间 | 音乐 | 环境声 | 关键音效 | 状态 |
|---|---|---|---|---|
| **列车 Hub** | 列车主题动机（贯穿全旅程） | 车厢内低鸣/轨道声 | 汽笛、到站提示、上下车 | **素材未定 / NOT TESTED** |
| **Desk《桌面以下》** | 探索音乐（温暖微缩） | 纸/木/陶瓷环境声 | 尺子摆放、桥落位、暖窗点亮 | **素材未定 / NOT TESTED**（A 的 `AUDIO_SHORTLIST` 是候选，非采用） |
| **Garden《失重花园》** | 空灵/漂浮 | 风/叶/玻璃声 | 落地复位、Backup Cue、台阶 | **素材未定 / NOT TESTED** |
| **Terminus《云海尽头》** | 收束主题（开阔） | 开阔风声 | 抵达/观景提示、终曲 | **素材未定 / NOT TESTED** |
| **全程** | 统一主题动机变奏 | — | 旅程转场音 | **NOT TESTED** |

> 设计基线的音乐候选（Sunset Plains / Magic Town / Meadow Thoughts / First Light Particles /
> Goodbye to Friends / Best Friends Theme）是**初筛记录，不代表已试听或正式采用**；
> 必须保存具体资源页、许可证和原始文件（≤ 见 `BELOWTHEDESK-DESIGN-BASIS.md` §8）。

---

## 3. 授权与来源记录（NOT TESTED）

| 项 | 状态 | 要求 |
|---|---|---|
| 每个音源的具体资源页 | **缺** | 记录 URL/来源 |
| 许可证类型与文本 | **缺** | CC0/CC-BY 等，保存许可文件 |
| 原始文件归档 | **缺** | 保存 WAV 原件与 meta.json |
| 商用/比赛使用合规 | **NOT TESTED** | 逐条核验 |

**未试听、未核验许可的素材不得标记为正式采用。**

---

## 4. 接入顺序（获 GUI 会话后执行）

1. 确定列车主题动机（一段），作为四空间统一锚点。
2. 每个空间选 1 首音乐 + 1 组环境声，先核验许可与试听，再归档。
3. 按官方模式绑定，播放时用 `ApplySoundSettings()`。
4. 实测：实际人耳试听 → 音量平衡（避免 BGM 压过音效）→ 循环检查 → 四空间切换不互相覆盖。
5. 提交 `AUDIO-MANIFEST` 更新（填素材 URL/许可/试听结论）+ 完整旅程录屏中的音轨。

---

## 5. 本轮状态汇总

| 项 | 状态 |
|---|---|
| 音频导入/绑定/播放技术链 | **TESTED** |
| 素材选定 | **NOT TESTED** |
| 实际试听 / 音量平衡 / 循环 | **NOT TESTED** |
| 授权记录 | **缺** |
| 统一主题动机 | **未定** |

不把 A5 探针等同于"音频完成"（符合 Issue #18 禁止事项：API play=true 不算人耳听到）。
