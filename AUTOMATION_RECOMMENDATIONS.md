# 🏠 Home Assistant - Personalisierte Automations-Empfehlungen

**Erstellt für:** Dein Setup mit 28 Lichtern, 4 Rollläden, FP2 Presence, 2 Thermostaten
**Basierend auf:** Vergessene Aktionen, tägliche Routinen (Haus verlassen, Schlafen gehen, Gaming)
**Ziel:** Weniger manuelle Aktionen, mehr Komfort, Energie sparen

---

## 📊 Übersicht der 8 empfohlenen Automationen

| # | Automation | Priorität | Nutzen | Schwierigkeit | Zeit |
|---|------------|-----------|--------|---------------|------|
| 1 | **Haus verlassen** | ⭐⭐⭐⭐⭐ | Sehr hoch | Einfach | 10 Min |
| 2 | **Gute Nacht** | ⭐⭐⭐⭐⭐ | Sehr hoch | Einfach | 10 Min |
| 3 | **Duschen-Modus** | ⭐⭐⭐⭐ | Mittel | Mittel | 15 Min |
| 4 | **Gaming-Modus** | ⭐⭐⭐⭐ | Hoch | Einfach | 10 Min |
| 5 | **Vergessene Lichter-Killer** | ⭐⭐⭐⭐⭐ | Sehr hoch | Mittel | 20 Min |
| 6 | **Heizungs-Vergess-Schutz** | ⭐⭐⭐⭐ | Hoch | Einfach | 10 Min |
| 7 | **Intelligente Rollläden** | ⭐⭐⭐ | Mittel | Mittel | 15 Min |
| 8 | **Benachrichtigungen** | ⭐⭐⭐ | Mittel | Einfach | 15 Min |

**Gesamt-Implementierungszeit:** ~2 Stunden für alle
**Tägliche Zeitersparnis:** ~10 Minuten
**Jährliche Energie-Ersparnis:** ~200-300€

---

## 🎯 Automation 1: "Haus verlassen"

### Problem das gelöst wird:
- ✅ Vergessene Lichter bleiben an → Strom-Verschwendung
- ✅ Heizung läuft weiter → Heiz-Verschwendung
- ✅ Rollläden falsch positioniert → Sicherheit/Energie
- ✅ Viele einzelne Aktionen beim Gehen

### Was passiert automatisch:
1. **Alle 28 Lichter ausschalten**
2. **Heizung auf Eco-Modus** (16°C in beiden Räumen)
3. **Rollläden optimieren:**
   - Sommer (Temp > 25°C): Alle zu (Hitze-Schutz)
   - Winter: Alle halb runter (Sicherheit, aber etwas Licht/Wärme rein)
4. **Fenster-Check:** Benachrichtigung falls noch offen
5. **FP2 Presence pausieren** (keine False-Trigger während Abwesenheit)

### Trigger-Optionen:
**Option A - Manueller Button (empfohlen):**
- Dashboard-Button "Haus verlassen"
- Physischer Button an der Tür (falls vorhanden)
- Sprachbefehl "Alexa, ich gehe"

**Option B - Automatisch (Device Tracker):**
- Handy verlässt Heimnetzwerk
- Letzte Person verlässt Haus (falls mehrere Handys getrackt)

**Option C - Intelligente Detection:**
- Keine Bewegung (FP2) für 30 Minuten + Tür geöffnet/geschlossen

### Rückgängig-Machen (Nach Hause kommen):
- Button "Ich bin zurück" → Heizung auf 20°C, Licht im Flur an
- Automatisch: Handy im Heimnetzwerk → Heizung hoch, Willkommens-Licht

### Entity-IDs die angepasst werden müssen:
```yaml
# Lichter (deine 28)
- light.bad
- light.bett_licht
- light.computer_licht
- ... (siehe automation_templates/01_leaving_home.yaml)

# Heizung
- climate.thermostat_bad
- climate.thermostat_computer

# Rollläden
- cover.rollladen_computer_vorhang
- cover.kuche_blind_vorhang
- cover.schlafen_blind_vorhang
- cover.yoga_blind_vorhang

# Fenster-Sensoren
- binary_sensor.aqara_door_and_window_sensor_tur
- binary_sensor.aqara_door_and_window_sensor_tur_2
```

