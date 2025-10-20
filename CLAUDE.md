# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Home Assistant Configuration Repository

This is a Home Assistant configuration running on:
- **System**: Raspberry Pi 4
- **OS**: Home Assistant OS 16.2
- **Core**: Home Assistant 2025.9.3 (aktuell: 2025.10.0)
- **Location**: Zuhause (49.91°N, 9.08°E, 150m elevation)
- **Timezone**: Europe/Berlin

## Directory Structure

```
/config/
├── configuration.yaml       # Main configuration file
├── automations.yaml         # All automations (UI + manual)
├── scripts.yaml            # Reusable script sequences
├── scenes.yaml             # Scene definitions
├── secrets.yaml            # Sensitive data (NEVER commit!)
├── blueprints/             # Automation blueprints
├── custom_components/      # Custom integrations
├── custom_zha_quirks/      # ZHA device quirks
├── packages/               # Modular configuration packages
├── www/                    # Static web resources
└── zigbee2mqtt/            # Zigbee2MQTT configuration
```

## Key Configuration Files

### configuration.yaml
- Uses `!include` directives for modular organization
- Automations: `!include automations.yaml`
- Scripts: `!include scripts.yaml`
- Packages: `!include_dir_named packages`
- ZHA with custom quirks enabled
- Logger configured for debug (ZHA, zigpy, zhaquirks)

### Existing Integrations
- ZHA (Zigbee Home Automation) with custom quirks
- Bluetooth
- OpenWeatherMap
- default_config (includes: automation, script, scene, etc.)

## YAML Syntax Rules

### Critical Rules
- **Indentation**: 2 spaces per level (NO TABS!)
- **Case-sensitive**: `on` ≠ `On` ≠ `ON`
- **Script names**: Only lowercase and underscores (e.g., `good_night_routine`)
- **Entity IDs**: Format `domain.object_id` (e.g., `light.wohnzimmer`)

### Common Patterns
```yaml
# Automation structure
- id: unique_id_here
  alias: Human-Readable Name
  mode: restart  # or single, queued, parallel
  trigger:
    - platform: ...
  condition:
    - condition: ...
  action:
    - service: ...
```

## Automation Structure

### Components
1. **Trigger** - What starts the automation
   - `platform: state` - Entity state changes
   - `platform: time` - Specific time
   - `platform: time_pattern` - Repeating pattern
   - `platform: numeric_state` - Threshold crossing
   - `platform: sun` - Sunrise/sunset

2. **Condition** - Optional checks before action
   - `condition: state`
   - `condition: numeric_state`
   - `condition: time`
   - `condition: template`
   - `condition: sun`

3. **Action** - What to do
   - `service:` - Call a service
   - `choose:` - Conditional branching
   - `delay:` - Wait
   - `wait_for_trigger:` - Wait for event
   - `repeat:` - Loop

### Modes
- `single` - Only one instance (default)
- `restart` - Cancel and restart
- `queued` - Queue up instances
- `parallel` - Run multiple instances

## Common Services

### Lights
- `light.turn_on` - Turn on light(s)
  - Optional: `brightness`, `rgb_color`, `color_temp`
- `light.turn_off` - Turn off light(s)
- `light.toggle` - Toggle light(s)

### Covers (Rollläden)
- `cover.open_cover` - Open cover
- `cover.close_cover` - Close cover
- `cover.set_cover_position` - Set position (0-100)
- `cover.stop_cover` - Stop movement

### Climate
- `climate.set_temperature` - Set target temperature
- `climate.set_hvac_mode` - Set mode (heat, cool, off, etc.)

### Notifications
- `notify.notify` - Send notification
- `notify.persistent_notification` - Persistent notification in UI

### System
- `homeassistant.restart` - Restart Home Assistant
- `homeassistant.reload_core_config` - Reload configuration
- `automation.reload` - Reload automations
- `script.reload` - Reload scripts

## Templates

Home Assistant uses Jinja2 templates for dynamic values.

### Basic Template Syntax
```yaml
# Get state
{{ states('sensor.temperature') }}

# Get attribute
{{ state_attr('sun.sun', 'azimuth') }}

# Convert to number
{{ states('sensor.temperature') | float(0) }}

# Check state
{{ is_state('light.wohnzimmer', 'on') }}

# Time-based
{{ now().hour }}
{{ as_timestamp(now()) }}
```

### Common Filters
- `| float(default)` - Convert to float
- `| int(default)` - Convert to integer
- `| round(precision)` - Round number
- `| lower` - Lowercase string
- `| upper` - Uppercase string

## Variables in Automations

```yaml
variables:
  # Define reusable values
  sun_ok: "{{ (state_attr('sun.sun','azimuth')|float(0) >= 120) }}"
  lux: "{{ states('sensor.light_level')|int(0) }}"

action:
  - condition: template
    value_template: "{{ sun_ok and lux > 600 }}"
```

## Scripts

### Basic Script Structure
```yaml
script_name:
  alias: "Human Readable Name"
  mode: restart
  fields:
    # Input parameters
    target_entity:
      description: "Entity to control"
      example: "light.wohnzimmer"
  sequence:
    - service: light.turn_on
      target:
        entity_id: "{{ target_entity }}"
```

