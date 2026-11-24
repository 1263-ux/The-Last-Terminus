const scriptHandle = "856203ac-0ee9-4df8-922b-fb07193a70d7";
await scene.components.add({
  nodes: ["n1"],
  type: "triggerData",
  values: [{shape:"box", enabled:true, center:{x:0,y:1,z:4}, size:{x:8,y:3,z:4}}]
});
const bindings = await scene.scripts.bind({
  nodes: ["n1"],
  script: scriptHandle,
  params: {}
});
return {bindings};