### Geschätzter Nutzen:
- **Zeitersparnis:** 2-3 Minuten/Tag
- **Energie-Ersparnis:** ~10-15% Heizkosten
- **Komfort:** ⭐⭐⭐⭐⭐

### Template-Datei:
→ `automation_templates/01_leaving_home.yaml`

---

## 🌙 Automation 2: "Gute Nacht"

### Problem das gelöst wird:
- ✅ Alle Lichter einzeln ausschalten (nervt!)
- ✅ Rollläden einzeln runterfahren
- ✅ Heizung optimal für Schlaf einstellen
- ✅ Vergessene Geräte anlassen

### Was passiert automatisch:
1. **Alle Lichter aus** (Ausnahme: Schlafzimmer-Nachtlicht 5% für 30 Sek)
2. **Alle 4 Rollläden runter** (komplette Abdunkelung)
3. **Heizung optimieren:**
   - Schlafzimmer: 18°C (optimal für Schlaf)
   - Andere Räume: 16°C (Eco während Schlaf)
4. **Smart-Plugs aus** (PC, Gaming-Geräte falls vorhanden)
5. **Fenster/Tür-Check:** Warnung falls noch offen (Sicherheit nachts)

### Trigger-Optionen:
**Option A - Manueller Button (empfohlen):**
- Dashboard-Button "Gute Nacht"
- Physischer Button am Bett
- Sprachbefehl "Alexa, Gute Nacht"

**Option B - Automatisch (Zeit-basiert):**
- Nach 23:00 Uhr + 20 Minuten keine Bewegung (FP2)
- Licht im Schlafzimmer geht aus → 5 Minuten später Routine starten

**Option C - Smart (Schlaf-Tracking):**
- Handy in Flugmodus / Nicht Stören aktiviert
- Smartwatch erkennt Schlaf-Phase

### Morgendliche Umkehrung ("Guten Morgen"):
- Wecker klingelt → Rollläden langsam hoch (15 Min Rampe)
- Heizung Bad auf 22°C (Vorheizen fürs Duschen)
- Licht im Schlafzimmer auf 10% warm-weiß

### Besonderheit - Nachtlicht:
```yaml
# 30 Sekunden sanftes Licht zum Orientieren
- service: light.turn_on
  target:
    entity_id: light.bett_licht
  data:
    brightness_pct: 5
    color_temp: 500  # Warm
- delay: "00:00:30"
- service: light.turn_off
  target:
    entity_id: light.bett_licht
```

### Entity-IDs anpassen:
- Alle 28 Lichter
- 4 Rollläden
- 2 Thermostate
- Optional: Smart Plugs für PC/Gaming

### Geschätzter Nutzen:
- **Zeitersparnis:** 3-5 Minuten/Tag
- **Energie-Ersparnis:** ~5% Stromkosten
- **Komfort:** ⭐⭐⭐⭐⭐ (TÄGLICH!)

### Template-Datei:
→ `automation_templates/02_good_night.yaml`

---

## 🚿 Automation 3: "Duschen-Modus"

### Problem das gelöst wird:
- ✅ Bad-Licht nicht optimal (zu dunkel oder zu hell)
- ✅ Bad kalt beim Duschen
- ✅ Heizung vergessen wieder runter zu drehen

### Was passiert automatisch:
1. **15 Min VOR Duschen:**
   - Bad-Heizung auf 24°C (Vorheizen)
2. **Beim Start (Button oder automatisch):**
   - Bad-Licht auf 100% warm-weiß (angenehm)
   - Optional: Musik starten (falls Alexa im Bad)
3. **Nach dem Duschen (Auto-Ende):**
   - Heizung zurück auf 20°C
   - Licht auf 70% (noch hell aber nicht blendend)
   - Nach 5 Min: Licht aus

### Trigger-Optionen:
**Option A - Manueller Button:**
- Dashboard-Button "Duschen"
- Physischer Button im Bad

**Option B - Zeit-basiert (Morgen-Routine):**
- Wochentags: 6:15 Uhr (15 Min vor Wecker um 6:30)
- Wochenende: 8:15 Uhr

**Option C - Automatisch (Sensoren):**
- FP2 Presence im Bad + Temperatur steigt + Luftfeuchtigkeit steigt
- (Erfordert zusätzlichen Temperatur/Luftfeuchtigkeit-Sensor)

