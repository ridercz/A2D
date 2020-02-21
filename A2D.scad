/****************************************************************************
 * Altair's 2D Objects for OpenSCAD              version 1.1.0 (2020-02-21) *
 * Copyright (c) Michal A. Valasek, 2020                                    *
 * ------------------------------------------------------------------------ *
 * www.rider.cz * www.altair.blog * github.com/ridercz/A2D                  *
 ****************************************************************************/

// Constants
a2d_version = [1, 1, 0];    // Version of a2d library [major, minor, revision]
pi = PI;                    // Pi value
phi = (1 + sqrt(5)) / 2;    // Golden ratio

/** POINT GENERATORS **/

// Generates points of vertices of regular polygon, given outer diameter and number of vertices, centered on origin
function regpoly_points(od, vertices) =
    assert(od > 0)
    assert(vertices > 1)
    [for(a = [0 : 360 / vertices : 359]) vector_point(a+90, od / 2)];

// Generates points of vertices of a rectangle ("square" in OpenSCAD terminology), given its size in [x, y]
function square_points(size, center = false) = 
    assert(is_list(size) && len(size) == 2)
    center 
        ? translate_points(square_points(size, false), size / -2)
        : [[0, 0], [size[0], 0], size, [0, size[1]]];

// Generates points of vertices of a star, given number of star points, outer diameter and inner diameter, centered on origin
function star_points(n, od, id) = 
    assert(n > 2)
    assert(od > id)
    assert(id > 0)
    [for(a = [0 : 360 / n : 359]) each([vector_point(a, od / 2), vector_point(a + 180 / n, id / 2)])];

/** SHAPES - STARS **/

// Creates a perfect five-pointed star of given outer diameter, centered on origin
module p5star(od) {
    assert(od > 0);

    id = od * (2 - phi);
    star(5, od,  id);
}

// Creates a perfect six-pointed star of given outer diameter, centered on origin
module p6star(od) {
    assert(od > 0);

    rotate(30) circle(d = od, $fn = 3);
    rotate(90) circle(d = od, $fn = 3);
}

// Creates a regular star of given number of points and outer and inner diameter, centered on origin
module star(n, od, id) {
    assert(n > 2);
    assert(od > id);
    assert(id > 0);

    polygon(star_points(n, od, id));
}

/** SHAPES - ROUNDED **/

// Creates a regular polygon with given outer diameter, number of vertices and vertex radius, centered on origin
module r_regpoly(od, vertices, radius) {
    // Validate arguments
    assert(od > 0);
    assert(vertices > 1);
    assert(radius >= 0);
    
    if(radius == 0) {
        circle(d = od, $fn = vertices);
    } else {
        hull() for(pos = regpoly_points(od - 2 * radius, vertices) ) translate(pos) circle(r = radius);
    }
}

// Creates a rectangle with given size and corner radius. Size may be specified:
// - as a scalar number, the same for all corners
// - as a list with two items, for top and bottom radii
// - as a list with four items, for all corners, starting with left bottom counterclockwise
module r_square(size, radius, center = false) {
    // Validate arguments
    assert(is_list(size) && len(size) == 2);
    assert(is_num(radius) || (is_list(radius) && len(radius) == 2) || len(radius) == 4);

    if(is_num(radius)) {
        // The same radius on all corners
        r_square(size, [radius, radius, radius, radius], center);
    } else if(len(radius) == 2) {
        // Different radii on top and bottom
        r_square(size, [radius[0], radius[0], radius[1], radius[1]], center);
    } else if(len(radius) == 4) {
        // Different radius on different corners
        translate(center ? [size[0] / -2, size[1] / -2] : [0, 0]) hull() {
            // BL
            if(radius[0] <= 0) square([1, 1]);
            else translate([radius[0], radius[0]]) circle(r = radius[0]);
            // BR
            if(radius[1] <= 0) translate([size[0] - 1, 0]) square([1, 1]);
            else translate([size[0] - radius[1], radius[1]]) circle(r = radius[1]);
            // TR
            if(radius[2] <= 0) translate([size[0] - 1, size[1] - 1]) square([1, 1]);
            else translate([size[0] - radius[2], size[1] - radius[2]]) circle(r = radius[2]);
            // TL
            if(radius[3] <= 0) translate([0, size[1] - 1]) square([1, 1]);
            else translate([radius[3], size[1] - radius[3]]) circle(r = radius[3]);
        }
    } else {
        // This code should be unreachable
        assert(false);
    }
}

/** SHAPES - HOLLOW **/

// Hollow circle (ring) with given wall thickness; use $fn to create hollow regular polygon
module h_circle(d, thickness) {
    assert(d > 0);
    assert(thickness != 0);

    difference() {
        circle(d = a2d_outer(d, thickness));
        circle(d = a2d_inner(d, thickness));
    }
}

