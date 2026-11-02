// =============================================================================
//  Gehäuse für ESP32 DevKit (USB-C, 54 × 27 mm) + SHT31-D Breakout (12,6 × 10,4 mm)
// =============================================================================
//  Aufbau (Wandmontage, USB-C rechts):
//
//      ┌──────────────────────────┐
//      │  ESP32-Kammer            │  ← oben: Abwärme steigt weg vom Sensor
//      │  (Platz für Kabelreserve)│
//      ├══════ Luftspalt ═════════┤  ← doppelte Trennwand als Wärmesperre
//      │  Sensorkammer (belüftet) │  ← unten: frische Raumluft
//      └──────────────────────────┘
//
//  Teile  : part = "base" | "lid" | "assembly"
//  Druck  : PLA/PETG, 0,2 mm Schichthöhe, 3 Wände, 15 % Infill, ohne Stützen
//  Montage: 4 × M3×10 Blechschrauben (Deckel), 2 × Schrauben Ø ≤ 4 mm (Wand)
// =============================================================================

part = "assembly";

/* [Allgemein] */
wall        = 2.0;    // Wandstärke
floor_t     = 2.0;    // Bodenstärke (Rückwand)
lid_t       = 2.4;    // Deckelstärke
inner_w     = 62.0;   // Innenbreite (X)
inner_d     = 31.0;   // Innentiefe (Z)
tol         = 0.3;    // Spiel rund um die Platinen

/* [ESP32 DevKit] */
esp_l       = 54.0;   // Platinenlänge (Datenblatt Händler: 5,4 cm)
esp_w       = 27.0;   // Platinenbreite (Datenblatt Händler: 2,7 cm)
esp_pcb     = 1.6;    // Platinenstärke
esp_top_h   = 3.2;    // Höhe Modul-Abschirmblech / USB-C-Buchse über der Platine
esp_under   = 24.0;   // Freiraum unter der Platine für Stiftleisten + Dupont-Stecker
usb_w       = 12.5;   // Ausschnitt für USB-C-Stecker (Breite)
usb_h       = 7.5;    // Ausschnitt für USB-C-Stecker (Höhe)

/* [SHT31-D Breakout] */
sht_l       = 12.6;   // Länge (Pin-Kante → Lochseite)
sht_w       = 10.4;   // Breite (entlang der Pin-Kante)
sht_hole_x  = 10.0;   // Befestigungsloch: Abstand von der Pin-Kante
sht_hole_y  = 2.8;    // Befestigungsloch: Abstand vom Rand (Bauteilseite oben)
sht_peg_d   = 2.0;    // Zentrierstift (passt in Löcher ab 2,2 mm)
sht_pin_strip = 3.5;  // Bereich der Stiftleiste, der frei bleiben muss

/* [Kammern] */
sensor_ch   = 24.0;   // Innenhöhe Sensorkammer (Y)
div_t       = 2.0;    // Stärke je Trennwand
div_gap     = 3.0;    // Luftspalt zwischen den Trennwänden
esp_ch      = 38.0;   // Innenhöhe ESP32-Kammer (Y)
wire_hole_w = 8.0;    // Kabeldurchführung (breit genug für Dupont-Stecker)
wire_hole_h = 8.0;

/* [Verschraubung & Montage] */
post_s      = 6.0;    // Schraubdom (quadratisch)
pilot_d     = 2.5;    // Vorbohrung für M3-Blechschraube
screw_d     = 3.4;    // Durchgangsloch im Deckel
keyhole_d   = 8.0;    // Schlüsselloch: Kopfdurchmesser
keyhole_s   = 4.0;    // Schlüsselloch: Schlitzbreite

/* [Lüftung] */
vent_w      = 1.8;
vent_pitch  = 4.0;

$fn = 48;

// ---------------------------------------------------------------- abgeleitet
div_total = 2 * div_t + div_gap;
inner_h   = sensor_ch + div_total + esp_ch;      // Innenmaß Y
outer_w   = inner_w + 2 * wall;
outer_h   = inner_h + 2 * wall;
outer_d   = floor_t + inner_d;