### Auto-Ende Detection:
- Nach 30 Minuten (Sicherheits-Timeout)
- Bad-Tür wieder geöffnet
- Luftfeuchtigkeit sinkt wieder (Duschen beendet)
- Keine Bewegung (FP2) für 5 Minuten

### Optional - Erweiterungen:
```yaml
# Musik-Integration
- service: media_player.play_media
  target:
    entity_id: media_player.bad_alexa
  data:
    media_content_id: "Deine Playlist"
    media_content_type: playlist

# Smart Mirror aktivieren (falls vorhanden)
- service: switch.turn_on
  target:
    entity_id: switch.bad_spiegel
```

### Entity-IDs:
- `light.bad` - Bad-Licht
- `climate.thermostat_bad` - Bad-Heizung
- `binary_sensor.presence_sensor_fp2_bad` - Presence (falls vorhanden)
- Optional: `media_player`, `switch` für Extras

### Geschätzter Nutzen:
- **Komfort:** ⭐⭐⭐⭐ (Warmes Bad!)
- **Energie:** Neutral (Heizung nur wenn gebraucht)
- **Coolness-Faktor:** ⭐⭐⭐⭐⭐

### Template-Datei:
→ `automation_templates/03_shower_mode.yaml`

---

## 🎮 Automation 4: "Gaming-Modus"

### Problem das gelöst wird:
- ✅ Licht blendet auf Monitor
- ✅ Rolladen muss manuell runter beim Zocken
- ✅ Andere Lichter stören Atmosphäre

### Was passiert automatisch:
1. **PC-Bereich Licht auf 50%** (nicht blendend, nicht zu dunkel)
2. **Rollladen PC runter** (kein Sonnenblendung)
3. **Restliche Lichter aus** (Fokus auf Monitor)
4. **Heizung PC-Raum auf 20°C** (PC heizt mit, nicht zu warm)
5. **Optional: RGB-Beleuchtung aktivieren** (falls vorhanden)

### Trigger:
**Option A - PC eingeschaltet (Smart Plug mit Leistungsmessung):**
```yaml
trigger:
  - platform: numeric_state
    entity_id: sensor.pc_plug_power
    above: 100  # Watt = PC ist an
```

**Option B - Abends + Bewegung am PC:**
```yaml
trigger:
  - platform: time
    at: "19:00:00"
condition:
  - condition: state
    entity_id: binary_sensor.presence_sensor_fp2_pc_bereich
    state: "on"
```

**Option C - Manueller Button:**
- Dashboard "Gaming starten"
- Sprachbefehl "Alexa, Gaming-Modus"

### Auto-Ende:
- PC ausgeschaltet (Smart Plug < 50 Watt)
- Keine Bewegung für 30 Minuten
- Nach 02:00 Uhr nachts (Sicherheits-Timeout)

### Rückgängig (Nach Gaming):
- Licht wieder auf normal (100%)
- Rollladen hoch (falls noch hell draußen)
- Heizung zurück auf 20°C

### Optional - Gaming-Atmosphäre:
```yaml
# Hue RGB-Strips (falls vorhanden)
- service: light.turn_on
  target:
    entity_id: light.pc_rgb_strip
  data:
    effect: "Gaming"  # Pulsierend, Regenbogen, etc.
    brightness_pct: 80

# Philips Hue Play Bars
- service: scene.turn_on
  target:
    entity_id: scene.gaming_atmosphere
```

### Entity-IDs:
- `light.computer_licht`
- `cover.rollladen_computer_vorhang`
- `climate.thermostat_computer`
- `sensor.pc_plug_power` (falls Smart Plug vorhanden)
- `binary_sensor.presence_sensor_fp2_computer`

### Geschätzter Nutzen:
- **Zeitersparnis:** 1-2 Minuten/Tag
- **Komfort:** ⭐⭐⭐⭐ (Besseres Gaming-Erlebnis!)
- **Energie:** Neutral

### Template-Datei:
→ `automation_templates/04_gaming_mode.yaml`

---

## 💡 Automation 5: "Vergessene Lichter-Killer"

