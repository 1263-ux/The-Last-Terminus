# Day-04 入口条件状态

> Owner：成员 A
> 更新：2026-11-23

---

## 入口条件逐条状态

| # | 条件 | 状态 | 负责人 | 说明 |
|---|---|---|---|---|
| 1 | B 玩家相机渲染状态已知（Preview + Published） | **NOT TESTED** | B | 需 GUI 操作 |
| 2 | B 尺子状态变化可见且可通行 | **NOT TESTED** | B | 依赖条件 1 |
| 3 | C 到达视野规则已验证 | **NOT TESTED** | C | 需盲测 |
| 4 | A 共享 GLB 导入约束和资产包 manifest 稳定 | **DONE** | A | `GLB-RECIPE.md` + `ASSET-MANIFEST.csv` |
| 5 | 一个 Tripo 导出已导入和检查 | **NOT TESTED** | A+设计总监 | 验证器已准备（`tools/validate_tripo.py`） |

## A 的准备工作已完成

1. **GLB 导入食谱**：7 个坑，1:1 尺寸验证
2. **共享资产**：6 个测试资产 + SHA-256 manifest
3. **Tripo 验证器**：`tools/validate_tripo.py`（Day-04 条件 #5 就绪）
4. **门禁机制**：单触发器+Update()轮询（B 的 E1 方案参考）
5. **音频模式**：官方指南确认
6. **技术快速参考**：B/C 一站式手册

## 阻塞项

| 项 | 阻塞方 | 解决条件 |
|---|---|---|
| B 渲染测试 | B | GUI 操作 |
| C 盲测 | C | 需要人类测试者 |
| WPRE 跨成员 | B/C | 需要第二个账号 |
| Tripo 资产 | 设计总监 | 提供一个代表性资产 |

## 结论

**A 的 Day-04 入口条件准备工作全部完成。**
等待 B/C/设计总监的外部输入后可进入 Day-04。
