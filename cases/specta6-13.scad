// Seeed Spectra6 13.3" ePaper display case
// Front frame + back panel sandwich; display sits between them.
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
case_margin = 8;  // added to each outer dimension (4 mm per side)
case_w = display_w + case_margin;
case_h = display_h + case_margin;
side_margin = case_margin / 2;

// Cutout centered on display; display centered in case.
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
screw_inset = 2;  // hole center from case edge, in the 4 mm margin outside display

// --- Stand base ---
stand_angle = 80;  // degrees from horizontal
stand_slot_clearance = 0.4;
stand_wall_t = 4;
stand_slot_length = case_w + 10;  // long bottom edge, landscape
stand_heel_h = 25;
stand_slot_depth = 15;
stand_foot_depth = 95;  // total Y extent: 1/3 behind slot, 2/3 in front
stand_foot_back = stand_foot_depth / 3;
stand_foot_front = 2 * stand_foot_depth / 3;
stand_foot_w = stand_slot_length + 10;
stand_base_t = 5;

// --- Render control ---
part = "base";  // [front, back, base]

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

// Foot with a vertical slot (opens upward) sized for the frame bottom edge.
// Landscape: long edge (case_w) in slot, leans back over case_h.
module stand_base(angle = stand_angle) {
    slot_w = case_thickness + stand_slot_clearance;
    tilt = angle - 90;  // vertical slot (90°) → desired lean

    // Foot: 1/3 behind slot (−Y), 2/3 in front (+Y) where display leans.
    translate([-(stand_foot_w - case_w) / 2, -stand_foot_back, 0])
        cube([stand_foot_w, stand_foot_depth, stand_base_t]);

    // Slot at the 1/3 / 2/3 boundary; runs along X, slides in from +Z.
    translate([-(stand_slot_length - case_w) / 2, 0, stand_base_t])
        rotate([tilt, 0, 0])
            difference() {
                cube([stand_slot_length, slot_w + 2 * stand_wall_t, stand_heel_h]);
                translate([
                    stand_wall_t,
                    stand_wall_t,
                    stand_heel_h - stand_slot_depth,
                ])
                    cube([
                        stand_slot_length - 2 * stand_wall_t,
                        slot_w,
                        stand_slot_depth + 0.02,
                    ]);
            }
}

if (part == "front") {
    front_frame();
} else if (part == "back") {
    back_panel();
} else if (part == "base") {
    stand_base();
}

