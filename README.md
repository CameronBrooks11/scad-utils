# scad-utils

Utility libraries for OpenSCAD.  
This collection provides reusable math, geometry, and transformation tools for parametric modeling.  
All modules are documented, consistently structured, and tested via dedicated `.scad` test files.

---

## Modules

### `hull.scad`: Convex Hull Utilities (2D and 3D)

Computes convex hulls for 2D or 3D point sets with special handling for collinear cases.

**Functions:**

- `hull(points)` - Main entry point, automatically detects 2D/3D and handles edge cases
- Returns polygon vertex indices `[i1, i2, i3, ...]` for 2D
- Returns triangular face indices `[[i1,i2,i3], [i2,i3,i4], ...]` for 3D
- Returns two extreme endpoints `[i_min, i_max]` for collinear points

**Features:**

- Uses optimized algorithms with incremental construction
- Handles degenerate cases (collinear, coplanar points)
- Includes utility functions for spherical/cartesian conversions
- Compatible with both clockwise and counter-clockwise orientations

### `linalg.scad`: Linear Algebra Utilities

Essential vector and matrix operations for 3D transformations.

**Vector Functions:**

- `vec3(p)` - Ensure vector is 3D (pads with 0)
- `vec4(p)` - Ensure vector is 4D homogeneous (pads with 1)
- `unit(v)` - Normalize vector to unit length
- `take3(v)` - Extract first 3 elements
- `tail3(v)` - Extract elements 3,4,5 (for 6-vectors)

**Matrix Functions:**

- `identity3()`, `identity4()` - Identity matrices
- `transpose_3(m)`, `transpose_4(m)` - Matrix transpose
- `rotation_part(m)`, `translation_part(m)` - Extract parts from 4×4 transform
- `rot_trace(m)`, `rot_cos_angle(m)` - Rotation analysis
- `invert_rt(m)` - Invert rigid transform (rotation + translation)
- `construct_Rt(R, t)` - Build 4×4 transform from 3×3 rotation and translation
- `hadamard(a, b)` - Element-wise multiplication (works recursively)

### `lists.scad`: List Manipulation Utilities

Functional programming helpers for array operations.

**Functions:**

- `flatten(list)` - Flatten nested arrays one level: `[[0,1],[2,3]] → [0,1,2,3]`
- `range(r)` - Convert range to list: `[0:2:6] → [0,2,4,6]`
- `reverse(list)` - Reverse element order: `[1,2,3] → [3,2,1]`
- `subarray(list, begin, end)` - Extract slice (end=-1 means full length)
- `set(list, i, x)` - Return copy with element at index i replaced by x
- `remove(list, i)` - Return copy with element at index i removed

### `mirror.scad`: Axis Mirroring Modules

Simple mirroring operations that duplicate and reflect geometry.

**Modules:**

- `mirror_x([col])` - Mirror across YZ-plane (flip X coordinate)
- `mirror_y([col])` - Mirror across XZ-plane (flip Y coordinate)
- `mirror_z([col])` - Mirror across XY-plane (flip Z coordinate)

**Parameters:**

- `col` - Optional color name to tint the mirrored copy (e.g., "red", "teal")

Each module creates a union of the original children plus the mirrored copy.

### `morphology.scad`: 2D Morphology Operations

Advanced 2D shape modification operations for polygon processing.

**Core Operations:**

- `outset(d=1)` - Grow shape outward by distance d (Minkowski sum with circle)
- `inset(d=1)` - Shrink shape inward by distance d (inverse of outset)
- `fillet(r=1)` - Add rounded fillets to concave (inward) corners
- `rounding(r=1)` - Round convex (outward) corners
- `shell(d, center=false)` - Create shell/band around shape edge

**Shell Parameters:**

- `d > 0, center=false`: shell extends outward
- `d < 0, center=false`: shell extends inward
- `center=true`: shell straddles the original edge

**Compatibility:**

- Works around OpenSCAD version differences in Minkowski operations
- Uses `render()` and `projection()` fallbacks for older versions

### `se3.scad`: SE(3) Lie Group Utilities

Exponential and logarithm maps for rigid body transformations (translation + rotation).

**Functions:**

- `se3_exp(mu)` - Convert 6D twist vector `[tx,ty,tz, rx,ry,rz]` to 4×4 transform matrix
- `se3_ln(m)` - Convert 4×4 transform matrix back to 6D twist vector

**Features:**

