# B｜B-07 追加排除：流式加载开关

分支：`feature/desk-world` · 编辑器 1.0.104
日期：2026-11-24

---

## 0. 新假设

在 `scene.data` 顶层发现：

```
isOpenStreamingLoad = True
```

假设：场景开启了流式加载，节点只在玩家靠近时实例化。
`deskworld` 根节点在 `(0, 0, 0)`，玩家出生在 `(119.74, 80, 88.64)`——**相距 120 米**，
可能因此永远不被加载。

---

## 1. 反证

### 1.1 距离不是原因

场景里 `ruler-bridge-full-v01` 位于 `(119.74, 80, 95)`，**距玩家仅 6 米**，
但运行时搜索仍然是：

```
imported nodes found = 0
```

所以不是"离得太远没流式加载"。

### 1.2 关掉流式加载也没用

```
改 isOpenStreamingLoad: True → False
重新打包 scene.data
runtime stop → start
结果: imported nodes found = 0
```

**假设被推翻。**

### 1.3 已恢复原状

测试后把原始 `scene.data` 恢复（784,504 bytes），没有留下手工修改。

---

## 2. 排除清单更新

B-07 现在共排除 **11 项**：

| # | 假设 | 结果 |
|---|---|---|
| 1 | 工程损坏 | 新工程同样 |
| 2 | `worldType=avatar` | 官方模板也是 |
| 3 | foreground/offscreen 模式 | 两者都空 |
| 4 | 未导入 | scene.data 有节点 |
| 5 | 未保存 | save committed |
| 6 | 未重启 | 完全重启无效 |
| 7 | `runtime reload` | 代次冲突 |
| 8 | 层级找错 | 全图 104 节点遍历 |
| 9 | 资产损坏 | SHA 7/7 一致 |
| 10 | 离玩家太远（流式） | 6 米处也不加载 |
| **11** | **isOpenStreamingLoad** | **关闭后仍不加载** |

---

## 3. 结论

`isOpenStreamingLoad` **不是** B-07 的原因。

结合运行时日志 `HamletWorldGame`（角色世界，按 EntryType 切换），
最可能的解释仍是：**`runtime start` 启动的入口类型不消费关卡场景内容**。

这需要 GUI 人工确认，CLI 侧已经没有可试的路径。

---

## 4. 我不会做的事

- 不再继续手工改 `scene.data` 试开关——这类改动风险高、收益为零
- 不把流式加载写成结论——已用两条证据推翻
- 不因为"又排除一个"就宣称进展——这只是在收窄未知

**B-07 状态不变：BLOCKED，需要人工 GUI 验证。**
