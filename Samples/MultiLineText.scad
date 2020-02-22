/****************************************************************************
 * Multi Line Text - sample for A2D OpenSCAD Library                        *
 * Copyright (c) Michal A. Valasek, 2020                                    *
 * www.rider.cz * www.altair.blog * github.com/ridercz/A2D                  *
 * ------------------------------------------------------------------------ *
 * This sample is intended to showcase how the multiline_text modules is    *
 * supposed to work.                                                        *
 ****************************************************************************/

include <../A2D.scad>;

text = [
    "Lorem ipsum",
    "dolor sit amet",
    "consectetur",
    "adipiscing elit"
];

multiline_text(text = text, font = "Arial", valign = "center", halign = "center");