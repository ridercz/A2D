/****************************************************************************
 * Stars Sample - sample for A2D OpenSCAD Library                          *
 * Copyright (c) Michal A. Valasek, 2020                                    *
 * www.rider.cz * www.altair.blog * github.com/ridercz/A2D                  *
 ****************************************************************************/

// Include A2D library and check for minimum required version
include <../A2D.scad>;
assert(a2d_required([1, 3, 0]), "Please upgrade A2D library to version 1.3.0 or higher.");

span = 75;

// Perfect stars
translate([0 * span, 1 * span]) p5star(od = 50);
translate([1 * span, 1 * span]) p6star(od = 50);
translate([2 * span, 1 * span]) p8star(od = 50);

// General stars
for(n = [3:14]) {
    y = -floor((n - 3) / 3);
    x = (n - 3) % 3;
    translate([x * span, y * span]) star(n = n, od = 50, id = 15);
}

