use <scad/lib/kit_layout.scad>
use <scad/lib/kit_terrain.scad>

// ============================================================================
// 《桌面以下》Desk — 低矮书页/书脊 + 纸面混合构图（总设计师 §2 锁定）
//
// 坐标系：宿主转换 SCAD [x,y,z] -> Unity [-x, z, -y]，即
//   ux = -sx, uz = -sy, uy = sz
// 本文件所有几何用「Unity 地面坐标」书写（ubox / uplace），由 scene import
// --position 把根放到玩家脚下，故局部 (0,0) 是玩家出生点在地面的投影。
//
// 2026-11-25 修正（B-07 真实根因，见 reports/day-04/B/RUNTIME-ENTRY-DIAGNOSIS.md）：
//   旧版在 SCAD 里 translate([-119.74,-88.64,0]) 想把地图挪到玩家处，但 WPrefab
//   导出会归一化内容根变换，translate 被抹掉，地图落回原点、离玩家 120 m。
//   这才是"看不到场景"的真正原因 —— 不是"运行时不加载导入资产"。
//   实测：导入的 ruler-bridge GLB 在运行时正常实例化（6 个 MeshRenderer），
//   刻度 PNG 正常解码（可读出 10/20/30/40/50/60/70）。旧结论作废。
//
// 断口做成「真实落差」而不是抽象墙：
//   纸面顶面抬到局部 +1.5 m，断口处不放纸面，露出下方引擎地形（局部 0）。
//   已验证：控制器没有 step-up —— 1.20 m 平台就挡住，平推高台不行。
//   所以掉进 1.5 m 的断口后爬不出来，只能靠坠落复位 → 这是真的过不去。
//   尺子桥面在 +1.5 m，与原纸面齐平，架上就能走过去。
//
// 可见带约束（实测）：相机在玩家上方 1.68 m、俯角 18°、垂直半 FOV 22.5°
//   => 地平线以上只有 4.5°，可见高度上限 ≈ 1.68 + 0.0787·d
//      d=10m -> 2.47m ; d=20m -> 3.25m ; d=30m -> 4.04m
//   故书体一律 0.8–1.9 m（相对纸面）。
//
// 玩法骨架（局部 Unity 坐标，+z 为玩家前向）：
//   z -10..8   近段纸面（出生点 z=0），纸面顶 +1.5
//   z  8..16   断口 8 m（= ruler-bridge 原始长度），露出地形，深 1.5
//   z 16..32   远段纸面
//   z 32..46   铅笔盒小镇到达平台
//   x ±11      左右书谷（低矮书脊 / 页块）
// ============================================================================

world_map_bounds = [48, 56];
world_seed = 7;

paper_top = 1.5;           // 纸面顶面相对地形的高度（断口深度）
paper_thick = 1.5;         // 纸面厚度，底与地形齐平
ruler_span = 8.0;          // 断口宽度 = 原始尺子长度（总设计师 §1 锁定，不改源 GLB）
chasm_z0 = 8.0;
chasm_z1 = chasm_z0 + ruler_span;

// Unity 中心坐标 (ux, uz) + 尺寸 -> SCAD 盒体；y0 为盒底高度，h 为盒高
module ubox(ux, uz, w, d, h, y0 = 0)
{
    translate([-ux - w / 2, -uz - d / 2, y0]) cube([w, d, h]);
}

// Unity 坐标平移（不产几何）
module uplace(ux, uz, uy = 0)
{
    translate([-ux, -uz, uy]) children();
}

// ---------------------------------------------------------------- 可走纸面
// 近段纸面 z ∈ [-10, 8]，顶面 +1.5
world_visual_form(id="paper-near", importance="primary", structure_kind="landform")
world_surface("paper-near-top", tags=["walkable"])
world_collider("paper-near-collider", tags=["walkable"], visual=true)
world_material([0.87, 0.83, 0.71, 1], roughness=0.95)
ubox(0, -1, 24, 18, paper_thick, 0);

// 纸页侧边：露出一叠页块的层次（读作"整叠纸的厚度"）
world_visual_form(id="paper-stack", importance="secondary", structure_kind="assembly")
world_material([0.94, 0.91, 0.81, 1], roughness=0.97)
ubox(0, -1, 24.2, 18.2, paper_thick - 0.42, 0.02);
world_material([0.72, 0.66, 0.52, 1], roughness=0.95)
ubox(0, -1, 24.34, 18.34, 0.30, 0.02);

