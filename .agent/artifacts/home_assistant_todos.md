# 🏠 Home Assistant TODO List
**Generated**: 2026-01-23  
**Current Automations**: 55 (+ 4 in packages)

---

## 🔴 HIGH PRIORITY - Missing Core Functionality

### 1. Flur (Hallway) - No Smart Devices
- [ ] **Add motion sensor** to Flur for hallway lighting
- [ ] **Add smart light** for Flur (ceiling or wall)
- [ ] **Create automation**: Motion-triggered hallway light

### 2. Entity Fixes Still Needed
- [ ] **Rename `no_area_*` entities** - Several devices not assigned to rooms:
  - `binary_sensor.no_area_aqara_door_and_window_sensor_tuer`
  - `binary_sensor.no_area_aqara_water_leak_sensor_wasserleck`
  - `sensor.no_area_shelly_blu_h_t_7ff9_*`
  - `sensor.no_area_shelly_blu_h_t_b922_*`
- [ ] **Assign rooms** to orphaned ZHA devices in Home Assistant UI

### 3. Cleaning Person Tracking (25€/hour)
- [ ] **Verify automation works**: `cleaning_person_entrance` / `cleaning_person_exit`
- [ ] **Test notification delivery** to Xiaomi phone
- [ ] **Add door sensor to Flur** for accurate entry/exit detection

---

## 🟡 MEDIUM PRIORITY - Improvements

### 4. Cannabis Tent Optimizations (Strawberry Lemonade)
- [ ] **Add soil moisture sensors** (3 needed, one per plant)
  - Current entities reference non-existent sensors:
    - `sensor.permanent_marker_l_cannabis_soil_moisture`
    - `sensor.cap_junky_m_cannabis_soil_moisture`
    - `sensor.candy_store_r_cannabis_soil_moisture`
- [ ] **Add light entity** for Mars Hydro TSL2000 (currently only switch)
- [ ] **Create automation**: Watering reminder based on soil moisture
- [ ] **Create dashboard card**: Real-time tent conditions

### 5. Presence Detection Enhancements
- [ ] **Combine FP2 zones** - Use all 6 zones for better room detection
- [ ] **Add Schlafzimmer presence sensor** to automations (just installed)
- [ ] **Create "True Presence" for Flur** once sensor is added

### 6. Energy Saving - Away Mode
- [ ] **Create `input_boolean.away_mode`** toggle
- [ ] **Automation**: When away, set all thermostats to ECO (16°C)
- [ ] **Automation**: When away, turn off all standby devices
- [ ] **Automation**: When returning home, warm up 30 min before arrival

### 7. Adaptive Lighting
- [ ] **Migrate to Adaptive Lighting integration** (already installed but not configured)
- [ ] **Configure per-room color temperature curves**
- [ ] **Exclude Kiffzimmer** (plants need specific light spectrum)

---

## 🟢 LOW PRIORITY - Nice to Have

### 8. Alexa Integration
- [ ] **Create routines** for voice control:
  - "Alexa, Filmabend" → Activates movie scene
  - "Alexa, Gute Nacht" → Activates sleep mode
  - "Alexa, Ich gehe" → Activates away mode
- [ ] **Add Alexa announcements** for critical alerts

### 9. Roborock Improvements
- [ ] **Create room-specific cleaning** with FP2 presence detection
- [ ] **Automation**: Daily cleaning only when nobody is in the room
- [ ] **Automation**: Return to dock when someone enters during cleaning

### 10. Security Enhancements
- [ ] **Add Flur door sensor** for front door
- [ ] **Automation**: Alert when door opens during vacation mode
- [ ] **Automation**: Turn on all lights if motion detected + vacation mode

### 11. Dashboard Improvements
- [ ] **Create mobile-optimized dashboard** for Xiaomi phone
- [ ] **Add cannabis tent monitoring card** with:
  - Current temp/humidity vs targets
  - Growth stage selector
  - Watering schedule
- [ ] **Add energy consumption tracking** per room

### 12. Scripts to Create
- [ ] `script.goodnight` - Turn off all lights, close blinds, set heating to night mode
- [ ] `script.leaving_home` - Activate away mode, close blinds, set ECO heating
- [ ] `script.movie_mode` - Dim lights, close blinds, set specific scene
- [ ] `script.emergency_all_off` - Kill switch for all devices

---

## 🔧 Technical Debt

### 13. Configuration Cleanup
- [ ] **Fix UTF-8 encoding** in alias names (showing `Ãƒ` instead of umlauts)
- [ ] **Update entity references** in remaining automations
- [ ] **Remove duplicate light entities** in scripts (e.g., both old and new names)
- [ ] **Add descriptions** to all automations

### 14. Monitoring & Alerts
- [ ] **Create sensor**: Count of unavailable entities
- [ ] **Automation**: Alert when any device goes offline > 1 hour
- [ ] **Automation**: Alert when battery < 20% on any sensor

### 15. Backup & Recovery
- [ ] **Schedule daily config backup** to external storage
- [ ] **Document recovery procedure** in README

---

## 📊 Current Coverage Summary

| Room | Lights | Motion/Presence | Climate | Blinds | Door Sensor |
|------|--------|-----------------|---------|--------|-------------|
| Wohnzimmer | ✅ | ✅ FP2 | ✅ | ✅ | ❌ |
| Küche | ✅ | ✅ Tuya + Motion | ✅ | ✅ | ❌ |
| Schlafzimmer | ✅ | ✅ Tuya | ❌ | ✅ | ✅ Kleiderschrank |
| Badezimmer | ✅ | ✅ Tuya + Motion | ✅ | ❌ | ❌ |
| Kiffzimmer | ✅ | ✅ Motion | ❌ (manual) | ✅ | ✅ |
| Flur | ❌ | ❌ | ❌ | ❌ | ❌ |

---

## 🎯 Next Actions (Recommended Order)

1. **Fix UTF-8 encoding** in automation aliases
2. **Assign rooms** to `no_area_*` devices
3. **Test cleaning person tracking** automation
4. **Add soil moisture sensors** for cannabis plants
5. **Set up Flur** with motion sensor and light
