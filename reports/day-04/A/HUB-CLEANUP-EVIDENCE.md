# A｜Hub 场景清场实测（运行态阻塞解除第一步）

> Owner：成员 A
> 日期：2026-11-26
> 方法：`scene remove`（明确 17 个残留 rootIDs）→ `scene save` → 关闭 → 重开 → 新 runtime 验证
> 边界：**只删旧测试探针节点**，不动 Env/地图/出生点/Terminus 白盒；删前已备份 scene.data。

---

## 0. 一句话

A 工程运行时场景从 **22 根降到 5 根**，18 个旧门禁/音频测试残留中的 17 个已按明确 rootID 清除，
保存重开后新 runtime 复验通过。这是"Hub/Terminus 可运行候选"的**前置清场**，
不是 Hub 本身完成——出生点仍错误、Hub 白盒仍缺失（见下）。

---

## 1. 实测过程（TESTED）

### 1.1 备份
- `scene.data` 793,068 bytes，SHA-256 `AAE64E034E61A4DC402695D68439C19FAEA8B24795B3BC407B27751F87A35CE5`
- 备份路径：`D:\zjx\projects\backups\scene-A-20261126-1340.data`

### 1.2 删除（17 个残留 rootID）
```
-2042842711 -1607152287 -1105024685 1051218594 1989658078 1684296779
1851674998 -181195476 1235422678 483545259 1390851605 -1991003086
1141747209 1092089078 560628402 760228294 628087978
```
返回：`status=committed`，`removedRootIDs` 17 个全部匹配；`requestId=cleanup-stale-a-1124`。
证据：`evidence/A-cleanup-remove.json`

### 1.3 保存
`scene save` → `status=committed`, `hasUnsavedChanges=false`, `requestId=cleanup-save-a-1124`。
证据：`evidence/A-cleanup-save.json`

### 1.4 关闭 → 重开 → 新 runtime 复验
```
runtime lua eval (list_runtime_roots.lua):
children=5: Env(0,0,0) | 地图(0,0,0) | 出生点(119.7,80,88.6) |
           A_终点站_地形级(119.7,78,88) | A_终点站_路线验证(119.7,78,88)
```
证据：`evidence/A-hub-clean-spawn.png`（1,216,598 bytes，13:40:13Z 玩家视角）。

---

## 2. 清场后诚实现状

| 项 | 状态 |
|---|---|
| 运行时根数 | **5**（从 22 降），无旧测试探针残留 —— **PASS** |
| 保存重开后唯一实例 | **PASS**（新 runtime 复验 5 根） |
| 玩家出生位置 | `(119.74, 78.00, 88.64)` —— BornPoint 写 y=80 但实际落 y=78，**仍错误** |
| 中央炉岛 Hub 白盒 | **仍缺失**（运行时只有 Terminus 两个白盒根，没有 Hub 独立节点） |
| Hub → Desk/Garden/Terminus 连接 | **NOT TESTED**（清场只是前置） |
| Terminus 连续观景 | **NOT TESTED**（有白盒，无人眼连续走通） |

---

## 3. 下一步（裁定 P0，仍未完成）

1. **修出生点**：需 GUI 把 BornPoint 移到真正 Hub 入口（CLI `scene` 无 Transform 写入），保存→关闭→重开→新 runtime 实测。
2. **建 Hub 白盒**：中央炉岛 Scheme 2 尚未作为独立可运行节点存在——需从作者源导入或 GUI 搭建。
3. **接线**：用 Desk Entry (119.74,79.41,88.64)、Garden Entry (120,70,105) 做 Trigger 连接。
4. **Terminus 观景**：从列车抵达→拱廊→观景点人眼评审。

本轮只清场、不新建内容；不把"清场 PASS"冒充"Hub 可运行候选 PASS"。
