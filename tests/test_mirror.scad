include <../mirror.scad>

// ---------------------------------------------------------------------------
// Sample reference shape
// ---------------------------------------------------------------------------
module sample_shape() {
  translate([20, 10, 5]) {
    cube([10, 6, 6], center=false);
    translate([10, 3, 6]) sphere(r=4, $fn=24);
  }
}

// ---------------------------------------------------------------------------
// Axes helper for orientation
// ---------------------------------------------------------------------------
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

// ---------------------------------------------------------------------------
// Demonstrations
// ---------------------------------------------------------------------------

// Mirror across X-axis
translate([-60, 0, 0]) {
  axes();
  mirror_x("teal") sample_shape();
}

// Mirror across Y-axis
translate([0, 0, 0]) {
  axes();
  mirror_y("indigo") sample_shape();
}

// Mirror across Z-axis
translate([60, 0, 0]) {
  axes();
  mirror_z("salmon") sample_shape();
}

// Compare with a plain built-in mirror
translate([-60, -40, 0]) {
  axes();
  union() {
    sample_shape();
    mirror([1, 0, 0]) color("MediumAquamarine") sample_shape();
  }
}

// 2D arrow example using mirror_y
module arrow(l = 1, w = 0.6, t = 0.15) {
  mirror_y("orange")
    polygon(
      [
        [0, 0],
        [l, 0],
        [l - w / 2, w / 2],
        [l - w / 2 - sqrt(2) * t, w / 2],
        [l - t / 2 - sqrt(2) * t, t / 2],
        [0, t / 2],
      ]
    );
}

translate([60, -40, 0]) {
  axes();
  arrow(l=20, w=10, t=2);
}
