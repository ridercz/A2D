/****************************************************************************
 * Square Grill Sample - sample for A2D OpenSCAD Library                    *
 * Copyright (c) Michal A. Valasek, 2020                                    *
 * www.rider.cz * www.altair.blog * github.com/ridercz/A2D                  *
 * ------------------------------------------------------------------------ *
 * This sample creates a simple door vent grill.                            *
 ****************************************************************************/

// Include A2D library and check for minimum required version
include <../A2D.scad>;
assert(a2d_required([1, 5, 0]), "Please upgrade A2D library to version 1.5.0 or higher.");

/* [Base plate] */
base_size = [150, 50];
height = 2;
corner_radius = 3;
screw_diameter = 4;

/* [Grill] */
padding = [10, 10];
size = [5, 5];
spacing = [3, 3];

/* [Hidden] */
grill_size = [for(i = [0, 1]) base_size[i] - 2 * padding[i]];

// Render model

linear_extrude(height) difference() {
    // Base plate
    r_square(base_size, corner_radius);

    // Screw holes
    screw_hole_points = [for(i = [0, 1]) base_size[i] - padding[i]];
    screw_hole_pos = translate_points(square_points(screw_hole_points), [padding[0] / 2, padding[1] / 2]);
    for(pos = screw_hole_pos) translate(pos) circle(d = screw_diameter, $fn = 16);

    // Grill
    translate(padding) grill_mask_square_auto(grill_size, size, spacing);
}