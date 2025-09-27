// ============================================================================
// Trajectory Utilities
// ----------------------------------------------------------------------------
// Purpose : Provide a clean way to construct SE(3) “twist” vectors
//           (translation + rotation) from intuitive parameters.
// Features:
//   - Flexible specification of translation (left/right, up/down, fwd/back)
//   - Flexible specification of rotation (pitch, yaw, roll) or direct vector
//   - Helpers for dealing with undef inputs and selection logic
//   - trajectory(...) returns [tx,ty,tz, yaw,pitch,roll] 6D vector
//   - rotationm(...) builds a 3x3 rotation matrix from angles
// ----------------------------------------------------------------------------
// Dependencies: so3.scad
// ============================================================================

use <so3.scad>

// --- Helpers ----------------------------------------------------------------

// Return `a` unless it is undef, then use `default`.
function val(a = undef, default = undef) =
  is_undef(a) ? default : a;

// Check if vector/list is fully undef or out-of-bounds (recursively).
function vec_is_undef(x, index_ = 0) =
  index_ >= len(x) ? true
  : is_undef_or_oob(x[index_]) && vec_is_undef(x, index_ + 1);

// Treat scalars, lists, or undef consistently.
function is_undef_or_oob(x) =
  is_undef(x) ? true
  : is_list(x) ? vec_is_undef(x)
  : false;

// Either return a or b (whichever is valid). If both valid → undef.
// If both invalid → default.
function either(a, b, default = undef) =
  is_undef_or_oob(a) ? (is_undef_or_oob(b) ? default : b)
  : is_undef_or_oob(b) ? a
  : undef;

// --- Translation builders ---------------------------------------------------

// Accepts directional keywords (left/right, up/down, forward/backward)
// or an explicit `translation` vector. Returns [x,y,z] or undef.
function translationv(
  left = undef,
  right = undef,
  up = undef,
  down = undef,
  forward = undef,
  backward = undef,
  translation = undef
) =
  translationv_2(
    // X axis points "up" (OpenSCAD’s Z is height, but we’re flexible here)
    x=either(up, is_undef(down) ? down : -down),
    y=either(right, is_undef(left) ? left : -left),
    z=either(forward, is_undef(backward) ? backward : -backward),
    translation=translation
  );

// Internal helper to finalize translation vector.
function translationv_2(x, y, z, translation) =
  (is_undef(x) && is_undef(y) && is_undef(z)) ? translation
  : (is_undef_or_oob(translation) ? [val(x, 0), val(y, 0), val(z, 0)] : undef);

// --- Rotation builders ------------------------------------------------------

// Accepts yaw/pitch/roll angles (deg), or an explicit `rotation` vector.
// Returns [yaw, pitch, roll] vector or undef.
function rotationv(
  pitch = undef,
  yaw = undef,
  roll = undef,
  rotation = undef
) =
  is_undef(rotation) ? [val(yaw, 0), val(pitch, 0), val(roll, 0)]
  : (is_undef(pitch) && is_undef(yaw) && is_undef(roll)) ? rotation
  : undef;

// --- Main API ---------------------------------------------------------------

// trajectory(...) → build a 6D twist vector = [tx,ty,tz, yaw,pitch,roll]
function trajectory(
  left = undef,
  right = undef,
  up = undef,
  down = undef,
  forward = undef,
  backward = undef,
  translation = undef,
  pitch = undef,
  yaw = undef,
  roll = undef,
  rotation = undef
) =
  concat(
    translationv(
      left=left, right=right, up=up, down=down,
      forward=forward, backward=backward,
      translation=translation
    ),
    rotationv(pitch=pitch, yaw=yaw, roll=roll, rotation=rotation)
  );

// rotationm(...) → build 3x3 rotation matrix from angles
function rotationm(rotation = undef, pitch = undef, yaw = undef, roll = undef) =
  so3_exp(rotationv(rotation=rotation, pitch=pitch, yaw=yaw, roll=roll));