### Calling Scripts
```yaml
# From automation
action:
  - service: script.good_night_routine
    data:
      target_entity: light.bedroom

# From script (chaining)
  - service: script.turn_on
    entity_id: script.another_script
```

## Entity Types in This System

### Common Entities
- `light.*` - Lights
- `cover.*` - Rollläden/Blinds (e.g., `cover.rollladen_computer_vorhang`)
- `sensor.*` - Sensors (temperature, light level, etc.)
- `binary_sensor.*` - Binary sensors (presence, motion, etc.)
- `input_number.*` - Number helpers (e.g., `input_number.pos_computer`)
- `input_boolean.*` - Boolean helpers
- `switch.*` - Switches
- `climate.*` - Thermostats
- `sun.sun` - Sun position

### Presence Detection
- `binary_sensor.presence_sensor_fp2_*_presence` - Aqara FP2 presence sensors

### Weather
- `sensor.openweathermap_temperature` - Outside temperature

## Testing & Debugging

### After Making Changes
1. **Check Configuration**:
   - Developer Tools → YAML → Check Configuration

2. **Reload** (without restart):
   - Developer Tools → YAML → Reload Automations
   - Developer Tools → YAML → Reload Scripts

3. **View Logs**:
   - Settings → System → Logs
   - Or: `/config/home-assistant.log`

### Template Editor
- Developer Tools → Template
- Test templates in real-time

### Trace Automations
- Settings → Automations & Scenes → [Select automation] → Traces
- Shows each execution step-by-step

## Best Practices

### Automation Design
- Use descriptive `alias` names
- Add `id:` for all automations (unique identifier)
- Choose appropriate `mode:` (restart for state-based, single for actions)
- Add `for:` to triggers to avoid flapping
- Use variables for complex templates (reusability + readability)

### Script Design
- Make scripts generic with `fields:` parameters
- Use descriptive variable names
- Add `alias:` to sequence steps for better traces

### Safety
- Never commit `secrets.yaml` to version control
- Use `!secret` for sensitive data in configuration
- Test automations in safe hours (avoid 3 AM surprises)
- Use conditions to prevent unwanted triggers

### Organization
- Group related automations by room/function
- Use comments to explain complex logic
- Consider using packages for modular organization
- Keep automations.yaml under ~1000 lines (split if needed)

## Common Patterns in This System

### Cover Control with Multiple Conditions
```yaml
# Pattern: Rollladen based on sun position, presence, and light level
variables:
  sun_ok: "{{ (state_attr('sun.sun','azimuth')|float(0) >= 120) and
               (state_attr('sun.sun','azimuth')|float(0) <= 240) }}"
  lux: "{{ states('sensor.light_level')|int(0) }}"
  present: "{{ is_state('binary_sensor.presence','on') }}"

action:
  - choose:
    - conditions:
      - "{{ present and sun_ok and lux >= 600 }}"
      sequence:
        - service: cover.set_cover_position
          data:
            entity_id: cover.rollladen
            position: 10
```

### Time-Based Position Setting
```yaml
# Pattern: Script for time-based cover movement
script.cover_fahre_zeitbasiert:
  fields:
    cover_entity:
      description: "Cover entity ID"
    pos_helper:
      description: "Input number for position tracking"
    travel_time:
      description: "Total travel time in seconds"
    position:
      description: "Target position (0-100)"
  sequence:
    - service: cover.set_cover_position
      target:
        entity_id: "{{ cover_entity }}"
      data:
        position: "{{ position }}"
    - service: input_number.set_value
      target:
        entity_id: "{{ pos_helper }}"
      data:
        value: "{{ position }}"
```

## Development Workflow with Claude Code

### Creating New Automations
1. Describe what you want in natural language
2. Claude generates YAML
3. Review and test in Developer Tools → Template
4. Add to automations.yaml
5. Reload automations

### Modifying Existing Automations
1. Show Claude the current automation
2. Describe desired changes
3. Claude provides updated YAML
4. Replace in automations.yaml
5. Reload and test

### Debugging
1. Share error message or unexpected behavior
2. Claude analyzes logs/config
3. Provides fix or troubleshooting steps

## SSH Access

- Host: `192.168.178.71` (or `reidhomeassistant.local`)
- User: `reid15`
- SSH Key: `~/.ssh/id_ed25519`
- Config path: `/config/`

### Quick Commands
```bash
# Connect
ssh reid15@192.168.178.71

# Edit automation
nano /config/automations.yaml

# Check logs
tail -f /config/home-assistant.log

# Restart HA (via SSH)
ha core restart
```

## Useful Resources

- **Official Docs**: https://www.home-assistant.io/docs/
- **Automation Docs**: https://www.home-assistant.io/docs/automation/
- **Script Docs**: https://www.home-assistant.io/integrations/script/
- **Template Docs**: https://www.home-assistant.io/docs/configuration/templating/
- **Community**: https://community.home-assistant.io/

## Notes

