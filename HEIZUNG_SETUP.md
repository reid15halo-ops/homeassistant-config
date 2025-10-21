# 🌡️ Intelligente Heizungssteuerung - Setup & Anleitung

## ✅ Was wurde installiert?

### 1. Helper-Entities (in configuration.yaml)

**Input Numbers (Temperatur-Sollwerte):**
- `input_number.heizung_solltemperatur_komfort` - Komfort-Modus (Standard: 21°C)
- `input_number.heizung_solltemperatur_eco` - Eco-Modus (Standard: 18°C)
- `input_number.heizung_solltemperatur_nacht` - Nacht-Modus (Standard: 17°C)

**Input Booleans (Modi):**
- `input_boolean.heizung_eco_mode` - Manueller Eco-Modus Toggle
- `input_boolean.heizung_winter_mode` - Winter-Modus für Rollläden-Optimierung

**Binary Sensor:**
- `binary_sensor.sommerbetrieb_ortsbasiert` - Automatische Sommerbetrieb-Erkennung (>18°C)

### 2. Automationen (7 neue + 1 deaktivierte)

#### ✅ Aktive Automationen:

1. **heizung_aus_warm_draussen** - Heizung aus bei >18°C Außentemperatur
2. **heizung_reduzieren_sonne** - Passive Solarheizung (Heizung reduzieren bei Sonne)
3. **heizung_vorheizen_kalt** - Morgens vorheizen bei kalter Wettervorhersage
4. **heizung_eco_abwesenheit** - Eco-Modus bei Abwesenheit >30 Min
5. **heizung_nachtabsenkung_smart** - Nachtabsenkung 22:00-06:00
6. **heizung_fenster_intelligent** - Intelligente Fenster-offen Automation (ersetzt alte)
7. **heizung_winter_rollladen** - Winter-Rollläden (Dämmung nachts + passive Heizung tags)

#### ❌ Deaktivierte Automation:
- `Heizung Aus Fenster offen (ALT)` - Ersetzt durch intelligente Version

---

## 🚀 Erste Schritte

### Schritt 1: YAML neu laden

```bash
# Via SSH:
ssh reid15@192.168.178.71

# YAML neu laden (ohne Neustart):
ha core reload

# ODER in der Home Assistant UI:
# Developer Tools → YAML → Alle YAML-Konfigurationen neu laden
```

### Schritt 2: Helper-Werte einstellen

Nach dem Neustart findest du die neuen Eingabefelder in der UI:

**Einstellungen → Geräte & Dienste → Helfer**

Dort kannst du die Temperaturen anpassen:
- Komfort: 21°C (wenn du zuhause bist)
- Eco: 18°C (bei Abwesenheit)
- Nacht: 17°C (22:00-06:00)

### Schritt 3: Modi aktivieren

**Winter-Modus aktivieren (empfohlen für Heizperiode):**

```yaml
# In Developer Tools → Services:
service: input_boolean.turn_on
target:
  entity_id: input_boolean.heizung_winter_mode
```

Oder in der UI: Schalter für "Heizung Winter-Modus" anschalten.

---

## 📊 Funktionsübersicht

### 1. Außentemperatur-basierte Steuerung

**Wie es funktioniert:**
- Prüft alle 15 Minuten die Außentemperatur
- Heizung AUS bei >18°C (Sommerbetrieb)
- Heizung AN bei <17°C (Winterbetrieb)

**Trigger:**
- Automatisch alle 15 Minuten
- Sofort bei Temperaturwechsel über/unter Schwellenwert

**Benachrichtigung:**
- Zeigt aktuelle Außentemperatur
- Informiert über Heizungs-Status

---

### 2. Passive Solarheizung

**Wie es funktioniert:**
- Erkennt starke Sonneneinstrahlung (>600 lux)
- Prüft Sonnenstand (Azimut 120-240°, Elevation >20°)
- Reduziert Heizung um -2°C wenn Sonne ins Zimmer scheint
- Spart Energie durch kostenlose Sonnenwärme

**Nur aktiv wenn:**
- Winter-Modus AN
- Außentemperatur <17°C
- Tagsüber (Sunrise-Sunset)

**Betroffene Zimmer:**
- Hauptsächlich Computer-Raum (Süd-Seite)

---

### 3. Vorheizen bei kaltem Wetter

**Wie es funktioniert:**
- Werktags um 05:00 Uhr
- Prüft Wettervorhersage für den Tag
- Heizt stärker vor (+1°C) wenn kalter Tag vorhergesagt (<10°C max)

**Vorteil:**
- Warmes Zimmer wenn du aufstehst
- Vorausschauende Planung

---

### 4. Eco-Modus bei Abwesenheit

