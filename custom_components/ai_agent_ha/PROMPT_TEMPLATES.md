# Prompt-Vorlagen: Optimiert für Claude, GPT-5 und Gemini

## ?? Claude Sonnet 3.7 (Empfohlen)

### Präsenz-basierte Beleuchtung
```
Erstelle eine Präsenz-Licht-Automation für den Raum "{{ROOM_NAME}}":
- Entity: binary_sensor.presence_sensor_fp2_{{ZONE_ID}}_presence
- Helligkeitssensor: sensor.presence_sensor_fp2_{{ZONE_ID}}_light_sensor_light_level
- Schwellwert: {{LUX_THRESHOLD}} lux (darunter = einschalten)
- Licht: light.{{LIGHT_ENTITY}}
- Brightness: {{BRIGHTNESS_PERCENT}}%
- Timeout: {{TIMEOUT_SECONDS}} Sekunden nach Verlassen
- Mode: restart
- Alias: "{{DESCRIPTIVE_NAME}}"
- Description: "Ausführliche Beschreibung der Funktionsweise"
Gib als automation_suggestion zurück mit vollständigem YAML.
```

### Sonnenstand-basierte Beschattung
```
Optimiere die Rollladensteuerung für "{{COVER_ENTITY}}":
- Sun sensor: sun.sun (azimuth, elevation)
- Light sensor: sensor.{{LIGHT_SENSOR}}_light_level
- Outside temp: sensor.openweathermap_temperature

Logik:
1. Tagsüber (6:00-20:00):
   - Bei Azimut {{AZIMUT_START}}-{{AZIMUT_END}} UND Lux > {{LUX_HIGH}}: Position {{POSITION_PARTIAL}}%
   - Bei Lux < {{LUX_LOW}}: Vollständig öffnen (100%)
2. Abends (20:00): Komplett schließen (0%)
3. Morgens (6:00): Komplett öffnen (100%)

Requirements:
- Mode: restart
- Variables für Schwellwerte definieren
- Bedingungen mit for: 5min zur Entprellung
- Sprechende Alias und Description

Output: automation_suggestion mit vollständigem trigger/condition/action
```

### Multi-Raum Gute-Nacht-Routine
```
Erstelle eine Gute-Nacht-Automation "Alles Aus":
- Trigger: time "22:30:00" oder manueller Button
- Actions:
  1. Alle Lichter ausschalten (domain: light, außer Nachtlicht)
  2. Alle Medienplayer pausieren (domain: media_player)
  3. Alle Rollläden schließen (domain: cover)
  4. Klimageräte auf Nachtmodus (climate.*, hvac_mode: sleep)
  5. Persistent Notification: "Gute Nacht - alle Geräte ausgeschaltet ?"
  6. Optional: TTS-Ansage über media_player.wohnzimmer

Exceptions:
- Nachtlicht (light.nachtlicht) soll AN bleiben
- Bad-Ventilator (switch.bad_ventilator) weiterlaufen lassen

Mode: single (nur einmal ausführbar)
Output: automation_suggestion mit choose-Struktur für Exceptions
```

---

## ?? GPT-5 / o3-mini (Strukturiert)

### Energie-Optimierung (Smart Charging)
```
Task: Create smart EV charging automation
Context:
- Charger: switch.wallbox_charging
- Price sensor: sensor.electricity_price_per_kwh
- SOC sensor: sensor.car_battery_soc
- Grid load: sensor.house_power_consumption

Logic:
- Charge when price < 0.20 EUR/kWh AND SOC < 80%
- Stop when SOC >= 80% OR price > 0.30 EUR/kWh
- Override: Always charge if SOC < 20% (emergency)
- Check interval: every 15 minutes

Requirements:
- Mode: restart
- Variables: price_threshold_low, price_threshold_high, soc_target
- Conditions with templating
- Detailed logging in actions

Output format: automation_suggestion JSON with complete structure
```

### Dynamische Heizungssteuerung
```
Task: Generate heating automation based on presence and weather
Entities:
- Thermostats: climate.bad, climate.computer, climate.wohnzimmer
- Presence: binary_sensor.presence_sensor_fp2_*_presence (multiple zones)
- Outside temp: sensor.openweathermap_temperature
- Window sensors: binary_sensor.fenster_*_contact

Conditions:
1. If any presence detected: Set temp to 21°C
2. If no presence for 30min: Set temp to 18°C (eco mode)
3. If outside temp > 15°C: Turn off heating
4. If any window open: Turn off heating in that room

Mode: restart
Output: automation_suggestion with nested choose/conditions
```

---

## ?? Gemini 2.5 (Experimentell)

