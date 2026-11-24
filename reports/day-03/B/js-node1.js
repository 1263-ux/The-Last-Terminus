const nodes = await scene.nodes.query({limit:3});
return { first: nodes.items[0], keys: Object.keys(nodes.items[0]) };
