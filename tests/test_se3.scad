use <../se3.scad>

// --- Unit Test for SE(3) ---------------------------------------------------
// Verify se3_ln(se3_exp(mu)) ≈ mu

mu_test = [20, -40, 60, -80, 100, -120];
result = se3_ln(se3_exp(mu_test));

echo("mu_test =", mu_test);
echo("se3_ln(se3_exp(mu_test)) =", result);
echo("Error norm =", norm(mu_test - result));
echo("PASS =", norm(mu_test - result) < 1e-8);