- System uses ZHA for Zigbee (not Zigbee2MQTT as primary)
- Custom ZHA quirks enabled in `/config/custom_zha_quirks/`
- Logger set to debug for ZHA troubleshooting
- Presence detection via Aqara FP2 sensors
- Weather data from OpenWeatherMap integration


---

## Available Entities in This System

### Summary Statistics
- **Total Entities**: 1210
- **Sensors**: 638
- **Switches**: 119
- **Binary Sensors**: 104
- **Device Trackers**: 98
- **Lights**: 28
- **Covers**: 4
- **Climate**: 2
- **Automations**: 40

### Lights (28 total)
```
light.bad                                    # Badezimmer Licht
light.bett_licht                            # Bett Beleuchtung
light.buffet_lichtstreifen                  # Buffet LED-Streifen
light.computer_licht                        # Computer-Bereich
light.kiffzimmer_lichtstreifen             # Growbox Beleuchtung
light.kuche_birne_1, light.kuche_birne_2    # Küche Lampen
light.kuche_streifen                        # Küche LED-Streifen
light.schlafzimmer_licht                    # Schlafzimmer
light.kleiderschrank                        # Schrank Beleuchtung
# + weitere Hintergrundbeleuchtungen für Rollläden
```

### Covers/Rollläden (4 total)
```
cover.rollladen_computer_vorhang           # Computer Rollladen
cover.kuche_blind_vorhang                  # Küche Rollladen
cover.schlafen_blind_vorhang               # Schlafzimmer Rollladen
cover.yoga_blind_vorhang                   # Yoga-Raum Rollladen
```

### Presence Sensors
```
binary_sensor.presence_sensor_fp2_f9cf_presence_sensor_1  # Aqara FP2 Zone 1
binary_sensor.presence_sensor_fp2_f9cf_presence_sensor_2  # Aqara FP2 Zone 2
binary_sensor.presence_sensor_fp2_f9cf_presence_sensor_3  # Aqara FP2 Zone 3
binary_sensor.presence_sensor_fp2_f9cf_presence_sensor_4  # Aqara FP2 Zone 4
binary_sensor.presence_sensor_fp2_f9cf_presence_sensor_5  # Aqara FP2 Zone 5
binary_sensor.clt_l09_anwesenheit                          # Handy Anwesenheit
binary_sensor.redmi_note_12_pro_5g_anwesenheit            # Redmi Anwesenheit
```

### Climate/Heizung
```
climate.thermostat_bad                      # Thermostat Badezimmer
climate.thermostat_computer                 # Thermostat Computer-Raum
```

### Key Sensors
```
sensor.presence_sensor_fp2_f9cf_light_sensor_light_level  # Lichtsensor (Lux)
sensor.openweathermap_temperature                          # Außentemperatur
sensor.openweathermap_humidity                             # Außen-Luftfeuchtigkeit
sun.sun                                                     # Sonnenstand
```

### Door/Window Sensors
```
binary_sensor.aqara_door_and_window_sensor_tur     # Tür-Sensor 1
binary_sensor.aqara_door_and_window_sensor_tur_2   # Tür-Sensor 2
binary_sensor.aqara_water_leak_sensor_feuchte      # Wasserleck-Sensor
```

### Media Players
```
media_player.wohnzimmer                     # Wohnzimmer Chromecast
media_player.blinds                         # Blinds Lautsprecher
```

### Common Automation Patterns

#### Typical Entity References in Your Automations
- **Presence Detection**: `binary_sensor.presence_sensor_fp2_f9cf_presence`
- **Light Level**: `sensor.presence_sensor_fp2_f9cf_light_sensor_light_level`
- **Outside Temp**: `sensor.openweathermap_temperature`
- **Sun Position**: `state_attr('sun.sun', 'azimuth')` and `state_attr('sun.sun', 'elevation')`
- **Position Tracking**: `input_number.pos_computer` (für Rollladen-Position)

#### Helper Entities (Input Numbers)
```
input_number.pos_computer                   # Rollladen Computer Position
# + weitere position tracking helpers
```

### Device Naming Conventions
- `*_cloud_verbindung` - Cloud connection sensors
- `*_uberhitzt` - Overheating sensors
- `*_battery` - Battery level sensors
- `*_lichtstreifen` - LED strips
- `*_blind_*` - Blind/Roller shutter related

### Integration Prefixes
- `sensor.22101316ug_*` - Android Device (Home Assistant Companion App)
- `sensor.fritz_box_*` - Fritz!Box Router
- `binary_sensor.aqara_*` - Aqara Zigbee Devices
- `sensor.openweathermap_*` - Weather Data

---

## Quick Entity Lookup Commands

```bash
# SSH into Home Assistant
ssh reid15@192.168.178.71

# List all entities
cat /config/.storage/core.entity_registry | grep -o '"entity_id":"[^"]*"' | cut -d'"' -f4 | sort

# Find entities by domain
cat /config/.storage/core.entity_registry | grep -o '"entity_id":"light\.[^"]*"' | cut -d'"' -f4

# Search for specific entity
cat /config/.storage/core.entity_registry | grep "computer"
```
