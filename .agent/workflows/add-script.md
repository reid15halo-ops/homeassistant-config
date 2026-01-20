---
description: How to create and add a new script to Home Assistant
---

# Add New Script

Scripts are reusable sequences of actions that can be called from automations, dashboards, or other scripts.

## Script File Location
All scripts are stored in: `scripts.yaml`

## Script Structure Template
```yaml
script_id:
  alias: "Descriptive Name"
  description: "What this script does"
  mode: single|restart|queued|parallel
  fields:
    parameter_name:
      description: "Parameter description"
      required: true|false
      example: "example value"
      default: "default value"
  sequence:
    - action: service.call
      target:
        entity_id: entity.name
      data:
        key: value
```

## Script Modes
| Mode | Behavior |
|------|----------|
| `single` | Won't start if already running (default) |
| `restart` | Stop current run and start new |
| `queued` | Queue runs and execute in order |
| `parallel` | Run multiple instances simultaneously |

## Established Scripts in This Setup

### 1. Safe Blind Control (Anti-Jamming)
```yaml
safe_open_blind:
  alias: "Safe Open Blind"
  description: "Opens blind only if it wasn't already opened"
  mode: single
  fields:
    cover_entity:
      description: "Cover entity to open"
      example: "cover.rollladen_computer_vorhang"
    tracker_entity:
      description: "Tracker boolean"
      example: "input_boolean.blind_computer_last_opened"
  sequence:
    - choose:
        - conditions:
            - condition: template
              value_template: "{{ is_state(tracker_entity, 'off') }}"
          sequence:
            - action: cover.open_cover
              target:
                entity_id: "{{ cover_entity }}"
            - action: input_boolean.turn_on
              target:
                entity_id: "{{ tracker_entity }}"
      default:
        - action: system_log.write
          data:
            message: "Skipped opening {{ cover_entity }}"
            level: warning
```

### 2. Ambient Light Effects
```yaml
ambient_fire_effect:
  alias: "Ambient – Fire Effect"
  mode: restart
  sequence:
    - action: tplink.random_effect
      target:
        entity_id: light.buffet_licht
      data:
        init_states: 2700,100,50
        segments: 0
        brightness: 70
        transition: 900
        hue_range: 26,42
        saturation_range: 35,70
        brightness_range: 10,92
```

### 3. Smart Light Toggle
```yaml
light_toggle_with_brightness:
  alias: "Toggle Light with Smart Brightness"
  mode: single
  fields:
    target_light:
      description: "Light entity to toggle"
      required: true
    brightness_day:
      default: 100
    brightness_night:
      default: 30
  sequence:
    - action: light.toggle
      target:
        entity_id: "{{ target_light }}"
      data:
        brightness_pct: >
          {% if is_state('sun.sun', 'above_horizon') %}
            {{ brightness_day }}
          {% else %}
            {{ brightness_night }}
          {% endif %}
```

### 4. Alexa Announcements
```yaml
announce_alexa:
  alias: "Announce via Alexa"
  mode: single
  fields:
    message:
      description: "Message to announce"
      required: true
    title:
      required: false
  sequence:
    - action: notify.alexa_media_wohnzimmer
      data:
        title: "{{ title | default('Home Assistant') }}"
        message: "{{ message }}"
      continue_on_error: true
```

### 5. Heating Control
```yaml
heating_comfort_now:
  alias: "Heizung - Sofort Komfort"
  description: "Set heating to comfort temperature"
  mode: single
  sequence:
    - action: climate.set_temperature
      target:
        entity_id:
          - climate.thermostat_bad
          - climate.thermostat_wohnzimmer
      data:
        temperature: "{{ states('input_number.heizung_solltemperatur')|float }}"
```

### 6. Open/Close All Covers
```yaml
all_covers_open:
  alias: "Open All Covers"
  mode: single
  sequence:
    - action: script.safe_open_blind
      data:
        cover_entity: cover.rollladen_computer_vorhang
        tracker_entity: input_boolean.blind_computer_last_opened
    - action: script.safe_open_blind
      data:
        cover_entity: cover.kuche_blind_vorhang
        tracker_entity: input_boolean.blind_kuche_last_opened
    # ... repeat for all blinds
```

## Steps to Add New Script

1. **Edit scripts.yaml**
   ```powershell
   code scripts.yaml
   ```

2. **Add your script** (maintain proper YAML indentation)

3. **Deploy to Home Assistant**
   ```powershell
   .\sync_to_ha.ps1
   ```

4. **Reload scripts**
   - Automatic via sync_to_ha.ps1
   - Or: Developer Tools → YAML → Reload Scripts

## Calling Scripts

### From Automation
```yaml
action:
  - action: script.script_id
    data:
      parameter: value
```

### From Dashboard Button
```yaml
type: button
tap_action:
  action: call-service
  service: script.script_id
  data:
    parameter: value
```

### From Another Script
```yaml
sequence:
  - action: script.turn_on
    target:
      entity_id: script.script_id
    data:
      variables:
        parameter: value
```

## Using Variables & Templates
```yaml
my_script:
  sequence:
    - variables:
        calculated_value: "{{ states('sensor.something')|float * 2 }}"
    - action: light.turn_on
      target:
        entity_id: light.example
      data:
        brightness_pct: "{{ calculated_value }}"
```