### Problem das gelöst wird:
- ✅ Lichter bleiben über Nacht an → Strom-Verschwendung
- ✅ Lichter bleiben an obwohl niemand im Raum → Verschwendung
- ✅ Lichter bleiben an obwohl es hell genug ist

### Was passiert automatisch:
**Regel 1: Nachts (23:30 Uhr)**
- Alle Lichter aus (Ausnahme: Schlafzimmer falls Presence)

**Regel 2: Raum verlassen (FP2 Presence)**
- Keine Bewegung für 2 Minuten → Licht aus
- Warnung 10 Sekunden vorher (Licht blinkt 3x kurz)

**Regel 3: Zu hell draußen**
- Helligkeit > 600 Lux → Licht aus (Tageslicht reicht!)
- Nur Räume mit Fenster

**Regel 4: Lange Abwesenheit**
- Kein Presence in Raum für 30 Minuten → Garantiert aus

### Intelligente Ausnahmen:
```yaml
# NICHT ausschalten wenn:
conditions:
  - condition: or
    conditions:
      # Gaming-Modus aktiv
      - condition: state
        entity_id: input_boolean.gaming_mode
        state: "on"

      # Film schauen (Medien-Player läuft)
      - condition: state
        entity_id: media_player.wohnzimmer
        state: "playing"

      # Gäste-Modus aktiv
      - condition: state
        entity_id: input_boolean.guest_mode
        state: "on"
```

### Warnung vor Auto-Aus:
```yaml
# 10 Sekunden vorher: Licht 3x blinken
- repeat:
    count: 3
    sequence:
      - service: light.turn_off
        target:
          entity_id: "{{ trigger.entity_id }}"
      - delay: "00:00:01"
      - service: light.turn_on
        target:
          entity_id: "{{ trigger.entity_id }}"
      - delay: "00:00:01"
```

### Pro-Raum Konfiguration:
```yaml
# Bad: 5 Min Timeout (länger wegen Duschen)
# Schlafzimmer: 30 Min Timeout (falls im Bett lesen)
# Küche: 2 Min Timeout (schnell an/aus)
# Wohnzimmer: 15 Min Timeout (Film, Entspannen)
```

### Entity-IDs:
- Alle 28 Lichter
- `sensor.presence_sensor_fp2_light_sensor_light_level` (Lux)
- `binary_sensor.presence_sensor_fp2_presence_sensor_X` (für jeden Raum)
- `input_boolean.gaming_mode`, `input_boolean.guest_mode` (Helper erstellen)

### Geschätzter Nutzen:
- **Energie-Ersparnis:** ~15-20% Stromkosten (Licht)
- **Umwelt:** ~100 kWh/Jahr weniger
- **Komfort:** ⭐⭐⭐⭐⭐ (Keine vergessenen Lichter mehr!)

### Template-Datei:
→ `automation_templates/05_forgotten_lights_killer.yaml`

---

## 🔥 Automation 6: "Heizungs-Vergess-Schutz"

### Problem das gelöst wird:
- ✅ Heizung läuft bei offenem Fenster → Massive Verschwendung
- ✅ Heizung bleibt hoch wenn Haus verlassen
- ✅ Heizung nicht optimal für Tageszeit

### Was passiert automatisch:
**Regel 1: Fenster auf + Heizung an**
```yaml
trigger:
  - platform: state
    entity_id: binary_sensor.aqara_door_and_window_sensor_tur
    to: "on"  # Fenster geöffnet
    for: "00:00:30"  # 30 Sek Debouncing

condition:
  - condition: numeric_state
    entity_id: climate.thermostat_bad
    attribute: temperature
    above: 16  # Heizung ist an

action:
  # Heizung aus
  - service: climate.set_temperature
    target:
      entity_id: climate.thermostat_bad
    data:
      temperature: 16

  # Benachrichtigung
  - service: notify.alexa_media_wohnzimmer
    data:
      title: "Heizung ausgeschaltet"
      message: "Fenster ist offen. Heizung wurde auf Eco gestellt."
```

**Regel 2: Fenster zu + Heizung war vorher an**
- Stelle Heizung wieder auf alte Temperatur
- Speichere vorherige Temperatur in `input_number.previous_temp`

**Regel 3: Haus verlassen**
- Alle Heizungen auf 16°C (Eco-Modus)
- Speichere aktuelle Temperaturen für Rückkehr

