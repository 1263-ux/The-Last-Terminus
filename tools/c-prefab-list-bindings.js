// Read-only: list script bindings in the garden-whitebox WPrefab.
const all = await scene.nodes.query({ limit: 500 });
const handles = all.items.map(n => n.handle);
const b = await scene.scripts.bindings(handles);
const items = (b.items || []).map(x => ({
  handle: x.handle,
  node: x.node,
  script: x.script,
  enabled: x.enabled,
  params: x.params,
}));
return { nodeCount: all.items.length, bindingCount: items.length, items };