// Hollow rectangle ("square" in OpenSCAD terminology) with given wall thickness
module h_square(size, thickness, center = false) {
    assert(thickness != 0);

    translate(center ? [0, 0] : [a2d_outer(size[0], thickness) / 2, a2d_outer(size[1], thickness) / 2])
        difference() {
            square([a2d_outer(size[0], thickness), a2d_outer(size[1], thickness)], center = true);
            square([a2d_inner(size[0], thickness), a2d_inner(size[1], thickness)], center = true);
        }
}

/** SHAPES - HOLLOW AND ROUNDED **/

// Hollow and rounded regular polygon
module hr_regpoly(od, vertices, radius, thickness) {
    rh_regpoly(od, vertices, radius, thickness);
}
module rh_regpoly(od, vertices, radius, thickness) {
    assert(od > 0);
    assert(vertices > 1);
    assert(radius >= 0);
    assert(thickness != 0);

    difference() {
        r_regpoly(a2d_outer(od, thickness), vertices, a2d_outer(radius, thickness, 1));
        r_regpoly(a2d_inner(od, thickness), vertices, a2d_inner(radius, thickness, 1));
    }
}

// Hollow and rounded rectangle ("square" in OpenSCAD terminology)
module hr_square(size, radius, thickness, center = false) {
    rh_square(size, radius, thickness, center);
}
module rh_square(size, radius, thickness, center = false) {
    // Validate arguments
    assert(is_list(size) && len(size) == 2);
    assert(is_num(radius) || (is_list(radius) && len(radius) == 2) || len(radius) == 4);
    assert(thickness != 0);

    translate(center ? [0, 0] : [a2d_outer(size[0], thickness) / 2, a2d_outer(size[1], thickness) / 2])
        difference() {
            r_square([a2d_outer(size[0], thickness), a2d_outer(size[1], thickness)], a2d_outer(radius, thickness, factor = 1), center = true);
            r_square([a2d_inner(size[0], thickness), a2d_inner(size[1], thickness)], a2d_inner(radius, thickness, factor = 1), center = true);
        }
}

/** FUNCTIONS **/

// Gets ciscumscribed circle diameter from given inscribed circle diameter for a regular polygon
function ins2cir(ri, n) = 
    assert(ri > 0)
    assert(n > 2)
    ri * tan(180 / n) / sin(180 / n);

// Gets inscribed circle diameter from given curcumscribed circle diameter for a regular polygon
function cir2ins(rc, n) =
    assert(rc > 0)
    assert(n > 0)
    rc * sin(180 / n) / tan(180 / n);

// Returns point (coordinates) for a given angle (alpha) and distance); follows left hand rule
function vector_point(alpha, delta) = [sin(alpha) * delta, cos(alpha) * delta];

// Will offset a list of points by given offset each
function translate_points(points, offset) = [for(p = points) p + offset];

/** TEXT **/

// Will display text on a circle curve of given radius and from-to angles a1-a2
module circle_text(radius, text, font, a1 = 0, a2 = 180, size = 10, valign = "baseline", language = "en", script = "latin", direction = "out") {
    char_count = len(text);
    angle_step = (a2 - a1) / (char_count - 1);

    for(i = [0:char_count - 1]) {
        r1a = direction == "out" ? a2 - angle_step * i : a1 + angle_step * i;
        r2a = direction == "out" ? -90 : +90;
        rotate(r1a)  translate([radius, 0]) rotate(r2a) text(text[i], size = size, font = font, halign = "center", valign = valign, language = language, script = script);
    }
}

// Will display multiline text with given line height 
module multiline_text(text, font, line_height = 1.2, size = 10, halign = "left", valign = "baseline", language = "en", script = "latin") {
    assert(is_list(text));

    line_count = len(text);
    line_spacing = size * line_height;
    total_height = (line_count - 1) * line_spacing + size;
    yo = valign == "top" ? - total_height
       : valign == "center" ? - total_height / 2
       : 0;

    for(i = [0 : line_count]) translate([0, i * line_spacing + yo]) text(text[line_count - 1 - i], size = size, font = font, halign = halign, valign = "baseline", language = language, script = script);
}

/** PRIVATE HELPER FUNCTIONS **/

function a2d_outer(d, thickness, factor = 2) = 
    assert(thickness != 0) 
    assert(factor > 0)
    is_list(d) 
        ? [for(x = d) a2d_outer(x, thickness, factor)] 
        : (thickness > 0 ? d + factor * thickness : d);

function a2d_inner(d, thickness, factor = 2) = 
    assert(thickness != 0)
    assert(factor > 0)
    is_list(d) 
        ? [for(x = d) a2d_inner(x, thickness, factor)] 
        : (thickness > 0 ? d : d + factor * thickness);
