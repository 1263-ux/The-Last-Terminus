// Complete C4 state gate example for B's ruler puzzle redesign.
// ALL in ONE script instance - solves the cross-binding state sharing problem.
// Includes: unlock zone + gate zone + REST->RAMP visual swap hook.
//
// Usage: Bind this ONE script to ONE trigger node covering both zones.
// The trigger box should span from the unlock zone to the gate zone.
//
// Zone layout (adjust UNLOCK_Z/GATE_Z to match your scene):
//   z < 90: unlock zone (player walks here to activate)
//   z >= 93: gate zone (teleport back if not activated)

const lua = [
  "---@displayName C4\u5b8c\u6574\u95e8\u7981_\u5355\u811a\u672c",
  "---@start",
  "---@var ReturnX:number=119.74",
  "---@name \u8fd4\u56de X",
  "---@var ReturnY:number=79",
  "---@name \u8fd4\u56de Y",
  "---@var ReturnZ:number=88",
  "---@name \u8fd4\u56de Z",
  "---@var CooldownSeconds:number=1.5",
  "---@name \u51b7\u5374\u79d2\u6570",
  "---@var RulerRestName:string=\"C4_RULER_REST\"",
  "---@name REST\u5c3a\u5b50\u8282\u70b9\u540d",
  "---@var RulerRampName:string=\"C4_RAMP_1\"",
  "---@name RAMP\u5c3a\u5b50\u8282\u70b9\u540d",
  "---@end",
  "",
  "local lastFire = -100",
  "local activated = false",
  "local UNLOCK_Z = 90",
  "local GATE_Z = 93",
  "",
  "-- Find a node by name in the scene hierarchy",
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
  "-- Swap REST ruler -> RAMP representation",
  "local function swapRulerState()",
  "  local restNode = findNode(RulerRestName)",
  "  local rampNode = findNode(RulerRampName)",
  "  if restNode ~= nil then restNode:SetActive(false) end",
  "  if rampNode ~= nil then rampNode:SetActive(true) end",
  "end",
  "",
  "function Update()",
  "  local actor = CS.DouyinActorService.GetLocalActor()",
  "  if actor == nil then return end",
  "  local z = actor.position.z",
  "  if z < UNLOCK_Z then",
  "    if not activated then",
  "      activated = true",
  "      swapRulerState()",
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

const script = await scene.scripts.create({ path: "c4-complete-gate.lua", content: lua });

// Create ONE trigger covering both zones
const trigger = await scene.nodes.create({ name: "C4_CompleteGate", parent: null });
await scene.components.add({ nodes: [trigger], type: "triggerData",
  values: [{ shape: "box", center: { x: 0, y: 0.5, z: 0 }, size: { x: 6, y: 4, z: 10 }, enabled: true }] });
await scene.transforms.set({ nodes: [trigger], space: "local", scope: "node-only",
  value: { position: { x: 119.74, y: 78, z: 92 } } });

const sid = script.id || script;
await scene.scripts.bind({ nodes: [trigger], script: sid,
  params: {
    ReturnX: 119.74, ReturnY: 79, ReturnZ: 88,
    CooldownSeconds: 1.5,
    RulerRestName: "C4_RULER_REST",
    RulerRampName: "C4_RAMP_1",
  } });

return { scriptId: sid, trigger: trigger };
