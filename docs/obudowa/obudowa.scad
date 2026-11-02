// Obudowa yoRadio — Waveshare ESP32-S3-Touch-LCD-2.8 + 2 głośniki 20x30x4
// Wymiary modułu: rysunek 2D Waveshare
//   https://files.waveshare.com/wiki/ESP32-S3-Touch-LCD-2.8/ESP32-S3-Touch-LCD-2.8%202D.pdf
// Druk (Bambu A1 mini, bez podpór): front twarzą do stołu, pokrywa zewnętrzną stroną do stołu,
// listwy dociskowe (2 szt.) listwą do stołu. Wkręty M3 wkręcane bezpośrednio w plastik.
// STL: openscad -o front.stl -D 'part="front"' obudowa.scad   (analogicznie back, clamp)
//
// Układ opisu (w nim drukujemy front — twarzą do stołu):
//   x = szerokość patrząc OD PRZODU, w prawo (0 = środek okna), y = wysokość wzdłuż frontu
//   (0 = dolna krawędź frontu), z = głębokość (0 = zewnętrzna powierzchnia frontu, rośnie do tyłu).
//   Taki układ jest lewoskrętny, dlatego na wyjściu wszystko przechodzi przez mx() (patrz niżej).
// Obudowa stoi pochylona o `tilt` — podstawa to płaszczyzna y*cos(t) - z*sin(t) = 0.
// Ekran poziomo, przyciski BOOT/RESET/PWR u góry, USB-C na prawym boku modułu.
//
// part = "front" | "back" | "clamp" | "assembly" | "inside" | "section"

part = "assembly";

$fn = 48;

// ---------- parametry ogólne ----------
tilt   = 12;     // pochylenie frontu [°]
wall   = 2.4;    // grubość ścianek
W      = 164;    // szerokość
H      = 70;     // wysokość frontu (wzdłuż pochylenia)
D      = 40;     // głębokość (front + tył)
r_out  = 6;      // promień zaokrąglenia naroży
tol    = 0.3;    // luz pasowania

// ---------- moduł (szkło 73.06 x 50.54, ekran poziomo) ----------
glass_w = 73.06;
glass_h = 50.54;
// okno = obszar widoczny dotyku 58.2 x 43.8 + 0.3 z każdej strony
win_w   = 58.8;
win_h   = 44.4;
win_chamfer = 1.5;
// środek obszaru widocznego jest 3.0 mm w lewo od środka szkła (ramka 4.43 / 10.43)
glass_x0 = -33.53;                  // lewa krawędź szkła (okno wyśrodkowane na x=0)
glass_y0 = H - wall - 1.2 - glass_h; // dolna krawędź szkła (1.2 mm pod górną ścianką)
win_cy   = glass_y0 + glass_h / 2;
pcb_back_z = wall + 6.0;            // tylna powierzchnia PCB (szkło dociśnięte do frontu)
comp_max_z = wall + 10.0;           // najwyższe elementy z tyłu PCB
pocket_rib = 3.0;                   // wysokość żeberek ustalających szkło
// otwory PCB (od lewego-dolnego rogu szkła, widok z przodu): 6.4/66.4 x 4.82/45.72
pcb_holes = [for (hx = [6.4, 66.4], hy = [4.82, 45.72]) [glass_x0 + hx, glass_y0 + hy]];
// przyciski na górnej krawędzi (x od lewej krawędzi szkła), oś na z ~ wall+7.0
btn_x = [14.24, 22.06, 29.88];
btn_z = wall + 7.0;
btn_d = 2.5;
// USB-C na prawej krawędzi
usb_y = glass_y0 + 25.12;
usb_z = wall + 8.0;

// ---------- komory głośników ----------
chamber_w = 23;                     // wewnętrzna szerokość komory
div_t     = 1.6;                    // ścianka działowa
div_x     = W/2 - wall - chamber_w - div_t;  // wewnętrzna krawędź ścianki działowej
spk_w = 20; spk_h = 30;             // głośnik (owal)
spk_cx = W/2 - wall - chamber_w/2;
spk_cy = win_cy;
grille_w = 15; grille_h = 25;       // kratka mieści się wewnątrz pierścienia uszczelki
slot_w = 1.6; slot_pitch = 3.2;
rim_h = 1.0; rim_t = 0.8;           // ranteczek ustalający głośnik
tab_w = 5.5;                        // wcięcie na języczek z przewodem (dół)

// ---------- mocowanie ----------
pilot_d  = 2.6;                     // otwór pod wkręt M3 wkręcany w plastik
screw_d  = 3.4;                     // otwór przelotowy M3
head_d   = 6.2;                     // pogłębienie pod łeb
boss_d   = 8;
clamp_z0 = comp_max_z + 0.6;        // spód listwy dociskowej (nad elementami)
clamp_t  = 3;
clamp_wd = 8;
clamp_boss_x = [glass_x0 - 4.5, glass_x0 + glass_w + 4.5];
back_boss_x = W/2 - wall - boss_d/2;
back_boss_y_top = H - wall - boss_d/2;

