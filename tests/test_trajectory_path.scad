include <../trajectory_path.scad>
include <../linalg.scad>
include <../se3.scad>

$fn = 24;

// Simple frame visualizer ----------------------------------------------------
module frame(T, s = 2) {
  multmatrix(T) {
    color("red") cube([s, .2, .2], center=false);
    color("green") cube([.2, s, .2], center=false);
    color("blue") cube([.2, .2, s], center=false);
    color("gray") translate([0, 0, 0]) sphere(r=.4);
  }
}

// Example trajectories (6D twists) ------------------------------------------
// Move +X 60, slight +Z arc; then yaw+translate; then small upward arc.
traj = [
  [60, 0, 0, 0, 0, 30], // translate 60 along X while yawing 30°
  [20, 0, 0, 0, 0, -45], // short turn back
  [0, 0, 30, 0, 90, 0], // arc up in pitch
  [0, 0, 20, 0, 0, 0], // short straight up (relative forward to base frame)
];

// --- Sampling with a physical step (units of translation norm) -------------
poses_step = quantize_trajectories(traj, step=5, start_position=0, loop=false);

// --- Sampling with a fixed number of steps across whole path ----------------
poses_steps = quantize_trajectories(traj, steps=30, start_position=0, loop=false);

// --- Looping path (returns to start) ---------------------------------------
poses_loop = quantize_trajectories(traj, step=5, loop=true);

// Render --------------------------------------------------------------------
translate([0, -70, 0]) {
  // By fixed step length
  for (T = poses_step) frame(T, s=3);
  echo("poses_step count =", len(poses_step));
}

translate([0, 0, 0]) {
  // By fixed number of steps
  for (T = poses_steps) frame(T, s=3);
  echo("poses_steps count =", len(poses_steps));
}

translate([0, 70, 0]) {
  // Looping variant
  for (T = poses_loop) frame(T, s=3);
  echo("poses_loop count =", len(poses_loop));
}

// Show overall end pose to verify loop closure visually
echo("End pose (open)  =", trajectories_end_position(traj));
echo("End pose (loop)  =", trajectories_end_position(close_trajectory_loop(traj)));
