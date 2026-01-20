---
description: How blinds/shutters work in this setup including anti-jamming protection
---

# Blind/Shutter Control System

This setup uses Aqara roller blinds with a sophisticated anti-jamming protection system to prevent motor damage from repeated open/close commands.

## Available Blinds
| Cover Entity | Location | Tracker Boolean |
|-------------|----------|-----------------|
| `cover.rollladen_computer_vorhang` | Computer Room | `input_boolean.blind_computer_last_opened` |
| `cover.kuche_blind_vorhang` | Kitchen | `input_boolean.blind_kuche_last_opened` |
| `cover.yoga_blind_vorhang` | Yoga Room | `input_boolean.blind_yoga_last_opened` |
| `cover.schlafen_blind_vorhang` | Bedroom | `input_boolean.blind_schlafen_last_opened` |

## Anti-Jamming System

### Problem
Aqara blinds can jam if you send multiple "open" commands in a row (e.g., if sunrise automation runs twice). The motor tries to open an already-open blind and can get stuck.

### Solution
Each blind has a "tracker" input_boolean that tracks whether the last action was open or close:
- `on` = Last action was OPEN
- `off` = Last action was CLOSE

### Safe Open/Close Scripts

**Always use these scripts instead of direct cover.open_cover/close_cover:**

#### Safe Open (scripts.yaml)
```yaml
safe_open_blind:
  alias: "Safe Open Blind"
  sequence:
    - choose:
        # Only open if last action was NOT open
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
        # Skip - already opened
        - action: system_log.write
          data:
            message: "Skipped opening {{ cover_entity }} - prevents jam"
            level: warning
```

#### Safe Close (scripts.yaml)
```yaml
safe_close_blind:
  alias: "Safe Close Blind"
  sequence:
    # Always allowed - multiple closes are safe
    - action: cover.close_cover
      target:
        entity_id: "{{ cover_entity }}"
    - action: input_boolean.turn_off
      target:
        entity_id: "{{ tracker_entity }}"
```

## How to Use in Automations

### Correct Way ✅
```yaml
action:
  - action: script.safe_open_blind
    data:
      cover_entity: cover.rollladen_computer_vorhang
      tracker_entity: input_boolean.blind_computer_last_opened
```

### Wrong Way ❌
```yaml
action:
  - action: cover.open_cover
    target:
      entity_id: cover.rollladen_computer_vorhang
```

## Seasonal Blind Schedules

### Winter (Nov, Dec, Jan, Feb)
- **Open**: Sunrise + 1 hour (for solar gain/free heating)
- **Close**: Sunset (retain heat)

### Spring/Fall (Mar, Apr, Oct)
- **Open**: Sunrise + 30 min
- **Close**: Sunset + 1 hour

### Summer (May - Sep)
- **Open**: Sunrise (early, but not before 6 AM)
- **Close**: Sunset + 2 hours

## Automation Examples

### Open All Blinds (Seasonal)
```yaml
- id: shutters_open_winter_weekend
  alias: "Rollläden - Öffnen Winter Wochenende"
  trigger:
    - platform: sun
      event: sunrise
      offset: "01:00:00"
  condition:
    - condition: template
      value_template: "{{ now().month in [11, 12, 1, 2] }}"
    - condition: time
      weekday: [sat, sun]
  action:
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

### Close Bedroom for Sleep
```yaml
- id: bedroom_shutters_sleep
  alias: "Schlafzimmer - Rollläden bei Schlaf"
  trigger:
    - platform: state
      entity_id: binary_sensor.motion_sensor_schlafen_bewegung
      to: "on"
  condition:
    - condition: time
      after: "21:00:00"
      before: "06:00:00"
    - condition: state
      entity_id: light.wohnzimmer_licht
      state: "off"
  action:
    - action: script.safe_close_blind
      data:
        cover_entity: cover.schlafen_blind_vorhang
        tracker_entity: input_boolean.blind_schlafen_last_opened
```

## Manual Override / Recovery

If a blind gets stuck or you need to reset the tracker:

### Reset Tracker (Dashboard or Developer Tools)
```yaml
action: input_boolean.turn_off
target:
  entity_id: input_boolean.blind_computer_last_opened
```

### Force Open (Emergency)
```yaml
action: cover.open_cover
target:
  entity_id: cover.rollladen_computer_vorhang
```
Then manually set the tracker to `on`.

## Position Tracking
Each blind has an `input_number` for position tracking:
- `input_number.pos_computer`
- `input_number.pos_kuche`
- `input_number.pos_yoga`
- `input_number.pos_schlafen`

These store 0-100% open position.

## Troubleshooting

### Blind Not Opening
1. Check tracker: Is `input_boolean.blind_xxx_last_opened` = `on`?
2. If yes, the system thinks it's already open
3. Set tracker to `off` and try again

### Blind Not Responding
1. Check ZHA integration
2. Verify entity exists in Developer Tools → States
3. Try: Settings → Devices → Find blind → Test controls