pcb_l = esp_l + 2 * tol;
pcb_w = esp_w + 2 * tol;
pcb_z = floor_t + esp_under;                     // Unterkante ESP32-Platine

// ESP32-Lage (Innenkoordinaten): USB-C-Ende 1 mm vor der rechten Wand
esp_x1 = inner_w - 1.0;
esp_x0 = esp_x1 - pcb_l;
esp_y0 = sensor_ch + div_total + 3.0;
esp_y1 = esp_y0 + pcb_w;
esp_cy = (esp_y0 + esp_y1) / 2;

// SHT31-Lage (Innenkoordinaten): Pin-Kante zeigt nach oben zur Trennwand
sht_cx  = inner_w / 2;
sht_top = sensor_ch - 4.0;                       // Pin-Kante
sht_bot = sht_top - sht_l;
sht_z   = pcb_z;                                 // gleiche Höhe wie ESP32 → nah am Deckel

module in() { translate([wall, wall, floor_t]) children(); }

module rbox(size, r = 2) {
    hull() for (x = [r, size[0] - r], y = [r, size[1] - r])
        translate([x, y, 0]) cylinder(r = r, h = size[2]);
}

module post_positions() {
    for (x = [post_s / 2, inner_w - post_s / 2], y = [post_s / 2, inner_h - post_s / 2])
        translate([x, y, 0]) children();
}

module vents_x(x0, x1, z0, z1, depth) {          // senkrechte Schlitze in X-Richtung verteilt
    n = floor((x1 - x0) / vent_pitch);
    off = (x1 - x0 - (n - 1) * vent_pitch) / 2;
    for (i = [0 : n - 1])
        translate([x0 + off + i * vent_pitch - vent_w / 2, -depth / 2, z0])
            cube([vent_w, depth, z1 - z0]);
}

module vents_y(y0, y1, z0, z1, depth) {          // senkrechte Schlitze in Y-Richtung verteilt
    n = floor((y1 - y0) / vent_pitch);
    off = (y1 - y0 - (n - 1) * vent_pitch) / 2;
    for (i = [0 : n - 1])
        translate([-depth / 2, y0 + off + i * vent_pitch - vent_w / 2, z0])
            cube([depth, vent_w, z1 - z0]);
}

module keyhole() {
    cylinder(d = keyhole_d, h = 10, center = true);
    hull() {
        cylinder(d = keyhole_s, h = 10, center = true);
        translate([0, 8, 0]) cylinder(d = keyhole_s, h = 10, center = true);
    }
}

