const b = await scene.scripts.bindings(["n1"]);
return {count: b.items.length, items: b.items.map(x=>({handle:x.handle, script:x.script}))};