- Handles small-angle approximations with Taylor series (1st, 2nd, 3rd order)
- Rotation angles specified in degrees (converted internally)
- Combines SO(3) rotations with translation using proper Lie algebra
- Numerical stability for near-identity transforms

**Dependencies:** `linalg.scad`, `so3.scad`

### `shapes.scad`: 2D Shape Generators

Parametric generators for common 2D shapes returned as point arrays.

**Functions:**

- `square(size)` - Centered square with edge length `size`
- `circle(r)` - Circle with radius `r` (uses global `$fn` for resolution)
- `regular(r, n)` - Regular n-sided polygon with circumradius `r`
- `rectangle_profile(size=[w,h])` - Rectangle with anchor at `[w/2, 0]`

**Output:** All functions return arrays of 2D points suitable for `polygon()`.

### `so3.scad`: SO(3) Lie Group Utilities

Exponential and logarithm maps for 3D rotations using Rodrigues formula.

**Functions:**

- `so3_exp(w)` - Convert axis-angle vector (degrees) to 3×3 rotation matrix
- `so3_ln(m)` - Convert 3×3 rotation matrix back to axis-angle vector (degrees)
- `so3_exp_rad(w)`, `so3_ln_rad(m)` - Radian versions for internal use

**Features:**

- Taylor expansions for small angles (1st, 2nd, 3rd order approximations)
- Handles near-π rotations with symmetric matrix decomposition
- Rodrigues formula implementation: `R = I + sin(θ)K + (1-cos(θ))K²`
- Numerical stability across full rotation range

**Dependencies:** `linalg.scad`

### `spline.scad`: Cubic Spline and Bezier Utilities

Comprehensive curve generation and evaluation with Frenet frame support.

**Spline Functions:**

- `spline_args(points, closed=false, v1=undef, v2=undef)` - Generate spline coefficients
- `spline(s, t)` - Evaluate position at parameter t
- `spline_tan(s, t)` - Evaluate tangent vector
- `spline_tan_unit(s, t)` - Unit tangent vector
- `spline_d2(s, t)` - Second derivative (curvature)
- `spline_normal_unit(s, t)`, `spline_binormal_unit(s, t)` - Frenet frame vectors
- `spline_transform(s, t)` - SE(3) transform aligned to curve

**Bezier Functions:**

- `bezier3_args(points, symmetric=false)` - Generate cubic Bezier coefficients

**Features:**

- Supports open and closed splines with customizable end conditions
- Frenet frame calculations for swept surfaces and path following
- Matrix-based coefficient computation with automatic boundary conditions
- Parameter t scales with curve segments (t=0..1 first segment, t=1..2 second, etc.)

**Dependencies:** `linalg.scad`, `lists.scad`

### `trajectory.scad`: SE(3) Twist Vector Construction

Intuitive interface for building 6D motion vectors from directional parameters.

**Functions:**

- `trajectory(left/right, up/down, forward/backward, translation, pitch, yaw, roll, rotation)`
- `rotationv(pitch, yaw, roll, rotation)` - Build rotation component
- `translationv(...)` - Build translation component
- `rotationm(...)` - Convert angles to 3×3 rotation matrix

**Direction Parameters:**

- Translation: `left/right`, `up/down`, `forward/backward` OR explicit `translation=[x,y,z]`
- Rotation: `pitch`, `yaw`, `roll` (degrees) OR explicit `rotation=[rx,ry,rz]`

**Output:** Returns `[tx,ty,tz, yaw,pitch,roll]` 6D twist vector suitable for `se3_exp()`

**Dependencies:** `so3.scad`

### `trajectory_path.scad`: Multi-Segment Path Quantization

Convert trajectory sequences into discrete transformation samples.

**Functions:**

- `quantize_trajectory(trajectory, step/steps, start_position)` - Sample single 6D twist
- `quantize_trajectories(trajectories, step/steps, start_position, loop)` - Sample path sequence
- `close_trajectory_loop(trajectories)` - Add segment to close loop
- `trajectories_length(trajectories)` - Compute total path length
- `trajectories_end_position(trajectories)` - Final accumulated transform

**Parameters:**

- `step`: Physical step length (units of translation norm)
- `steps`: Fixed number of uniform samples across entire path
- `start_position`: Arc-length offset for starting point
- `loop=true`: Automatically close path back to start

**Output:** Arrays of 4×4 transformation matrices for each sample point