### Wetter-basierte Bewässerung
```
Generiere bitte eine intelligente Gartenbewässerung-Automation:

Trigger:
- Täglich um 06:00 Uhr
- Nur wenn kein Regen in letzten 24h (sensor.rain_today == 0)

Bedingungen:
1. Außentemperatur > 20°C (sensor.openweathermap_temperature)
2. Luftfeuchtigkeit < 60% (sensor.openweathermap_humidity)
3. Boden-Feuchtigkeit < 30% (sensor.soil_moisture_garden)
4. Regenwahrscheinlichkeit < 40% (sensor.openweathermap_forecast_precipitation_probability)

Actions:
1. Schalte switch.garden_irrigation für 30 Minuten ein
2. Warte 30 Minuten (delay)
3. Schalte switch.garden_irrigation aus
4. Sende Benachrichtigung: "Garten bewässert - {{sensor.soil_moisture_garden}}% Feuchtigkeit"

Mode: single
Format: automation_suggestion mit vollständiger YAML-Struktur
```

### Alarm-System mit Verzögerung
```
Erstelle ein Alarm-System für "Haus verlassen":

Trigger:
- Haustür schließt (binary_sensor.aqara_door_and_window_sensor_tur changes to 'off')
- Alle Personen verlassen Haus (device_tracker.* all 'not_home')

Actions mit Verzögerung:
1. Warte 60 Sekunden (Zeit zum Verlassen)
2. Aktiviere Alarm (alarm_control_panel.home_alarm, code: !secret alarm_code)
3. Schalte alle Lichter aus (light.turn_off service, target: all)
4. Stelle Thermostate auf Eco (climate.set_temperature, temperature: 16)
5. Sende Push-Benachrichtigung: "Alarm scharf - Haus gesichert ??"

Deaktivierung:
- Bei Rückkehr (device_tracker.* becomes 'home'): Deaktiviere Alarm sofort

Mode: restart
Format: automation_suggestion mit wait_template und conditions
```

---

## ?? Universal-Prompts (für alle Provider)

### Basis-Template
```
Erstelle eine {{AUTOMATION_TYPE}} Automation:
- Name: {{DESCRIPTIVE_NAME}}
- Trigger: {{TRIGGER_DESCRIPTION}}
- Bedingung: {{CONDITION_DESCRIPTION}}
- Aktion: {{ACTION_DESCRIPTION}}
- Mode: {{MODE}} (single/restart/queued/parallel)

Nutze diese Entities:
{{ENTITY_LIST}}

Output: automation_suggestion im JSON-Format
```

### Erweitertes Template mit Variablen
```
Automation Request:
Type: {{TYPE}}
Trigger: {{TRIGGER}}
Conditions:
  - {{CONDITION_1}}
  - {{CONDITION_2}}
Actions:
  - {{ACTION_1}}
  - {{ACTION_2}}
Variables:
  {{VAR_NAME_1}}: {{VAR_VALUE_1}}
  {{VAR_NAME_2}}: {{VAR_VALUE_2}}
Mode: {{MODE}}
Output format: automation_suggestion JSON with complete YAML
```

---

## ?? Beispiel-Werte für Platzhalter

```yaml
# Räume
{{ROOM_NAME}}: "Wohnzimmer", "Bad", "Computer", "Schlafzimmer"

# Entitäten
{{LIGHT_ENTITY}}: "wohnzimmer", "bad", "computer_licht"
{{COVER_ENTITY}}: "rollladen_computer_vorhang", "kuche_blind_vorhang"
{{ZONE_ID}}: "f9cf_presence_sensor_1", "f9cf_presence_sensor_2"

# Schwellwerte
{{LUX_THRESHOLD}}: 400, 600, 800
{{BRIGHTNESS_PERCENT}}: 80, 60, 100
{{TIMEOUT_SECONDS}}: 300 (5min), 600 (10min), 1800 (30min)
{{AZIMUT_START}}: 120, 140
{{AZIMUT_END}}: 240, 260
{{POSITION_PARTIAL}}: 10, 20, 30

# Modi
{{MODE}}: "restart", "single", "queued", "parallel"

# Typen
{{AUTOMATION_TYPE}}: "Präsenz-Licht", "Rolladen-Steuerung", "Heizung", "Alarm"
```

---

## ? Quick-Prompts (Copy & Paste)

### Licht bei Bewegung
```
Schalte light.{{ROOM}} ein bei binary_sensor.presence_{{ROOM}}_presence, nur wenn sensor.light_level < 400. Mode: restart. Als automation_suggestion.
```

### Rolladen bei Sonne
```
Schließe cover.{{ROOM}} auf 20% bei sun.azimuth 120-240 UND lux > 600. Als automation_suggestion.
```

### Heizung Eco-Modus
```
Setze climate.{{ROOM}} auf 18°C wenn keine Präsenz seit 30min. Als automation_suggestion.
```

### Alle Lichter aus
```
Schalte alle light.* aus um 23:00 Uhr. Mode: single. Als automation_suggestion.
```

---

**Hinweis:** Ersetze `{{PLATZHALTER}}` mit tatsächlichen Entity-IDs aus deinem Home Assistant Setup (siehe CLAUDE.md für verfügbare Entities).
