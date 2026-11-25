# C｜Day 4 证据索引

> 全部为本会话真实 runtime 截图/读数，未合成、未复用 Day 3 截图冒充。

## Clean-scene 复测（Issue #23 P0-2）

| 文件 | 内容 | 读数/说明 |
|---|---|---|
| `evidence/day-04/C/c02-01b-fresh-entry.png` | 新 runtime 首次传送进入入口岛，相机默认视角 | 深蓝入口面 + 左侧绿墙，天空（地形单面，从下看是天空） |
| `evidence/day-04/C/c02-02-cue-fired.png` | 真实等待 52 s 后（45 s Cue 已触发） | 对应读数 `armed=true, cues=1/3, elapsed=12.80, last=light+time` |
| `evidence/day-04/C/c02-03-stair-top.png` | 连续走完根系下坡 + 34 级台阶，到达台阶顶 `(115.09,76.01,139.14)` | 与 Day 3 `(115,76.01,139.1)` 一致 |
| `evidence/day-04/C/c02-04-vista.png` | U 形回转后向观景台走，掉入北槽后画面 | 落在 `(119.77,72.47,136.96)` |
| `evidence/day-04/C/c02-05-whitebox-before-tint-fix.png` | 从上方俯视白盒位置（`--object garden-whitebox --distance 70`） | 只能看到地形，白盒被埋；证明"从地表看不到花园" |
| `evidence/day-04/C/c02-06-vista-default-view.png` | 观景台面 `(120,76.01,135)` 默认视角 | 深蓝平台 + 绿色台沿 + 天空；倒悬温室不在默认视角 |
| `evidence/day-04/C/c02-07-after-restart-respawn.png` | restart 后云垫坠落复位落点 | `1:respawned`，落 `(120.00,70.00,107.00)` |

## 数据/日志

| 文件 | 内容 |
|---|---|
| `reports/day-04/C/walk-log.jsonl` | 21 段连续行走逐段坐标（JSONL：`t / seg / pos`） |
| `reports/day-04/C/AFTER-ROOTS.md` | 持久清理后 44 节点 / 4 根 / 单 whitebox 清单 |
| `reports/day-04/C/BEFORE-ROOTS.md` | 清理前清单（对照） |
| `reports/day-04/C/after-dedup.png` / `current-view.png` | 清理后 runtime 截图 |

## 关键读数原文（可复跑）

```
# 45 s Cue（新 runtime）
armed=true,cues=1/3,elapsed=12.80,last=light+time

# restart 后
GetState()    = 0:none
GetCueState() = armed=false,cues=0/3,elapsed=-1.00,last=none
previewGameRoot children=4 whitebox=1

# restart 后坠落复位
BEFORE 0:none → AFTER 1:respawned → 落地 (120.00,70.00,107.00)

# 花冠台面（射线网格）
台面 x 116.5–123.5, z 131–138 = 76.00–76.01
台沿 x=116 / x=124 / z=139.5 = 76.56（0.56 m）
北槽 z=140, x≥117.5 = MISS
```
