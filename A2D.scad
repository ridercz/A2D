/****************************************************************************
 * Altair's 2D Objects for OpenSCAD              version 1.6.2 (2021-05-07) *
 * Copyright (c) Michal A. Valasek, 2020-2021                               *
 * ------------------------------------------------------------------------ *
 * www.rider.cz * www.altair.blog * github.com/ridercz/A2D                  *
 ****************************************************************************/

// Constants
a2d_version = [1, 6, 0];    // Version of a2d library [major, minor, revision]
pi = PI;                    // Pi value
phi = (1 + sqrt(5)) / 2;    // Golden ratio

/** POINT GENERATORS **/

// Generates points of vertices of regular polygon, given outer diameter and number of vertices, centered on origin
function regpoly_points(od, vertices) =
    assert(od > 0)
    assert(vertices > 1)
    [for(a = [0 : 360 / vertices : 359]) vector_point(a + 90, od / 2)];

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

// Creates a perfect eight-pointed star of given outer diameter, centered on origin
module p8star(od) {
    assert(od > 0);
    circle(d = od, $fn = 4);
    rotate(45) circle(d = od, $fn = 4);
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

// Creates a rectangle with given size and corner radius. Radius may be specified:
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
            else translate([radius[0], radius[0]]) pie(d = radius[0] * 2, a1 = 180, a2 = 270);
            // BR
            if(radius[1] <= 0) translate([size[0] - 1, 0]) square([1, 1]);
            else translate([size[0] - radius[1], radius[1]]) pie(d = radius[1] * 2, a1 = 270, a2 = 360);
            // TR
            if(radius[2] <= 0) translate([size[0] - 1, size[1] - 1]) square([1, 1]);
            else translate([size[0] - radius[2], size[1] - radius[2]]) pie(d = radius[2] * 2, a1 = 0, a2 = 90);
            // TL
            if(radius[3] <= 0) translate([0, size[1] - 1]) square([1, 1]);
            else translate([radius[3], size[1] - radius[3]]) pie(d = radius[3] * 2, a1 = 90, a2 = 180);
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

/** SHAPES - other **/

// Creates a knurled circle with given number of knurls
module knurled_circle(d, knurl_count, knurl_size = .6) {
    assert(d > 0);
    assert(knurl_count > 4);
    assert(knurl_size > 0);

    knurl_diameter = PI * d / knurl_count * knurl_size;
    inner_diameter = d - knurl_diameter;

    circle(d = inner_diameter + knurl_diameter * (1 - knurl_size), $fn = knurl_count);
    knurl_points = regpoly_points(od = inner_diameter, vertices = knurl_count);
    for(pos = knurl_points) translate(pos) circle(d = knurl_diameter);
}

// Creates a pie slice with given diameter and angles
module pie(d, a1, a2) {
    assert(d > 0);

    mask_points = [
        [0,0],
        for(i = [0:4]) vector_point(((4 - i) * a1 + i * a2) / 4, d)
    ];