// ---------- pomocnicze ----------
function floor_y(z, off=0) = (off + z * sin(tilt)) / cos(tilt);

module rrect(w, h, r) {           // zaokrąglony prostokąt, róg w (0,0)
    translate([r, r]) offset(r=r) square([w - 2*r, h - 2*r]);
}
module stadium(w, h) {            // owal: prostokąt z półokrągłymi końcami (pionowy)
    hull() { translate([0, -(h-w)/2]) circle(d=w); translate([0, (h-w)/2]) circle(d=w); }
}
module keep_above_floor(off=0) {  // półprzestrzeń nad podstawą (+ off)
    rotate([-tilt, 0, 0]) translate([-W, off, -2*D]) cube([2*W, 2*H, 4*D]);
}

module outer_solid() {
    intersection() {
        translate([-W/2, 0, 0]) linear_extrude(D) rrect(W, H, r_out);
        keep_above_floor();
    }
}
module inner_solid() {
    intersection() {
        translate([-W/2 + wall, wall, wall]) linear_extrude(D - 2*wall)
            rrect(W - 2*wall, H - 2*wall, r_out - wall);
        keep_above_floor(wall);
    }
}
// wnętrze (bez ograniczenia z tyłu) — do przycinania żeber i słupków
module inner_open() {
    intersection() {
        translate([-W/2 + wall, wall, wall]) linear_extrude(D) rrect(W - 2*wall, H - 2*wall, r_out - wall);
        keep_above_floor(wall);
    }
}

// ---------- front ----------
module grille() {
    intersection() {
        linear_extrude(wall*3, center=true) stadium(grille_w, grille_h);
        for (i = [-floor(grille_h/2/slot_pitch) : floor(grille_h/2/slot_pitch)])
            translate([-grille_w/2, i*slot_pitch - slot_w/2, -wall*2]) cube([grille_w, slot_w, wall*4]);
    }
}

module speaker_rim() {
    difference() {
        linear_extrude(rim_h) offset(r=tol + rim_t) stadium(spk_w, spk_h);
        translate([0, 0, -1]) linear_extrude(rim_h + 2) offset(r=tol) stadium(spk_w, spk_h);
        translate([-tab_w/2, -spk_h/2 - 5, -1]) cube([tab_w, 6, rim_h + 2]);
    }
}

module front() {
    difference() {
        union() {
            difference() {
                outer_solid();
                inner_solid();
                // tył otwarty pod pokrywę
                translate([-W, -10, D - wall]) cube([2*W, H + 20, wall + 1]);
            }
            intersection() {
                union() {
                    // ścianki działowe komór
                    for (s = [-1, 1]) translate([s > 0 ? div_x : -div_x - div_t, 0, wall])
                        cube([div_t, H, D - 2*wall]);
                    // słupki pod pokrywę (w narożnikach komór)
                    for (sx = [-1, 1], yy = [back_boss_y_top, floor_y(D - wall, wall) + boss_d/2 + 0.5])
                        translate([sx*back_boss_x, yy, wall]) cylinder(d=boss_d, h=D - 2*wall);
                    // żeberka ustalające szkło
                    translate([0, 0, wall]) linear_extrude(pocket_rib) difference() {
                        translate([glass_x0 - tol - 1.2, glass_y0 - tol - 1.2])
                            square([glass_w + 2*tol + 2.4, glass_h + 2*tol + 2.4]);
                        translate([glass_x0 - tol, glass_y0 - tol]) square([glass_w + 2*tol, glass_h + 2*tol]);
                    }
                    // słupki pod listwy dociskowe
                    for (cx = clamp_boss_x, hy = [pcb_holes[0][1], pcb_holes[1][1]])
                        translate([cx, hy, wall]) cylinder(d=boss_d - 1, h=clamp_z0 - wall);
                    // ranteczki głośników
                    for (s = [-1, 1]) translate([s*spk_cx, spk_cy, wall]) speaker_rim();
                }
                inner_open();
            }
        }
        // okno ekranu z fazką na zewnątrz
        hull() {
            translate([-win_w/2, win_cy - win_h/2, wall - 0.01]) cube([win_w, win_h, 0.02]);
            translate([-win_w/2 - win_chamfer, win_cy - win_h/2 - win_chamfer, -0.01])
                cube([win_w + 2*win_chamfer, win_h + 2*win_chamfer, 0.02]);
            translate([-win_w/2, win_cy - win_h/2, wall - 0.01]) cube([win_w, win_h, 1]);
        }
        // kratki głośników
        for (s = [-1, 1]) translate([s*spk_cx, spk_cy, wall/2]) grille();
        // otwory na szpilkę do przycisków (górna ścianka) z pogłębieniem
        for (bx = btn_x) translate([glass_x0 + bx, H - wall - 1, btn_z]) rotate([-90, 0, 0]) {
            cylinder(d=btn_d, h=wall + 2);
            translate([0, 0, wall + 1 - 0.8]) cylinder(d1=btn_d, d2=btn_d + 1.6, h=0.81);
        }
        // otwory na przewody głośników w ściankach działowych
        for (s = [-1, 1]) translate([s*(div_x + div_t/2), floor_y(8, wall) + 3, 8]) rotate([0, 90, 0])
            cylinder(d=3.5, h=div_t + 2, center=true);
        // otwory pilotowe w słupkach pokrywy
        for (sx = [-1, 1], yy = [back_boss_y_top, floor_y(D - wall, wall) + boss_d/2 + 0.5])
            translate([sx*back_boss_x, yy, D - wall - 14]) cylinder(d=pilot_d, h=15);
        // otwory pilotowe w słupkach listew
        for (cx = clamp_boss_x, hy = [pcb_holes[0][1], pcb_holes[1][1]])
            translate([cx, hy, clamp_z0 - 9]) cylinder(d=pilot_d, h=10);
    }
}

