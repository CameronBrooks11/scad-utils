include <../mirror.scad>

// Simple reference shape offset from the origin so the mirror is obvious
module sample_shape() {
  translate([20, 10, 5]) {
    cube([10, 6, 6], center=false);
    translate([10, 3, 6]) sphere(r=4, $fn=24);
  }
}

// Tiny axes helper for orientation
module axes(len = 25) {
  color("red") cube([len, 0.8, 0.8], center=false); // +X
  color("green") cube([0.8, len, 0.8], center=false); // +Y
  color("blue") cube([0.8, 0.8, len], center=false); // +Z
}

// Arrange three demos side-by-side
translate([-60, 0, 0]) {
  axes();
  mirror_x() sample_shape();
}

translate([0, 0, 0]) {
  axes();
  mirror_y() sample_shape();
}

translate([60, 0, 0]) {
  axes();
  mirror_z() sample_shape();
}

// Compare with a single plain mirror
translate([-60, -30, 0]) {
  axes();
  color("orange")
    union() {
      sample_shape();
      mirror([1, 0, 0]) sample_shape();
    }
}
