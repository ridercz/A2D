/****************************************************************************
 * Make Round Transformation Sample - sample for A2D OpenSCAD Library       *
 * Copyright (c) Michal A. Valasek, 2020                                    *
 * www.rider.cz * www.altair.blog * github.com/ridercz/A2D                  *
 * ------------------------------------------------------------------------ *
 * This sample explains use of the make_round() transformation              *
 ****************************************************************************/

// Include A2D library and check for minimum required version
include <../A2D.scad>;
assert(a2d_required([1, 6, 0]), "Please upgrade A2D library to version 1.6.0 or higher.");

// This is basic shape without any rounding
color("#ff0000") linear_extrude(1) l_shape();
color("#000000") linear_extrude(2) translate([5, 5]) text("Original shape", size = 4.5, font = "Consolas");

// This is shape with outer rounding only
translate([80, 0]) {
    color("#00ff00") linear_extrude(1) make_round(ro = 5) l_shape();
    color("#000000") linear_extrude(2) translate([5, 5]) text("ro = 5", size = 4.5, font = "Consolas");
}

// This is shape with inner rounding only
translate([160, 0]) {
    color("#44ccff") linear_extrude(1) make_round(ri = 5) l_shape();
    color("#000000") linear_extrude(2) translate([5, 5]) text("ri = 5", size = 4.5, font = "Consolas");
}

// This is shape with both outer and inner rounding
translate([240, 0]) {
    color("#ffff00") linear_extrude(1) make_round(ri = 5, ro = 5) l_shape();
    color("#000000") linear_extrude(2) translate([5, 5]) text("ri = 5, ro = 5", size = 4.5, font = "Consolas");
}

// This is the common shape used for demo
module l_shape() {
    translate([30, 30]) difference() {
        square(60, center = true);
        square(31, center = false);
    }
}