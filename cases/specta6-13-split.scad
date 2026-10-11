// Seeed Spectra6 13.3" — split for smaller printers (~220 mm bed).
// Front: plain split. Back: snap pegs align and hold the thin rear halves.
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

// --- Frame lip (display pocket) ---
lip_h = 1;
lip_t = 1;
pocket_depth = frame_depth - lip_h;

// --- Fasteners (M3) ---
screw_hole_d = 3.2;
screw_inset = 2;

// --- Back ribbon cable notches (landscape: long edge horizontal) ---
cable_notch_inset = 39;
cable_notch_w = side_margin;
cable_notch_y = cable_notch_inset;
cable_notch_h = case_h - 2 * cable_notch_inset;

module cable_notches(depth) {
    translate([-0.01, cable_notch_y, -0.01])
        cube([cable_notch_w + 0.01, cable_notch_h, depth + 0.02]);
    translate([case_w - cable_notch_w, cable_notch_y, -0.01])
        cube([cable_notch_w + 0.01, cable_notch_h, depth + 0.02]);
}

// --- Split ---
split_x = case_w / 2;
snap_d = 5;
snap_len = 8;
snap_y = [case_h * 0.35, case_h * 0.5, case_h * 0.65];

// --- Stand foot (one segment; print foot_count copies) ---
stand_angle = 80;
stand_slot_clearance = 0.4;
stand_wall_t = 4;
foot_len = 90;
stand_foot_depth = 95;
stand_foot_back = stand_foot_depth / 3;
stand_foot_front = 2 * stand_foot_depth / 3;
stand_heel_h = 25;
stand_slot_depth = 15;
stand_base_t = 5;
foot_count = 4;  // suggested copies along the frame bottom edge

// --- Render control ---
part = "all";  // [front-left, front-right, back-left, back-right, foot, all]
layout_gap = 10;
layout_col_w = split_x + layout_gap;
layout_row_h = case_h + layout_gap;

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
        translate([display_x, display_y, -0.01])
            cube([display_w, display_h, pocket_depth + 0.01]);
        translate([display_x + lip_t, display_y + lip_t, pocket_depth - 0.01])
            cube([display_w - 2 * lip_t, display_h - 2 * lip_t, lip_h + 0.02]);
        screw_holes(frame_depth);
    }
}

module back_panel() {
    difference() {
        cube([case_w, case_h, back_depth]);
        screw_holes(back_depth);
        cable_notches(back_depth);
    }
}

module clip_x_half(side, height) {
    pad = 0.02;
    intersection() {
        children();
        if (side == "left")
            cube([split_x + pad, case_h + pad, height + pad]);
        else
            translate([split_x, 0, 0])
                cube([case_w - split_x + pad, case_h + pad, height + pad]);
    }
}

module case_half(side, height) {
    if (side == "left") {
        clip_x_half("left", height)
            children();
    } else {
        translate([-split_x, 0, 0])
            clip_x_half("right", height)
                children();
    }
}

function snap_radius(height) = min(snap_d, height - 0.5);

module snap_pegs(height) {
    r = snap_radius(height);
    z = height / 2;
    for (y = snap_y)
        translate([split_x, y, z])
            rotate([0, 90, 0])
                cylinder(h = snap_len, d = r, $fn = 32);
}

module snap_holes(height) {
    r = snap_radius(height);
    z = height / 2;
    for (y = snap_y)
        translate([split_x, y, z])
            rotate([0, 90, 0])
                cylinder(h = snap_len + 0.02, d = r + 0.3, $fn = 32);
}

module front_frame_half(side) {
    case_half(side, frame_depth)
        front_frame();
}

module back_panel_half(side) {
    if (side == "left") {
        union() {
            clip_x_half("left", back_depth)
                back_panel();
            snap_pegs(back_depth);
        }
    } else {
        translate([-split_x, 0, 0])
            difference() {
                clip_x_half("right", back_depth)
                    back_panel();
                snap_holes(back_depth);
            }
    }
}

// stand_base, narrowed to foot_len; notch without end caps (open along X).
module stand_foot(angle = stand_angle) {
    slot_w = case_thickness + stand_slot_clearance;
    tilt = angle - 90;

    translate([0, -stand_foot_back, 0])
        cube([foot_len, stand_foot_depth, stand_base_t]);

    translate([0, 0, stand_base_t])
        rotate([tilt, 0, 0])
            difference() {
                cube([foot_len, slot_w + 2 * stand_wall_t, stand_heel_h]);
                translate([0, stand_wall_t, stand_heel_h - stand_slot_depth])
                    cube([foot_len, slot_w, stand_slot_depth + 0.02]);
            }
}

if (part == "all") {
    front_frame_half("left");
    translate([layout_col_w, 0, 0])
        front_frame_half("right");
    translate([0, layout_row_h, 0])
        back_panel_half("left");
    translate([layout_col_w, layout_row_h, 0])
        back_panel_half("right");
    translate([case_w + layout_gap * 2, stand_foot_back, 0])
        stand_foot();
} else if (part == "front-left") {
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
