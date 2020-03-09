/****************************************************************************
 * Knurled Knob Sample - sample for A2D OpenSCAD Library                    *
 * Copyright (c) Michal A. Valasek, 2020                                    *
 * www.rider.cz * www.altair.blog * github.com/ridercz/A2D                  *
 * ------------------------------------------------------------------------ *
 * This sample uses various features of A2D library to create parametric    *
 * knurled knob for square shaft.                                           *
 ****************************************************************************/

// Include A2D library and check for minimum required version
include <../A2D.scad>;
assert(a2d_required([1, 2, 0]), "Please upgrade A2D library to version 1.2.0 or higher.");

/* [Shaft] */
shaft_size = 6.5;
shaft_length = 20;

/* [Knob] */
outer_diameter = 40;
base_height = 2;
wall_thickness = 1.67;
knurl_count = 32;

/* [Hidden] */
inner_diameter = shaft_size * 1.8;
text_height = .6;
text_radius = inner_diameter / 2 + 2 * wall_thickness;

// Shaft
linear_extrude(base_height + shaft_length) difference() {
    circle(d = inner_diameter, $fn = knurl_count);
    square([shaft_size, shaft_size], center = true);
}

// Shaft brace
linear_extrude(base_height * 2) h_circle(d = inner_diameter, thickness = wall_thickness, $fn = knurl_count);

// Knob base
linear_extrude(base_height) knurled_circle(d = outer_diameter, knurl_count = knurl_count, $fn = knurl_count / 2);

// Knob sides
linear_extrude(base_height + shaft_length * .3) difference() {
    knurled_circle(d = outer_diameter, knurl_count = knurl_count, $fn = knurl_count / 2);
    circle(d = outer_diameter * .85, $fn = knurl_count);
}

// Signature text
linear_extrude(base_height + text_height) {
    circle_text(radius = text_radius, text = "RIDER.CZ", font = "Arial:bold", size = 5);
    rotate(180) circle_text(text = "2020", font = "Arial:bold", size = 5, a1 = 50, a2 = 130, radius = text_radius, direction = "in", valign = "top");
}