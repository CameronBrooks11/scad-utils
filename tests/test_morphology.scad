use <../morphology.scad>
use <test_mirror.scad> // for arrow()

// ---------------------------------------------------------------------------
// Base test shape
// ---------------------------------------------------------------------------
module shape() {
  polygon(
    [
      [0, 0],
      [1, 0],
      [1.5, 1],
      [2.5, 1],
      [2, -1],
      [0, -1],
    ]
  );
}

debug = true;

if (debug) {
  $fn = 32;

  // 10 groups of 3 columns: [original, arrow, transformed]
  for (p = [0:10 * 3 - 1]) {
    o = floor(p / 3); // row index (operation group)

    translate([(p % 3) * 2.5, -o * 3]) {
      if (p % 3 == 0) shape(); // original
      if (p % 3 == 1) translate([0.6, 0]) color("grey") arrow(); // arrow
      if (p % 3 == 2) {
        // transformed
        if (o == 0) inset(d=0.3) shape();
        if (o == 1) outset(d=0.3) shape();
        if (o == 2) rounding(r=0.3) shape();
        if (o == 3) fillet(r=0.3) shape();
        if (o == 4) rounding(r=0.3) fillet(r=0.3) shape();
        if (o == 5) shell(d=0.3) shape();
        if (o == 6) shell(d=-0.3) shape();
        if (o == 7) shell(d=0.3, center=true) shape();
        if (o == 8) shell(d=0.3, center=true) fillet(r=0.3) rounding(r=0.3) shape();
        if (o == 9) shell(d=-0.3) fillet(r=0.3) rounding(r=0.3) shape();
      }
    }
  }
}
