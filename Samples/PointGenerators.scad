/****************************************************************************
 * Point Generator Sample - sample for A2D OpenSCAD Library                 *
 * Copyright (c) Michal A. Valasek, 2020                                    *
 * www.rider.cz * www.altair.blog * github.com/ridercz/A2D                  *
 * ------------------------------------------------------------------------ *
 * This sample is intended to showcase how the point generators can be used *
 * to specify corner holes placement.                                       *
 ****************************************************************************/

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
