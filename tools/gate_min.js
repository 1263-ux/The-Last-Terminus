// Minimal gate: unlock via Update() polling, no placeRuler().
const lua = [
  "---@displayName GateMin",
  "---@start",
  "---@end",
  "",
  "local activated = false",
  "local UNLOCK_Z = 90",
  "local GATE_Z = 93",
  "",
  "function Update()",
  "  local actor = CS.DouyinActorService.GetLocalActor()",
  "  if actor == nil then return end",
  "  local z = actor.position.z",
  "  if z < UNLOCK_Z then",
  "    activated = true",
  "    return",
  "  end",
  "  if z >= GATE_Z then",
  "    if not activated then",
  "      local pos = CS.UnityEngine.Vector3(119.74, 79, 88)",
  "      local rot = CS.UnityEngine.Quaternion.Euler(0, 0, 0)",
  "      actor:Teleport(pos, rot)",
  "    end",
  "  end",
  "end",
  "",
  "function OnActorTriggerEnter(actor) end",
  "function OnActorTriggerExit(actor) end",
].join("\n");

const script = await scene.scripts.create({ path: "gate-min.lua", content: lua });

const trigger = await scene.nodes.create({ name: "GateMinTrigger", parent: null });
await scene.components.add({ nodes: [trigger], type: "triggerData",
  values: [{ shape: "box", center: { x: 0, y: 0.5, z: 0 }, size: { x: 8, y: 4, z: 12 }, enabled: true }] });
await scene.transforms.set({ nodes: [trigger], space: "local", scope: "node-only",
  value: { position: { x: 119.74, y: 78, z: 92 } } });

const sid = script.id || script;
await scene.scripts.bind({ nodes: [trigger], script: sid, params: {} });

return { scriptId: sid, trigger: trigger };
