include <../A2D.scad>;

text_angle = 30;
text_size = 20;
text_radius = 50;

// Top part
circle_text(text = "HORSE", font = "Arial:bold", size = text_size,
    a1 = text_angle, a2 = 180 - text_angle, 
    radius = text_radius);

// Bottom part
rotate(180) circle_text(text = "POWER", font = "Arial:bold", size = text_size, 
    a1 = text_angle, a2 = 180 - text_angle, 
    radius = text_radius, 
    direction = "in", valign = "top");

// Stars
circle_text(text = "**", font = "Courier:bold", size = text_size, 
    radius = text_radius);

// Center ring
h_circle(d = 2 * (text_radius - text_size * 0.2), thickness = -text_size * .2, $fn = 64);

// Outer ring
h_circle(d = 2 * (text_radius + text_size * 1.2), thickness = text_size * .2, $fn = 64);