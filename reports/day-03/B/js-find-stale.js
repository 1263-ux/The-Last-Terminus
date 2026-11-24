const all = await scene.nodes.query({limit:200});
const handles = all.items.map(n=>n.handle);
const b = await scene.scripts.bindings(handles);
const staleIds = ["856203ac-0ee9-4df8-922b-fb07193a70d7",
                  "f58d0bdd-2a07-4e54-af86-c715673e6eae",
                  "351c2555-1f15-43ae-93be-af035a77ffd7"];
return {total: b.items.length,
        stale: b.items.filter(x=>staleIds.includes(x.script)).map(x=>x.handle)};
