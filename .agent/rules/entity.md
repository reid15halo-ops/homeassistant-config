---
trigger: always_on
---

# Home Assistant Entity Reference
Generated: 2026-01-20
Total Entities: 326

## Lights (13)
```
light.buffet_lichtstreifen
light.kuche_birne_2_2
light.kuche_birne_1
light.kuche_streifen
light.bad_2
light.bett_licht_2
light.kiffzimmer_lichtstreifen
light.buffet_licht
light.bad_licht
light.bett_licht
light.computer_licht
light.rollladen_computer_hintergrundbeleuchtung
light.kuche_rollladen_hintergrundbeleuchtung
```

## Covers/Blinds (4)
```
cover.rollladen_computer_vorhang
cover.schlafen_blind_vorhang
cover.kuche_blind_vorhang
cover.yoga_blind_vorhang
```

## Climate/Thermostats (2)
```
climate.thermostat_computer
climate.thermostat_bad
```

## Fans (2)
```
fan.ceiling_fan_with_light
fan.dc_fan_lamp
```

## Binary Sensors - Motion/Presence (41)
### PIR Motion Sensors
```
binary_sensor.human_presence_detector_bewegung
binary_sensor.human_presence_detector_2_bewegung
binary_sensor.human_presence_detector_3_bewegung
binary_sensor.motion_sensor_kuche_bewegung
binary_sensor.motion_sensor_bad_bewegung
binary_sensor.motion_sensor_schlafen_bewegung
binary_sensor.kiffzimmer_motion_sensor
binary_sensor.human_presence_detector_schlaf_bewegung
```

### mmWave/Presence Sensors
```
binary_sensor.badezimmer_motion_sensor
binary_sensor.presence_bad_bewegung
binary_sensor.wohnzimmer_aqara_fp2_presence_sensor_1
binary_sensor.living_room_presence
binary_sensor.kitchen_presence
binary_sensor.schlafen_presence
```

### Template Sensors (True Presence)
```
binary_sensor.wohnzimmer_true_presence
binary_sensor.kuche_true_presence
binary_sensor.bad_true_presence
binary_sensor.schlafen_true_presence
binary_sensor.kiffzimmer_true_presence
binary_sensor.jemand_zuhause
binary_sensor.heizperiode
binary_sensor.dunkel_draussen
binary_sensor.sommerbetrieb_ortsbasiert
```

## Switches (30)
```
switch.kiffzimmer_aktivkohlefilter
switch.t34_smart_plug_schalter_1
switch.roborock_q7_max_do_not_disturb
switch.roborock_q7_max_child_lock
```

## Input Booleans (19)
```
input_boolean.gaming_mode
input_boolean.movie_mode
input_boolean.party_mode
input_boolean.vacation_mode
input_boolean.sleep_mode
input_boolean.guest_mode
input_boolean.away_mode
input_boolean.stream_mode
input_boolean.heizung_eco_mode
input_boolean.heizung_winter_mode
input_boolean.auto_lights_enabled
input_boolean.auto_shutters_enabled
input_boolean.auto_heating_enabled
input_boolean.fire_effect
input_boolean.blind_computer_last_opened
input_boolean.blind_schlafen_last_opened
input_boolean.blind_kuche_last_opened
input_boolean.blind_yoga_last_opened
input_boolean.someone_sleeping
```

## Input Numbers (10)
```
input_number.pos_computer
input_number.pos_kuche
input_number.pos_yoga
input_number.pos_schlafen
input_number.heizung_solltemperatur_komfort
input_number.heizung_solltemperatur_eco
input_number.heizung_solltemperatur_nacht
input_number.motion_timeout
input_number.flux_kelvin
input_number.flux_brightness
```

## Input Selects (2)
```
input_select.ambient_modus
input_select.home_mode
```

## Scripts (13)
```
script.ambient_fire_effect
script.ambient_velvet_rainbow
script.announce_alexa
script.lights_bedtime
script.all_covers_open
script.all_covers_close
script.light_toggle_with_brightness
script.safe_open_blind
script.safe_close_blind
script.heating_comfort_now
script.fan_winter_heat_now
```

## Vacuum (1)
```
vacuum.roborock_q7_max
```

## Persons (2)
```
person.jonas_glawion
person.redmi_note_12_pro_5g
```

## Other Important Entities
```
sun.sun
sensor.aktuelle_jahreszeit
sensor.rollladen_offset_minuten
binary_sensor.roborock_q7_max_reinigen
```

---

## Entity Naming Conventions

| Domain | Example | Description |
|--------|---------|-------------|
| `light.*` | `light.buffet_licht` | All light entities |
| `cover.*_vorhang` | `cover.rollladen_computer_vorhang` | Roller blinds |
| `binary_sensor.*_bewegung` | `binary_sensor.motion_sensor_kuche_bewegung` | Motion sensors |
| `binary_sensor.*_true_presence` | `binary_sensor.wohnzimmer_true_presence` | Combined presence |
| `climate.thermostat_*` | `climate.thermostat_bad` | Heating thermostats |
| `input_boolean.blind_*_last_opened` | `input_boolean.blind_computer_last_opened` | Blind trackers |

## Quick Reference by Room

### Wohnzimmer (Living Room)
- Light: `light.buffet_licht`, `light.buffet_lichtstreifen`
- Presence: `binary_sensor.wohnzimmer_true_presence`
- Blind: `cover.rollladen_computer_vorhang`

### Küche (Kitchen)
- Lights: `light.kuche_birne_1`, `light.kuche_birne_2_2`, `light.kuche_streifen`
- Presence: `binary_sensor.kuche_true_presence`
- Blind: `cover.kuche_blind_vorhang`

### Bad (Bathroom)
- Light: `light.bad_licht`, `light.bad_2`
- Presence: `binary_sensor.bad_true_presence`
- Climate: `climate.thermostat_bad`

### Schlafzimmer (Bedroom)
- Light: `light.bett_licht`, `light.bett_licht_2`
- Presence: `binary_sensor.schlafen_true_presence`
- Blind: `cover.schlafen_blind_vorhang`

### Kiffzimmer
- Light: `light.kiffzimmer_lichtstreifen`, `light.computer_licht`
- Presence: `binary_sensor.kiffzimmer_true_presence`
- Blind: `cover.yoga_blind_vorhang`
- Climate: `climate.thermostat_computer`
