const nodes = await scene.nodes.query({limit:100});
return { count: nodes.items.length, items: nodes.items.slice(0,30).map(n=>({id:n.id,name:n.name})) };
