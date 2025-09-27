use <../morphology.scad>


// TEST CODE

use <../mirror.scad>

module arrow(l = 1, w = .6, t = 0.15) {
  mirror_y() polygon([[0, 0], [l, 0], [l - w / 2, w / 2], [l - w / 2 - sqrt(2) * t, w / 2], [l - t / 2 - sqrt(2) * t, t / 2], [0, t / 2]]);
}

module shape() {
  polygon([[0, 0], [1, 0], [1.5, 1], [2.5, 1], [2, -1], [0, -1]]);
}

debug = true;

if (debug)
  assign ($fn = 32) {

    for (p = [0:10 * 3 - 1])
      assign (o = floor(p / 3)) {
        translate([(p % 3) * 2.5, -o * 3]) {
          //%if (p % 3 == 1) translate([0,0,1]) shape();
          if (p % 3 == 0) shape();
          if (p % 3 == 1) translate([0.6, 0]) arrow();
          if (p % 3 == 2) {
            if (o == 0) inset(d=0.3) shape();
            if (o == 1) outset(d=0.3) shape();
            if (o == 2) rounding(r=0.3) shape();
            if (o == 3) fillet(r=0.3) shape();
            if (o == 4) shell(d=0.3) shape();
            if (o == 5) shell(d=-0.3) shape();
            if (o == 6) shell(d=0.3, center=true) shape();
            if (o == 7) rounding(r=0.3) fillet(r=0.3) shape();
            if (o == 8) shell(d=0.3, center=true) fillet(r=0.3) rounding(r=0.3) shape();
            if (o == 9) shell(d=-0.3) fillet(r=0.3) rounding(r=0.3) shape();
          }
        }
      }
  }
