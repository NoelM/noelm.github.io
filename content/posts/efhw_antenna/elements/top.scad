echo(version=version());

inner_radius = 180/2;
outer_radius = 320/2;
holes_radius = 20;
holes_pos = (outer_radius+inner_radius)/2;
height = 50;

difference() {
    cube([120, 180, 50], center = true);
    
    translate([0, 30, 0])
    cylinder(h=60, r=35, center=true);
    
    translate([0, -90+40, 0])
    cylinder(h=60, r=10, center=true);
}
