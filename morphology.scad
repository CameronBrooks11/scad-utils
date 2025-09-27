// ============================================================================
// Morphology Utilities (2D)
// ----------------------------------------------------------------------------
// Provides basic 2D morphological operations:
// - outset(d=1): offset polygon outward
// - inset(d=1): offset polygon inward
// - fillet(r=1): fillet concave corners
// - rounding(r=1): round convex corners
// - shell(d, center=false): create a band (shell) around a polygon
//
// Notes:
// - Works around version-specific issues with minkowski/projection
// - Internal `_inverse()` helper used for inset/boolean operations
// ============================================================================

// --- Outset / Inset ---------------------------------------------------------

// Outset: grows a shape outward by distance d
module outset(d = 1) {
  // Bug workaround for older OpenSCAD versions
  if (version_num() < 20130424)
    render() outset_extruded(d) children();
  else
    minkowski() {
      circle(r=d);
      children();
    }
}

// Helper for older OpenSCAD: emulate outset by extrusion + projection
module outset_extruded(d = 1) {
  projection(cut=true)
    minkowski() {
      cylinder(r=d);
      linear_extrude(center=true) children();
    }
}

// Inset: shrinks a shape inward by distance d
module inset(d = 1) {
  render() _inverse() outset(d=d) _inverse() children();
}

// --- Corner Modifiers -------------------------------------------------------

// Fillet: adds arcs of radius r to concave corners
module fillet(r = 1) {
  inset(d=r) render() outset(d=r) children();
}

// Rounding: rounds convex corners with arcs of radius r
module rounding(r = 1) {
  outset(d=r) inset(d=r) children();
}

// --- Shells ----------------------------------------------------------------

// Shell: creates a band of width d around the polygon edge
// - d > 0, center=false: shell on the outside
// - d < 0, center=false: shell on the inside
// - center=true: shell straddles the edge
module shell(d, center = false) {
  if (center && d > 0) {
    difference() {
      outset(d=d / 2) children();
      inset(d=d / 2) children();
    }
  }
  if (!center && d > 0) {
    difference() {
      outset(d=d) children();
      children();
    }
  }
  if (!center && d < 0) {
    difference() {
      children();
      inset(d=-d) children();
    }
  }
  if (d == 0) children();
}

// --- Internal Helpers -------------------------------------------------------

// Inverse: covers the plane and subtracts children (used in inset)
module _inverse() {
  difference() {
    square(1e5, center=true);
    children();
  }
}
