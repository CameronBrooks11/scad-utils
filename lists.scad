// ============================================================================
// List Utilities
// ----------------------------------------------------------------------------
// Provides small helper functions for working with lists:
// - Flattening
// - Ranges
// - Reversals and subarrays
// - Element updates and removals
// ============================================================================

// --- Flatten ---------------------------------------------------------------
// Flatten a list one level.
// Example: flatten([[0,1],[2,3]]) => [0,1,2,3]
function flatten(list) = [for (sub = list, v = sub) v];

// --- Range -----------------------------------------------------------------
// Create a list from a range.
// Example: range([0:2:6]) => [0,2,4,6]
function range(r) = [for (x = r) x];

// --- Reverse ---------------------------------------------------------------
// Reverse the order of elements.
// Example: reverse([1,2,3]) => [3,2,1]
function reverse(list) =
  [for (i = [len(list) - 1:-1:0]) list[i]];

// --- Subarray --------------------------------------------------------------
// Extract a subarray from index `begin` (inclusive) to `end` (exclusive).
// Notes:
//   - If `end < 0`, uses `len(list)`.
//   - FIXME: Consider renaming to `sublist` for clarity.
// Example: subarray([1,2,3,4], 1, 3) => [2,3]
function subarray(list, begin = 0, end = -1) =
  let (end = (end < 0) ? len(list) : end) [for (i = [begin:end - 1]) list[i]];

// --- Set -------------------------------------------------------------------
// Return a copy of a list with the element at index `i` replaced by `x`.
// Example: set([1,2,3,4], 2, 5) => [1,2,5,4]
function set(list, i, x) =
  [for (j = [0:1:len(list) - 1]) (i == j) ? x : list[j]];

// --- Remove ---------------------------------------------------------------
// Remove the element at index `i`.
// Example: remove([4,3,2,1], 1) => [4,2,1]
function remove(list, i) =
  [for (j = [0:1:len(list) - 2]) list[ (j < i) ? j : j + 1]];
