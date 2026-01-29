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

## Tuya ZigBee mmWave Sensor Limitations (ZY-M100 / WZ-M100)

Based on extensive user feedback and testing, the Tuya ZigBee presence sensors have known limitations:

### Known Issues

| Issue | Description | Impact |
|-------|-------------|--------|
| **60-second absence delay** | Firmware-level delay before sensor reports "off" | Lights stay on longer than expected |
| **Intermittent unavailability** | Sensor goes offline randomly | Automations don't trigger |
| **False positives** | Reports "present" even when room is empty | Lights won't turn off |
| **No obstacle penetration** | Requires direct line of sight | Misses people behind furniture |
| **Limited ZHA functionality** | Only presence/illuminance in ZHA, no distance | Missing advanced features |

### Vendor Warning

Tuya officially states their ZigBee products do **NOT** support:
- Zigbee2MQTT
- Home Assistant (directly)

They recommend using their Tuya Smart app only. However, with custom ZHA quirks, the sensors can work in Home Assistant with limitations.

### Workarounds

#### 1. Increase Off-Delay in Automations
Account for the 60-second sensor delay plus buffer time:
```yaml
trigger:
  - platform: state
    entity_id: binary_sensor.tuya_presence
    to: "off"
    for: "00:03:00"  # 3 minutes total = 60s sensor + 2min buffer
```

#### 2. Handle Unavailable State
Add fallback for when sensor goes offline:
```yaml
condition:
  - condition: not
    conditions:
      - condition: state
        entity_id: binary_sensor.tuya_presence
        state: "unavailable"
```

#### 3. Power Cycle Script
Create a script to power cycle the sensor when it gets stuck:
```yaml
script:
  reset_tuya_presence:
    sequence:
      - service: zha.remove
        data:
          ieee: "your_sensor_ieee"
      - delay: "00:00:30"
      - service: zha.permit
```

#### 4. Use Custom Quirks
For full functionality with ZHA, custom quirks are required. See the community guide:
https://community.home-assistant.io/t/tuya-zha-quirk-for-zy-m100

Custom quirks location: `/config/custom_zha_quirks/`

### Alternative Sensors

If Tuya sensors don't work well for your setup, consider:

| Sensor | Protocol | Pros | Cons |
|--------|----------|------|------|
| **Aqara FP2** | WiFi | Reliable, multi-zone, no quirks needed | Expensive, cloud-dependent |
| **Sonoff SNZB-03** | ZigBee | Cheap, reliable PIR | Motion only, not presence |
| **Everything Presence One** | ESPHome | Local, configurable | DIY, requires ESP32 |

### Current Sensor Configuration

This Home Assistant uses the following presence sensors:

| Room | Sensor | Type | Notes |
|------|--------|------|-------|
| Wohnzimmer | FP2 | WiFi mmWave | Most reliable |
| Küche | Tuya | ZigBee mmWave | Has 60s delay |
| Bad | Tuya | ZigBee mmWave | Has 60s delay |
| Schlafzimmer | Tuya | ZigBee mmWave | Has 60s delay |
| Kiffzimmer | Tuya | ZigBee mmWave | Has 60s delay |

### Debugging Tuya Sensors

1. **Check ZHA logs for communication issues:**
   ```
   Developer Tools → Logs → Filter: zha
   ```

2. **Monitor sensor state changes:**
   ```
   Developer Tools → States → binary_sensor.room_motion_sensor
   ```

3. **Test if sensor is responsive:**
   - Wave hand in front of sensor
   - Check if state changes within 1-2 seconds for "on"
   - Check if state changes within 60-90 seconds for "off"

4. **If sensor is stuck "on":**
   - Power cycle the sensor (unplug USB-C)
   - Wait 30 seconds
   - Plug back in
   - Re-interview in ZHA if needed
