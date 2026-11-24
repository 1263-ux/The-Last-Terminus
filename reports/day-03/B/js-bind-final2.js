const ruler = await scene.nodes.create({parent:"n1", name:"desk-ruler-rest"});
const bound = await scene.scripts.bind({
  nodes:[ruler],
  script:"aae47e30-ec23-4690-8e97-24bb552b9a55",
  params:{TriggerZ:92.0, TriggerRadius:3.0}
});
return {ruler:ruler, bindings:bound};
