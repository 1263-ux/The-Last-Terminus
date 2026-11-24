// Broken Book Canyon puzzle - complete implementation for B's vertical slice.
// Demonstrates: ruler bridge state gate + REST/RAMP swap + Teleport crossing.
//
// Scene layout (adjust coordinates to match B's world):
//   z=88: near book platform (unlock zone - player observes ruler + anchors)
//   z=93: canyon gap (gate zone - blocked until ruler placed)
//   z=98: far book platform (destination - pencil case town entrance)
//
// Flow:
//   1. Player starts on near platform (z=88)
//   2. Walks to unlock zone (z<90) -> ruler observation triggered
//   3. Walks toward gate (z>=93) -> teleported back if ruler not placed
//   4. After "placing ruler" (unlock), gate opens -> player crosses
//   5. Player arrives at far platform (z=98+) -> town entrance feedback

const lua = [
  "---@displayName \u65ad\u88c2\u4e66\u8c37_\u5c3a\u5b50\u6865",
  "---@start",
  "---@var ReturnX:number=119.74",
  "---@name \u8fd4\u56de X",
  "---@var ReturnY:number=79",
  "---@name \u8fd4\u56de Y",
  "---@var ReturnZ:number=88",
  "---@name \u8fd4\u56de Z",
  "---@var CooldownSeconds:number=2.0",
  "---@name \u51b7\u5374\u79d2\u6570",
  "---@var RulerRestName:string=\"Canyon_Ruler_REST\"",
  "---@name REST\u5c3a\u5b50\u8282\u70b9\u540d",
  "---@var RulerRampName:string=\"Canyon_Ruler_RAMP\"",
  "---@name RAMP\u5c3a\u5b50\u8282\u70b9\u540d",
  "---@var TownLightName:string=\"Town_Entrance_Light\"",
  "---@name \u5c0f\u9547\u706f\u8282\u70b9\u540d",
  "---@end",
  "",
  "local lastFire = -100",
  "local activated = false",
  "local UNLOCK_Z = 90",
  "local GATE_Z = 93",
  "",
  "local function findNode(name)",
  "  local root = CS.UnityEngine.GameObject.Find('previewGameRoot')",
  "  if root == nil then return nil end",
  "  local function f(go, d)",
  "    if go == nil or d > 10 then return nil end",
  "    if go.name == name then return go end",
  "    for i = 0, go.transform.childCount - 1 do",
  "      local r = f(go.transform:GetChild(i).gameObject, d + 1)",
  "      if r ~= nil then return r end",
  "    end",
  "    return nil",
  "  end",
  "  return f(root, 0)",
  "end",
  "",
  "local function placeRuler()",
  "  -- Hide REST ruler, show RAMP bridge",
  "  local rest = findNode(RulerRestName)",
  "  local ramp = findNode(RulerRampName)",
  "  if rest ~= nil then rest:SetActive(false) end",
  "  if ramp ~= nil then ramp:SetActive(true) end",
  "  -- Light up town entrance",
  "  local light = findNode(TownLightName)",
  "  if light ~= nil then light:SetActive(true) end",
  "end",
  "",
  "function Update()",
  "  local actor = CS.DouyinActorService.GetLocalActor()",
  "  if actor == nil then return end",
  "  local z = actor.position.z",
  "  if z < UNLOCK_Z then",
  "    if not activated then",
  "      activated = true",
  "      placeRuler()",
  "    end",
  "    return",
  "  end",
  "  if z >= GATE_Z then",
  "    if not activated then",
  "      if CS.UnityEngine.Time.time - lastFire >= CooldownSeconds then",
  "        lastFire = CS.UnityEngine.Time.time",
  "        local pos = CS.UnityEngine.Vector3(ReturnX, ReturnY, ReturnZ)",
  "        local rot = CS.UnityEngine.Quaternion.Euler(0, 0, 0)",
  "        actor:Teleport(pos, rot)",
  "      end",
  "    end",
  "  end",
  "end",
  "",
  "function OnActorTriggerEnter(actor) end",
  "function OnActorTriggerExit(actor) end",
].join("\n");

const script = await scene.scripts.create({ path: "canyon-bridge.lua", content: lua });

// ONE trigger covering unlock zone + gate zone
const trigger = await scene.nodes.create({ name: "Canyon_BridgeGate", parent: null });
await scene.components.add({ nodes: [trigger], type: "triggerData",
  values: [{ shape: "box", center: { x: 0, y: 0.5, z: 0 }, size: { x: 8, y: 4, z: 12 }, enabled: true }] });
await scene.transforms.set({ nodes: [trigger], space: "local", scope: "node-only",
  value: { position: { x: 119.74, y: 78, z: 92 } } });

const sid = script.id || script;
await scene.scripts.bind({ nodes: [trigger], script: sid,
  params: {
    ReturnX: 119.74, ReturnY: 79, ReturnZ: 88,
    CooldownSeconds: 2.0,
    RulerRestName: "Canyon_Ruler_REST",
    RulerRampName: "Canyon_Ruler_RAMP",
    TownLightName: "Town_Entrance_Light",
  } });

return { scriptId: sid, trigger: trigger };
