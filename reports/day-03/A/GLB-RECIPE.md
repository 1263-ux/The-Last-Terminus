# GLB 导入操作食谱（B/C 可直接照做）

> Owner：成员 A
> 依据：`GLB-IMPORT-MATRIX.md` 实测结论
> 引擎：造世界编辑器 1.0.104 / CLI douyin-world 1.0.104

---

## 一句话

**用 `resource model import` 链路导入 GLB，尺寸 1:1 保留；X 轴会被镜像，非对称资产必须在导入后确认朝向。**

## 完整流程（逐步）

### 1. 准备 GLB 文件

- 每个 primitive 必须带 **POSITION + NORMAL + TEXCOORD_0**（NORMAL 缺失 → 有影无面）
- 单个 GLB ≤ **30000 面 / 10 MiB**
- 建议命名：`<描述>-<尺寸>.glb`（如 `ruler-bridge-12m.glb`）

### 2. 创建 Prefab（每个可交付物独立）

```powershell
douyin-world authoring prefab create myworld --instance <I> --workspace-id <W>
```

**⚠ 不要复用公共探针 Prefab**——`prefab attach` 是追加，会累积重复几何。

### 3. 导入 GLB

```powershell
douyin-world authoring resource model import model-xxx --prefab myworld --workspace-id <W> --instance <I> --glb .\my-model.glb
```

返回 `sourceState: "topology"`（正常）。

### 4. 归档

```powershell
douyin-world authoring resource archive model-xxx --kind model --prefab myworld --workspace-id <W> --instance <I>
```

返回 `uri`（后续 attach 用）。

### 5. 装配

```powershell
douyin-world authoring prefab attach myworld --workspace-id <W> --instance <I> --kind model --uri <uri>
```

### 6. 构建 + 导出

```powershell
douyin-world authoring prefab build myworld --workspace-id <W> --instance <I>
douyin-world authoring prefab export myworld --workspace-id <W> --instance <I> --out <目录>
```

导出为 `.wprefab` 单文件（可跨工程交接）。

### 7. 导入场景

```powershell
douyin-world scene import --instance <I> --uri <wprefab-uri> --name "我的世界" --position x,y,z
douyin-world scene save --instance <I> --request-id save-1
```

---

## 必须知道的 5 个坑

| # | 坑 | 解法 |
|---|---|---|
| 1 | **X 轴镜像**（+X → −X） | 非对称资产导入后目视确认朝向；或导出前预镜像 |
| 2 | **`prefab attach` 是追加** | 一个可交付物用独立 Prefab；迭代前 `scene remove` 旧根 |
| 3 | **材质属性是 `_BaseColor`/`_BaseTex`** | 查 `color`/`mainTexture` 得空是假故障 |
| 4 | **NORMAL 必带** | 缺失 → 有影无面（C-11） |
| 5 | **空节点 + physicsColliderData 不生成 Collider** | 碰撞体依赖可见 Mesh；但玩家是运动学刚体，碰撞无效 |

---

## 尺寸对照表

| 源 GLB 尺寸 | 导入后 prefab scale | 运行时包围盒 | 判定 |
|---|---|---|---|
| 1×1×1 m | (1,1,1) | 1×1×1 | 1:1 |
| 2×2×2 m | (1,1,1) | 2×2×2 | 1:1 |
| 4×4×4 m | (1,1,1) | 4×4×4 | 1:1 |

**结论：A 的导入链路 1:1 保留，不需要预缩放。**
B 的 `sqrt(T)` 是直接 `scene import` 裸 GLB 路径的局部经验，**不能混用**。

## 轴向标记

| 作者方向 | 导入后 | 判定 |
|---|---|---|
| +X（红长臂） | **−X** | **X 取反** |
| +Z（蓝短臂） | +Z | 保持 |
| +Y（绿标记） | +Y | 保持 |

## 共享测试资产

见 `reports/day-03/A/shared-assets/`（6 个资产 + ASSET-MANIFEST.csv）。

| 资产 | 用途 |
|---|---|
| `probe-cube-1m.glb` | 尺寸基准 |
| `probe-cube-2m.glb` | 尺寸基准 |
| `probe-cube-4m.glb` | 尺寸基准 |
| `probe-axis-marker.glb` | X/Y/Z 方向验证 |
| `probe-textured-cube.glb` | 贴图/材质验证 |
| `probeminimal.wprefab` | WPRE 交接测试包 |
