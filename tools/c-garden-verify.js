// c-garden-verify.js — C 花园白盒可玩性自检（可在任意 runtime 反复运行）
//
// 用法：
//   douyin-world runtime js eval --file tools/c-garden-verify.js --session <session> --runtime-id <id>
// 返回 JSON 字符串，包含：
//   scene       : garden-whitebox 实例数 / previewGameRoot 子节点数
//   crown       : 观景台四周台沿高度、北侧深槽、台面是否与北条带形成 ≤0.45m 可走衔接
//   bridgeGap   : 断桥缺口在 x=115/116/117 三列的连续性
//   routeFloors : 路线关键点地面高度
//   verdict     : PASS / FAIL / NEEDS-JUMP（仅几何判定，不含玩家输入测试）
//
// 说明：射线从 y=77.4 向下打（在地形面 77.9–78.3 之下、白盒面 66–76 之上），
// 只取白盒碰撞体（跳过 C_* 触发器），因此结果不受地形遮挡影响。

const DOWN = new CS.UnityEngine.Vector3(0, -1, 0);
const STEP_MAX = 0.45;

function topAt(x, z, fromY) {
  const o = new CS.UnityEngine.Vector3(x, fromY === undefined ? 77.4 : fromY, z);
  const hits = CS.UnityEngine.Physics.RaycastAll(o, DOWN, 60, CS.UnityEngine.QueryTriggerInteraction.Ignore);
  if (!hits || hits.Length === 0) return null;
  let best = null;
  let bestName = null;
  for (let k = 0; k < hits.Length; k++) {
    const h = hits.get_Item(k);
    const n = h.collider.name;
    if (n.indexOf("C_") === 0) continue;
    if (n.indexOf("Player") >= 0) continue; // 跳过玩家自身碰撞体
    if (best === null || h.point.y > best) { best = h.point.y; bestName = n; }
  }
  return best === null ? null : { y: best, name: bestName.replace("__optimized_merged_material_", "m") };
}

const out = {};

// --- scene ---
const root = CS.UnityEngine.GameObject.Find("previewGameRoot");
let wbCount = 0;
let childCount = 0;
if (root) {
  childCount = root.transform.childCount;
  for (let i = 0; i < childCount; i++) {
    if (root.transform.GetChild(i).name === "garden-whitebox") wbCount++;
  }
}
out.scene = { previewGameRootChildren: childCount, gardenWhiteboxCount: wbCount };

// --- crown ---
const crown = {};
// 台面中心
crown.deck = topAt(120, 135);
// 四周台沿（世界坐标）：西 x=116 / 东 x=124 / 北 z=139.5
crown.rimWest = topAt(116, 136);
crown.rimEast = topAt(124, 136);
crown.rimNorth = topAt(120, 139.5);
// 北侧深槽（z=140, x=119）
crown.northSlot = topAt(119, 140);
// 北条带（z=141）
crown.northStrip = topAt(119, 141);
// 台面西缘缺口
crown.westNotch = topAt(117, 139);

const deckY = crown.deck ? crown.deck.y : null;
const stripY = crown.northStrip ? crown.northStrip.y : null;
crown.stepFromStripToDeck = (deckY !== null && stripY !== null) ? +(stripY - deckY).toFixed(2) : null;
let walkable = false;
let verdict = "NO-DECK";
if (deckY !== null) {
  const rimOk = crown.rimNorth !== null && (crown.rimNorth.y - deckY) <= STEP_MAX;
  const slotOk = crown.northSlot !== null;
  walkable = rimOk && slotOk;
  verdict = walkable ? "PASS" : (rimOk || slotOk ? "FAIL-PARTIAL" : "NEEDS-JUMP");
}
crown.walkableIn = walkable;
crown.verdict = verdict;
out.crown = crown;

// --- bridge gap ---
const gap = {};
for (const x of [115, 116, 117]) {
  const cells = [];
  for (let z = 108.0; z <= 112.01; z += 0.5) {
    const t = topAt(x, z);
    cells.push(t === null ? "MISS" : t.y.toFixed(2));
  }
  gap["x" + x] = cells;
}
out.bridgeGap = gap;

// --- route floors ---
out.routeFloors = {
  entry: topAt(120, 105),
  descentStart: topAt(116.5, 113.8),
  roof: topAt(116.5, 123.7),
  stairTop: topAt(115.1, 139.1),
  vista: topAt(120, 135)
};

// --- verdict ---
const sceneOk = wbCount === 1;
out.verdict = {
  sceneOk: sceneOk,
  crownWalkable: walkable,
  crownVerdict: verdict,
  overall: sceneOk && walkable ? "PASS" : "FAIL"
};
return JSON.stringify(out);

