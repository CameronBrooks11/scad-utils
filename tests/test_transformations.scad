include <../transformations.scad>

$fn = 24;

// ============================================================================
// Test Suite for transformations.scad
// ----------------------------------------------------------------------------
// Covers:
// - rotation (Euler and axis-angle)
// - scaling
// - translation
// - project / transform / to_3d
// ============================================================================

// --- Sample Shape -----------------------------------------------------------
points = [[0, 0, 0], [10, 0, 0], [10, 10, 0], [0, 10, 0]];

// --- Rotation Tests ---------------------------------------------------------
Rz45 = rotation(axis=[0, 0, 45]);
echo("Rotation Z45 applied =", transform(Rz45, points));

Rx90 = rotation(xyz=[90, 0, 0]);
echo("Rotation X90 applied =", transform(Rx90, [[0, 0, 1]]));

// --- Scaling Tests ----------------------------------------------------------
S = scaling([2, 1, 1]);
echo("Scaling [2,1,1] =", transform(S, points));

// --- Translation Tests ------------------------------------------------------
T = translation([5, 5, 0]);
echo("Translation [5,5,0] =", transform(T, points));

// --- Combined Transform -----------------------------------------------------
M = T * Rz45 * S;
echo("Combined TRS =", transform(M, points));

// --- Project / to_3d Tests --------------------------------------------------
p_h = [3, 4, 5, 1];
echo("Project [3,4,5,1] =", project(p_h));
echo("to_3d([ [1,2], [3,4,5] ]) =", to_3d([[1, 2], [3, 4, 5]]));
