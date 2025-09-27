// ============================================================================
// Mirror Utilities
// ----------------------------------------------------------------------------
// Provides simple mirroring modules around the X, Y, and Z axes.
// Each module duplicates its children and adds a mirrored copy.
// Optional: pass `col="colorname"` to tint the mirrored copy.
// - mirror_x([col]): mirror across the YZ-plane (flip X)
// - mirror_y([col]): mirror across the XZ-plane (flip Y)
// - mirror_z([col]): mirror across the XY-plane (flip Z)
// ============================================================================

// --- Mirror across X-axis ---------------------------------------------------
module mirror_x(col = undef) {
  union() {
    children();
    if (is_undef(col))
      scale([-1, 1, 1]) children();
    else
      color(col) scale([-1, 1, 1]) children();
  }
}

// --- Mirror across Y-axis ---------------------------------------------------
module mirror_y(col = undef) {
  union() {
    children();
    if (is_undef(col))
      scale([1, -1, 1]) children();
    else
      color(col) scale([1, -1, 1]) children();
  }
}

// --- Mirror across Z-axis ---------------------------------------------------
module mirror_z(col = undef) {
  union() {
    children();
    if (is_undef(col))
      scale([1, 1, -1]) children();
    else
      color(col) scale([1, 1, -1]) children();
  }
}
