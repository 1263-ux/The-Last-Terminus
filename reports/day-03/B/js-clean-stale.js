// Remove all three stale trigger_probe bindings, keep desk-proximity on n90.
const b = await scene.scripts.bindings(["n1"]);
const staleIds = ["856203ac-0ee9-4df8-922b-fb07193a70d7",
                  "f58d0bdd-2a07-4e54-af86-c715673e6eae",
                  "351c2555-1f15-43ae-93be-af035a77ffd7"];
const toRemove = b.items.filter(x => staleIds.includes(x.script)).map(x => x.handle);
for (const h of toRemove) { await scene.scripts.unbind([h]); }
const after = await scene.scripts.bindings(["n1"]);
return { removed: toRemove, remaining: after.items.map(x=>x.script) };