**Wie es funktioniert:**
- Erkennt Abwesenheit über `binary_sensor.clt_l09_anwesenheit`
- Nach 30 Min: Heizung auf Eco-Temperatur (18°C)
- Bei Heimkehr: Automatisch zurück auf Komfort (21°C)

**Energie-Ersparnis:**
- ~15-20% durch intelligente Absenkung
- Nur wenn wirklich nötig heizen

**Benachrichtigung:**
- "Eco-Modus aktiv" bei Abwesenheit
- "Willkommen!" bei Heimkehr

---

### 5. Nachtabsenkung

**Zeitplan:**
- 22:00 Uhr → Nacht-Temperatur (17°C)
- 06:00 Uhr → Komfort-Temperatur (21°C) - nur wenn zuhause

**Besonderheit:**
- Morgens nur hochheizen wenn jemand zuhause
- Sonst bleibt Eco-Modus aktiv

---

### 6. Intelligente Fenster-Steuerung

**Verbesserungen gegenüber alter Version:**

✅ Heizung geht automatisch WIEDER AN wenn Fenster zu
✅ Prüft Außentemperatur (nur bei Bedarf anschalten)
✅ Setzt richtige Temperatur je nach Tageszeit/Modus
✅ 2-Minuten Wartezeit (nicht sofort an nach Schließen)

**Logik:**
```
Fenster auf → Heizung AUS
↓ (warte bis alle Fenster zu)
Alle Fenster zu + draußen kalt (<17°C)
↓ (warte 2 Minuten)
Heizung AN mit passender Temperatur:
  - Eco-Modus aktiv? → 18°C
  - Nachtzeit (22-06)? → 17°C
  - Sonst → 21°C (Komfort)
```

---

### 7. Winter-Rollläden Optimierung

**Nur aktiv wenn:**
- Winter-Modus AN (`input_boolean.heizung_winter_mode`)
- Außentemperatur <15°C

**Zeitplan:**
- **Sonnenaufgang +30 Min:** Alle Rollläden AUF
  - Grund: Passive Solarheizung durch Sonneneinstrahlung

- **Sonnenuntergang -30 Min:** Alle Rollläden ZU
  - Grund: Wärmedämmung (Rollläden = zusätzliche Isolierung)

**Energie-Ersparnis:**
- Nachts: Bis zu 10% Wärmeverlust-Reduktion durch geschlossene Rollläden
- Tags: Kostenlose Sonnenwärme nutzen

---

## 🎛️ Manuelle Steuerung

### Eco-Modus manuell aktivieren

```yaml
service: input_boolean.turn_on
target:
  entity_id: input_boolean.heizung_eco_mode
```

**Was passiert:**
- Heizung wird auf Eco-Temperatur gesenkt
- Bleibt aktiv bis du es manuell ausschaltest
- Wird NICHT durch Heimkehr-Automation überschrieben

### Winter-Modus aktivieren/deaktivieren

**Aktivieren (Heizperiode):**
```yaml
service: input_boolean.turn_on
target:
  entity_id: input_boolean.heizung_winter_mode
```

**Deaktivieren (Sommer):**
```yaml
service: input_boolean.turn_off
target:
  entity_id: input_boolean.heizung_winter_mode
```

### Temperatur-Sollwerte ändern

**Via UI:**
- Einstellungen → Helfer → "Heizung Komfort-Temperatur" etc.
- Schieberegler verwenden

**Via Service:**
```yaml
service: input_number.set_value
target:
  entity_id: input_number.heizung_solltemperatur_komfort
data:
  value: 22
```

---

## 📈 Erwartete Energie-Ersparnis

### Berechnungsgrundlage:
- Basis: Durchschnittliche Heizkosten 1200€/Jahr
- System: 2 Thermostate (Bad + Computer)

### Einsparpotenzial nach Maßnahme:

| Maßnahme | Ersparnis | € pro Jahr |
|----------|-----------|------------|
| Außentemperatur-Steuerung (aus bei >18°C) | 5-8% | 60-96€ |
| Passive Solarheizung (Sonne nutzen) | 3-5% | 36-60€ |
| Eco-Modus bei Abwesenheit | 10-15% | 120-180€ |
| Nachtabsenkung (22:00-06:00) | 8-12% | 96-144€ |
| Winter-Rollläden Optimierung | 5-10% | 60-120€ |
| **GESAMT (ohne Überlappung)** | **15-25%** | **180-300€** |

**Realistische Ersparnis:** 200-250€ pro Jahr

---

## 🔧 Anpassungen & Optimierungen

### Temperaturschwellenwerte anpassen

**Heizung aus bei anderer Außentemperatur:**

