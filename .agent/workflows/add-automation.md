---
description: How to create and add a new automation to Home Assistant
---

# Add New Automation

This workflow guides you through creating a new automation following the established patterns in this Home Assistant setup.

## Automation File Location
All automations are stored in: `automations.yaml`

## Automation Structure Template
```yaml
- id: unique_automation_id
  alias: "Descriptive Name - German Preferred"
  description: "What this automation does"
  trigger:
    - platform: state|time|sun|template
      # trigger configuration
  condition:
    - condition: state|time|template
      # optional conditions
  action:
    - action: service.call
      target:
        entity_id: entity.name
      data:
        # service data
  mode: single|restart|queued|parallel
```

## Common Trigger Types

### State Trigger (Entity Changes)
```yaml
trigger:
  - platform: state
    entity_id: binary_sensor.motion_sensor_bewegung
    to: "on"
    id: motion_detected
```

### Time Trigger
```yaml
trigger:
  - platform: time
    at: "07:00:00"
```

### Sun Trigger
```yaml
trigger:
  - platform: sun
    event: sunrise|sunset
    offset: "01:00:00"
```

### Template Trigger
```yaml
trigger:
  - platform: template
    value_template: "{{ states('sensor.temperature')|float > 25 }}"
```

## Common Condition Types

### Time Condition
```yaml
condition:
  - condition: time
    after: "06:00:00"
    before: "22:00:00"
    weekday:
      - mon
      - tue
      - wed
      - thu
      - fri
```

### State Condition
```yaml
condition:
  - condition: state
    entity_id: binary_sensor.someone_home
    state: "on"
```

### Template Condition (Season Check)
```yaml
condition:
  - condition: template
    value_template: "{{ now().month in [11, 12, 1, 2] }}"
```

## Established Patterns in This Setup

### 1. True Presence Light Control
```yaml
- id: light_room_smart_presence
  alias: "Room - Smartes Licht (True Presence)"
  description: "Controls lights based on True Presence"
  trigger:
    - platform: state
      entity_id: binary_sensor.room_true_presence
      to: "on"
      id: occupied
    - platform: state
      entity_id: binary_sensor.room_true_presence
      to: "off"
      id: vacant
  action:
    - choose:
        - conditions:
            - condition: trigger
              id: occupied
          sequence:
            - action: light.turn_on
              target:
                entity_id: light.room_light
              data:
                brightness_pct: "{{ states('input_number.flux_brightness')|int }}"
                kelvin: "{{ states('input_number.flux_kelvin')|int }}"
                transition: 2
        - conditions:
            - condition: trigger
              id: vacant
          sequence:
            - action: light.turn_off
              target:
                entity_id: light.room_light
              data:
                transition: 2
  mode: restart
```

### 2. Seasonal Blind Control
```yaml
- id: shutters_control_season
  alias: "Rollläden - Seasonal Control"
  trigger:
    - platform: sun
      event: sunrise|sunset
      offset: "HH:MM:SS"
  condition:
    - condition: template
      value_template: "{{ now().month in [MONTHS] }}"
  action:
    - action: script.safe_open_blind|safe_close_blind
      data:
        cover_entity: cover.name_vorhang
        tracker_entity: input_boolean.blind_name_last_opened
  mode: single
```

### 3. Wake-up Automation (Weekday/Weekend)
```yaml
- id: morning_wakeup_weekday
  alias: "Morgen - Aufwachen Werktag"
  trigger:
    - platform: time
      at: "05:00"
  condition:
    - condition: time
      weekday: [mon, tue, wed, thu, fri]
  action:
    - action: light.turn_on
      target:
        entity_id: light.bett_licht
      data:
        brightness_pct: 5
        color_temp_kelvin: 2700
        transition: 1800  # 30 min gradual
  mode: single
```

## Steps to Add New Automation

1. **Edit automations.yaml**
   ```powershell
   code automations.yaml
   ```

2. **Add your automation at the end of the file**

3. **Validate YAML syntax**
   Use the Home Assistant Developer Tools → Template to test templates

4. **Deploy to Home Assistant**
   ```powershell
   .\sync_to_ha.ps1
   ```

5. **Reload automations**
   - Via UI: Developer Tools → YAML → Reload Automations
   - Via API: Called automatically by sync_to_ha.ps1

## Naming Conventions
- **id**: lowercase with underscores, e.g., `light_kitchen_motion`
- **alias**: German preferred, descriptive, e.g., "Küche - Bewegungslicht"
- Use consistent prefixes: "Rollläden -", "Licht -", "Morgen -", etc.

## Testing
After deployment:
1. Go to Settings → Automations
2. Find your new automation
3. Click the three dots → Trace to test
4. Manually trigger to verify behavior
