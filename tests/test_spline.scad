include <../spline.scad>
include <../se3.scad>

$fn = 24;

// ============================================================================
// Test Suite for spline.scad
// ----------------------------------------------------------------------------
// Covers:
// - spline_args with open/closed curves
// - tangent / binormal / normal evaluation
// - Bezier curve generation
// - Frenet frame transform visualization
// - Regression consistency checks
// ============================================================================

// --- Basic Spline Example (closed curve) -----------------------------------
p1 = [[0, 10, 0], [10, 0, 0], [0, -5, 2]];
s1 = spline_args(p1, v1=[0, 1, 0], v2=[-1, 0, 0], closed=true);

// Visualize spline points
for (t = [0:0.01:len(s1)])
  translate(spline(s1, t))
    color("red") sphere(r=0.1);

// Tangent demo
for (t = [0:0.5:len(s1)])
  let (pt = spline(s1, t))
  color("blue")
    translate(pt) cylinder(r=0.1, h=2, center=true, $fn=12);

// --- Open Spline Example ---------------------------------------------------
p2 = [[0, 0, 0], [0, 0, 15], [26, 0, 41]];
s2 = spline_args(p2, v2=[40, 0, 0]);

for (t = [0:0.01:len(s2)])
  translate(spline(s2, t))
    color("indigo") sphere(r=0.1);

// --- Bezier Curve Example --------------------------------------------------
p3 = [
  [0, 0, 0],
  [0, 0, 10],
  [0, 0, 15],
  [0, 0, 26 * 0.552],
  [26, 0, 41],
  [26 * 0.552, 0, 0],
];
s3 = bezier3_args(p3, symmetric=true);

echo("Bezier coefficients =", s3);

for (t = [0:0.01:len(s3)])
  translate(spline(s3, t))
    color("green") sphere(r=0.1);

// --- Frenet Frame Demo -----------------------------------------------------
// Rotation methods (ported from list-comprehension-demos/sweep.scad)
function __rotation_from_axis(x, y, z) =
  [[x[0], y[0], z[0]], [x[1], y[1], z[1]], [x[2], y[2], z[2]]];

function __rotate_from_to(a, b, _axis = []) =
  len(_axis) == 0 ? __rotate_from_to(a, b, unit(cross(a, b)))
  : _axis * _axis >= 0.99 ? __rotation_from_axis(unit(b), _axis, cross(_axis, unit(b))) * transpose_3(__rotation_from_axis(unit(a), _axis, cross(_axis, unit(a))))
  : identity3();

p4 = [[0, 10, 0], [6, 6, 0], [10, 0, 0], [0, -5, 4]];
s4 = spline_args(p4, v1=[0, 1, 0], v2=[-1, 0, 0], closed=true);

// Normal/binormal markers
for (t = [0:0.05:len(s4)])
  translate(spline(s4, t)) {
    translate([0, 0, 3])
      multmatrix(m=__rotate_from_to([0, 0, 1], spline_normal_unit(s4, t)))
        color("teal")
          cylinder(r1=0.1, r2=0, h=1, $fn=3);
    translate([0, 0, 6])
      multmatrix(m=__rotate_from_to([0, 0, 1], spline_binormal_unit(s4, t)))
        color("brown")
          cylinder(r1=0.1, r2=0, h=1, $fn=3);
  }

// Spline transform demo (Frenet-aligned cubes)
translate([0, 0, 9])for (t = [0:0.025:len(s4)])
  multmatrix(spline_transform(s4, t))
    color("orange")
      cube([1, 1, 0.1], center=true);

// --- Consistency Check -----------------------------------------------------
__test = [20, -40, 60, -80, 100, -120];
echo("SE3 consistency =", norm(__test - se3_ln(se3_exp(__test))) < 1e-8);
