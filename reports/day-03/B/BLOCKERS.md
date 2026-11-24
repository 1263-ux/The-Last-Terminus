# B｜B-07 阻塞：运行时从不加载场景几何（已多路径排除）

分支：`feature/desk-world` · 编辑器 **1.0.104**
状态：**BLOCKED（P0）** — 冻结全部需要"真实 GLB 出现在画面"的验收项

---

## 0. 一句话

> **不论用哪个工程、哪种启动模式、是否新建、是否真实导入并保存，
> 运行时 `WorldRoot` 永远是 0 子节点、全场景 `MeshRenderer` 数永远是 0。**

资产、导入、保存、数据层全部正常。失效点在"已保存的场景数据 → 运行中的关卡"这一步。

---

## 1. 完整证据链（四组独立测试）

| # | 工程 | 模式 | 是否导入+保存 | `WorldRoot` 子节点 | `meshRenderers` | 场景名 |
|---|---|---|---:|---:|---|---|
| 1 | 原工程 `project-006822bc…` | foreground | ✅ 导入 7 件 + save | **0** | **0** | `HamletPreview` |
| 2 | 新建 `DeskWorldProbe`（模板空白） | foreground | ❌ 未导入 | **0** | **0** | `HamletPreview` |
| 3 | 同上 | **offscreen** | ❌ 未导入 | **0** | **0** | `HamletPreview` |
| 4 | 同上 | offscreen | ✅ 导入尺子桥 + save | **0** | **0** | `HamletPreview` |

**四组结果完全一致。**

---

## 2. 数据层是完好的（关键对照）

第 4 组测试后，`scene.data` 解包回读 —— **14 个节点，尺子桥层级完整**：

```
-145304910  地图
-518093461  地形
1379704555  湖泊
750902110   地形块(0,0)
1694159390  地形块
1465652140  边界墙
314639729   出生点
-1661484697 ruler-bridge-full-v01          ← 根节点
-1198576814  ├─ SM_bridge_ruler
 833630249   ├─ SM_bridge_numerals          ← 刻度数字（PNG 载体）
 1405773773  ├─ SM_bridge_post_l
-66003503    ├─ SM_bridge_post_r
-1686872025  ├─ SM_bridge_bracket_l
-534607956   ├─ SM_bridge_bracket_r
```

**这正是 `TASK-ACCEPTANCE` §A-01 要求的「单个 GLB root + 内部多个 mesh children」形态**，
且 6 个部件与清单「6 meshes」逐一对应，`SM_bridge_numerals` 明确存在。

**数据层 PASS，运行层 FAIL。**

---

## 3. 已排除的原因（逐条有检查）

| # | 假设 | 检查方法 | 结论 |
|---|---|---|---|
| 1 | 工程损坏 | 用 `project create` 建全新工程 | ❌ **新工程同样为 0** |
| 2 | `worldType=avatar` 异常 | 读官方模板 `templates/empty/project/world-config.json` | ❌ **模板本身也是 avatar** |
| 3 | 启动模式错误 | foreground vs **offscreen**（workflow 指南推荐新项目用 offscreen） | ❌ **两种模式都是 0** |
| 4 | 需要真实导入才加载 | 在新工程导入尺子桥 + `scene save committed` 后重启 runtime | ❌ **仍为 0** |
| 5 | 需要完整重启 | `runtime stop` → `start`，等待 20 s | ❌ 无效 |
| 6 | `runtime reload` | 尝试 | ❌ 报 `runtime-generation-conflict` |
| 7 | 导入未落盘 | 解包 `scene.data` 回读 | ❌ **节点完整存在** |
| 8 | 层级搜索位置错 | 全图遍历（深度 14，104 节点），名字含 ruler/bridge 计数 | ❌ **命中 0** |
| 9 | 资产本身坏 | 7/7 SHA 与包内清单一致；编辑器正确解析 `faceCount` | ❌ **资产正常** |
| 10 | 编辑器解析能力不足 | 7 件资产入库全部成功，面数正确 | ❌ 解析正常 |

**十条排除后，唯一剩下的解释是：本版本的 `runtime start` 不实例化 `scene.data` 中的关卡内容，
只启动 `HamletPreview` 角色预览场景。**

---

## 4. 旁证：为什么我以前"能看到东西"

我在 Day 1–3 一度以为渲染有问题，实际是**两件不同的事**：

