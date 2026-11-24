use <scad/lib/kit_layout.scad>
use <scad/lib/kit_terrain.scad>

world_map_bounds=[40,48];
world_seed=7;
// Host converts SCAD [x,y,z] -> Unity [-x, z, -y]. Player spawns at Unity
// (119.74, 77.91, 88.64), so the map must sit at SCAD x=-119.74, y=-88.64.
map_origin_x=-119.74;
map_origin_y=-88.64;
translate([map_origin_x, map_origin_y, 0]) {

world_visual_form(id="desk-surface", importance="secondary", structure_kind="landform")
world_surface("desk", tags=["walkable"])
world_collider("desk-collider", tags=["walkable"], visual=true)
world_material([0.82,0.78,0.68,1], roughness=0.92)
translate([-world_map_bounds[0]/2, -world_map_bounds[1]/2, -0.15])
    cube([world_map_bounds[0], world_map_bounds[1], 0.15]);

world_visual_form(id="near-ledge", importance="primary", structure_kind="landform")
world_surface("near-ledge-top", tags=["walkable"])
world_collider("near-ledge-collider", tags=["walkable"], visual=true)
world_material([0.45,0.24,0.20,1], roughness=0.88)
translate([-4, 0, 0]) cube([8, 10, 0.30]);

world_material([0.30,0.16,0.13,1], roughness=0.90)
translate([-4.25, 0, 0]) cube([0.25, 10, 0.42]);
world_material([0.86,0.82,0.70,1], roughness=0.95)
translate([-3.90, 0.20, 0.30]) cube([7.80, 9.60, 0.02]);

world_visual_form(id="chasm-mark", importance="secondary", structure_kind="path")
world_material([0.18,0.16,0.20,1], roughness=0.98)
translate([-4, 9.90, -0.02]) cube([8, 2.20, 0.02]);

world_visual_form(id="far-ledge", importance="primary", structure_kind="landform")
world_surface("far-ledge-top", tags=["walkable"])
world_collider("far-ledge-collider", tags=["walkable"], visual=true)
world_material([0.28,0.34,0.40,1], roughness=0.88)
translate([-4, 12, 0]) cube([8, 12, 0.30]);
world_material([0.86,0.82,0.70,1], roughness=0.95)
translate([-3.90, 12.10, 0.30]) cube([7.80, 11.80, 0.02]);

world_visual_form(id="ruler-rest", importance="primary", structure_kind="assembly")
world_material([0.80,0.64,0.42,1], roughness=0.80)
translate([-7.20, 2.00, 0.32]) cube([0.90, 8.00, 0.16]);
world_material([0.24,0.18,0.12,1], roughness=0.85)
for (k=[0:6])
    translate([-7.20, 2.60 + k*1.10, 0.48]) cube([0.90, 0.06, 0.02]);

world_visual_form(id="ruler-ramp", importance="primary", structure_kind="path")
world_material([0.80,0.64,0.42,1], roughness=0.80)
translate([-4.00, 9.60, 0.30]) cube([8.00, 1.20, 0.22]);
for (k=[0:6])
    translate([-3.40 + k*1.10, 9.60, 0.52]) cube([0.06, 1.20, 0.02]);

world_visual_form(id="town-block", importance="primary", structure_kind="building")
world_surface("town-ground", tags=["walkable"])
world_collider("town-collider", tags=["walkable"], visual=true)
world_material([0.20,0.32,0.38,1], roughness=0.86)
translate([-12, 26, 0]) cube([24, 4.0, 5.0]);
world_material([0.62,0.24,0.22,1], roughness=0.82)
translate([-12.20, 25.80, 5.00]) cube([24.40, 4.40, 0.50]);
world_material([1.00,0.86,0.52,1], roughness=0.35)
for (k=[0:5])
    translate([-10.50 + k*4.00, 25.95, 2.00]) cube([1.20, 0.12, 1.40]);

world_visual_form(id="desk-lamp", importance="secondary", structure_kind="assembly")
world_material([0.78,0.66,0.42,1], roughness=0.70)
translate([16, 34, 0]) cylinder(h=0.25, r=1.05, $fn=24);
translate([16, 34, 0.25]) cylinder(h=2.60, r=0.14, $fn=12);
translate([16, 34, 2.85]) cylinder(h=0.50, r1=1.00, r2=0.55, $fn=24);
}
