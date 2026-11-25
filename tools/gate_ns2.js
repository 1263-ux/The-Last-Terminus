// Gate with node-position state storage - uses GameObject.Find for marker lookup.
const lua = [
  "---@displayName GateNS2",
  "---@start",
  "---@end",
  "",
  "local UNLOCK_Z = 90",
  "local GATE_Z = 93",
  "",
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
  "function Update()",
  "  local actor = CS.DouyinActorService.GetLocalActor()",
  "  if actor == nil then return end",
  "  local z = actor.position.z",
  "  if z < UNLOCK_Z then",
  "    if not isUnlocked() then setUnlocked() end",
  "    return",
  "  end",
  "  if z >= GATE_Z then",
  "    if not isUnlocked() then",
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

const script = await scene.scripts.create({ path: "gate-ns2.lua", content: lua });

const marker = await scene.nodes.create({ name: "GateStateMarker", parent: null });
await scene.transforms.set({ nodes: [marker], space: "local", scope: "node-only",
  value: { position: { x: 119.74, y: 78, z: 0 } } });

const trigger = await scene.nodes.create({ name: "GateNS2Trigger", parent: null });
await scene.components.add({ nodes: [trigger], type: "triggerData",
  values: [{ shape: "box", center: { x: 0, y: 0.5, z: 0 }, size: { x: 8, y: 4, z: 12 }, enabled: true }] });
await scene.transforms.set({ nodes: [trigger], space: "local", scope: "node-only",
  value: { position: { x: 119.74, y: 78, z: 92 } } });

const sid = script.id || script;
await scene.scripts.bind({ nodes: [trigger], script: sid, params: {} });

return { scriptId: sid, marker: marker, trigger: trigger };
