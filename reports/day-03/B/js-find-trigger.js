const nodes = await scene.nodes.query({limit:200});
const withTrigger = nodes.items.filter(n=>n.componentTypes && n.componentTypes.includes("triggerData"));
const withCollider = nodes.items.filter(n=>n.componentTypes && n.componentTypes.includes("physicsColliderData"));
return { triggerCount: withTrigger.length, trigger: withTrigger.slice(0,10),
         colliderCount: withCollider.length, collider: withCollider.slice(0,5) };
