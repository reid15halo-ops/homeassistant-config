---
description: How True Presence detection works combining PIR and mmWave sensors
---

# True Presence Detection System

This setup uses "True Presence" template binary sensors that combine multiple motion/presence sensors for reliable room occupancy detection.

## Why True Presence?

### Problem with Single Sensors
- **PIR sensors**: Only detect motion, not presence (miss stationary people)
- **mmWave sensors**: Can have false positives (fans, pets, reflections)

### Solution
Combine both sensor types with intelligent logic:
- PIR catches initial motion
- mmWave detects stationary presence
- Delay-off prevents flickering

## True Presence Sensors

| Room | Entity | Delay Off |
|------|--------|-----------|
| Wohnzimmer | `binary_sensor.wohnzimmer_true_presence` | 1 min |
| Küche | `binary_sensor.kuche_true_presence` | 1 min |
| Bad | `binary_sensor.bad_true_presence` | 1 min |
| Schlafzimmer | `binary_sensor.schlafen_true_presence` | 30 sec |
| Kiffzimmer | `binary_sensor.kiffzimmer_true_presence` | 1 min |

## Configuration (in configuration.yaml)

```yaml
template:
  - binary_sensor:
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

      - name: "Küche True Presence"
        unique_id: kuche_true_presence
        delay_off: "00:01:00"
        state: >
          {{ 
             is_state('binary_sensor.human_presence_detector_3_bewegung', 'on')
             or is_state('binary_sensor.kitchen_presence', 'on')
          }}
        icon: mdi:stove
```

## How It Works

### Logic Flow
```
PIR Motion Detected  ──┐
                       ├──▶ OR Gate ──▶ True Presence = ON
mmWave Presence ───────┘

All Sensors OFF ───▶ Wait 60s ───▶ True Presence = OFF
```

### Delay-Off Explanation
The `delay_off: "00:01:00"` means:
- Sensor turns ON immediately when any source detects presence
- Sensor stays ON for 1 minute AFTER all sources turn off
- This prevents lights flickering when you briefly leave sensor range

## Sensors Per Room

### Wohnzimmer (Living Room)
| Sensor | Type | Entity |
|--------|------|--------|
| PIR Motion | ZHA | `binary_sensor.human_presence_detector_bewegung` |
| Aqara FP2 | mmWave | `binary_sensor.wohnzimmer_aqara_fp2_presence_sensor_1` |
| Tuya Presence | mmWave | `binary_sensor.living_room_presence` |

### Küche (Kitchen)
| Sensor | Type | Entity |
|--------|------|--------|
| PIR Motion | ZHA | `binary_sensor.human_presence_detector_3_bewegung` |
| Tuya Presence | mmWave | `binary_sensor.kitchen_presence` |

### Bad (Bathroom)
| Sensor | Type | Entity |
|--------|------|--------|
| PIR Motion | ZHA | `binary_sensor.motion_sensor_bad_bewegung` |
| mmWave | WiFi | `binary_sensor.badezimmer_motion_sensor` |
| Tuya Presence | mmWave | `binary_sensor.presence_bad_bewegung` |

### Schlafzimmer (Bedroom)
| Sensor | Type | Entity |
|--------|------|--------|
| PIR Motion | ZHA | `binary_sensor.motion_sensor_schlafen_bewegung` |
| mmWave | Tuya | `binary_sensor.schlafen_presence` |

## Using True Presence in Automations

### Light Control Pattern
```yaml
- id: light_room_smart_presence
  alias: "Room - Smartes Licht (True Presence)"
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

## Adding a New True Presence Sensor

1. **Identify all sensors for the room**
   - List PIR motion sensors
   - List mmWave/presence sensors

2. **Add to configuration.yaml**
```yaml
template:
  - binary_sensor:
      - name: "NewRoom True Presence"
        unique_id: newroom_true_presence
        delay_off: "00:01:00"
        state: >
          {{ 
             is_state('binary_sensor.motion_sensor_1', 'on')
             or is_state('binary_sensor.presence_sensor_1', 'on')
          }}
        icon: mdi:motion-sensor
```

3. **Restart Home Assistant** (configuration.yaml changes require restart)

4. **Create light automation** using the new sensor

## Tuning Delay-Off

| Use Case | Recommended Delay |
|----------|------------------|
| Bathroom | 1-2 min (short visits) |
| Kitchen | 1-2 min (cooking activities) |
| Living Room | 2-3 min (TV watching, reading) |
| Bedroom | 30 sec (quick transition to sleep) |
| Office | 3-5 min (focused work) |

## Troubleshooting

### Lights Turn Off While Room is Occupied
- Increase `delay_off` value
- Check if all sensors are being included in the template
- Add another sensor type (PIR or mmWave)

### Lights Stay On When Room is Empty
- Check for sensor false positives (fans, pets, moving curtains)
- Reduce `delay_off` value
- Check sensor placement (avoid HVAC vents, mirrors)

### Debug in Developer Tools
Check each sensor state:
```
States → Filter: binary_sensor.room
```

Test the True Presence sensor logic:
```
Developer Tools → Template:
{{ 
   is_state('binary_sensor.sensor_1', 'on')
   or is_state('binary_sensor.sensor_2', 'on')
}}
```