**Regel 4: Nach Hause kommen**
- Heizungen wieder auf Komfort-Temperatur (20°C)

**Regel 5: Optimale Temperaturen**
```yaml
# Tageszeit-basiert
06:00-08:00 Uhr: 21°C (Morgen-Komfort)
08:00-17:00 Uhr: 19°C (Tagsüber, evtl. nicht zu Hause)
17:00-23:00 Uhr: 20°C (Abend-Komfort)
23:00-06:00 Uhr: 18°C (Schlaf-Temperatur)
```

### Intelligente Erweiterung:
```yaml
# Wetter-basierte Anpassung
# Sonnig + warm → Heizung runter
# Bewölkt + kalt → Heizung etwas höher

condition:
  - condition: numeric_state
    entity_id: sensor.openweathermap_temperature
    below: 10  # Draußen kalt

action:
  - service: climate.set_temperature
    data:
      temperature: "{{ 21 if is_state('sun.sun', 'above_horizon') else 20 }}"
```

### Entity-IDs:
- `climate.thermostat_bad`
- `climate.thermostat_computer`
- `binary_sensor.aqara_door_and_window_sensor_tur`
- `binary_sensor.aqara_door_and_window_sensor_tur_2`
- `sensor.openweathermap_temperature`
- `input_number.previous_temp_bad` (Helper erstellen)

### Geschätzter Nutzen:
- **Energie-Ersparnis:** ~20-30% Heizkosten (!)
- **Jährliche Einsparung:** ~150-250€
- **Umwelt:** ~500-800 kWh/Jahr weniger

### Template-Datei:
→ `automation_templates/06_heating_protection.yaml`

---

## 🪟 Automation 7: "Intelligente Rollläden"

### Problem das gelöst wird:
- ✅ Rollläden manuell jeden Tag hoch/runter
- ✅ Rollladen-Position nicht optimal für Jahreszeit
- ✅ Vergessen bei Sonne/Blendung

### Was passiert automatisch:
**Morgens (Sonnenaufgang):**
```yaml
trigger:
  - platform: sun
    event: sunrise
    offset: "+00:30:00"  # 30 Min nach Sonnenaufgang

action:
  - service: cover.open_cover
    target:
      entity_id:
        - cover.kuche_blind_vorhang
        - cover.schlafen_blind_vorhang
        - cover.yoga_blind_vorhang
  # PC-Rollladen bleibt zu (wegen Gaming/Monitor)
```

**Abends (Sonnenuntergang):**
```yaml
trigger:
  - platform: sun
    event: sunset
    offset: "-00:30:00"  # 30 Min vor Sonnenuntergang

action:
  - service: cover.close_cover
    target:
      entity_id:
        - cover.kuche_blind_vorhang
        - cover.schlafen_blind_vorhang
        - cover.yoga_blind_vorhang

  # PC-Rollladen nur wenn NICHT Gaming-Modus
  - choose:
    - conditions:
        - condition: state
          entity_id: input_boolean.gaming_mode
          state: "off"
      sequence:
        - service: cover.close_cover
          target:
            entity_id: cover.rollladen_computer_vorhang
```

**Sommer-Hitze-Schutz:**
```yaml
# Tagsüber bei Hitze: Rollläden zu
trigger:
  - platform: numeric_state
    entity_id: sensor.openweathermap_temperature
    above: 28
  - platform: time
    at: "12:00:00"  # Mittags checken

condition:
  - condition: state
    entity_id: sun.sun
    state: "above_horizon"
  - condition: numeric_state
    entity_id: sensor.openweathermap_temperature
    above: 25

action:
  - service: cover.close_cover  # Alle zu bei Hitze
```

**Winter-Wärme-Gewinn:**
```yaml
# Sonnig + kalt → Rollläden auf für Sonnen-Wärme
condition:
  - condition: numeric_state
    entity_id: sensor.openweathermap_temperature
    below: 10
  - condition: state
    entity_id: sun.sun
    state: "above_horizon"
  - condition: numeric_state
    entity_id: sensor.openweathermap_cloud_coverage
    below: 30  # Wenig Wolken

action:
  - service: cover.open_cover  # Alle auf für Sonnen-Wärme
```

