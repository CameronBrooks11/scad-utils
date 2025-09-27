// ============================================================================
// Trajectory Path Utilities
// ----------------------------------------------------------------------------
// Purpose : Quantize SE(3) “twists” (6D vectors) into discrete transforms,
//           compose segments, and optionally close loops.
// Key ideas
//   - A single trajectory is a 6D vector mu = [tx,ty,tz, wx,wy,wz] (angles in deg)
//     interpreted via se3_exp(mu) -> 4x4 homogeneous transform.
//   - A list of trajectories is concatenated piecewise in the given order.
//   - Quantization can be specified either by:
//       * step:   physical step length along translation part, OR
//       * steps:  fixed number of samples for the *entire* path
//   - start_position allows skipping an initial arc-length offset.
// ----------------------------------------------------------------------------
// Dependencies: linalg.scad, se3.scad
// ============================================================================

use <linalg.scad>
use <se3.scad>

// --- Small helpers ----------------------------------------------------------

// Left-multiply a single transform `a` by each transform in array `bs`.
function left_multiply(a, bs, i_ = 0) =
  (i_ >= len(bs)) ? []
  : concat([a * bs[i_]], left_multiply(a, bs, i_ + 1));

// Right-multiply each transform in array `as` by a single transform `b`.
function right_multiply(as, b, i_ = 0) =
  (i_ >= len(as)) ? []
  : concat([as[i_] * b], right_multiply(as, b, i_ + 1));

// --- Single-trajectory quantization ----------------------------------------
// quantize_trajectory: produces an array of 4x4 transforms sampled along one 6D twist.
// If `steps` is provided, it overrides `step` and distributes uniformly.
// If `step` is provided, samples start at `start_position` and advance by `step`.
// `start_position` and `step` are in the units of the translation norm.
//
// Notes:
//   - Length is computed from the translational part only: norm(take3(trajectory))
//   - For steps==1, returns the transform at the path end (t=1).
function quantize_trajectory(
  trajectory,
  step = undef,
  start_position = 0,
  steps = undef,
  i_ = 0,
  length_ = undef
) =
  // Bootstrap total length if not provided
  is_undef(length_) ?
    quantize_trajectory(
      trajectory=trajectory,
      start_position=is_undef(step) ? (norm(take3(trajectory)) / steps) * start_position
      : start_position,
      length_=norm(take3(trajectory)),
      step=step,
      steps=steps,
      i_=i_
    )
    // Termination: either finished by count, or past end by distance
  : (
    is_undef(steps) ? (start_position > length_)
    : (i_ >= steps)
  ) ? []
    // Emit current sample and recurse
  : concat(
    [
      se3_exp(
        trajectory * (
          is_undef(steps) ? start_position / length_
          : i_ / (steps > 1 ? (steps - 1) : 1)
        )
      ),
    ],
    quantize_trajectory(
      trajectory=trajectory,
      step=step,
      start_position=is_undef(steps) ? (start_position + step) : start_position,
      steps=steps,
      i_=i_ + 1,
      length_=length_
    )
  );

// --- Multi-trajectory helpers ----------------------------------------------

// Append a final segment that closes the loop back to identity when applied
// after the whole chain (computed in SE(3) log space).
function close_trajectory_loop(trajectories) =
  concat(
    trajectories,
    [se3_ln(invert_rt(trajectories_end_position(trajectories)))]
  );

// Total translational arc-length of a list of 6D twists.
function trajectories_length(trajectories, i_ = 0) =
  (i_ >= len(trajectories)) ? 0
  : norm(take3(trajectories[i_])) + trajectories_length(trajectories, i_ + 1);

// End pose after chaining all twists (via se3_exp and left-to-right product).
function trajectories_end_position(rt, i_ = 0, last_ = identity4()) =
  (i_ >= len(rt)) ? last_
  : trajectories_end_position(rt, i_ + 1, last_ * se3_exp(rt[i_]));

// --- Multi-trajectory quantization -----------------------------------------
// Quantize a *list* of twists into an array of transforms along the whole path.
// Parameters mirror quantize_trajectory; additionally:
//  - loop=true closes the path with an extra segment that returns to start
// Behavior:
//  - If `steps` is given, we derive a uniform `step` for the *whole* path.
//  - Returns an array of transforms (absolute poses), starting from identity.
function quantize_trajectories(
  trajectories,
  step = undef,
  start_position = 0,
  steps = undef,
  loop = false,
  last_ = identity4(),
  i_ = 0,
  current_length_ = undef,
  j_ = 0
) =
  // Optionally close the loop by appending a final corrective twist
  loop ?
    quantize_trajectories(
      trajectories=close_trajectory_loop(trajectories),
      step=step,
      start_position=start_position,
      steps=steps,
      loop=false,
      last_=last_,
      i_=i_,
      current_length_=current_length_,
      j_=j_
    )
    // End when all segments consumed. If steps was given but rounding skipped
    // the final sample, return the last pose once more.
  : (i_ >= len(trajectories)) ? ( (!is_undef(steps) && (j_ < steps)) ? [last_] : [])
    // Initialize global step/offset once we know total length
  : is_undef(current_length_) ?
    quantize_trajectories(
      trajectories=trajectories,
      step=is_undef(step) ? (trajectories_length(trajectories) / steps) : step,
      start_position=is_undef(step) ? (start_position * trajectories_length(trajectories) / steps)
      : start_position,
      steps=steps,
      loop=loop,
      last_=last_,
      i_=i_,
      current_length_=norm(take3(trajectories[i_])),
      j_=j_
    )
    // Emit samples for current segment (absolute poses), then continue
  : concat(
    // Sample the i_-th local twist, then left-multiply by `last_` to get
    // absolute poses for this segment.
    left_multiply(
      last_,
      quantize_trajectory(
        trajectory=trajectories[i_],
        start_position=start_position,
        step=step
      )
    ),
    // Recurse to next segment:
    quantize_trajectories(
      trajectories=trajectories,
      step=step,
      // Advance start_position into the next segment:
      start_position=(start_position > current_length_) ? (start_position - current_length_)
      : (step - ( (current_length_ - start_position) % step)),
      steps=steps,
      loop=loop,
      last_=last_ * se3_exp(trajectories[i_]),
      i_=i_ + 1,
      current_length_=undef,
      j_=j_ + len(
        quantize_trajectory(
          trajectory=trajectories[i_],
          start_position=start_position,
          step=step
        )
      )
    )
  );
