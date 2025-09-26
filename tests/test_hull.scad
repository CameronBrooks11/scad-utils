include <../hull.scad>

// --- Test Data --------------------------------------------------------------
phi = 1.618033988749895;

testpoints_on_sphere = [
  for (
    p = [
      [1, phi, 0],
      [-1, phi, 0],
      [1, -phi, 0],
      [-1, -phi, 0],
      [0, 1, phi],
      [0, -1, phi],
      [0, 1, -phi],
      [0, -1, -phi],
      [phi, 0, 1],
      [-phi, 0, 1],
      [phi, 0, -1],
      [-phi, 0, -1],
    ]
  ) unit(p),
];
testpoints_spherical = [for (p = testpoints_on_sphere) spherical(p)];
testpoints_circular = [for (a = [0:15:360 - epsilon]) [cos(a), sin(a)]];
testpoints_coplanar = let (u = unit([1, 3, 7]), v = unit([-2, 1, -2])) [for (i = [1:10]) rands(-1, 1, 1)[0] * u + rands(-1, 1, 1)[0] * v];
testpoints_collinear_2d = let (u = unit([5, 3])) [for (i = [1:20]) rands(-1, 1, 1)[0] * u];
testpoints_collinear_3d = let (u = unit([5, 3, -5])) [for (i = [1:20]) rands(-1, 1, 1)[0] * u];
testpoints2d = 20 * [for (i = [1:10]) concat(rands(-1, 1, 2))];
testpoints3d = 20 * [for (i = [1:50]) concat(rands(-1, 1, 3))];

// --- Visualization ----------------------------------------------------------
echo("Test points 3d");
visualize_hull(testpoints3d);
echo("Test points on sphere");
translate([-50, 0]) visualize_hull(20 * testpoints_on_sphere);
echo("Test points on 2d");
translate([50, 0]) visualize_hull(testpoints2d);
echo("Test points on circular");
translate([0, 50]) visualize_hull(20 * testpoints_circular);
echo("Test points coplanar");
translate([0, -50]) visualize_hull(20 * testpoints_coplanar);
echo("Test points collinear 2d");
translate([50, 50]) visualize_hull(20 * testpoints_collinear_2d);
echo("Test points collinear 3d");
translate([-50, 50]) visualize_hull(20 * testpoints_collinear_3d);

// --- Visualization Helpers --------------------------------------------------
module visualize_hull(points) {
  let (faces = hull(points)) {
    echo("Faces: ", faces);
    if (len(faces) == 0) {
      // nothing
    } else if (is_list(faces[0])) {
      %polyhedron(points=points, faces=faces); // 3D hull
    } else if (len(faces) >= 3) {
      %polyhedron(points=points, faces=[faces]); // 2D hull
    } else if (len(faces) == 2) {
      // collinear case: show a rod between endpoints
      p0 = points[faces[0]];
      p1 = points[faces[1]];
      hull() {
        translate(p0) sphere(r=0.8, $fn=24);
        translate(p1) sphere(r=0.8, $fn=24);
      }
    }

    // Draw points: blue if on hull, red otherwise
    for (i = [0:len(points) - 1]) {
      translate(points[i])
        color(hull_contains_index(faces, i) ? "blue" : "red")
          sphere(r=1, $fn=16);
    }
  }
}

function hull_contains_index(faces, idx) =
  search(idx, faces, 1, 0) || search(idx, faces, 1, 1) || search(idx, faces, 1, 2);
