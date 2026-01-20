---
description: How to add template sensors, binary sensors, and input helpers
---

# Add Template Entities & Helpers

This workflow covers adding new template sensors, binary sensors, input booleans, input numbers, and input selects.

## File Locations
| Entity Type | Location |
|-------------|----------|
| Template Sensors | `configuration.yaml` (under `template:`) |
| Template Binary Sensors | `configuration.yaml` (under `template:`) |
| Input Booleans | `input_boolean.yaml` |
| Input Numbers | `configuration.yaml` (under `input_number:`) |
| Input Selects | `configuration.yaml` (under `input_select:`) |

---

## Template Sensors

### Location in configuration.yaml
```yaml
template:
  - sensor:
      - name: "Sensor Name"
        unique_id: sensor_unique_id
        state: >
          {{ template_expression }}
        unit_of_measurement: "unit"
        icon: mdi:icon-name
```

### Examples from This Setup

#### Season Sensor
```yaml
- name: "Aktuelle Jahreszeit"
  unique_id: aktuelle_jahreszeit
  state: >
    {% set month = now().month %}
    {% if month in [3, 4, 5] %}
      Frühling
    {% elif month in [6, 7, 8] %}
      Sommer
    {% elif month in [9, 10, 11] %}
      Herbst
    {% else %}
      Winter
    {% endif %}
```

#### Calculated Value Sensor
```yaml
- name: "Solar Offset Minuten"
  unique_id: solar_offset_minuten
  state: >
    {% set month = now().month %}
    {% if month in [5, 6, 7, 8, 9] %}
      120
    {% elif month in [3, 4, 10] %}
      60
    {% else %}
      0
    {% endif %}
```

---

## Template Binary Sensors

### Location in configuration.yaml
```yaml
template:
  - binary_sensor:
      - name: "Binary Sensor Name"
        unique_id: binary_sensor_id
        state: "{{ template_returning_true_or_false }}"
        delay_off: "00:01:00"  # optional delay before turning off
        icon: mdi:icon-name
```

### Examples from This Setup

#### True Presence Sensor (Combines Multiple Motion Sensors)
```yaml
- name: "Wohnzimmer True Presence"
  unique_id: wohnzimmer_true_presence
  delay_off: "00:01:00"
  state: >
    {{ 
       is_state('binary_sensor.human_presence_detector_bewegung', 'on')
       or is_state('binary_sensor.wohnzimmer_aqara_fp2_presence_sensor_1', 'on')
       or is_state('binary_sensor.living_room_presence', 'on')
    }}
  icon: mdi:sofa
```

#### Heating Required Sensor
```yaml
- name: "Heizung notwendig"
  unique_id: heizung_notwendig
  state: "{{ states('sensor.openweathermap_temperature')|float(0) < 16 }}"
  icon: mdi:radiator
```

#### Dark Outside
```yaml
- name: "Dunkel draußen"
  unique_id: dunkel_draussen
  state: "{{ is_state('sun.sun', 'below_horizon') }}"
  icon: mdi:weather-night
```

---

## Input Booleans

### Location: input_boolean.yaml
```yaml
blind_name_last_opened:
  name: "Rollladen Name - Letzter Status"
  icon: mdi:window-shutter
```

### Examples from This Setup
```yaml
# Blind tracking (for anti-jamming)
blind_computer_last_opened:
  name: "Rollladen Computer - Last Opened"
  icon: mdi:window-shutter-open

blind_kuche_last_opened:
  name: "Rollladen Küche - Last Opened"
  icon: mdi:window-shutter-open

# Mode toggles
sleep_mode:
  name: "Schlafmodus"
  icon: mdi:sleep

vacation_mode:
  name: "Urlaubsmodus"
  icon: mdi:palm-tree
```

---

## Input Numbers

### Location in configuration.yaml
```yaml
input_number:
  helper_name:
    name: "Display Name"
    min: 0
    max: 100
    step: 1
    initial: 50
    unit_of_measurement: "%"
    mode: slider|box
    icon: mdi:icon-name
```

### Examples from This Setup
```yaml
# Blind positions
pos_computer:
  name: "Rollladen Computer Position"
  min: 0
  max: 100
  step: 1
  unit_of_measurement: "%"
  mode: box
  icon: mdi:window-shutter

# Temperature settings
heizung_solltemperatur:
  name: "Heizung Soll-Temperatur"
  min: 15
  max: 25
  step: 0.5
  initial: 21
  unit_of_measurement: "°C"
  mode: slider
  icon: mdi:thermometer

# Adaptive lighting
flux_kelvin:
  name: "Flux Target Kelvin"
  min: 2000
  max: 6500
  step: 100
  initial: 2700
  mode: box
  icon: mdi:temperature-kelvin

flux_brightness:
  name: "Flux Target Brightness"
  min: 1
  max: 100
  step: 1
  initial: 80
  mode: box
  icon: mdi:brightness-6
```

---

## Input Selects

### Location in configuration.yaml
```yaml
input_select:
  select_name:
    name: "Display Name"
    options:
      - "Option 1"
      - "Option 2"
      - "Option 3"
    initial: "Option 1"
    icon: mdi:icon-name
```

### Examples from This Setup
```yaml
ambient_modus:
  name: "Ambient Modus"
  options:
    - "Aus"
    - "Fire"
    - "Rainbow"
    - "Cozy"
  initial: "Aus"
  icon: mdi:lightbulb-group

haus_modus:
  name: "Haus Modus"
  options:
    - "Normal"
    - "Gäste"
    - "Party"
    - "Urlaub"
  initial: "Normal"
  icon: mdi:home-assistant
```

---

## Steps to Add New Entity

### For Template Sensors/Binary Sensors
1. Edit `configuration.yaml`
2. Find the `template:` section
3. Add under `- sensor:` or `- binary_sensor:`
4. **Requires Home Assistant restart** (configuration.yaml changes)

### For Input Booleans
1. Edit `input_boolean.yaml`
2. Add new entry at end of file
3. Deploy and reload: `input_boolean/reload`

### For Input Numbers/Selects
1. Edit `configuration.yaml`
2. Find `input_number:` or `input_select:` section
3. Add new entry
4. **Requires Home Assistant restart**

## Deployment
```powershell
.\sync_to_ha.ps1
```

For configuration.yaml changes, restart HA:
- Settings → System → Restart
