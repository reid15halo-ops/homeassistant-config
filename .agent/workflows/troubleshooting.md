---
description: Common troubleshooting steps for Home Assistant issues
---

# Troubleshooting Guide

Quick reference for diagnosing and fixing common Home Assistant issues.

## Connection Issues

### Cannot Access HA Web UI
```powershell
# 1. Ping the Raspberry Pi
ping 192.168.178.70

# 2. Check if port 8123 is responding
Test-NetConnection -ComputerName 192.168.178.70 -Port 8123
```

**Solutions**:
- Power cycle the Raspberry Pi
- Check router/network
- Try accessing via IP: `http://192.168.178.70:8123`

### Samba Share Not Accessible
```powershell
# Test Samba share
Test-Path "\\192.168.178.70\config"
```

**Solutions**:
1. Check Samba Share addon is running in HA
2. Restart Samba Share addon
3. Try accessing in File Explorer: `\\192.168.178.70`

---

## Entity Issues

### Entity Shows "Unavailable"
1. **Check device connection**
   - Settings → Devices → Find device
   - Check last seen time

2. **For ZHA devices**:
   - Settings → Devices & Services → ZHA → Configure
   - Try "Reconfigure Device"

3. **Restart integration**:
   - Settings → Devices & Services → [Integration] → ⋮ → Reload

### Entity ID Changed
Common after HA updates or re-pairing devices.

**Find new entity ID**:
1. Developer Tools → States
2. Search for device name
3. Note new entity_id

**Update configurations**:
```powershell
# Search for old entity in all files
Select-String -Path "*.yaml" -Pattern "old_entity_id" -Recurse
```

### Wrong Entity in Automation
1. View automation in UI
2. Settings → Automations → Edit
3. Use device selector to pick correct entity
4. Sync from HA: `.\sync_from_ha.ps1`

---

## Automation Issues

### Automation Not Triggering
1. **Check if enabled**:
   - Settings → Automations → Find automation
   - Toggle should be ON

2. **Check trigger conditions**:
   - Developer Tools → States
   - Verify trigger entity has expected state

3. **Check conditions**:
   - Temporarily remove conditions
   - Test manually

4. **View trace**:
   - Automations → [Your automation] → Traces
   - See what step failed

### Automation Running Multiple Times
- Check for duplicate automations with same trigger
- Set `mode: single` to prevent re-runs
- Add `delay` or `wait_template` between actions

### Automation Running at Wrong Time
```yaml
# Check time trigger format
trigger:
  - platform: time
    at: "07:00:00"  # Correct - 24h format with quotes
```

---

## ZHA/Zigbee Issues

### Device Offline
1. Check device battery (if battery-powered)
2. Move device closer to coordinator
3. Add Zigbee router devices for better mesh

### Device Not Pairing
1. Settings → Devices & Services → ZHA → Add Device
2. Put device in pairing mode (usually hold button 5+ sec)
3. Wait up to 60 seconds

### All ZHA Devices Offline
1. Check Zigbee coordinator (USB dongle)
2. Restart ZHA integration
3. Restart Home Assistant

---

## Light Issues

### Lights Not Responding
1. **Check entity state**:
   - Developer Tools → States → search light
   
2. **Test via service**:
   - Developer Tools → Services
   - Select `light.turn_on`
   - Pick entity and call service

3. **Check automation mode**:
   ```yaml
   mode: restart  # Allows new triggers to interrupt
   ```

### Lights Wrong Color/Brightness
Check for conflicting automations or Adaptive Lighting settings:
```yaml
# Verify flux helpers
states('input_number.flux_kelvin')
states('input_number.flux_brightness')
```

---

## Blind/Shutter Issues

### Blind Not Moving
1. **Check tracker state**:
   - Developer Tools → States
   - Search `input_boolean.blind_xxx_last_opened`
   
2. **Reset tracker**:
   - If `on` and trying to open: set to `off`
   - Developer Tools → Services → `input_boolean.turn_off`

3. **Test direct control**:
   - Developer Tools → Services
   - `cover.open_cover` / `cover.close_cover`

### Blind Jammed
See: `.agent/BLIND_ANTI_JAMMING_SOLUTION.md`

---

## Configuration Issues

### YAML Syntax Error
```powershell
# Check configuration in HA
Developer Tools → YAML → Check Configuration
```

Common YAML mistakes:
- Wrong indentation (use 2 spaces, not tabs)
- Missing quotes around times: `at: "07:00:00"`
- Missing colons: `trigger:` not `trigger`

### Configuration Not Loading
1. Check logs: Settings → System → Logs
2. Look for error messages
3. Fix YAML and restart

---

## Log Analysis

### View Logs
**In UI**: Settings → System → Logs

**Via API**:
```powershell
$token = "YOUR_TOKEN"
$headers = @{"Authorization" = "Bearer $token"}
Invoke-RestMethod -Uri "http://192.168.178.70:8123/api/error_log" -Headers $headers
```

### Enable Debug Logging
In `configuration.yaml`:
```yaml
logger:
  default: warning
  logs:
    homeassistant.components.automation: debug
    homeassistant.components.zha: debug
```

---

## Quick Commands

### Reload Services
```powershell
$HA_URL = "http://192.168.178.70:8123"
$token = "YOUR_TOKEN"
$headers = @{"Authorization" = "Bearer $token"; "Content-Type" = "application/json"}

# Reload automations
Invoke-RestMethod -Uri "$HA_URL/api/services/automation/reload" -Method POST -Headers $headers

# Reload scripts
Invoke-RestMethod -Uri "$HA_URL/api/services/script/reload" -Method POST -Headers $headers

# Reload template entities
Invoke-RestMethod -Uri "$HA_URL/api/services/template/reload" -Method POST -Headers $headers
```

### Restart Home Assistant
```powershell
Invoke-RestMethod -Uri "$HA_URL/api/services/homeassistant/restart" -Method POST -Headers $headers
```

### Check HA Version
```powershell
Invoke-RestMethod -Uri "$HA_URL/api/" -Headers $headers
```

---

## Recovery Checklist

If something is broken:

1. ☐ Check HA is accessible (ping, web UI)
2. ☐ View logs for errors
3. ☐ Check entity states in Developer Tools
4. ☐ Verify YAML syntax
5. ☐ Reload affected integration
6. ☐ Restart Home Assistant if needed
7. ☐ Sync from HA to capture any UI changes