    intersection() {
        circle(d = d);
        polygon(mask_points);
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

// Returns point (coordinates) for a given angle (alpha) and distance); follows right hand rule
function vector_point(alpha, delta) = [cos(alpha) * delta, sin(alpha) * delta];

// Will offset a list of points by given offset each
function translate_points(points, offset) = [for(p = points) p + offset];

// Check if current version is greater or equal to minimal required version
function a2d_required(minver) = a2d_ver2num(a2d_version) >= a2d_ver2num(minver);

// Converts version vector [x, y, z] to number xyyzz
function a2d_ver2num(version) = version[0] * 10000 + version[1] * 100 + version[2];

/** TEXT **/

// Will display text on a circle curve of given radius and from-to angles a1-a2
module circle_text(radius, text, font, a1 = 0, a2 = 180, size = 10, valign = "baseline", language = "en", script = "latin", direction = "out") {
    char_count = len(text);
    angle_step = (a2 - a1) / (char_count - 1);

    for(i = [0:char_count - 1]) {
        r1a = direction == "out" ? a2 - angle_step * i : a1 + angle_step * i;
        r2a = direction == "out" ? -90 : +90;
        rotate(r1a) translate([radius, 0]) rotate(r2a) text(text[i], size = size, font = font, halign = "center", valign = valign, language = language, script = script);
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

/** GRILLS **/

module grill_mask_square(hsize, spacing, count) {
    assert(is_num(hsize) || (is_list(hsize) && len(hsize) == 2), "hsize must be number or list with two items");
    assert(is_num(spacing) || (is_list(spacing) && len(spacing) == 2), "spacing must be number or list with two items");
    assert(is_num(count) || (is_list(count) && len(count) == 2), "count must be number or list with two items");

    // Expand scalars to lists if necessary
    rhsize = a2d_num2list(hsize, 2);
    rspacing = a2d_num2list(spacing, 2);
    rcount = a2d_num2list(count, 2);

    // Draw squares
    for(xi = [0:rcount[0] - 1], yi = [0:rcount[1] - 1]) {
        pos = [xi * (rhsize[0] + rspacing[0]), yi * (rhsize[1] + rspacing[1])];
        translate(pos) square(rhsize);
    }
}

module grill_mask_square_auto(size, hsize, spacing) {
    assert(is_num(size) || (is_list(size) && len(size) == 2), "size must be number or list with two items");
    assert(is_num(hsize) || (is_list(hsize) && len(hsize) == 2), "hsize must be number or list with two items");
    assert(is_num(spacing) || (is_list(spacing) && len(spacing) == 2), "spacing must be number or list with two items");

    // Expand scalars to lists if necessary
    rsize = a2d_num2list(size, 2);
    rhsize = a2d_num2list(hsize, 2);
    rspacing = a2d_num2list(spacing, 2);

    // Compute real square size and count
    count = [for(i = [0, 1]) floor((rsize[i] + rspacing[i]) / (rhsize[i] + rspacing[i]))];
    rrhsize = [for(i = [0, 1]) (rsize[i] - rspacing[i] * (count[i] - 1)) / count[i]];

    // Draw mask
    grill_mask_square(rrhsize, spacing, count);
}

module grill_mask_circle(diameter, size, spacing, count, spokes = 4, spoke_rotate = 0, spoke_width = 0) {
    assert(diameter > 0);
    assert(size > 0);
    assert(spacing > 0);
    assert(count > 0);
    assert(spokes > 2);
    assert(spoke_width >= 0);

    real_spoke_width = spoke_width == 0 ? spacing : spoke_width;

    difference() {
        // Circles
        for(i = [0:count - 1]) h_circle(d = diameter - 2 * i * (size + spacing), thickness = -size);

        // Spokes
        for(a = [0 : 360 / spokes : 359]) rotate(a + spoke_rotate) translate([-real_spoke_width / 2, 0]) square([real_spoke_width, diameter]);
    }
}

module grill_mask_circle_auto(outer_diameter, inner_diameter, size, spacing, spokes = 4, spoke_rotate = 0, spoke_width = 0) {
    assert(outer_diameter > 0 && outer_diameter > inner_diameter);
    assert(inner_diameter > 0);
    assert(size > 0);
    assert(spacing > 0);
    assert(spokes > 2);
    assert(spoke_width >= 0);

    // Compute real ring count size
    dd = (outer_diameter - inner_diameter + spacing) / 2;
    ring_count = floor(dd / (size + spacing));
    real_size = (dd - ring_count * spacing) / ring_count;

    // Draw mask
    grill_mask_circle(diameter = outer_diameter, size = real_size, spacing = spacing, count = ring_count, spokes = spokes, spoke_rotate = spoke_rotate, spoke_width = spoke_width);
}

/** TRANSFORMATIONS **/

// Will make its children round; ro is outside radius, ri is inner radius
module make_round(ro = 0, ri = 0) {
    assert(ro >= 0);
    assert(ri >= 0);

    offset(r = ro) offset(r = -ro)
    offset(r = -ri) offset(r = ri)
    children(0);
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

function a2d_num2list(num, len) = 
    assert(len > 0) 
    is_list(num) 
        ? num
        : [for(i = [0 : len - 1]) num];
