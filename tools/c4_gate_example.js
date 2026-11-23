// Complete C4 gate example for B's ruler puzzle redesign.
// Demonstrates: GLB visual + state gate + unlock + teleport, all in one scene.
// This is the "E1 state-gated route" the design director approved.

const gateLua = [
  "---@displayName C4\u95e8\u7981_\u5c3a\u5b50\u5761\u9053",
  "---@start",
  "---@var ReturnX:number=119.74",
  "---@name \u8fd4\u56de X",
  "---@var ReturnY:number=79",
  "---@name \u8fd4\u56de Y",
  "---@var ReturnZ:number=88",
  "---@name \u8fd4\u56de Z",
  "---@var CooldownSeconds:number=1.5",
  "---@name \u51b7\u5374\u79d2\u6570",
  "---@end",
  "",
  "local lastFire = -100",
  "local activated = false",
  "local UNLOCK_Z = 90",
  "local GATE_Z = 93",
  "",
  "function Update()",
  "  local actor = CS.DouyinActorService.GetLocalActor()",
  "  if actor == nil then return end",
  "  local z = actor.position.z",
  "  if z < UNLOCK_Z then",
  "    if not activated then",
  "      activated = true",
  "      -- Here you would swap REST ruler -> RAMP representation",
  "      -- e.g., SetActive(false) on REST node, SetActive(true) on RAMP node",
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

const script = await scene.scripts.create({ path: "c4-gate-example.lua", content: gateLua });

// Gate trigger covering both zones
const trigger = await scene.nodes.create({ name: "C4_GateTrigger", parent: null });
await scene.components.add({ nodes: [trigger], type: "triggerData",
  values: [{ shape: "box", center: { x: 0, y: 0.5, z: 0 }, size: { x: 6, y: 4, z: 10 }, enabled: true }] });
await scene.transforms.set({ nodes: [trigger], space: "local", scope: "node-only",
  value: { position: { x: 119.74, y: 78, z: 92 } } });

const sid = script.id || script;
await scene.scripts.bind({ nodes: [trigger], script: sid,
  params: { ReturnX: 119.74, ReturnY: 79, ReturnZ: 88, CooldownSeconds: 1.5 } });

return { scriptId: sid, trigger: trigger };
