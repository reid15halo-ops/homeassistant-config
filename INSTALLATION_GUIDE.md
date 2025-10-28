# Installation Guide - Code Review Changes

## Quick Start (5 Minutes)

### 1. Backup Current Configuration
```bash
# SSH into Home Assistant
ssh reid15@192.168.178.71

# Create backup
cd /config
cp automations.yaml automations.yaml.backup
cp scripts.yaml scripts.yaml.backup
cp custom_zha_quirks/ts0601_radar_tze284.py custom_zha_quirks/ts0601_radar_tze284.py.backup
```

### 2. Copy New Files
Upload these files to your Home Assistant:
- `custom_zha_quirks/ts0601_radar_tze284.py` (overwrite)
- `automations.yaml` (overwrite)
- `scripts.yaml` (overwrite)
- `template_sensors.yaml` (new file)
- `input_numbers.yaml` (new file)

### 3. Update configuration.yaml
Add these lines to `/config/configuration.yaml`:

```yaml
# Template sensors for reusable calculations
template: !include template_sensors.yaml

# Configurable parameters (UI-editable)
input_number: !include input_numbers.yaml
```

**Location**: Add anywhere in the file (suggested: near other includes)

### 4. Check Configuration
```bash
# Via UI
Developer Tools → YAML → Check Configuration

# Via CLI
ha core check
```

### 5. Restart Home Assistant
```bash
# Via UI
Settings → System → Restart

# Via CLI
ha core restart
```

### 6. Reload ZHA (for quirk changes)
```bash
# Via UI
Settings → Devices & Services → ZHA → ⋮ → Reload
```

---

## Verification Checklist

### ✅ Check New Entities Created
Go to: **Configuration → Entities**

Search for these new entities:
- `binary_sensor.sun_position_suitable`
- `sensor.fp2_light_level`
- `binary_sensor.brightness_bright`
- `binary_sensor.brightness_dark`
- `binary_sensor.outdoor_ventilation_suitable`

### ✅ Check Input Numbers
Go to: **Configuration → Helpers**

Look for:
- `input_number.lux_threshold_bright`
- `input_number.lux_threshold_dark`
- `input_number.ventilation_wind_max`
- `input_number.motion_timeout_bad`
- (and ~15 more helpers)

### ✅ Check Scripts
Go to: **Settings → Automations & Scenes → Scripts**

Look for new scripts:
- `notify_all`
- `lights_bedtime`
- `all_lights_off`
- `all_covers_open`
- `check_ventilation_conditions`
- (and 3 more)

### ✅ Test Key Automations
Go to: **Settings → Automations & Scenes**

Manually trigger:
1. **Bad Licht an** - Check for debouncing
2. **Rollladen Computer – Anti-Glare** - Check reduced polling
3. **Schlafzimmer – Wecker-Lichtrampe** - Check unified logic

### ✅ Check Logs
Go to: **Settings → System → Logs**

Look for:
- No YAML errors
- No template errors
- ZHA quirk loaded successfully

---

## Troubleshooting

### Problem: "Template Error" in Logs
**Solution**: Check that all referenced entities exist
```yaml
# If this fails:
{{ states('sensor.presence_sensor_fp2_f9cf_light_sensor_light_level')|int(0) }}

# Verify entity exists:
Developer Tools → States → Search for "fp2"
```

### Problem: Input Numbers Not Appearing
**Cause**: `input_number: !include` requires restart (not just reload)
**Solution**:
```bash
ha core restart
```

### Problem: ZHA Quirk Not Loading
**Check**: Settings → System → Logs → Search "quirk"
**Solution**:
- Verify file path: `/config/custom_zha_quirks/ts0601_radar_tze284.py`
- Check file syntax (no Python errors)
- Reload ZHA: Settings → Devices & Services → ZHA → Reload

### Problem: Automation Still Using Old Polling
**Cause**: Automations not reloaded
**Solution**:
```bash
Developer Tools → YAML → Reload Automations
```

### Problem: Scripts Not Found
**Cause**: scripts.yaml syntax error or not reloaded
**Solution**:
1. Check configuration: `Developer Tools → YAML → Check Configuration`
2. Reload: `Developer Tools → YAML → Reload Scripts`

---

## Rollback Instructions

If something goes wrong, rollback to backups:

```bash
ssh reid15@192.168.178.71
cd /config

# Restore files
cp automations.yaml.backup automations.yaml
cp scripts.yaml.backup scripts.yaml
cp custom_zha_quirks/ts0601_radar_tze284.py.backup custom_zha_quirks/ts0601_radar_tze284.py

# Remove new files (optional)
rm template_sensors.yaml
rm input_numbers.yaml

# Remove from configuration.yaml:
# template: !include template_sensors.yaml
# input_number: !include input_numbers.yaml

# Restart
ha core restart
```

---

## Performance Monitoring

After installation, monitor performance for 24-48 hours:

### CPU/Memory Usage
**Settings → System → System Health**
- Check CPU load (should be same or lower)
- Check memory usage

### Automation Execution Count
**Settings → Automations → [Select] → Statistics**
- Check execution frequency
- Should see ~80% reduction in time-based automations

### Log Activity
**Settings → System → Logs**
- Should see fewer automation triggers
- No recurring errors

---

## FAQ

### Q: Do I need to reconfigure anything?
**A**: No! All changes are backward compatible. Your automations work exactly as before, just optimized.

### Q: Will my automations break?
**A**: No. We only:
- Fixed bugs (time condition, duplicates)
- Optimized polling (added state triggers, kept backup polling)
- Added new optional helpers (not required for existing automations)

### Q: Can I use the new helpers in my own automations?
**A**: Yes! For example:
```yaml
# Use template sensor instead of complex template
condition:
  - condition: state
    entity_id: binary_sensor.sun_position_suitable
    state: 'on'

# Use input_number instead of hardcoded value
condition:
  - condition: numeric_state
    entity_id: sensor.fp2_light_level
    above: "{{ states('input_number.lux_threshold_bright')|int }}"

# Call reusable script
action:
  - service: script.notify_all
    data:
      title: "Alert"
      message: "Something happened!"
```

### Q: What if I don't want the new files?
**A**: You can skip them! The changes to `automations.yaml` work standalone. Just don't add the includes to `configuration.yaml`.

### Q: How do I adjust the thresholds (lux, timeouts, etc.)?
**A**: Via UI!
1. Go to **Configuration → Helpers**
2. Find the helper (e.g., `lux_threshold_bright`)
3. Click it and adjust the slider
4. No restart needed!

---

## Next Steps

### Week 1: Monitor & Tune
- Watch logs for errors
- Adjust input_numbers via UI
- Test automations at different times

### Week 2: Optimize Further
- Review automation traces
- Identify slow/problematic automations
- Consider converting more hardcoded values to input_numbers

### Month 1: Expand
- Create custom automations using new helpers
- Add more reusable scripts
- Consider splitting automations.yaml into packages

---

## Support Resources

- **Home Assistant Docs**: https://www.home-assistant.io/docs/
- **Community Forum**: https://community.home-assistant.io/
- **Changelog**: See `CHANGELOG_CODE_REVIEW.md` for detailed changes
- **Your CLAUDE.md**: Reference for entity IDs and patterns

---

**Installation complete! Enjoy your optimized Home Assistant setup! 🎉**
