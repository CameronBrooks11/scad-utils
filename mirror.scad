// ============================================================================
// Mirror Utilities
// ----------------------------------------------------------------------------
// Provides simple mirroring modules around the X, Y, and Z axes.
// Each module duplicates its children and adds a mirrored copy.
// - mirror_x(): mirror across the YZ-plane (flip X)
// - mirror_y(): mirror across the XZ-plane (flip Y)
// - mirror_z(): mirror across the XY-plane (flip Z)
// ============================================================================

// --- Mirror across X-axis ---------------------------------------------------
module mirror_x() {
  union() {
    children();
    scale([-1, 1, 1]) children();
  }
}

// --- Mirror across Y-axis ---------------------------------------------------
module mirror_y() {
  union() {
    children();
    scale([1, -1, 1]) children();
  }
}

// --- Mirror across Z-axis ---------------------------------------------------
module mirror_z() {
  union() {
    children();
    scale([1, 1, -1]) children();
  }
}