**PC-Rollladen Anti-Blendung (bereits vorhanden, erweitern):**
- Nutze bestehende `roller_pc_anti_glare` Automation
- Erweitere um Gaming-Modus-Ausnahme

### Bei Abwesenheit:
```yaml
# Sicherheit: Rollläden halb runter
action:
  - service: cover.set_cover_position
    target:
      entity_id: all
    data:
      position: 50  # Halb = nicht komplett dunkel (Anwesenheit simulieren)
```

### Entity-IDs:
- `cover.rollladen_computer_vorhang`
- `cover.kuche_blind_vorhang`
- `cover.schlafen_blind_vorhang`
- `cover.yoga_blind_vorhang`
- `sun.sun`
- `sensor.openweathermap_temperature`
- `sensor.openweathermap_cloud_coverage`

### Geschätzter Nutzen:
- **Zeitersparnis:** 2-3 Minuten/Tag
- **Energie (Sommer):** ~10% Kühlung (weniger Hitze)
- **Energie (Winter):** ~5% Heizung (Sonnen-Wärme nutzen)
- **Komfort:** ⭐⭐⭐⭐

### Template-Datei:
→ `automation_templates/07_intelligent_covers.yaml`

---

## 🔔 Automation 8: "Benachrichtigungs-Zentrale"

### Problem das gelöst wird:
- ✅ Wichtige Sachen vergessen zu checken
- ✅ Keine Warnung bei kritischen Situationen
- ✅ Zu viele unnötige Benachrichtigungen

### Intelligente Benachrichtigungen:
**1. Haus verlassen + Fenster/Tür offen**
```yaml
trigger:
  - platform: state
    entity_id: device_tracker.dein_handy
    from: "home"
    to: "not_home"

condition:
  - condition: or
    conditions:
      - condition: state
        entity_id: binary_sensor.aqara_door_and_window_sensor_tur
        state: "on"
      - condition: state
        entity_id: binary_sensor.aqara_door_and_window_sensor_tur_2
        state: "on"

action:
  - service: notify.mobile_app_dein_handy
    data:
      title: "⚠️ Fenster/Tür offen!"
      message: "Du hast das Haus verlassen, aber ein Fenster oder Tür ist noch offen."
      data:
        actions:
          - action: "IGNORE"
            title: "Ignorieren"
          - action: "REMIND_LATER"
            title: "Später erinnern"
```

**2. Nachts (23:00 Uhr) Fenster offen**
```yaml
trigger:
  - platform: time
    at: "23:00:00"

condition:
  - condition: state
    entity_id: binary_sensor.aqara_door_and_window_sensor_tur
    state: "on"

action:
  - service: notify.alexa_media_wohnzimmer
    data:
      message: "Achtung: Ein Fenster ist noch offen. Möchtest du es schließen?"
```

**3. Heizung läuft bei offenem Fenster > 10 Min**
```yaml
trigger:
  - platform: state
    entity_id: binary_sensor.aqara_door_and_window_sensor_tur
    to: "on"
    for: "00:10:00"

condition:
  - condition: numeric_state
    entity_id: climate.thermostat_bad
    attribute: temperature
    above: 16

action:
  - service: notify.persistent_notification
    data:
      title: "💸 Energie-Verschwendung!"
      message: "Heizung läuft seit 10 Minuten bei offenem Fenster."
```

**4. Keine Bewegung > 24 Stunden (Presence-Check)**
```yaml
# Sicherheits-Feature: Prüft ob jemand zu Hause ist
trigger:
  - platform: state
    entity_id: binary_sensor.presence_sensor_fp2_combined
    to: "off"
    for: "24:00:00"

action:
  - service: notify.mobile_app_notfall_kontakt
    data:
      title: "🚨 Keine Bewegung seit 24h"
      message: "Es wurde seit 24 Stunden keine Bewegung im Haus erkannt. Alles OK?"
```

**5. Wasser-Leck detektiert**
```yaml
trigger:
  - platform: state
    entity_id: binary_sensor.aqara_water_leak_sensor_feuchte
    to: "on"

action:
  - service: notify.mobile_app_dein_handy
    data:
      title: "🚨 WASSER-LECK!"
      message: "Der Wasser-Sensor hat Feuchtigkeit erkannt!"
      data:
        priority: high
        ttl: 0
        channel: alarm_stream

  - service: notify.alexa_media_wohnzimmer
    data:
      message: "ACHTUNG! Wasser-Leck erkannt! Bitte sofort prüfen!"
      data:
        type: announce
```