// ---------- pokrywa tylna (drukowana zewnętrzną stroną do stołu) ----------
module back() {
    difference() {
        intersection() {
            translate([-W/2, 0, D - wall]) linear_extrude(wall) rrect(W, H, r_out);
            keep_above_floor();
        }
        // wkręty
        for (sx = [-1, 1], yy = [back_boss_y_top, floor_y(D - wall, wall) + boss_d/2 + 0.5])
            translate([sx*back_boss_x, yy, 0]) {
                translate([0, 0, D - wall - 1]) cylinder(d=screw_d, h=wall + 2);
                translate([0, 0, D - 1.2]) cylinder(d=head_d, h=2);
            }
        // przepust przewodu USB (wtyk kątowy, przewód prosto do tyłu)
        translate([glass_x0 + glass_w + 7, usb_y, D - wall - 1]) linear_extrude(wall + 2)
            offset(r=2) square([10, 6], center=true);
        // wentylacja za modułem
        for (i = [-3 : 3]) translate([i*7 - 1, win_cy - 12, D - wall - 1]) linear_extrude(wall + 2)
            offset(r=1) square([0.01, 24], center=true);
    }
}

// ---------- listwy dociskowe PCB (2 szt., drukowane płasko) ----------
module clamp() {
    hy = pcb_holes[0][1];
    x0 = clamp_boss_x[0]; x1 = clamp_boss_x[1];
    difference() {
        union() {
            translate([x0 - clamp_wd/2, hy - clamp_wd/2, clamp_z0])
                linear_extrude(clamp_t) rrect(x1 - x0 + clamp_wd, clamp_wd, 2);
            for (hx = [pcb_holes[0][0], pcb_holes[2][0]]) translate([hx, hy, 0]) {
                translate([0, 0, pcb_back_z]) cylinder(d=4.5, h=clamp_z0 - pcb_back_z + 0.01);
                translate([0, 0, pcb_back_z - 1.2]) cylinder(d=1.9, h=1.21);  // kołek w otwór PCB
            }
        }
        for (cx = clamp_boss_x) translate([cx, hy, clamp_z0 - 1]) cylinder(d=screw_d, h=clamp_t + 2);
    }
}

// ---------- wyjście ----------
// Geometria jest opisana w widoku od przodu (x w prawo). Układ (x, y, z) z z do tyłu jest
// prawoskrętny tylko po odbiciu x — mx() zamienia opis na rzeczywistą bryłę.
// Części do druku obracamy (rotate), nigdy nie odbijamy — odbicie dałoby lustrzaną część.
module mx() mirror([1, 0, 0]) children();

if (part == "front") mx() front();
else if (part == "back") translate([0, 0, D]) rotate([0, 180, 0]) mx() back();
else if (part == "clamp") translate([0, 0, clamp_z0 + clamp_t]) rotate([0, 180, 0]) mx() clamp();
else if (part == "section") {   // przekrój do kontroli: plaster x = section_x (x w układzie opisu)
    intersection() {
        translate([section_x - 0.5, -50, -50]) cube([1, 200, 200]);
        assembly_local();
    }
}
else if (part == "inside") mx() assembly_local();   // podgląd wnętrza od tyłu
else rotate([90 + tilt, 0, 0]) mx() assembly_local();

section_x = 0;
show_back = true;   // false = podgląd wnętrza bez pokrywy

module assembly_local() {
    {
        color("SlateGray") front();
        if (show_back) color("DimGray", 0.6) back();
        color("Orange") for (hy = [pcb_holes[0][1], pcb_holes[1][1]])
            translate([0, hy - pcb_holes[0][1], 0]) clamp();
        // moduł (podgląd)
        color("Black") translate([glass_x0, glass_y0, wall]) cube([glass_w, glass_h, 3.6]);
        color("SeaGreen") translate([glass_x0 + 1.9, glass_y0 + 0.32, wall + 4.45]) cube([69, 49.9, 1.55]);
        // głośniki (podgląd)
        color("Black") for (s = [-1, 1]) translate([s*spk_cx, spk_cy, wall + rim_h - 1])
            linear_extrude(4) stadium(spk_w, spk_h);
    }
}