Datei: `automations.yaml`, Automation `heizung_aus_warm_draussen`

```yaml
# Ändere diese Zeilen:
above: 18  # ← Heizung aus wenn >18°C
below: 17  # ← Heizung an wenn <17°C
```

### Vorheiz-Zeiten ändern

**Andere Uhrzeit für Vorheizen:**

Datei: `automations.yaml`, Automation `heizung_vorheizen_kalt`

```yaml
trigger:
  - platform: time
    at: "05:00:00"  # ← Ändere auf gewünschte Zeit
```

### Abwesenheits-Delay anpassen

**Eco-Modus nach anderer Zeit:**

Datei: `automations.yaml`, Automation `heizung_eco_abwesenheit`

```yaml
trigger:
  - platform: state
    entity_id: binary_sensor.clt_l09_anwesenheit
    to: 'off'
    for:
      minutes: 30  # ← Ändere auf gewünschte Wartezeit
```

### Nachtabsenkungs-Zeiten ändern

**Andere Nacht-Zeiten:**

Datei: `automations.yaml`, Automation `heizung_nachtabsenkung_smart`

```yaml
trigger:
  - platform: time
    at: "22:00:00"  # ← Abends runter
    id: night

  - platform: time
    at: "06:00:00"  # ← Morgens hoch
    id: morning
```

---

## 🐛 Troubleshooting

### Problem: Helper-Entities nicht verfügbar

**Lösung:**
```bash
# SSH ins System:
ssh reid15@192.168.178.71

# Configuration prüfen:
ha core check

# Bei OK:
ha core restart
```

### Problem: Automationen triggern nicht

**Prüfen:**
1. Developer Tools → States → Suche nach `sensor.openweathermap_temperature`
2. Ist der Wert aktuell? (sollte sich alle ~10-15 Min aktualisieren)
3. Automation Trace ansehen:
   - Settings → Automations & Scenes → [Automation] → Traces

**Häufige Ursache:**
- OpenWeatherMap Integration offline
- Fix: Settings → Integrations → OpenWeatherMap → Neu einrichten

### Problem: Heizung schaltet nicht zurück nach Fenster zu

**Debug:**
```yaml
# In Developer Tools → Template:
{{ states('binary_sensor.aqara_door_and_window_sensor_tur') }}
{{ states('binary_sensor.aqara_door_and_window_sensor_tur_2') }}
{{ states('sensor.openweathermap_temperature')|float(0) }}
```

**Prüfe:**
- Sind beide Sensoren auf `off`?
- Ist Außentemperatur <17°C?
- Wenn ja → Automation sollte triggern nach 2 Min

### Problem: Winter-Modus funktioniert nicht

**Prüfen:**
1. Ist `input_boolean.heizung_winter_mode` auf `on`?
2. Ist Außentemperatur <15°C?
3. Trace der Automation `heizung_winter_rollladen` ansehen

---

## 📱 Dashboard-Integration (optional)

### Heizungs-Karte für Lovelace:

```yaml
type: entities
title: 🌡️ Heizungssteuerung
entities:
  - entity: input_number.heizung_solltemperatur_komfort
    name: Komfort-Temperatur
  - entity: input_number.heizung_solltemperatur_eco
    name: Eco-Temperatur
  - entity: input_number.heizung_solltemperatur_nacht
    name: Nacht-Temperatur
  - type: divider
  - entity: input_boolean.heizung_eco_mode
    name: Eco-Modus
  - entity: input_boolean.heizung_winter_mode
    name: Winter-Modus
  - type: divider
  - entity: binary_sensor.sommerbetrieb_ortsbasiert
    name: Sommerbetrieb
  - entity: sensor.openweathermap_temperature
    name: Außentemperatur
```

### Energie-Karte:

```yaml
type: vertical-stack
cards:
  - type: thermostat
    entity: climate.thermostat_bad
    name: Thermostat Bad

  - type: thermostat
    entity: climate.thermostat_computer
    name: Thermostat Computer

  - type: entities
    title: Status
    entities:
      - entity: binary_sensor.aqara_door_and_window_sensor_tur
        name: Fenster 1
      - entity: binary_sensor.aqara_door_and_window_sensor_tur_2
        name: Fenster 2
      - entity: binary_sensor.clt_l09_anwesenheit
        name: Anwesenheit
```

---

## 🎓 Wie die Automationen zusammenarbeiten

### Prioritäts-Hierarchie:

