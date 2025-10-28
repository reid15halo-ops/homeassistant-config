# Device ID Migration Guide

## Current Status

**Converted Automations:** 5 critical ones
**Remaining device_ids:** ~76 references across ~25 automations

## Why Device IDs Should Be Converted

### Current State (Device-based)
```yaml
- type: turn_on
  device_id: 8c0861d5de0795e1492a8eaeea69c72a
  entity_id: 1368fea07848a80d288c0aff0af3cf1c
  domain: light
```

**Problems:**
- Unreadable device and entity IDs
- Hard to understand what this controls
- Device-specific (breaks if device replaced)

### Target State (Entity-based)
```yaml
- service: light.turn_on
  target:
    entity_id: light.ambient_light_1
  continue_on_error: true
```

**Benefits:**
- Clear, readable entity name
- Works across device replacements
- Better error handling
- Easier to maintain

---

## How to Convert (Step-by-Step)

### Step 1: Find Entity Names

#### Method A: Via UI
1. Go to **Settings → Devices & Services**
2. Find the device by its model/location
3. Click on device → See all entities
4. Note the entity_id (e.g., `light.wohnzimmer`)

#### Method B: Via Developer Tools
1. **Developer Tools → States**
2. Search for entity by type (light, cover, etc.)
3. Match by last activity time or manually test

#### Method C: Via CLI/SSH
```bash
# List all entities with their device IDs
cat /config/.storage/core.entity_registry | grep "device_id" | grep "YOUR_DEVICE_ID"

# Example output:
# "entity_id": "light.wohnzimmer", "device_id": "8c0861d5de..."
```

### Step 2: Convert Triggers

**Before:**
```yaml
trigger:
  - type: motion
    device_id: aebec0c58872e00fe8fa89b0a846a29e
    entity_id: 58a470e22a792e2f2d7a2e13233b3d50
    domain: binary_sensor
    trigger: device
```

**After:**
```yaml
trigger:
  - platform: state
    entity_id: binary_sensor.motion_sensor_bad
    to: 'on'
    for:
      seconds: 2  # Optional: add debouncing
```

### Step 3: Convert Actions

**Before:**
```yaml
action:
  - type: turn_on
    device_id: 8c0861d5de0795e1492a8eaeea69c72a
    entity_id: 1368fea07848a80d288c0aff0af3cf1c
    domain: light
```

**After:**
```yaml
action:
  - service: light.turn_on
    target:
      entity_id: light.wohnzimmer
    continue_on_error: true
```

### Step 4: Convert Conditions

**Before:**
```yaml
condition:
  - condition: device
    type: is_on
    device_id: 8c0861d5de0795e1492a8eaeea69c72a
    entity_id: 1368fea07848a80d288c0aff0af3cf1c
    domain: light
```

**After:**
```yaml
condition:
  - condition: state
    entity_id: light.wohnzimmer
    state: 'on'
```

---

## Conversion Priority List

### HIGH Priority (Security & Comfort)
- [ ] `bett_licht_aus_no_motion_20s` - Bedroom lights (partially done)
- [ ] `Aufstehen Arbeit ANaus` - Morning routine
- [ ] `Schlafen gehen Arbeit Licht aus` - Night routine
- [ ] Remaining cover automations

### MEDIUM Priority (Convenience)
- [ ] `Licht aus Küche` - Kitchen lights
- [ ] `Wohnzimmer Licht an Nach Sonnenuntergang` - Living room
- [ ] `Küche Licht ein` - Kitchen motion
- [ ] All remaining motion-based light automations

### LOW Priority (Nice to Have)
- [ ] `AI Automation Creator` - Experimental
- [ ] Duplicate/backup automations
- [ ] Test automations

---

## Already Converted (Reference)

✅ **schlafen_werk_close_0455** - Cover control (weekday morning)
✅ **schlafen_weekend_open_1000** - Cover control (weekend)
✅ **Licht an 15lx** - Low-light ambient (62 → 34 lines, -45%)
✅ **Heizung Aus Fenster offen** - Climate control with debouncing

---

## Batch Conversion Script

For advanced users who want to convert many at once:

```python
#!/usr/bin/env python3
"""
Device ID to Entity ID converter for Home Assistant automations
"""

import yaml
import sys

# 1. Load your automation file
with open('automations.yaml') as f:
    automations = yaml.safe_load(f)

# 2. Create mapping (you need to fill this manually!)
DEVICE_TO_ENTITY = {
    '8c0861d5de0795e1492a8eaeea69c72a': 'light.ambient_light_1',
    # Add more mappings here...
}

# 3. Convert function
def convert_device_action(action):
    if action.get('device_id') in DEVICE_TO_ENTITY:
        device_id = action.pop('device_id')
        entity_hash = action.pop('entity_id')
        domain = action.pop('domain')
        action_type = action.pop('type')

        return {
            'service': f'{domain}.{action_type}',
            'target': {
                'entity_id': DEVICE_TO_ENTITY[device_id]
            },
            'continue_on_error': True
        }
    return action

# 4. Process all automations
for auto in automations:
    if 'actions' in auto:
        auto['actions'] = [convert_device_action(a) for a in auto['actions']]

# 5. Save
with open('automations_converted.yaml', 'w') as f:
    yaml.dump(automations, f, default_flow_style=False)

print("Conversion complete! Review automations_converted.yaml")
```

