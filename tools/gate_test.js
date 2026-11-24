// Minimal gate test: unlock via OnActorTriggerEnter, gate via Update().
// Tests whether OnActorTriggerEnter fires reliably for unlock.
const lua = [
  "---@displayName GateTest",
  "---@start",
  "---@var ReturnZ:number=88",
  "---@name \u8fd4\u56de Z",
  "---@end",
  "",
  "local activated = false",
  "local UNLOCK_Z = 90",
  "local GATE_Z = 93",
  "",
  "function OnActorTriggerEnter(actor)",
  "  if actor == nil or not actor.isLocal then return end",
  "  local z = actor.position.z",
  "  if z < UNLOCK_Z then",
  "    activated = true",
  "  end",
  "end",
  "",
  "function Update()",
  "  local actor = CS.DouyinActorService.GetLocalActor()",
  "  if actor == nil then return end",
  "  local z = actor.position.z",
  "  if z >= GATE_Z then",
  "    if not activated then",
  "      local pos = CS.UnityEngine.Vector3(119.74, 79, ReturnZ)",
  "      local rot = CS.UnityEngine.Quaternion.Euler(0, 0, 0)",
  "      actor:Teleport(pos, rot)",
  "    end",
  "  end",
  "end",
  "",
  "function OnActorTriggerExit(actor) end",
].join("\n");

const script = await scene.scripts.create({ path: "gate-test.lua", content: lua });

const trigger = await scene.nodes.create({ name: "GateTestTrigger", parent: null });
await scene.components.add({ nodes: [trigger], type: "triggerData",
  values: [{ shape: "box", center: { x: 0, y: 0.5, z: 0 }, size: { x: 8, y: 4, z: 12 }, enabled: true }] });
await scene.transforms.set({ nodes: [trigger], space: "local", scope: "node-only",
  value: { position: { x: 119.74, y: 78, z: 92 } } });

const sid = script.id || script;
await scene.scripts.bind({ nodes: [trigger], script: sid,
  params: { ReturnZ: 88 } });

return { scriptId: sid, trigger: trigger };
