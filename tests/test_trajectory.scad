include <../trajectory.scad>
include <../so3.scad>

$fn = 24;

// --- Regression / Echo Tests ------------------------------------------------
echo("Forward 10 =", trajectory(forward=10)); // expect [0,0,10, 0,0,0]
echo("Up 5, Left 3 =", trajectory(up=5, left=3)); // expect [-3,5,0, 0,0,0]
echo("Yaw 45 =", rotationv(yaw=45)); // expect [45,0,0]
echo("Pitch 90 matrix =", rotationm(pitch=90));

// Combined twist
twist1 = trajectory(forward=20, yaw=45);
echo("Combined twist =", twist1);

// --- Visual Demonstrations --------------------------------------------------

// Helper: apply trajectory to a cube
module demo_traj(traj, col = "lightblue") {
  T = concat(take3(traj), [0]); // translation
  R = rotationm(rotation=tail3(traj));
  multmatrix(
    [
      [R[0][0], R[0][1], R[0][2], T[0]],
      [R[1][0], R[1][1], R[1][2], T[1]],
      [R[2][0], R[2][1], R[2][2], T[2]],
      [0, 0, 0, 1],
    ]
  )
    color(col) cube([5, 5, 5], center=true);
}

// Show original then two trajectory examples side by side
translate([0, 0, 0]) demo_traj(trajectory(up=0), "lightblue");
translate([-20, 0, 0]) demo_traj(trajectory(right=10, up=5, yaw=30), "red");
translate([20, 0, 0]) demo_traj(trajectory(translation=[5, 5, 5], rotation=[0, 90, 0]), "green");
