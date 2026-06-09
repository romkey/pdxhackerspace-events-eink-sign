// Seeed Spectra6 13.3" — split for smaller printers (~220 mm bed).
// Front/back print in left/right halves with snap pegs; base is a foot segment
// (print several and space along the frame bottom edge).
//
// Dimensions (mm):
//   Visible cutout:     270.4 x 202.8
//   Display (incl bezel): 284.7 x 208.8  (+14.3 x +6 beyond cutout)
//   Case outer:           292.7 x 216.8  (+8 x +8 beyond display)

// --- Display & case geometry ---
cutout_w = 270.4;
cutout_h = 202.8;
bezel_extra_w = 14.3;
bezel_extra_h = 6;
display_w = cutout_w + bezel_extra_w;
display_h = cutout_h + bezel_extra_h;
case_margin = 8;
case_w = display_w + case_margin;
case_h = display_h + case_margin;
side_margin = case_margin / 2;

display_x = side_margin;
display_y = side_margin;
cutout_x = display_x + (display_w - cutout_w) / 2;
cutout_y = display_y + (display_h - cutout_h) / 2;

// --- Part thickness ---
frame_depth = 5;
back_depth = 3;
case_thickness = frame_depth + back_depth;

// --- Fasteners (M3) ---
screw_hole_d = 3.2;
screw_inset = 2;

// --- Split joint ---
split_x = case_w / 2;
snap_d = 5;
snap_len = 8;
snap_hole_d = snap_d + 0.3;
snap_y = [case_h * 0.35, case_h * 0.5, case_h * 0.65];

// --- Stand foot (one segment; print foot_count copies) ---
stand_angle = 80;
stand_slot_clearance = 0.4;
foot_len = 90;
stand_foot_depth = 95;
stand_foot_back = stand_foot_depth / 3;
stand_foot_front = 2 * stand_foot_depth / 3;
stand_heel_h = 25;
stand_slot_depth = 15;
stand_base_t = 5;
foot_count = 4;  // suggested copies along the frame bottom edge

// --- Render control ---
part = "front-left";  // [front-left, front-right, back-left, back-right, foot]

module screw_holes(height) {
    positions = [
        [screw_inset, screw_inset],
        [case_w - screw_inset, screw_inset],
        [case_w - screw_inset, case_h - screw_inset],
        [screw_inset, case_h - screw_inset],
    ];
    for (pos = positions)
        translate([pos[0], pos[1], -0.01])
            cylinder(h = height + 0.02, d = screw_hole_d, $fn = 32);
}

module front_frame() {
    difference() {
        cube([case_w, case_h, frame_depth]);
        translate([cutout_x, cutout_y, -0.01])
            cube([cutout_w, cutout_h, frame_depth + 0.02]);
        screw_holes(frame_depth);
    }
}

module back_panel() {
    difference() {
        cube([case_w, case_h, back_depth]);
        screw_holes(back_depth);
    }
}

module clip_x_half(side, height) {
    pad = 0.02;
    intersection() {
        children();
        if (side == "left")
            cube([split_x + snap_len, case_h + pad, height + pad]);
        else
            translate([split_x - snap_len, 0, 0])
                cube([case_w - split_x + snap_len + pad, case_h + pad, height + pad]);
    }
}

module snap_pegs(height) {
    z = height / 2;
    for (y = snap_y)
        translate([split_x - 0.01, y, z])
            rotate([0, 90, 0])
                cylinder(h = snap_len, d = snap_d, $fn = 32);
}

module snap_holes(height) {
    z = height / 2;
    for (y = snap_y)
        translate([split_x - 0.01, y, z])
            rotate([0, 90, 0])
                cylinder(h = snap_len + 0.02, d = snap_hole_d, $fn = 32);
}

module front_frame_half(side) {
    difference() {
        union() {
            clip_x_half(side, frame_depth)
                front_frame();
            if (side == "left")
                snap_pegs(frame_depth);
        }
        if (side == "right")
            snap_holes(frame_depth);
    }
}

module back_panel_half(side) {
    difference() {
        union() {
            clip_x_half(side, back_depth)
                back_panel();
            if (side == "left")
                snap_pegs(back_depth);
        }
        if (side == "right")
            snap_holes(back_depth);
    }
}

// Narrow segment of stand_base (print foot_count copies along the frame edge).
module stand_foot(angle = stand_angle) {
    slot_w = case_thickness + stand_slot_clearance;
    tilt = angle - 90;

    // Foot: 1/3 behind slot (−Y), 2/3 in front (+Y) where display leans.
    translate([0, -stand_foot_back, 0])
        cube([foot_len, stand_foot_depth, stand_base_t]);

    // Slot at the 1/3 / 2/3 boundary; same as full base but no side walls.
    translate([0, 0, stand_base_t])
        rotate([tilt, 0, 0])
            difference() {
                cube([foot_len, slot_w, stand_heel_h]);
                translate([0, 0, stand_heel_h - stand_slot_depth])
                    cube([foot_len, slot_w, stand_slot_depth + 0.02]);
            }
}

if (part == "front-left") {
    front_frame_half("left");
} else if (part == "front-right") {
    front_frame_half("right");
} else if (part == "back-left") {
    back_panel_half("left");
} else if (part == "back-right") {
    back_panel_half("right");
} else if (part == "foot") {
    stand_foot();
}
