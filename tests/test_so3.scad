use <../so3.scad>

// --- Unit Test for SO(3) ---------------------------------------------------
// Verify so3_ln(so3_exp(w)) ≈ w

w_test = [12, -125, 110];
result = so3_ln(so3_exp(w_test));

echo("w_test =", w_test);
echo("so3_ln(so3_exp(w_test)) =", result);
echo("Error norm =", norm(w_test - result));
echo("PASS =", norm(w_test - result) < 1e-8);
