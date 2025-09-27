// ============================================================================
// Shape Generators (2D)
// ----------------------------------------------------------------------------
// Provides simple parametric 2D shape generators:
// - square(size): centered square polygon
// - circle(r): circle polygon using current $fn
// - regular(r, n): regular n-gon (circle with fixed $fn)
// - rectangle_profile(size=[w,h]): rectangular profile with anchor at [w/2,0]
// ----------------------------------------------------------------------------
// Notes:
// - All outputs are polygon point lists (suitable for polygon(), etc.)
// - `circle` and `regular` depend on $fn resolution
// ============================================================================

// --- Square -----------------------------------------------------------------
// size: length of edge
function square(size) =
  [[-size, -size], [-size, size], [size, size], [size, -size]] / 2;

// --- Circle -----------------------------------------------------------------
// r: radius
// Uses global $fn for resolution
function circle(r) =
  [for (i = [0:$fn - 1]) let (a = i * 360 / $fn) r * [cos(a), sin(a)]];

// --- Regular Polygon --------------------------------------------------------
// r: circumradius
// n: number of sides
function regular(r, n) = circle(r, $fn=n);

// --- Rectangle Profile ------------------------------------------------------
// size = [w, h]
// Anchor point is [w/2, 0]
function rectangle_profile(size = [1, 1]) =
  [
    [size[0] / 2, 0],
    [size[0] / 2, size[1] / 2],
    [-size[0] / 2, size[1] / 2],
    [-size[0] / 2, -size[1] / 2],
    [size[0] / 2, -size[1] / 2],
  ];

// TODO: Move rectangle and rounded rectangle from extrusion.scad