---

## Entity ID Mapping Reference

Based on analysis and context clues, here are likely mappings:

| Device ID (First 8 chars) | Entity ID (Best Guess) | Context |
|---|---|---|
| aebec0c5 | binary_sensor.motion_sensor_bad | Bad motion sensor |
| 2ce83ab1 | sensor.fp2_* (multiple) | FP2 presence sensor |
| bc3db6d0 | binary_sensor.presence_sensor_* | Presence sensor bed area |
| 09da8d97 | light.bed_light | Bed light |
| 24856663 | light.bett_licht | Alternative bed light |
| 8c0861d5 | light.ambient_light_1 | Ambient strip 1 |
| dff6231b | light.ambient_light_2 | Ambient strip 2 |
| ceb5bc29 | light.ambient_light_3 | Ambient strip 3 |
| 3586709559e4e46394dfa54ebf906373 | fan.ceiling_fan | Ceiling fan |
| 76361dfbed405867437d4b94a3995bb6 | fan.ceiling_fan_with_light | Fan with light |
| ffd6ad36 | light.bad_2 | Bathroom light 2 |
| e21cdce8 | cover.* (unknown name) | Additional cover |

**Note:** These are educated guesses. Verify via UI before using!

---

## Testing After Conversion

1. **Syntax Check:**
   ```bash
   Developer Tools → YAML → Check Configuration
   ```

2. **Reload Automations:**
   ```bash
   Developer Tools → YAML → Reload Automations
   ```

3. **Test Individually:**
   - Go to automation
   - Click "Run" button
   - Check traces for errors

4. **Monitor Logs:**
   ```bash
   Settings → System → Logs
   # Look for "Entity not found" errors
   ```

---

## Rollback Plan

If converted automation doesn't work:

1. Keep backup of device-based version in comments
2. Test new version for 24h before removing backup
3. If issues, restore from git or comments

**Example:**
```yaml
# OLD (Device-based) - Backup in case of issues
# - type: turn_on
#   device_id: 8c0861d5de0795e1492a8eaeea69c72a
#   entity_id: 1368fea07848a80d288c0aff0af3cf1c
#   domain: light

# NEW (Entity-based) - Active
- service: light.turn_on
  target:
    entity_id: light.ambient_light_1
  continue_on_error: true
```

---

## FAQ

### Q: Will my automations break during migration?
**A:** No! Convert one at a time, test, then move to next. Old device-based format still works.

### Q: How do I find the entity_id for a device_id?
**A:** See "Step 1: Find Entity Names" above. CLI method is fastest.

### Q: Can I convert everything at once?
**A:** Technically yes (using script above), but risky. Better to do incrementally.

### Q: What if I can't find the entity name?
**A:** Leave device-based for now, add TODO comment. It still works!

### Q: Do I need to convert trigger AND actions?
**A:** For best results, yes. But you can do triggers first, then actions separately.

---

## Progress Tracking

Use this checklist to track your migration:

```markdown
## Automation Conversion Checklist

### Critical Automations
- [x] schlafen_werk_close_0455
- [x] schlafen_weekend_open_1000
- [x] Licht an 15lx
- [x] Heizung Aus Fenster offen
- [ ] bett_licht_aus_no_motion_20s (partially done - has mixed device/entity)
- [ ] Schlafen Arbeit Bettgehlicht
- [ ] Schlafen gehen Arbeit Licht aus
- [ ] Aufstehen Arbeit ANaus

### Light Automations
- [x] Licht an 15lx (major refactor)
- [ ] Bad Licht an (partially done)
- [ ] Bad aus
- [ ] Licht aus Küche
- [ ] Wohnzimmer Licht an Nach Sonnenuntergang
- [ ] Wohnzimmer - Abend Licht an
- [ ] Küche Licht ein

### Cover Automations
- [x] schlafen_werk_close_0455
- [x] schlafen_weekend_open_1000
- [ ] All rollers_* automations (check for device refs)

### Remaining
- [ ] (List others as you find them)
```

---

**Need Help?**
- Check Home Assistant Community Forums
- Review official docs: https://www.home-assistant.io/docs/automation/trigger/
- Ask in Discord/Reddit for specific device mappings

---

**Last Updated:** 2025-10-28 (Code Review Session)
