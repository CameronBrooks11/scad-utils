include <../mirror.scad>

// Simple reference shape offset from the origin so the mirror is obvious
module sample_shape() {
  translate([20, 10, 5]) {
    cube([10, 6, 6], center=false);
    translate([10, 3, 6]) sphere(r=4, $fn=24);
  }
}

// Tiny axes helper for orientation
module axes(len = 25, thick = 0.8) {
  // +X axis (red)
  color("red")
    translate([len / 2, 0, 0])
      cube([len, thick, thick], center=true);

  // +Y axis (green)
  color("green")
    translate([0, len / 2, 0])
      cube([thick, len, thick], center=true);

  // +Z axis (blue)
  color("blue")
    translate([0, 0, len / 2])
      cube([thick, thick, len], center=true);
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
translate([-60, -40, 0]) {
  axes();
  color("orange")
    union() {
      sample_shape();
      mirror([1, 0, 0]) sample_shape();
    }
}

module arrow(l = 1, w = .6, t = 0.15) {
  mirror_y() polygon([[0, 0], [l, 0], [l - w / 2, w / 2], [l - w / 2 - sqrt(2) * t, w / 2], [l - t / 2 - sqrt(2) * t, t / 2], [0, t / 2]]);
}

// Compare with a single plain mirror
translate([60, -40, 0]) {
  axes();
  color("orange")
    arrow(l=20, w=10, t=2);
}
