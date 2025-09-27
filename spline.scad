// ============================================================================
// Spline Utilities
// ----------------------------------------------------------------------------
// Provides cubic spline and Bezier curve utilities for OpenSCAD.
//
// Functions:
//   - spline_args(p, closed=false, v1=undef, v2=undef)
//       → compute spline coefficient matrices for given control points
//   - spline(s, t)
//       → evaluate spline at parameter t
//   - spline_tan(), spline_tan_unit()
//       → evaluate tangent vector
//   - spline_d2(), spline_binormal_unit(), spline_normal_unit()
//       → evaluate higher derivatives and Frenet frame
//   - spline_transform()
//       → construct SE3 transform aligned to spline
//   - bezier3_args(p, symmetric=false)
//       → construct cubic Bezier coefficient matrices
//
// Internal helpers implement determinant, matrix inversion, etc.
//
// Author: Sergei Kuzmin, 2014
// License: BSD
// ============================================================================

use <linalg.scad>

// --- Predefined Matrices ----------------------------------------------------
q1 = [[1, 0, 0, 0], [1, 1, 1, 1], [0, 1, 2, 3], [0, 0, 1, 3]];
q1inv = [[1, 0, 0, 0], [-3, 3, -2, 1], [3, -3, 3, -2], [-1, 1, -1, 1]];
q2 = [[0, 0, 0, 0], [0, 0, 0, 0], [0, -1, 0, 0], [0, 0, -1, 0]];
qn1i2 = -q1inv * q2;

z3 = [0, 0, 0];
z4 = [0, 0, 0, 0];

// --- Spline Construction ----------------------------------------------------

// Local utility
function spline_u(i, p) = [p[i], p[i + 1], z3, z3];

// Compute spline coefficient matrices
function spline_args(p, closed = false, v1 = undef, v2 = undef) =
  len(p) < 2 ? []
  : let (
    q3 = closed ? q2
    : [
      z4,
      z4,
      v1 == undef ? [0, 0, 1, 0] : [0, 1, 0, 0],
      z4,
    ],
    q4 = closed ? q1
    : [
      [1, 0, 0, 0],
      [1, 1, 1, 1],
      z4,
      v2 == undef ? [0, 0, 1, 3] : [0, 1, 2, 3],
    ],
    pcnt = closed ? len(p) + 1 : len(p),
    un = [
      p[pcnt - 2],
      p[closed ? 0 : pcnt - 1],
      v1 == undef ? z4 : v1,
      v2 == undef ? z4 : v2,
    ],
    sn = matrix_invert(q4 + q3 * matrix_power(qn1i2, pcnt - 2)) * (un - q3 * q1inv * spline_helper(0, pcnt, p))
  )
  // result[i+1] recurrently defines result[i]. This is O(n) runtime with 
  // imperative language and may be O(n^2) if OpenSCAD doesn't cache spline_si(i+1).
  [for (i = [0:pcnt - 2]) spline_si(i, pcnt - 2, p, sn)];

// Helper recursion for spline_args
// n is number of points including pseudopoint for closed contour
// Weird construct cause there is no if statement for functions
function spline_helper(i, n, p) =
  let (u = [p[i], p[i + 1], z3, z3]) i + 3 >= n ? u
  : u - q2 * q1inv * spline_helper(i + 1, n, p);

// Recursive calculation of segment coefficients
// knowing s[j+1], calculate s[j]. Stop when found s[i]

function spline_si(i, n, p, sn) =
  i == n ? sn
  : q1inv * (spline_u(i, p) - q2 * spline_si(i + 1, n, p, sn));

// --- Bezier Utilities -------------------------------------------------------
// Takes array of (3n+1) points or (2n + 2) points, if tangent segments are symmetric.
// For non-symmetric version input is: 
//   point0, normal0, neg_normal1, point1, normal1, ... neg_normal_n, point_n
// For symmetric version: 
//   point0, normal0, point1, normal1, ... , normal_n_sub_1, point_n
// In the second case second tangent is constructed from the next tangent by symmetric map.
// I.e. if current points are p0,p1,p2 then anchor points are p0 and p2, first tangent 
// defined by p1-p0, second tangent defined by p3-p2.
// Return array of coefficients accepted by spline(), spline_tan() and similar
function bezier3_args(p, symmetric = false) =
  let (step = symmetric ? 2 : 3) [
      for (i = [0:step:len(p) - 3]) [[1, 0, 0, 0], [-3, 3, 0, 0], [3, -6, 3, 0], [-1, 3, -3, 1]] * (
        symmetric ? [p[i], p[i] + p[i + 1], p[i + 2] - p[i + 3], p[i + 2]]
        : [p[i], p[i] + p[i + 1], p[i + 3] + p[i + 2], p[i + 3]]
      ),
  ];

// --- Evaluation -------------------------------------------------------------
// Evaluate spline/Bezier and derivatives
// s - spline arguments calculated by spline_args
// t - defines point on curve. Each segment length is 1. 
//     i.e. t= 0..1 is first segment, t=1..2 - second.   
function spline(s, t) =
  let (
    i = t >= len(s) ? len(s) - 1 : floor(t),
    t2 = t - i
  ) [1, t2, t2 * t2, t2 * t2 * t2] * s[i];

function spline_tan(s, t) =
  let (
    i = t >= len(s) ? len(s) - 1 : floor(t),
    t2 = t - i
  ) [0, 1, 2 * t2, 3 * t2 * t2] * s[i];

function spline_tan_unit(s, t) = unit(spline_tan(s, t));

function spline_d2(s, t) =
  let (
    i = t >= len(s) ? len(s) - 1 : floor(t),
    t2 = t - i
  ) [0, 0, 2, 6 * t2] * s[i];

function spline_binormal_unit(s, t) = unit(cross(spline_tan(s, t), spline_d2(s, t)));
function spline_normal_unit(s, t) = unit(cross(spline_tan(s, t), spline_binormal_unit(s, t)));

function spline_transform(s, t) =
  construct_Rt(
    transpose_3(
      [
        spline_normal_unit(s, t),
        spline_binormal_unit(s, t),
        spline_tan_unit(s, t),
      ]
    ),
    spline(s, t)
  );
