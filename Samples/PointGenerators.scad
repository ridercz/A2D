// Simple lid with a corner holes

include <../A2D.scad>

size = [60, 40];
corner_radius = 6;
hole_diameter = 3;
height = 2;

linear_extrude(height) difference() {
    // Main shape
    r_square(size, corner_radius, center = true, $fn = 32);

    // Corner holes
    hole_pos = square_points([size[0] - 2 * corner_radius, size[1] - 2 * corner_radius], center = true);
    for(pos = hole_pos) translate(pos) circle(d = hole_diameter, $fn = 16);
}