| 方式 | 能否出现在运行时 | 原因 |
|---|---|---|
| 运行时 `GameObject.CreatePrimitive` / `scene import` 后 **lua 动态创建** | ✅ **能** | 直接进当前场景，不依赖加载器 |
| `scene import` 写入 `scene.data` 的 GLB / 地形 | ❌ **不能** | `WorldRoot` 不加载 |

所以此前所有"看得到"的画面，**都是我运行时动态创建的对象**，不是从场景数据加载的。

> 这解释了为什么 `18-visibility-law-proof.jpg` 里那个红块能看到 —— 它是 `CreatePrimitive`。

---

## 5. 影响范围

| B 线验收项 | 依赖 | 状态 |
|---|---|---|
| B-02 导入烟雾测试（层级/mesh 数） | 数据层 | ✅ **PASS** |
| B-02 尺寸/朝向/X 镜像运行时复测 | 运行时 | ⛔ **NOT TESTED** |
| B-04 尺子桥 PNG 刻度解码 | 运行时 | ⛔ **NOT TESTED**（强制项 FAIL 未判） |
| B-03 玩家视角可见性 | 运行时 | ⛔ **NOT TESTED** |
| B-04 REST → 完整桥体切换 | 运行时 | ⛔ **NOT TESTED** |
| B-05 一镜到底连续通行 | 运行时 | ⛔ **NOT TESTED** |
| B-06 5–8 分钟垂直切片 | 运行时 | ⛔ **NOT TESTED** |
| B-07 失败恢复/保存重开 | 运行时 | ❌ **FAIL**（重开后仍空） |

**B Gate 全部核心条件无法判定。**

---

## 6. 我能自主做到的部分（阻塞期间）

| 工作 | 状态 |
|---|---|
| 资产包 SHA 校验（ZIP + 7/7 GLB） | ✅ PASS |
| GLB 结构审计与清单逐项核对 | ✅ PASS |
| 资产入库 7/7 | ✅ PASS |
| `scene.data` 层级验证（1 root + 6 children） | ✅ PASS |
| `√T` 缩放规律在第三方资产上复现 | ✅ 数据层已验证 |
| 用运行时 primitive 验证玩法**逻辑** | ✅ 已做（门禁 `ruleFires true→false`） |
| 用 primitive 验证**比例关系** | ✅ 部分（8 m 箱体代尺子） |
| 真实 GLB 的材质/刻度/朝向 | ❌ 无法替代 |

**我可以继续做逻辑与比例，但交不出"真实资产看起来对"的证据。**

---

## 7. 需要的动作（按优先级）

| # | 谁 | 做什么 | 为什么关键 |
|---|---|---|---|
| **1** | **成员 B 本人（GUI）** | 在编辑器**界面里**点"运行/预览"，看地形和导入的书桌是否出现 | 区分"CLI 预览不加载" vs "运行时根本不加载" |
| **2** | 成员 B 本人（GUI） | 若 GUI 预览能看到 → 说明是 `runtime start` 的加载路径问题，记录工作方式 | 决定我后续用哪条路径取证 |
| **3** | A（集成） | 在 A 的工程里 `scene import` 同一 GLB，检查 `WorldRoot` 子节点 | 判断是本机问题还是普遍现象 |
| 4 | 编辑器侧 | 说明：`runtime start` 是否会加载 `scene.data`；关卡内容的正确启动方式 | 定位文档缺失 |

**第 1 条最关键且只需 30 秒。** 我无法点击 GUI 的"运行"按钮。

---

## 8. 恢复条件

任一条成立即可解除：

1. 找到让 `WorldRoot` 加载场景内容的方法（参数、命令或 GUI 操作）；
2. 或确认需要**发布后运行**才加载，并提供发布流程；
3. 或官方说明何种情况下 `runtime start` 会实例化 `scene.data`。

---

## 9. 我不会做的事

- ❌ 不会拿运行时 primitive 冒充"GLB 导入成功"的证据；
- ❌ 不会因为 `scene.data` 有节点就宣称导入 PASS；
- ❌ 不会用节点定向截图冒充玩家视角；
- ❌ 不会为凑时长伪造垂直切片。

`TASK-ACCEPTANCE` §0 明确：**Blender ACCEPTED ≠ 造世界编辑器导入 PASS**。
同理，**数据层 PASS ≠ 运行层 PASS**。
