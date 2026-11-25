// Complete gate demo: node-position state storage + REST/RAMP swap + unlock.
// This is B's E1 solution - copy and adapt coordinates.
const lua = [
  "---@displayName GateDemo",
  "---@start",
  "---@var ReturnX:number=119.74",
  "---@name \u8fd4\u56de X",
  "---@var ReturnY:number=79",
  "---@name \u8fd4\u56de Y",
  "---@var ReturnZ:number=88",
  "---@name \u8fd4\u56de Z",
  "---@var CooldownSeconds:number=2.0",
  "---@name \u51b7\u5374\u79d2\u6570",
  "---@var RulerRestName:string=\"Ruler_REST\"",
  "---@name REST\u5c3a\u5b50\u8282\u70b9\u540d",
  "---@var RulerRampName:string=\"Ruler_RAMP\"",
  "---@name RAMP\u5c3a\u5b50\u8282\u70b9\u540d",
  "---@end",
  "",
  "local lastFire = -100",
  "local UNLOCK_Z = 90",
  "local GATE_Z = 93",
  "",
  "-- State stored in marker node position (z=0 locked, z=1 unlocked)",
  "local function isUnlocked()",
  "  local m = CS.UnityEngine.GameObject.Find('GateStateMarker')",
  "  if m == nil then return false end",
  "  return m.transform.position.z > 0.5",
  "end",
  "",
  "local function setUnlocked()",
  "  local m = CS.UnityEngine.GameObject.Find('GateStateMarker')",
  "  if m ~= nil then",
  "    local pos = m.transform.position",
  "    m.transform.position = CS.UnityEngine.Vector3(pos.x, pos.y, 1)",
  "  end",
  "end",
  "",
  "local function swapRuler()",
  "  local rest = CS.UnityEngine.GameObject.Find(RulerRestName)",
  "  local ramp = CS.UnityEngine.GameObject.Find(RulerRampName)",
  "  if rest ~= nil then rest:SetActive(false) end",
  "  if ramp ~= nil then ramp:SetActive(true) end",
  "end",
  "",
  "function Update()",
  "  local actor = CS.DouyinActorService.GetLocalActor()",
  "  if actor == nil then return end",
  "  local z = actor.position.z",
  "  -- Unlock zone: player observes ruler and anchors",
  "  if z < UNLOCK_Z then",
  "    if not isUnlocked() then",
  "      setUnlocked()",
  "      swapRuler()",
  "    end",
  "    return",
  "  end",
  "  -- Gate zone: block if not unlocked",
  "  if z >= GATE_Z then",
  "    if not isUnlocked() then",
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

const script = await scene.scripts.create({ path: "gate-demo.lua", content: lua });

// State marker node
const marker = await scene.nodes.create({ name: "GateStateMarker", parent: null });
await scene.transforms.set({ nodes: [marker], space: "local", scope: "node-only",
  value: { position: { x: 119.74, y: 78, z: 0 } } });

// Trigger node covering unlock zone + gate zone
const trigger = await scene.nodes.create({ name: "GateDemoTrigger", parent: null });
await scene.components.add({ nodes: [trigger], type: "triggerData",
  values: [{ shape: "box", center: { x: 0, y: 0.5, z: 0 }, size: { x: 8, y: 4, z: 12 }, enabled: true }] });
await scene.transforms.set({ nodes: [trigger], space: "local", scope: "node-only",
  value: { position: { x: 119.74, y: 78, z: 92 } } });

const sid = script.id || script;
await scene.scripts.bind({ nodes: [trigger], script: sid,
  params: {
    ReturnX: 119.74, ReturnY: 79, ReturnZ: 88,
    CooldownSeconds: 2.0,
    RulerRestName: "Ruler_REST",
    RulerRampName: "Ruler_RAMP",
  } });

return { scriptId: sid, marker: marker, trigger: trigger };