**Dependencies:** `linalg.scad`, `se3.scad`

### `transformations.scad`: Geometric Transformation Matrices

High-level constructors for common 3D transformations.

**Matrix Constructors:**

- `rotation(xyz=[rx,ry,rz])` - Euler angles (Rz·Ry·Rx order)
- `rotation(axis=[x,y,z])` - Axis-angle rotation
- `scaling([sx,sy,sz])` - Non-uniform scaling
- `translation([tx,ty,tz])` - Translation matrix

**Utility Functions:**

- `project(x)` - Convert homogeneous to Cartesian coordinates
- `transform(m, points)` - Apply matrix to point list
- `to_3d(points)` - Ensure points are 3D vectors

**Usage:** Matrices can be multiplied for composition: `T * R * S` applies scaling, then rotation, then translation.

**Dependencies:** `se3.scad`, `linalg.scad`, `lists.scad`

## Examples

### Morphology Operations

With a basic sample polygon shape,

```scad
module shape() {
    polygon([[0,0],[1,0],[1.5,1],[2.5,1],[2,-1],[0,-1]]);
}
$fn = 32;
```

- `inset(d=0.3) shape();`

![Inset Morphology Example](http://oskarlinde.github.io/scad-utils/img/morph-0.png)

- `outset(d=0.3) shape();`

![Outset Morphology Example](http://oskarlinde.github.io/scad-utils/img/morph-1.png)

- `rounding(r=0.3) shape();`

![Rounding Morphology Example](http://oskarlinde.github.io/scad-utils/img/morph-2.png)

- `fillet(r=0.3) shape();`

![Fillet Morphology Example](http://oskarlinde.github.io/scad-utils/img/morph-3.png)

- `shell(d=0.3) shape();`

![Shell Morphology Example Positive](http://oskarlinde.github.io/scad-utils/img/morph-4.png)

- `shell(d=-0.3) shape();`

![Shell Morphology Example Negative](http://oskarlinde.github.io/scad-utils/img/morph-5.png)

- `shell(d=0.3,center=true) shape();`

![Shell Morphology Example Centered](http://oskarlinde.github.io/scad-utils/img/morph-6.png)

### Mirror Operations

```scad
module arrow(l=1, w=0.6, t=0.15) {
  mirror_y("orange")
    polygon([[0,0], [l,0], [l-w/2,w/2],
             [l-w/2-sqrt(2)*t,w/2],
             [l-t/2-sqrt(2)*t,t/2], [0,t/2]]);
}

arrow(l=20, w=10, t=2);
```

### Convex Hull

```scad
use <hull.scad>

points_3d = [[0,0,0], [10,0,0], [5,10,0], [0,0,10]];
faces = hull(points_3d);
polyhedron(points=points_3d, faces=faces);
```

### Spline Curves

```scad
use <spline.scad>

points = [[0,0,0], [10,5,0], [20,0,5], [30,10,0]];
spline_data = spline_args(points, closed=true);

for (t = [0:0.1:len(spline_data)])
  translate(spline(spline_data, t))
    sphere(r=0.5);
```

### SE(3) Transformations

```scad
use <se3.scad>
use <trajectory.scad>

// Define a 6D twist: translate [10,0,5] + rotate 45° about Z
twist = trajectory(forward=10, up=5, yaw=45);
transform_matrix = se3_exp(twist);

multmatrix(transform_matrix)
  cube([2,2,2]);
```

### Multi-Segment Paths

```scad
use <trajectory_path.scad>

// Define path segments
path = [
  [20, 0, 0, 0, 0, 30],    // forward + yaw
  [0, 15, 0, 0, 45, 0],    // right + pitch
  [0, 0, 10, 0, 0, -60]    // up + yaw back
];

// Sample every 5 units
poses = quantize_trajectories(path, step=5);

for (T = poses)
  multmatrix(T)
    cube([1,1,1]);
```

## `tests/` Directory

Each module includes comprehensive test files in the `tests/` directory:

**Test Coverage:**

- **Regression Tests:** Echo-based validation of mathematical properties (e.g., `so3_ln(so3_exp(w)) ≈ w`)
- **Visual Tests:** Geometric demonstrations with color-coded results
- **Edge Cases:** Boundary conditions, degenerate inputs, numerical stability
- **Integration Tests:** Multi-module workflows (splines with SE(3), trajectory chains)

**Running Tests:** Load test files directly in OpenSCAD to see both console output and visual results.