// 远段纸面 z ∈ [16, 32]
world_visual_form(id="paper-far", importance="primary", structure_kind="landform")
world_surface("paper-far-top", tags=["walkable"])
world_collider("paper-far-collider", tags=["walkable"], visual=true)
world_material([0.86, 0.82, 0.70, 1], roughness=0.95)
ubox(0, 24, 24, 16, paper_thick, 0);

// 断口底部：薄暗色层贴在地形上，读作"撕裂处的暗底"
world_visual_form(id="chasm-bed", importance="secondary", structure_kind="path")
world_material([0.11, 0.10, 0.13, 1], roughness=0.98)
ubox(0, chasm_z0 + ruler_span / 2, 24, ruler_span, 0.06, 0.01);

// 断口两侧的纸边毛口（薄条，仅视觉；立在纸面顶面）
world_visual_form(id="paper-rip", importance="secondary", structure_kind="path")
world_material([0.70, 0.64, 0.51, 1], roughness=0.96)
ubox(-7.6, chasm_z0, 8.4, 0.12, 0.06, paper_top);
ubox(7.6, chasm_z1, 8.4, 0.12, 0.06, paper_top);

// 防软锁：断口【靠出生侧】贴一段回爬阶梯，每级 0.19 m（低于控制器 0.20 台阶上限）。
// 高的一端挨着近段纸沿（z≈8.1），低的一端落在断口底（z≈15）。所以：
//   掉进断口 → 往 -z 方向爬回近段纸面，不会被卡死；
//   但它【不能】通往对岸 —— 对岸仍是 1.5 m 直墙，只能靠架桥通过。
world_visual_form(id="chasm-steps", importance="secondary", structure_kind="assembly")
world_material([0.88, 0.84, 0.74, 1], roughness=0.94)
for (k = [0 : 7])
    ubox(-8.6, 8.60 + k * 0.94, 1.8, 0.96, paper_top - k * 0.19, 0);

// ---------------------------------------------------------------- 书脊 / 书页
// 一本低矮硬壳书。实测约束与对策：
//   - 一个 world_visual_form 只接受一个 world_material，同 form 内重复
//     world_material 会把整块刷成最后一种颜色（实测 rgba 全 0）。
//   - 但 one form = one material 可以靠"拆 form"实现分段上色，
//     前提是每个 form 的 id 唯一。str() 可以拼出合法 id（已验证）。
// 所以一本书拆成三个 form，共用同一个 uplace 摆放：
//   1) book-<i>-pages  页块 + 页边细棱（米白）
//   2) book-<i>-spine  书脊半圆柱 + 两道压印（封面色压暗）
//   3) book-<i>-cover  封面顶板 + 两长边下折（彩色，外扩形成包边）
module book_low(idx, ux, uz, w, d, h, cover, spine = -1)
{
    // ---- 页块 + 页边线
    world_visual_form(id=str("book-", idx, "-pages"), importance="secondary", structure_kind="assembly")
    world_material([0.94, 0.91, 0.81, 1], roughness=0.97)
    uplace(ux, uz, paper_top) {
        ubox(0, 0, w - 0.14, d - 0.10, h * 0.84, h * 0.06);
        world_material([0.86, 0.82, 0.71, 1], roughness=0.98)
        for (k = [0 : 4])
            ubox(0, 0, w - 0.128, d - 0.096, 0.014, h * 0.14 + k * h * 0.15);
    }

    // ---- 书脊（压暗的封面色）
    world_visual_form(id=str("book-", idx, "-spine"), importance="primary", structure_kind="assembly")
    world_material([cover[0] * 0.58, cover[1] * 0.58, cover[2] * 0.62, 1], roughness=0.72)
    uplace(ux, uz, paper_top) {
        // 书脊板：整本书高度，稍微凸出封面之外，形成"装订面"
        uplace(spine * (w / 2 + 0.012), 0, 0)
            ubox(0, 0, 0.055, d, h * 0.99, 0);
        // 书脊上的圆角棱（一条细圆柱，读作折页边）
        uplace(spine * (w / 2 + 0.040), 0, h * 0.985)
            rotate([90, 0, 0]) cylinder(h=d, r=0.030, $fn=10);
        uplace(spine * (w / 2 + 0.040), 0, h * 0.015)
            rotate([90, 0, 0]) cylinder(h=d, r=0.030, $fn=10);
    }
    // 压印线单独一个 form（浅色），否则会被书脊色吃掉
    world_visual_form(id=str("book-", idx, "-stamp"), importance="secondary", structure_kind="assembly")
    world_material([0.97, 0.94, 0.83, 1], roughness=0.50)
    uplace(ux, uz, paper_top)
        uplace(spine * (w / 2 + h * 0.02), 0, 0) {
            ubox(0, d * 0.26, 0.024, 0.055, h * 0.34, h * 0.32);
            ubox(0, -d * 0.26, 0.024, 0.055, h * 0.34, h * 0.32);
        }

