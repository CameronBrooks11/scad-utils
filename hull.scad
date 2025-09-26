// ============================================================================
// Convex Hull Utilities (2D and 3D)
// ----------------------------------------------------------------------------
// This implementation calculates convex hulls for 2D or 3D point sets.
// - 2D: returns polygon vertex indices [i1, i2, i3, ...]
// - 3D: returns triangular face indices [[i1,i2,i3], [i2,i3,i4], ...]
// - Collinear: returns the two extreme endpoints [i_min, i_max]
// ----------------------------------------------------------------------------
// Notes:
//   * Uses let() and list comprehensions
//   * Relies on bug-fixed search()
//   * Assumes vector min()/max() are available
// ============================================================================

epsilon = 1e-9;

// --- Entry point ------------------------------------------------------------
function hull(points) =
  (len(points) == 0) ? []
  : (len(points[0]) == 2) ? convexhull2d(points)
  : (len(points[0]) == 3) ? convexhull3d(points) : [];

// --- 2D Convex Hull ---------------------------------------------------------
function convexhull2d(points) =
  (len(points) < 3) ? []
  : let (
    a = 0,
    b = 1,
    c = find_first_noncollinear([a, b], points, 2)
  ) (c == len(points)) ? convexhull_collinear(points)
  : let (
    remaining = [for (i = [2:len(points) - 1]) if (i != c) i],
    polygon = (area_2d(points[a], points[b], points[c]) > 0) ?
      [a, b, c]
    : [b, a, c]
  ) convex_hull_iterative_2d(points, polygon, remaining);

function convex_hull_iterative_2d(points, polygon, remaining, i_ = 0) =
  (i_ >= len(remaining)) ? polygon
  : let (
    i = remaining[i_],
    conflicts = find_conflicting_segments(points, polygon, points[i])
  ) (len(conflicts) == 0) ?
    convex_hull_iterative_2d(points, polygon, remaining, i_ + 1)
  : let (
    polygon = remove_conflicts_and_insert_point(polygon, conflicts, i)
  ) convex_hull_iterative_2d(points, polygon, remaining, i_ + 1);

function find_conflicting_segments(points, polygon, point) =
  [
    for (i = [0:len(polygon) - 1]) let (j = (i + 1) % len(polygon)) if (area_2d(points[polygon[i]], points[polygon[j]], point) < 0) i,
  ];

function remove_conflicts_and_insert_point(polygon, conflicts, point) =
  (conflicts[0] == 0) ?
    let (
      nonconf = [for (i = [0:len(polygon) - 1]) if (!contains(conflicts, i)) i],
      indices = concat(nonconf, (nonconf[len(nonconf) - 1] + 1) % len(polygon))
    ) concat([for (i = indices) polygon[i]], point)
  : let (
    before = [for (i = [0:1:min(conflicts)]) polygon[i]],
    after = [for (i = [max(conflicts) + 1:1:len(polygon) - 1]) polygon[i]]
  ) concat(before, point, after);

// --- 3D Convex Hull ---------------------------------------------------------
function convexhull3d(points) =
  (len(points) < 3) ? [for (i = [0:1:len(points) - 1]) i]
  : let (
    a = 0,
    b = 1,
    c = 2,
    pl = plane(points, a, b, c),
    d = find_first_noncoplanar(pl, points, 3)
  ) (d == len(points)) ?
    // all coplanar: project to 2D hull
    let (
      pts2d = [for (p = points) plane_project(p, points[a], points[b], points[c])]
    ) convexhull2d(pts2d)
  : let (
    remaining = [for (i = [3:len(points) - 1]) if (i != d) i],
    bc = in_front(pl, points[d]) ? [c, b] : [b, c],
    b2 = bc[0],
    c2 = bc[1],
    tris = [[a, b2, c2], [d, b2, a], [c2, d, a], [b2, d, c2]],
    planes = [for (t = tris) plane(points, t[0], t[1], t[2])]
  ) convex_hull_iterative(points, tris, planes, remaining);

function plane(points, a, b, c) =
  let (n = unit(cross(points[c] - points[a], points[b] - points[a]))) [n, n * points[a]];