1. **Fenster offen** → Heizung AUS (höchste Priorität)
2. **Außentemperatur >18°C** → Heizung AUS
3. **Manuelle Eco-Mode** → Bleibt aktiv bis ausgeschaltet
4. **Automatischer Eco (Abwesenheit)** → Wird bei Heimkehr deaktiviert
5. **Nachtabsenkung** → 22:00-06:00
6. **Passive Solarheizung** → Reduziert bei Sonne
7. **Vorheizen** → Morgens bei kaltem Wetter

### Beispiel-Szenarien:

**Szenario 1: Morgens um 06:00 Uhr (Werktag, Winter)**
```
1. Nachtabsenkung-Automation triggert (morning)
2. Prüft: Zuhause? JA
3. Setzt Temperatur auf Komfort (21°C)
4. Wenn draußen sehr kalt (<12°C):
   → Vorheiz-Automation prüft Forecast
   → Ggf. auf 22°C erhöhen
```

**Szenario 2: Tagsüber, Sonne scheint**
```
1. Lichtsensor misst >600 lux
2. Sonnenstand OK (Süd-Seite)
3. Winter-Modus aktiv? JA
4. → Heizung Computer auf 19°C (21-2)
5. Spart Energie durch passive Solarwärme
```

**Szenario 3: Verlasse Haus**
```
1. Nach 30 Min: Abwesenheit erkannt
2. Eco-Automation triggert
3. Setzt input_boolean.heizung_eco_mode = ON
4. Heizung auf 18°C
5. Spart ~15% Energie
```

**Szenario 4: Heimkehr**
```
1. Anwesenheit erkannt
2. Eco-Automation triggert (home)
3. Deaktiviert Eco-Modus
4. Heizung auf Komfort (21°C)
5. Benachrichtigung: "Willkommen!"
```

**Szenario 5: Fenster öffnen zum Lüften**
```
1. Fenster-Sensor: ON
2. Heizung sofort AUS
3. Benachrichtigung: "Fenster offen"
---
(10 Min später)
4. Fenster geschlossen
5. Warte 2 Minuten
6. Prüfe Außentemp: <17°C? JA
7. Heizung AN
8. Setze Temperatur je nach Tageszeit:
   - 22:00-06:00 → 17°C (Nacht)
   - Eco aktiv → 18°C
   - Sonst → 21°C (Komfort)
```

---

## 🔄 Wartung & Updates

### Regelmäßige Checks (alle 3 Monate):

1. **Sensor-Verfügbarkeit prüfen:**
   - Developer Tools → States
   - Suche: `unavailable`
   - Batterien prüfen!

2. **Automation-Traces ansehen:**
   - Settings → Automations & Scenes
   - Sortiere nach "Last Triggered"
   - Prüfe ob alle aktiv sind

3. **Temperatur-Sollwerte optimieren:**
   - Nach Jahreszeit anpassen
   - Winter: Komfort 21°C, Eco 18°C, Nacht 17°C
   - Übergangszeit: Komfort 20°C, Eco 17°C, Nacht 16°C

### Saisonale Anpassungen:

**Frühjahr (März-Mai):**
- Winter-Modus DEAKTIVIEREN
- Heizung-Sollwerte leicht senken
- Mehr auf passive Solarheizung setzen

**Sommer (Juni-August):**
- Alle Heizungsautomationen inaktiv (>18°C Außentemp)
- Sommerbetrieb automatisch aktiv

**Herbst (September-November):**
- Winter-Modus vorbereiten
- Batterien in Sensoren prüfen
- Sollwerte anpassen

**Winter (Dezember-Februar):**
- Winter-Modus AKTIVIEREN
- Vorheizen aktiviert
- Rollläden-Optimierung läuft

---

## ✅ Checkliste: Setup abgeschlossen

- [ ] YAML neu geladen (ha core reload)
- [ ] Helper-Entities erscheinen in UI (Settings → Helfer)
- [ ] Standard-Werte gesetzt (Komfort 21°C, Eco 18°C, Nacht 17°C)
- [ ] Winter-Modus aktiviert (für Heizperiode)
- [ ] Automation-Traces prüfen (eine sollte getriggert haben)
- [ ] Dashboard-Karte erstellt (optional)
- [ ] Alte Fenster-Automation deaktiviert (auskommentiert)
- [ ] Benachrichtigungen funktionieren (teste durch Fenster öffnen)

---

## 📞 Support

Bei Problemen:

1. **Logs prüfen:**
   ```bash
   ssh reid15@192.168.178.71
   tail -f /config/home-assistant.log | grep -i heizung
   ```

2. **YAML Syntax prüfen:**
   - Developer Tools → YAML → Check Configuration

3. **Automation debuggen:**
   - Settings → Automations & Scenes
   - [Automation] → Traces
   - Ansehen welcher Schritt fehlschlägt

---

**Viel Erfolg beim Energie sparen! 🌱💰**