**6. Regen-Warnung + Fenster offen**
```yaml
trigger:
  - platform: state
    entity_id: weather.openweathermap
    attribute: forecast
    # Regen in den nächsten 30 Minuten

condition:
  - condition: state
    entity_id: binary_sensor.aqara_door_and_window_sensor_tur
    state: "on"

action:
  - service: notify.mobile_app_dein_handy
    data:
      title: "☔ Regen-Warnung"
      message: "In 30 Minuten kommt Regen und ein Fenster ist noch offen!"
```

### Benachrichtigungs-Einstellungen:
```yaml
# Nicht zwischen 00:00 - 07:00 Uhr (außer Kritisch)
condition:
  - condition: or
    conditions:
      # Kritische Benachrichtigung (immer)
      - condition: template
        value_template: "{{ is_critical }}"

      # Oder normale Zeit (7-24 Uhr)
      - condition: time
        after: "07:00:00"
        before: "00:00:00"
```

### Via-Optionen:
- **Alexa Ansage:** `notify.alexa_media_wohnzimmer`
- **Handy-Benachrichtigung:** `notify.mobile_app_dein_handy`
- **Persistent (in HA UI):** `notify.persistent_notification`
- **E-Mail:** `notify.email` (falls konfiguriert)

### Entity-IDs:
- Alle Fenster/Tür-Sensoren
- `device_tracker.dein_handy`
- `binary_sensor.aqara_water_leak_sensor_feuchte`
- `weather.openweathermap`
- Thermostate

### Geschätzter Nutzen:
- **Sicherheit:** ⭐⭐⭐⭐⭐ (Kritische Warnungen!)
- **Energie-Ersparnis:** ~5-10% (durch Erinnerungen)
- **Komfort:** ⭐⭐⭐⭐

### Template-Datei:
→ `automation_templates/08_notification_center.yaml`

---

## 📊 Gesamt-Nutzen Übersicht

### Zeitersparnis pro Woche:
- Haus verlassen: 14-21 Min/Woche
- Gute Nacht: 21-35 Min/Woche
- Gaming/Duschen: 7-14 Min/Woche
- **Gesamt:** ~1 Stunde/Woche = **52 Stunden/Jahr**

### Energie-Einsparung pro Jahr:
| Bereich | Einsparung | Kosten (0.30€/kWh) |
|---------|------------|---------------------|
| Lichter | 150 kWh | ~45€ |
| Heizung | 500-800 kWh | ~150-240€ |
| Optimierung | 100 kWh | ~30€ |
| **GESAMT** | **~750-1050 kWh** | **~225-315€/Jahr** |

### Komfort-Gewinn:
- ⭐⭐⭐⭐⭐ Keine vergessenen Aktionen mehr
- ⭐⭐⭐⭐⭐ Ein-Knopf-Lösungen für komplexe Abläufe
- ⭐⭐⭐⭐ Intelligente Anpassung an Situationen
- ⭐⭐⭐⭐ Benachrichtigungen für wichtige Events

---

## 🚀 Nächste Schritte

### 1. Templates durchgehen
Siehe `automation_templates/` Ordner - jede Datei ist fertig zum Importieren!

### 2. Installation
Siehe `AUTOMATION_INSTALLATION_GUIDE.md` für detaillierte Anleitung

### 3. Priorisierung
**Sofort (größter Nutzen):**
1. Haus verlassen
2. Gute Nacht
3. Vergessene Lichter-Killer

**Diese Woche:**
4. Heizungs-Schutz
5. Gaming-Modus

**Später:**
6. Duschen-Modus
7. Intelligente Rollläden
8. Benachrichtigungen

### 4. Anpassung
- Entity-IDs in jedem Template ersetzen
- Zeiten/Schwellwerte an deine Präferenzen anpassen
- Testen & Optimieren

---

**Viel Erfolg! Bei Fragen siehe `AUTOMATION_INSTALLATION_GUIDE.md` oder frag mich einfach!** 😊