    // ---- 封面（彩色）
    world_visual_form(id=str("book-", idx, "-cover"), importance="primary", structure_kind="assembly")
    world_material(cover, roughness=0.86)
    uplace(ux, uz, paper_top) {
        ubox(0, 0, w, d, h * 0.13, h * 0.87);
        ubox(0, 0, w, 0.045, h * 0.82, h * 0.04);
    }
}

// 左侧书谷（局部 +x 一侧）
world_visual_form(id="book-valley-left", importance="primary", structure_kind="assembly")
book_low(1, 11.5, -3.0, 2.8, 6.0, 1.30, [0.42, 0.20, 0.17, 1]);
book_low(2, 11.7, 4.0, 2.3, 4.6, 0.88, [0.20, 0.28, 0.34, 1]);
book_low(3, 12.1, 11.0, 3.1, 6.4, 1.70, [0.36, 0.30, 0.20, 1]);
book_low(4, 11.5, 19.0, 2.5, 5.0, 1.06, [0.24, 0.22, 0.30, 1]);
book_low(5, 11.9, 26.5, 2.9, 5.4, 1.55, [0.30, 0.22, 0.19, 1]);

// 右侧书谷（局部 -x 一侧）
world_visual_form(id="book-valley-right", importance="primary", structure_kind="assembly")
book_low(6, -11.5, -3.6, 2.5, 5.2, 1.02, [0.26, 0.31, 0.36, 1], 1);
book_low(7, -12.0, 3.2, 3.3, 6.6, 1.86, [0.46, 0.23, 0.19, 1], 1);
book_low(8, -11.6, 10.6, 2.2, 4.4, 0.84, [0.34, 0.28, 0.18, 1], 1);
book_low(9, -11.9, 17.6, 2.9, 5.8, 1.42, [0.21, 0.25, 0.31, 1], 1);
book_low(10, -11.7, 25.0, 2.6, 5.0, 1.20, [0.28, 0.26, 0.21, 1], 1);

// 更远一层书：只做层次剪影，允许部分超出可见带
world_visual_form(id="book-far-layer", importance="secondary", structure_kind="assembly")
book_low(11, -16.4, 14.0, 3.8, 8.4, 2.50, [0.30, 0.19, 0.16, 1], 1);
book_low(12, 16.4, 5.0, 3.6, 7.4, 2.25, [0.19, 0.24, 0.29, 1]);
book_low(13, 16.8, 22.0, 3.2, 6.6, 1.95, [0.26, 0.20, 0.17, 1]);

// ---------------------------------------------------------------- 尺子 REST（侧躺备用尺）
// 出生点正前方偏右平放，玩家沿 +z 走 4.5 m 就会走到它旁边 —— 这是交互触发点。
world_visual_form(id="ruler-rest", importance="primary", structure_kind="assembly")
uplace(0, 0, paper_top) {
    world_material([0.80, 0.64, 0.42, 1], roughness=0.80)
    ubox(3.2, 4.6, 0.90, 7.6, 0.10, 0);
    world_material([0.22, 0.17, 0.12, 1], roughness=0.85)
    for (k = [0 : 7])
        ubox(3.2, 1.4 + k * 1.0, 0.90, 0.05, 0.02, 0.10);
}

// ---------------------------------------------------------------- 尺子 RAMP
// 注意：这里【不】放静态桥面。断口必须一开始是真的过不去，
// 桥体由真实的 ruler-bridge-full-v01 GLB 提供，且默认 inactive，
// 只有玩家走近侧躺的尺子后由 desk-gate.lua 打开。
// 若在 SCAD 里再放一条静态桥，断口就被提前架好了，玩法消失。

