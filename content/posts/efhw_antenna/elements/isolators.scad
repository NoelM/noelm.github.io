// text_on_cube.scad - Example for text() usage in OpenSCAD

echo(version=version());

font = "Inter:style=Bold"; //["Liberation Sans", "Liberation Sans:style=Bold", "Liberation Sans:style=Italic", "Liberation Mono", "Liberation Serif"]

width = 120;
depth = 400;
height= 40;

letter_height = 3;
letter_size = 42;

module letter(l) {
  // Use linear_extrude() to make the letters 3D objects as they
  // are only 2D shapes when only using text()
  color("gray")
  linear_extrude(height = letter_height) {
    text(l, size = letter_size, font = font, halign = "center", valign = "center", $fn = 16);
  }
}

module insulator(x, band1, band2) {

translate([x, 0, 0])
union() {
    difference() {
        translate([width/2+75, 0, 0])
        cube([150, 150, 40], center=true);
        
        translate([width/2+75, 0, 0])
        cylinder(h=50, r=35, center= true);
    }
    difference() {
        union() {
            cube([width, depth, height], center= true);
            
            translate([0, 0, height/2])
            rotate([0, 0, -90])
            letter(band1);
            
            translate([0, 0, -height/2])
            rotate([0, -180, -90])
            letter(band2);
        }
        
        translate([0,-150, 0])
        cylinder(h=50, r=15, center= true);
    
        translate([0,150, 0])
        cylinder(h=50, r=15, center= true);
    }
}
}

insulator(0, "15m \u25BA", "17m \u25BA");
insulator(350, "17m \u25BA", "20m \u25BA");
insulator(700, "20m \u25BA", "30m \u25BA");
insulator(1050, "30m \u25BA", "40m \u25BA");
insulator(1400, "40m \u25BA", "");



/*
o = cube_size / 2 - letter_height / 2;

module letter(l) {
  // Use linear_extrude() to make the letters 3D objects as they
  // are only 2D shapes when only using text()
  linear_extrude(height = letter_height) {
    text(l, size = letter_size, font = font, halign = "center", valign = "center", $fn = 16);
  }
}

difference() {
  union() {
    color("gray") cube(cube_size, center = true);
    translate([0, -o, 0]) rotate([90, 0, 0]) letter("C");
    translate([o, 0, 0]) rotate([90, 0, 90]) letter("U");
    translate([0, o, 0]) rotate([90, 0, 180]) letter("B");
    translate([-o, 0, 0]) rotate([90, 0, -90]) letter("E");
  }

  // Put some symbols on top and bottom using symbols from the
  // Unicode symbols table.
  // (see https://en.wikipedia.org/wiki/Miscellaneous_Symbols)
  //
  // Note that depending on the font used, not all the symbols
  // are actually available.
  translate([0, 0, o])  letter("\u263A");
  translate([0, 0, -o - letter_height])  letter("\u263C");
}



// Written in 2014 by Torsten Paul <Torsten.Paul@gmx.de>
//
// To the extent possible under law, the author(s) have dedicated all
// copyright and related and neighboring rights to this software to the
// public domain worldwide. This software is distributed without any
// warranty.
//
// You should have received a copy of the CC0 Public Domain
// Dedication along with this software.
// If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/
