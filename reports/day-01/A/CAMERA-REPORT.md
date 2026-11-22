# 相机行为实测报告｜P09

> Owner：成员 A
> 目的：解决 `HUB-WHITEBOX.md` §5 中标为最高优先级的未验证项——
> **第三人称相机是否会被车厢墙壁挤压 / 穿墙？**
> 引擎：造世界编辑器 1.0.104

---

## 1. 结论（一句话）

**相机有真实的碰撞避让。它不会穿墙，靠墙时自动拉近玩家。**

这否定了我 Day-01 白盒记录里的担忧。**车厢不需要为了相机而加宽**，
但需要为"靠墙时画面被角色占满"这一现象做设计应对。

---

## 2. 决定性 A/B 实验

同一请求 `SetDistance(6.0)`，只改"身后有没有墙"：

| 条件 | 请求距离 | **实测水平距离** | 相机是否穿墙 |
|---|---|---|---|
| 车厢内（墙在 1.90 m 处） | 6.0 m | **1.60 m** | **否**（`camX = -1.71 > -1.90`） |
| 开阔地形（身后无遮挡） | 6.0 m | **5.98 m** | 不适用 |

**这组对照是关键**：若相机没有避让，两种情况都应是 6 m 左右。
实际车厢内被压到 1.60 m，且停在墙面之前 0.19 m 处 —— 只能是碰撞避让。

证据：`edge/P09-camera-AB-distance6.txt`、`P09-camera-AB-open-control.txt`

---

## 3. 相机参数实测

| 项 | 实测值 | 获取方式 |
|---|---|---|
| 默认跟随距离 | **1.80 m** | 车厢中心，`SetYaw(0)` 后静止 |
| 默认高度 | 角色上方 **约 1.01 m** | 早期 `P08-camera-metrics.json` |
| FOV | **45°** | `Camera.main.fieldOfView` |
| 靠墙最小距离 | **0.72 m**（实测到过的下限） | 玩家贴墙 + 相机朝墙 |
| `SetDistance()` 是否生效 | **是** | 1.80 → 0.70 → 1.60，随参数变化 |
| `SetYaw()` / `SetPitch()` 是否生效 | **是** | 朝向随参数改变 |
| 相机 yaw 是否跟随角色朝向 | **否** | 角色转 90° 后相机朝向不变，需显式 `SetYaw` |

### 3.1 三个必须知道的相机行为

1. **相机 yaw 独立于角色朝向。** 角色转身不会带动相机。
   想让镜头对准某个方向，必须显式 `DouyinCameraService.SetYaw()`。
   → 做"下车后面向地标"时，**不能只转角色**，还要转相机。

2. **`SetDistance` 有平滑过渡。** 设置后立刻读取仍是旧值，
   需等待若干帧 / 数百毫秒。`P09-camera-distance.txt` 里三次连读
   都是 `0.93` 就是这个原因，**不是 API 失效**。

3. **靠墙时相机拉到 0.72–1.60 m。** 此时角色会占据画面很大比例。
   这在 3.8 m 宽的车厢里很难避免，需要在设计上接受或补偿。

---

## 4. 对列车 Hub 设计的影响（更新 HUB-WHITEBOX 结论）

| 原担忧 | 实测结论 | 设计动作 |
|---|---|---|
| 相机会穿墙 | **不会** | ✅ 无需加宽车厢到 4.4 m |
| 3.8 m 宽不够给相机空间 | 够用，但会拉近 | 保留 3.80 m，**接受近距构图** |
| 需要相机避让系统 | 引擎自带 | ✅ 无需自研 |

**剩下要处理的是"贴墙时画面被角色占满"的观感问题**，方案按成本排序：

1. **不处理**——车厢本来就是窄空间，拉近是可接受的手感（零成本）。
2. **靠墙侧墙做半透明**——玩家贴墙时能看穿，不丢视野（低成本，1 个材质改动）。
3. **限制玩家靠墙距离**——墙内侧加 0.2 m 不可行走带（低成本，改碰撞）。
4. **动态 `SetDistance`**——检测到相机被压到 <1.2 m 时略微抬高 pitch（中成本，需写 Lua）。

**Day-02 建议先试方案 1 与 2，用截图对比后再定。**

---

## 5. 尚未验证

| 项 | 状态 |
|---|---|
| 相机对 **Trigger（无实体）** 是否也避让 | **NOT TESTED** |
| 相机对**半透明材质**的避让是否相同 | **NOT TESTED** |
| 相机避让的**最小距离下限**是多少 | **NOT TESTED**（观察到 0.72 m，未穷尽） |
| `SetDistance` 的最大可用值 | 5.98 m 可用；更远未测 |
| 移动中（非静止）避让是否平滑 | **NOT TESTED** |

---

## 6. 复现步骤

```powershell
# 1. 启动实例与预览
douyin-world instance start --project <A项目> --mode offscreen
douyin-world runtime start --instance <I>

# 2. 车厢内 A 组：站中心、相机朝 -X、请求 6m
douyin-world runtime lua eval --file cam_ab_setup.lua --instance <I> --runtime-id <R> --global
# 等 4 秒
douyin-world runtime lua eval --file cam_read.lua --instance <I> --runtime-id <R> --global
# → horizDist=1.60  camOutsideWall=false

# 3. 开阔地 对照组：同请求 6m
douyin-world runtime lua eval --file cam_control.lua --instance <I> --runtime-id <R> --global
# 等 4 秒
douyin-world runtime lua eval --file cam_read_open.lua --instance <I> --runtime-id <R> --global
# → horizDist=5.98
```