// =============================================================================
//  Unterteil
// =============================================================================
module base() {
    difference() {
        union() {
            // Schale
            difference() {
                rbox([outer_w, outer_h, outer_d]);
                in() cube([inner_w, inner_h, inner_d + 1]);
            }

            in() {
                // Schraubdome
                post_positions() translate([-post_s / 2, -post_s / 2, 0]) cube([post_s, post_s, inner_d]);

                // Doppelte Trennwand mit Luftspalt
                translate([0, sensor_ch, 0]) cube([inner_w, div_t, inner_d]);
                translate([0, sensor_ch + div_t + div_gap, 0]) cube([inner_w, div_t, inner_d]);

                // ESP32: Auflageböcke unter beiden Schmalseiten (mittig, zwischen den Stiftleisten)
                for (x = [esp_x0, esp_x1 - 2.5])
                    translate([x, esp_cy - 7, 0]) cube([2.5, 14, esp_under]);

                // ESP32: Führungen (außerhalb der Platinenkontur)
                translate([esp_x0 - 1.2, esp_cy - 6, 0]) cube([1.2, 12, esp_under + esp_pcb + 1.5]);
                for (y = [esp_y0 - 1.2, esp_y1])
                    translate([(esp_x0 + esp_x1) / 2 - 5, y, 0]) cube([10, 1.2, esp_under + esp_pcb + 1.5]);

                // SHT31: Sockel (lässt den Stiftleisten-Streifen frei) + Zentrierstift
                translate([sht_cx - sht_w / 2 + 0.7, sht_bot + 0.7, 0])
                    cube([sht_w - 1.4, sht_l - sht_pin_strip - 0.7, esp_under]);
                translate([sht_cx + sht_w / 2 - sht_hole_y, sht_top - sht_hole_x, esp_under - 0.01])
                    cylinder(d = sht_peg_d, h = 2.0);
            }
        }

        in() {
            // Vorbohrungen Schraubdome
            post_positions() translate([0, 0, inner_d - 12]) cylinder(d = pilot_d, h = 13);

            // Kabeldurchführung durch beide Trennwände (unten, nahe Rückwand)
            translate([inner_w / 2 - wire_hole_w / 2, sensor_ch - 1, 2])
                cube([wire_hole_w, div_total + 2, wire_hole_h]);

            // USB-C-Ausschnitt rechte Wand (nach oben offen, Deckel schließt)
            usb_cz = esp_under + esp_pcb + esp_top_h / 2;
            translate([inner_w - 1, esp_cy - usb_w / 2, usb_cz - usb_h / 2])
                cube([wall + 2, usb_w, inner_d]);

            // Lüftung Sensorkammer: Unterseite + beide Seiten
            translate([0, -wall / 2, 0])      vents_x(post_s + 4, inner_w - post_s - 4, 5, inner_d - 3, wall + 2);
            translate([-wall / 2, 0, 0])      vents_y(post_s + 2, sensor_ch - 2, 5, inner_d - 3, wall + 2);
            translate([inner_w + wall / 2, 0, 0]) vents_y(post_s + 2, sensor_ch - 2, 5, inner_d - 3, wall + 2);

            // Lüftung ESP32-Kammer: Oberseite (Abwärme nach oben)
            translate([0, inner_h + wall / 2, 0]) vents_x(post_s + 6, inner_w - post_s - 6, 5, inner_d - 3, wall + 2);

            // Schlüssellöcher für Wandmontage
            for (x = [16, inner_w - 16])
                translate([x, esp_cy - 4, -floor_t]) keyhole();
        }
    }
}

// =============================================================================
//  Deckel (im eingebauten Zustand modelliert)
// =============================================================================
module lid() {
    difference() {
        union() {
            translate([0, 0, outer_d]) rbox([outer_w, outer_h, lid_t]);

            // Niederhalter: Modul-Abschirmblech und USB-C-Buchse
            hold = inner_d - esp_under - esp_pcb - esp_top_h;
            in() {
                translate([esp_x0 + 10, esp_cy - 5, inner_d - hold]) cube([10, 10, hold]);
                translate([esp_x1 - 6.5, esp_cy - 3, inner_d - hold]) cube([5, 6, hold]);
            }
        }

        in() {
            // Schraublöcher
            post_positions() translate([0, 0, inner_d - 1]) cylinder(d = screw_d, h = lid_t + 2);

            // Lüftung über dem Sensor
            translate([0, 0, inner_d - 1]) intersection() {
                translate([post_s + 3, 3, 0]) cube([inner_w - 2 * post_s - 6, sensor_ch - 6, lid_t + 2]);
                for (y = [3 : vent_pitch : sensor_ch - 3])
                    translate([0, y, 0]) cube([inner_w, vent_w, lid_t + 2]);
            }

            // Lüftung oben in der ESP32-Kammer
            translate([0, 0, inner_d - 1]) intersection() {
                translate([post_s + 3, esp_y1 + 1.5, 0]) cube([inner_w - 2 * post_s - 6, inner_h - esp_y1 - 2.5, lid_t + 2]);
                for (x = [0 : vent_pitch : inner_w])
                    translate([x, 0, 0]) cube([vent_w, inner_h, lid_t + 2]);
            }
        }
    }
}

// =============================================================================
//  Ausgabe
// =============================================================================
if (part == "base") {
    base();
} else if (part == "lid") {
    // Druckausrichtung: Außenseite aufs Druckbett
    translate([0, outer_h, outer_d + lid_t]) rotate([180, 0, 0]) lid();
} else {
    base();
    color("white", 0.35) lid();
}
