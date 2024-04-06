echo(version=version());

inner_radius = 180/2;
outer_radius = 320/2;
holes_radius = 15;
holes_pos = (outer_radius+inner_radius)/2;
height = 50;

difference() {
    cylinder(h=height, r=outer_radius, center=true);
    cylinder(h=height+10, r=inner_radius, center=true);
    
    translate([holes_pos, 0, 0])
    cylinder(h=height+10, r=holes_radius, center= true);
    
    translate([-holes_pos, 0, 0])
    cylinder(h=height+10, r=holes_radius, center= true);
    
    translate([0, holes_pos, 0])
    cylinder(h=height+10, r=holes_radius, center= true);
    
    translate([0, -holes_pos, 0])
    cylinder(h=height+10, r=holes_radius, center= true);
}
