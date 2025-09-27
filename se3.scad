// ============================================================================
// SE(3) Utilities (Rigid Body Transformations in 3D)
// ----------------------------------------------------------------------------
// Provides exponential and logarithm maps for SE(3) using so3 + translation.
// - se3_exp(mu): exponential map of 6-vector [t, w] (t=translation, w=rotation)
// - se3_ln(m): logarithm map from 4x4 rigid transform matrix to 6-vector
// ----------------------------------------------------------------------------
// Dependencies:
//   - linalg.scad  (matrix utilities)
//   - so3.scad     (SO(3) exponential/logarithm maps)
// ============================================================================

use <linalg.scad>
use <so3.scad>

// --- Core Helpers -----------------------------------------------------------

// Combine rotation (Rodrigues) with translated ABt components
function combine_se3_exp(w, ABt) =
  construct_Rt(
    rodrigues_so3_exp(w, ABt[0], ABt[1]),
    ABt[2]
  );

// --- Exponential Map (Taylor Approximations) --------------------------------

// Small-angle approx (1st order)
function se3_exp_1(t, w) =
  concat(
    so3_exp_1(w * w),
    [t + 0.5 * cross(w, t)]
  );

// 2nd order Taylor expansion
function se3_exp_2(t, w) = se3_exp_2_0(t, w, w * w);

function se3_exp_2_0(t, w, theta_sq) =
  se3_exp_23(
    so3_exp_2(theta_sq),
    C=(1.0 - theta_sq / 20) / 6,
    t=t,
    w=w
  );

// 3rd order approximation
function se3_exp_3(t, w) =
  se3_exp_3_0(
    t, w,
    theta_deg=sqrt(w * w) * 180 / PI,
    inv_theta=1 / sqrt(w * w)
  );

function se3_exp_3_0(t, w, theta_deg, inv_theta) =
  se3_exp_23(
    so3_exp_3_0(theta_deg=theta_deg, inv_theta=inv_theta),
    C=(1 - sin(theta_deg) * inv_theta) * (inv_theta * inv_theta),
    t=t,
    w=w
  );

// Shared expansion for orders 2–3
function se3_exp_23(AB, C, t, w) =
  [AB[0], AB[1], t + AB[1] * cross(w, t) + C * cross(w, cross(w, t))];

// --- Exponential Map Wrapper ------------------------------------------------

// se3_exp: exponential map from 6-vector μ = [t, w]
// Converts w from degrees to radians internally
function se3_exp(mu) =
  se3_exp_0(
    t=take3(mu),
    w=tail3(mu) / 180 * PI
  );

function se3_exp_0(t, w) =
  combine_se3_exp(
    w,
    (w * w < 1e-8) ? se3_exp_1(t, w)
    : (w * w < 1e-6) ? se3_exp_2(t, w)
    : se3_exp_3(t, w)
  );

// --- Logarithm Map ----------------------------------------------------------

// Logarithm: returns [t, w] in degrees
function se3_ln(m) = se3_ln_to_deg(se3_ln_rad(m));

function se3_ln_to_deg(v) = concat(take3(v), tail3(v) * 180 / PI);

// Internal: logarithm in radians
function se3_ln_rad(m) =
  se3_ln_0(
    m,
    rot=so3_ln_rad(rotation_part(m))
  );

function se3_ln_0(m, rot) =
  se3_ln_1(
    m, rot,
    theta=sqrt(rot * rot)
  );

function se3_ln_1(m, rot, theta) =
  se3_ln_2(
    m, rot, theta,
    shtot=(theta > 1e-5) ? sin(theta / 2 * 180 / PI) / theta : 0.5,
    halfrotator=so3_exp_rad(rot * -0.5)
  );

function se3_ln_2(m, rot, theta, shtot, halfrotator) =
  concat(
    (
      halfrotator * translation_part(m) - (
        (theta > 1e-3) ?
          rot * ( (translation_part(m) * rot) * (1 - 2 * shtot) / (rot * rot))
        : rot * ( (translation_part(m) * rot) / 24)
      )
    ) / (2 * shtot),
    rot
  );
