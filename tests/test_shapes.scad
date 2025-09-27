include <../shapes.scad>

$fn = 16;

echo("square(2) =", square(2));
echo("circle(r=5) =", circle(5));
echo("regular(r=5, n=6) =", regular(5, 6));
echo("rectangle_profile([4,2]) =", rectangle_profile([4, 2]));

// Quick visualization
translate([-15, 0, 0]) polygon(square(10));
translate([0, 0, 0]) polygon(circle(5));
translate([15, 0, 0]) polygon(regular(5, 6));
translate([30, 0, 0]) polygon(rectangle_profile([8, 4]));
