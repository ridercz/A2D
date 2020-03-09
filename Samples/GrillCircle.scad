/****************************************************************************
 * Fan Grill Sample - sample for A2D OpenSCAD Library                       *
 * Copyright (c) Michal A. Valasek, 2020                                    *
 * www.rider.cz * www.altair.blog * github.com/ridercz/A2D                  *
 * ------------------------------------------------------------------------ *
 * This sample creates a simple parametric fan grill. The default values    *
 * are for a standard 80 mm fan.                                            *
 ****************************************************************************/

// Include A2D library and check for minimum required version
include <../A2D.scad>;
assert(a2d_required([1, 5, 0]), "Please upgrade A2D library to version 1.5.0 or higher.");

/* [Fan parameters] */
outer_size = 80;
screw_span = 71.5;
screw_diameter = 4;
corner_radius = 3;

/* [Grill options] */
height = 2;
sides = 64;
spokes = 4;
rotation = 0;
hole_size = 3;
hole_spacing = 3;

/* [Hidden] */
$fn = 32;
grill_od = screw_span;
grill_id = grill_od * .2;

// Render model

linear_extrude(height) difference() {
    // Base plate
    r_square([outer_size, outer_size], corner_radius, center = true);

    // Screw holes
    for(pos = square_points([screw_span, screw_span], center = true)) translate(pos) circle(d = screw_diameter);

    // Grill
    grill_mask_circle_auto(grill_od, grill_id, hole_size, hole_spacing, spokes, rotation, $fn = sides);
}