// ---------------------------------------------------------------- 近侧探索支路
// 出生点身后（-z）有一小片"书页高台"：三级 0.19 m 台阶（低于控制器 0.20 台阶上限，
// 可爬），上去能俯瞰整条断口与小镇——这是给玩家的第一个"为什么要往那边走"的理由。
// 注意：台阶必须立在纸面顶面（paper_top），否则会被埋进纸块里。
world_visual_form(id="vantage-steps", importance="primary", structure_kind="assembly")
world_material([0.90, 0.86, 0.76, 1], roughness=0.95)
for (k = [0 : 2])
    ubox(1.0, -4.2 - k * 1.1, 9.0, 1.15, 0.19 * (k + 1), paper_top);
world_visual_form(id="vantage-deck", importance="primary", structure_kind="landform")
world_surface("vantage-top", tags=["walkable"])
world_collider("vantage-collider", tags=["walkable"], visual=true)
world_material([0.86, 0.82, 0.72, 1], roughness=0.94)
ubox(1.0, -8.6, 9.0, 3.6, 0.57, paper_top);

// 高台边缘的书页角标识，提示这层是纸不是土
world_visual_form(id="vantage-detail", importance="secondary", structure_kind="assembly")
world_material([0.72, 0.66, 0.52, 1], roughness=0.96)
ubox(-3.0, -8.6, 0.10, 3.4, 0.62, paper_top);
ubox(5.0, -8.6, 0.10, 3.4, 0.62, paper_top);

// 近侧纸面上的两排低矮书，形成"走廊 + 两个开口"，逼玩家选路而不是直线冲
world_visual_form(id="near-corridor", importance="primary", structure_kind="assembly")
book_low(14, -4.6, -1.4, 2.2, 3.0, 0.62, [0.38, 0.24, 0.20, 1], 1);
book_low(15, -4.6, 2.4, 2.2, 3.2, 0.72, [0.23, 0.28, 0.33, 1], 1);
book_low(16, 4.8, -1.6, 2.4, 3.2, 0.68, [0.33, 0.27, 0.19, 1]);
book_low(17, 4.8, 2.2, 2.4, 3.0, 0.58, [0.26, 0.21, 0.29, 1]);

// ---------------------------------------------------------------- 小镇到达平台
world_visual_form(id="town-platform", importance="primary", structure_kind="landform")
world_surface("town-ground", tags=["walkable"])
world_collider("town-collider", tags=["walkable"], visual=true)
world_material([0.24, 0.34, 0.39, 1], roughness=0.86)
ubox(0, 40, 32, 16, paper_thick, 0);

// 铅笔盒外壳色带（真实 town-row / shopfront GLB 叠在上面）
world_visual_form(id="pencilcase-shell", importance="primary", structure_kind="building")
world_material([0.17, 0.30, 0.35, 1], roughness=0.80)
ubox(0, 34.0, 32, 0.7, 1.05, paper_top);
world_material([0.78, 0.76, 0.70, 1], roughness=0.45)
for (k = [0 : 15])
    ubox(-15.6 + k * 2.08, 34.0, 0.30, 0.16, 0.14, paper_top + 1.05);

// 暖窗：真实 MAT_window_glow 自发光在运行时不生效，用暖色块兜底
world_visual_form(id="town-windows", importance="primary", structure_kind="assembly")
world_material([1.00, 0.84, 0.48, 1], roughness=0.35)
for (k = [0 : 5])
    ubox(-10.5 + k * 4.2, 33.7, 1.20, 0.14, 1.05, paper_top + 0.95);

// 小镇内部低矮房屋体量（远景剪影，给 town-row 托底）
world_visual_form(id="town-blocks", importance="secondary", structure_kind="building")
world_material([0.30, 0.36, 0.40, 1], roughness=0.88)
ubox(-8.5, 38.0, 5.0, 5.0, 1.85, paper_top);
ubox(0.5, 39.5, 6.0, 6.0, 2.30, paper_top);
ubox(9.0, 37.5, 4.5, 5.5, 1.65, paper_top);

// ---------------------------------------------------------------- 远景台灯
world_visual_form(id="desk-lamp", importance="secondary", structure_kind="assembly")
world_material([0.78, 0.66, 0.42, 1], roughness=0.70)
uplace(21.0, 36.0, paper_top) cylinder(h=0.22, r=1.05, $fn=24);
uplace(21.0, 36.0, paper_top + 0.22) cylinder(h=2.30, r=0.13, $fn=12);
uplace(21.0, 36.0, paper_top + 2.52) cylinder(h=0.48, r1=0.98, r2=0.52, $fn=24);
world_material([1.00, 0.90, 0.66, 1], roughness=0.30)
uplace(21.0, 36.0, paper_top + 2.96) sphere(r=0.34, $fn=18);
