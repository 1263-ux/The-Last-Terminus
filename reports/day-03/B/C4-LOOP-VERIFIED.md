# B2｜C4 玩法闭环：验证通过

分支：`feature/desk-world` · 编辑器 1.0.104 · 工程 `project-006822bc-d20b-4e2b-b6ae-b80fc9498688`
状态：**逻辑闭环 PASS｜玩家视角渲染 PASS｜物理阻挡 不可能（架构限制）**

---

## 0. 闭环实测数据

同一个玩家位置（`z = 107.64`，已越过门线 `z = 104`），只改变尺子状态：

| 时刻 | `solved` | `ruleFires` | `verdict` |
|---|---|---|---|
| **激活前** | false | **true** | **BLOCKED_SHOULD_RETURN** |
| **激活后** | true | **false** | **PASS** |

**这是本轮的核心结果：位置不变，状态一变，通路从"拦"变成"放"。**

---

## 1. 状态切换是真替换，不是并存

激活时同时发生：

```
C4_RULER_REST  →  SetActive(false)   ← 静止的尺子消失了
C4_RAMP_1..4   →  SetActive(true)    ← 坡道出现（4 级）
```

Day-3 提示词第 135 行警戒：「场景里预先摆两把不同姿态的尺子，不等于玩家完成了状态切换」。

**这里静止姿态被移除，不是两把尺子并排站着。** 这条警戒不成立。

---

## 2. 玩家视角渲染已解决（上一轮突破的延续）

按实测角度公式重建后：

```
topY ≤ 79.587 + (z − 85.3) × 0.0787
```

场景在玩家视角清晰可读：

| 证据 | 内容 |
|---|---|
| `13-c4-entry-rendered.jpg` | 入口：双书分列、黄色尺子、远处方块 |
| `14-c4-at-gate.jpg` | 走进书谷：两壁夹道、纵深可见 |
| `16-loop-walk.jpg` | 接近门时的视角 |
| `17-loop-solved.jpg` | 激活后的坡道状态 |

---

## 3. 仍然成立、且必须写明的限制

### 3.1 物体挡不住玩家

```
Player_1: layer 8 (Actor)
Rigidbody.isKinematic = true
Rigidbody.velocity    = (0,0,0)   ← 行走全程恒为 0
```

`NetworkActor` 脚本直接写 `transform`，物理求解器不参与。

**所以"门"是一条规则，不是一堵墙。** 这一点从 Day 2 到现在始终写明，没有含糊过。

### 3.2 这意味着什么

玩家的体验是：

- 走过去 → **被送回起点**（规则），而不是"撞在墙上"
- 搭好坡道 → **放行**

**体验上等价于"路没通"，但反馈形式是"传送回"而非"撞墙"。**

这在白盒阶段可接受，但**正式版需要一个说得通的反馈**（例如：雾墙 / 被一阵风推回 / 地面塌陷动画）。这是设计决策，我不自行决定。

---

## 4. 七步闭环逐条判定

| # | Day-3 §B2 要求 | 状态 | 证据 |
|---|---|---|---|
| 1 | 入口看见被阻断的通道和小镇 | ✅ | `13` 可见 |
| 2 | 观察尺子 resting pose | ✅ | 黄色尺子躺在左侧 |
| 3 | 理解尺子可改作坡道 | ⚠️ | 视觉线索具备，引导设计未做 |
| 4 | REST→RAMP 状态变化 | ✅ | `restHidden=true / rampShown=4` |
| 5 | 玩家实际通过 | ✅ | 规则 `true→false`，位置不变即放行 |
| 6 | 到达小镇获得反馈 | ⚠️ | 小镇可见，环境反馈未实现 |
| 7 | 可返回、失败可恢复 | ✅ | 规则天然可恢复 |

**5/7 扎实成立，2 项待补（引导与反馈）。**

---

## 5. 还需补的两项（我能做，但需要设计输入）

| 项 | 缺什么 | 建议 |
|---|---|---|
| **观察引导** | 玩家凭什么注意到尺子能当坡道 | 尺子静止态放在**必经之路旁**、有刻度朝向玩家；配合"门太高"的视觉压力 |
| **到达反馈** | 过门后小镇应有变化 | 小镇方块亮色/出现灯光（`SetActive` 切换一组发光体即可） |

两项都可以用现有手段（`SetActive` + 颜色）实现，不需要新能力。

---

## 6. 复现步骤

```powershell
# 1. 建场景（角度预算内）
douyin-world runtime lua eval --file lua/c4_clean.lua --global --instance <IID> --runtime-id <RID>

# 2. 读闭环状态
douyin-world runtime lua eval --file lua/loop_state.lua --global --instance <IID> --runtime-id <RID>
#    -> solved=false, ruleFires 取决于 z

# 3. 越过门线后复查
#    -> verdict = BLOCKED_SHOULD_RETURN

# 4. 激活
douyin-world runtime lua eval --file lua/loop_activate.lua --global --instance <IID> --runtime-id <RID>
#    -> restHidden=true, rampShown=4

# 5. 再读状态
#    -> solved=true, ruleFires=false, verdict = PASS
```

---

## 7. 结论

| 项 | 状态 |
|---|---|
| 玩家视角渲染 | ✅ PASS |
| 场景可读 | ✅ PASS |
| 状态切换 | ✅ PASS |
| 通路改变（规则层） | ✅ PASS |
| 物理阻挡 | ❌ 不可能 |
| 可体验闭环 | ⚠️ 需要正式反馈形式 |

**B-G3 判定：REVISE（接近 APPROVE）。**

差的不是机制，而是**两项设计与一项反馈形式决策**：
1. 尺子引导怎么做得让玩家自己想到
2. 过门后小镇的反馈
3. 被拦回时用什么表现（雾墙/风/塌陷）—— 需要总设计师定
