// ============================================================================
// Transformations Utilities
// ----------------------------------------------------------------------------
// Provides matrix constructors and helpers for geometric transformations:
// - rotation(xyz, axis): create rotation from Euler angles or axis-angle
// - scaling(v): scaling matrix
// - translation(v): translation matrix
// - project(x): cartesian from homogeneous coordinates
// - transform(m, list): apply matrix to list of points
// - to_3d(list): ensure vectors are 3D
//
// Notes:
// - Euler convention: R = Rz * Ry * Rx
// - Axis rotation uses se3 exponential map
// ============================================================================

use <se3.scad>
use <linalg.scad>
use <lists.scad>

// --- Rotation ---------------------------------------------------------------
// Creates a rotation matrix
// Options:
//   - xyz = Euler angles (applied as Rz * Ry * Rx)
//   - axis = axis-angle vector (axis * angle)
// Examples:
//   rotation(xyz=[90,0,0])   // rotate 90° about X
//   rotation(axis=[0,0,45])  // rotate 45° about Z
function rotation(xyz = undef, axis = undef) =
  // disallow both forms together
  (!is_undef(xyz) && !is_undef(axis)) ?
    undef
  :
  // pure axis-angle exponential form
  (is_undef(xyz) && !is_undef(axis)) ?
    se3_exp([0, 0, 0, axis[0], axis[1], axis[2]])
  :
  // shorthand for single-angle rotation about Z
  (is_undef(axis) && !is_undef(xyz) && !is_list(xyz)) ?
    rotation(axis=[0, 0, xyz])
  :
  // full Euler xyz case
  (is_undef(axis) && is_list(xyz)) ?
    (
      len(xyz) >= 3 ?
        rotation(axis=[0, 0, xyz[2]])
      : identity4()
    ) * (
      len(xyz) >= 2 ?
        rotation(axis=[0, xyz[1], 0])
      : identity4()
    ) * (
      len(xyz) >= 1 ?
        rotation(axis=[xyz[0], 0, 0])
      : identity4()
    )
  :
  // fallback
  identity4();

// --- Scaling ----------------------------------------------------------------
// Creates a scaling matrix: scaling([sx, sy, sz])
function scaling(v) =
  [
    [v[0], 0, 0, 0],
    [0, v[1], 0, 0],
    [0, 0, v[2], 0],
    [0, 0, 0, 1],
  ];

// --- Translation ------------------------------------------------------------
// Creates a translation matrix: translation([tx, ty, tz])
function translation(v) =
  [
    [1, 0, 0, v[0]],
    [0, 1, 0, v[1]],
    [0, 0, 1, v[2]],
    [0, 0, 0, 1],
  ];

// --- Coordinate Conversion --------------------------------------------------
// Converts from homogeneous to cartesian coordinates
function project(x) = subarray(x, end=len(x) - 1) / x[len(x) - 1];

// Applies matrix `m` to a list of points
function transform(m, list) = [for (p = list) project(m * vec4(p))];

// Ensures points are represented as 3D vectors
function to_3d(list) = [for (v = list) vec3(v)];
