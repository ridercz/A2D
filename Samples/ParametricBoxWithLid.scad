/****************************************************************************
 * Parametric Box with Lid - sample for A2D OpenSCAD Library                *
 * Copyright (c) Michal A. Valasek, 2020                                    *
 * www.rider.cz * www.altair.blog * github.com/ridercz/A2D                  *
 * ------------------------------------------------------------------------ *
 * This sample is intended to showcase how the r_square and rh_square       *
 * modules are supposed to work.                                            *
 ****************************************************************************/

include <../A2D.scad>

/* [Dimensions] */

// Inner box dimensions
inner_size = [80, 50, 40];

// Outer radius
radius = 5;

// Outside height of top lid
lid_height = 20;

/* [Details] */
// Vertical wall thickness, should be even number of perimeters
vwt = 1.67;

// Horizontal wall thickness
hwt = 2;

// Height of lid lip
lip_height = 6;

lid_tolerance = .2;

/* [Hidden] */
X = 0; Y = 1; Z = 2;
$fudge = 1;
$fn = 32;

outer_size = [
    inner_size[X] + 2 * vwt,
    inner_size[Y] + 2 * vwt,
    inner_size[Z] + 2 * hwt,
];
outer_bottom_height = outer_size[Z] - lid_height;

/** Render **/

translate([0, inner_size[Y] * 1.5]) part_box();
part_lid();

/** Parts **/

module part_lid() {
    // Walls
    linear_extrude(lid_height + hwt) rh_square([outer_size[X], outer_size[Y]], radius + vwt * 2, -vwt, center = true);

    // Bottom plate
    linear_extrude(hwt) r_square([outer_size[X], outer_size[Y]], radius + vwt * 2, center = true);
}

module part_box() {
    // Lip
    linear_extrude(outer_bottom_height + lip_height) 
    rh_square([inner_size[X], inner_size[Y]], radius, vwt - lid_tolerance, center = true);

    // Walls
    linear_extrude(outer_bottom_height) 
    rh_square([inner_size[X], inner_size[Y]], radius, vwt * 2, center = true);

    // Bottom plate
    linear_extrude(hwt) 
    r_square([outer_size[X], outer_size[Y]], radius + vwt * 2, center = true);
}