function convex_hull_iterative(points, triangles, planes, remaining, i_ = 0) =
  (i_ >= len(remaining)) ? triangles
  : let (
    idx = remaining[i_],
    conflicts = find_conflicts(points[idx], planes),
    halfedges = [
      for (c = conflicts) for (k = [0:2]) let (j = (k + 1) % 3) [triangles[c][k], triangles[c][j]],
    ],
    horizon = remove_internal_edges(halfedges),
    new_tris = [for (h = horizon) concat(h, idx)],
    new_pls = [for (t = new_tris) plane(points, t[0], t[1], t[2])]
  ) convex_hull_iterative(
    points,
    concat(remove_elements(triangles, conflicts), new_tris),
    concat(remove_elements(planes, conflicts), new_pls),
    remaining,
    i_ + 1
  );

// --- Collinear Special Case -------------------------------------------------
function convexhull_collinear(points) =
  let (
    n = points[1] - points[0],
    a = points[0],
    pts1d = [for (p = points) (p - a) * n],
    min_i = min_index(pts1d),
    max_i = max_index(pts1d)
  ) [min_i, max_i];

// --- Utility Functions ------------------------------------------------------
function min_index(values, min_ = undef, idx_min = undef, i_ = 0) =
  (i_ == 0) ? min_index(values, values[0], 0, 1)
  : (i_ >= len(values)) ? idx_min
  : (values[i_] < min_) ? min_index(values, values[i_], i_, i_ + 1)
  : min_index(values, min_, idx_min, i_ + 1);

function max_index(values, max_ = undef, idx_max = undef, i_ = 0) =
  (i_ == 0) ? max_index(values, values[0], 0, 1)
  : (i_ >= len(values)) ? idx_max
  : (values[i_] > max_) ? max_index(values, values[i_], i_, i_ + 1)
  : max_index(values, max_, idx_max, i_ + 1);

function remove_elements(arr, to_remove) =
  [for (i = [0:len(arr) - 1]) if (!search(i, to_remove)) arr[i]];

function remove_internal_edges(edges) =
  [for (h = edges) if (!contains(edges, reverse(h))) h];

function plane_project(p, a, b, c) =
  let (u = b - a, v = c - a, n = cross(u, v), w = cross(n, u), rel = p - a) [rel * u, rel * w];

function plane_unproject(p, a, b, c) =
  let (u = b - a, v = c - a, n = cross(u, v), w = cross(n, u)) a + p[0] * u + p[1] * w;

function reverse(arr) = [for (i = [len(arr) - 1:-1:0]) arr[i]];

function contains(arr, el) = (search([el], arr)[0] != []) ? true : false;

function find_conflicts(p, planes) =
  [for (i = [0:len(planes) - 1]) if (in_front(planes[i], p)) i];

function find_first_noncollinear(line, pts, i) =
  (i >= len(pts)) ? len(pts)
  : collinear(pts[line[0]], pts[line[1]], pts[i]) ?
    find_first_noncollinear(line, pts, i + 1)
  : i;

function find_first_noncoplanar(pl, pts, i) =
  (i >= len(pts)) ? len(pts)
  : coplanar(pl, pts[i]) ? find_first_noncoplanar(pl, pts, i + 1) : i;

function distance(pl, p) = pl[0] * p - pl[1];
function in_front(pl, p) = distance(pl, p) > epsilon;
function coplanar(pl, p) = abs(distance(pl, p)) <= epsilon;

function unit(v) = v / norm(v);

function area_2d(a, b, c) =
  (a[0] * (b[1] - c[1]) + b[0] * (c[1] - a[1]) + c[0] * (a[1] - b[1])) / 2;

function collinear(a, b, c) = abs(area_2d(a, b, c)) < epsilon;

function spherical(cart) = [atan2(cart[1], cart[0]), asin(cart[2])];
function cartesian(sph) =
  [
    cos(sph[1]) * cos(sph[0]),
    cos(sph[1]) * sin(sph[0]),
    sin(sph[1]),
  ];
