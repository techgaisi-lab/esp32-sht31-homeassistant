# ESP32 SHT31 Home Assistant Sensor

Temperatur- und Luftfeuchtigkeitssensor für **Home Assistant** auf Basis eines **ESP32 DevKit** und eines **Sensirion SHT31-D**.
Die Firmware ist reine [ESPHome](https://esphome.io)-Konfiguration: kein eigener C++-Code und kein MQTT-Broker. Das Gerät wird in Home Assistant automatisch erkannt.

![Platform](https://img.shields.io/badge/platform-ESP32-blue)
![Firmware](https://img.shields.io/badge/firmware-ESPHome-black)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Funktionen

| Entität           | Einheit | Beschreibung                                  |
|-------------------|---------|-----------------------------------------------|
| Temperatur        | °C      | Messwert des SHT31, geglättet                 |
| Luftfeuchtigkeit  | %       | Relative Luftfeuchtigkeit, geglättet          |
| Taupunkt          | °C      | Berechnet aus Temperatur und Feuchte (Magnus) |
| WLAN-Signal       | dBm     | Diagnose                                      |
| Laufzeit          | s       | Diagnose                                      |
| IP-Adresse        | –       | Diagnose                                      |
| Status            | –       | Online/Offline                                |
| Neustart          | –       | Button zum Neustarten des ESP32               |

Außerdem dabei: verschlüsselte API, Updates über WLAN (OTA) und ein Fallback-Hotspot, falls das WLAN nicht erreichbar ist.

## Hardware

- ESP32 DevKit (z. B. ESP32-WROOM-32 DevKitC)
- SHT31-D Breakout-Board (I²C)
- 4 Jumper-Kabel
- Micro-USB-/USB-C-Kabel und ein 5-V-Netzteil

## Verdrahtung

| SHT31-D | ESP32   |
|---------|---------|
| VIN     | 3V3     |
| GND     | GND     |
| SDA     | GPIO21  |
| SCL     | GPIO22  |
| ADR     | frei → Adresse `0x44` |

```
 SHT31-D            ESP32 DevKit
 ┌──────┐          ┌────────────┐
 │ VIN  ├──────────┤ 3V3        │
 │ GND  ├──────────┤ GND        │
 │ SCL  ├──────────┤ GPIO22     │
 │ SDA  ├──────────┤ GPIO21     │
 └──────┘          └────────────┘
```

> **Tipp:** Den Sensor mit ein paar Zentimetern Abstand zum ESP32 montieren. Der ESP32 erwärmt sich im Betrieb, und direkt daneben misst der Sensor sonst zu hohe Temperaturen.

## Installation

### 1. Repository klonen

```bash
git clone https://github.com/techgaisi-lab/esp32-sht31-homeassistant.git
cd esp32-sht31-homeassistant
```

### 2. Zugangsdaten anlegen

```bash
cp secrets.example.yaml secrets.yaml
```

`secrets.yaml` mit eigenem WLAN und Passwörtern ausfüllen. Den API-Key erzeugst du mit:

```bash
openssl rand -base64 32
```

### 3. Flashen

**Variante A: ESPHome Add-on in Home Assistant**

1. *Einstellungen → Add-ons → ESPHome Device Builder* installieren und öffnen
2. Inhalt von `esp32-sht31.yaml` als neues Gerät einfügen und die Werte aus `secrets.yaml` in die ESPHome-Secrets übernehmen
3. **Install → Plug into this computer** (beim ersten Mal per USB, danach per WLAN)

**Variante B: ESPHome CLI**

```bash
pip install esphome
esphome run esp32-sht31.yaml
```

### 4. In Home Assistant hinzufügen

Nach dem Start taucht das Gerät unter *Einstellungen → Geräte & Dienste* als **ESPHome** auf. Dort auf **Konfigurieren** klicken und den API-Key aus `secrets.yaml` eingeben.

## Konfiguration

Die wichtigsten Einstellungen stehen gesammelt oben in `esp32-sht31.yaml` unter `substitutions`:

| Variable          | Standard       | Beschreibung                          |
|-------------------|----------------|---------------------------------------|
| `device_name`     | `esp32-sht31`  | Hostname im Netzwerk                  |
| `friendly_name`   | `Raumklima`    | Anzeigename in Home Assistant         |
| `update_interval` | `30s`          | Messintervall                         |
| `i2c_sda`         | `GPIO21`       | SDA-Pin                               |
| `i2c_scl`         | `GPIO22`       | SCL-Pin                               |
| `sht31_address`   | `0x44`         | `0x45`, wenn ADR auf 3V3 liegt        |

Für **mehrere Sensoren** einfach die YAML-Datei kopieren und `device_name` sowie `friendly_name` ändern, zum Beispiel `sht31-wohnzimmer` und `sht31-schlafzimmer`.

**Kalibrierung:** Weicht ein Wert von einem Referenzthermometer ab, kannst du ihn über den `offset`-Filter beim jeweiligen Sensor korrigieren.

## Fehlerbehebung

| Problem                                | Lösung                                                                 |
|----------------------------------------|------------------------------------------------------------------------|
| `Communication failed` / Werte `NaN`   | SDA und SCL vertauscht? Im Log nach dem I²C-Scan suchen (`Found i2c device at address 0x44`). |
| Nur Adresse `0x45` gefunden            | `sht31_address: "0x45"` setzen                                          |
| Temperatur zu hoch                     | Sensor weiter vom ESP32 entfernt montieren oder `offset` anpassen       |
| Gerät nicht in Home Assistant sichtbar | ESP32 und Home Assistant im selben Netz? Logs prüfen: `esphome logs esp32-sht31.yaml` |
| WLAN nicht erreichbar                  | Mit dem Hotspot `Raumklima Fallback` verbinden und WLAN neu eintragen   |

## Projektstruktur

```
.
├── esp32-sht31.yaml        # ESPHome-Konfiguration (Firmware)
├── secrets.example.yaml    # Vorlage für Zugangsdaten
├── .gitignore              # schließt secrets.yaml und Build-Dateien aus
├── LICENSE
└── README.md
```

## Lizenz

[MIT](LICENSE) © 2026 Lorenz Gaishofer
