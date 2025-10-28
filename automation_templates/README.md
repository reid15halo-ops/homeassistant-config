# Home Assistant Automation Templates

Fertige YAML-Templates für sofortige Verwendung in Home Assistant.

---

## 📁 Verfügbare Templates

### ⭐ **01_leaving_home.yaml** - "Haus verlassen"
**Priorität:** Sehr hoch | **Schwierigkeit:** Einfach | **Zeit:** 10 Min

**Löst:** Vergessene Lichter, Heizung, Rollläden beim Verlassen

**Features:**
- Alle Lichter aus
- Heizung auf Eco (16°C)
- Rollläden optimieren (Sommer/Winter)
- Fenster-Check mit Benachrichtigung
- Trigger: Button, Device Tracker, oder automatisch

**Nutzen:** ~2-3 Min/Tag + ~10% Heizkosten-Ersparnis

---

### 🌙 **02_good_night.yaml** - "Gute Nacht"
**Priorität:** Sehr hoch | **Schwierigkeit:** Einfach | **Zeit:** 10 Min

**Löst:** Alle Lichter/Rollläden einzeln beim Schlafengehen

**Features:**
- Alle Lichter aus (mit 30-Sek-Nachtlicht)
- Alle Rollläden runter
- Heizung auf Schlaf-Temperatur (18°C Schlafzimmer, 16°C andere)
- Fenster-Check
- Optional: Smart Plugs aus (PC, etc.)

**Bonus:** "Guten Morgen"-Routine (Lichtwecker, Heizung vorheizen)

**Nutzen:** ~3-5 Min/Tag + besserer Schlaf

---

## 🚀 Installation & Verwendung

### Schritt 1: Template herunterladen
```bash
# Download von GitHub
git clone https://github.com/reid15halo-ops/homeassistant-config.git
cd homeassistant-config/automation_templates
```

### Schritt 2: Entity-IDs anpassen

**WICHTIG:** Ersetze alle `⚠️ ERSETZE` Platzhalter mit deinen tatsächlichen Entity-IDs!

**Wie finde ich meine Entity-IDs?**
1. Home Assistant UI → Developer Tools → States
2. Suche nach `light.`, `climate.`, `cover.`, etc.
3. Kopiere die Entity-ID (z.B. `light.wohnzimmer`)

**Beispiel:**
```yaml
# Template (ORIGINAL):
- light.bad
- light.computer_licht

# Deine Anpassung:
- light.badezimmer  # ← Deine tatsächliche Entity-ID
- light.pc_bereich  # ← Deine tatsächliche Entity-ID
```

### Schritt 3: Helpers erstellen (falls benötigt)

Viele Templates benötigen **Input Booleans** als Trigger:

**Configuration → Helpers → Create Helper → Toggle**

Beispiele:
- `input_boolean.leaving_home_trigger` (Haus verlassen)
- `input_boolean.good_night_trigger` (Gute Nacht)

### Schritt 4: In Home Assistant importieren

**Methode A: File Editor Add-on (einfachste)**
```
1. Settings → Add-ons → File Editor installieren
2. Navigiere zu /config/automations.yaml
3. Template-Inhalt ans Ende kopieren
4. Speichern
5. Developer Tools → YAML → Reload Automations
```

**Methode B: SSH**
```bash
# SSH-Verbindung
ssh reid15@192.168.178.71

# Navigiere zu config
cd /config

# Öffne automations.yaml
nano automations.yaml

# Füge Template-Inhalt ans Ende ein
# Speichern: Strg+O, Enter, Strg+X

# Reload Automations
ha core reload --area automations
```

**Methode C: Home Assistant UI (empfohlen für Einsteiger)**
```
1. Settings → Automations & Scenes → Create Automation
2. ⋮ (3 Punkte) → Edit in YAML
3. Template-Inhalt einfügen
4. Anpassen
5. Save
```

### Schritt 5: Testen!

**Developer Tools → Services:**
```yaml
service: automation.trigger
target:
  entity_id: automation.haus_verlassen
```

Oder: Klicke auf den Helper-Button im Dashboard!

---

## 🎛️ Dashboard-Buttons hinzufügen

### Einfacher Button
```yaml
type: button
entity: input_boolean.leaving_home_trigger
name: "🚪 Haus verlassen"
tap_action:
  action: toggle
show_state: false
```

### Card mit mehreren Buttons
```yaml
type: entities
title: "Schnellzugriff"
entities:
  - entity: input_boolean.leaving_home_trigger
    name: "🚪 Haus verlassen"
    tap_action:
      action: toggle
  - entity: input_boolean.good_night_trigger
    name: "🌙 Gute Nacht"
    tap_action:
      action: toggle
  - entity: input_boolean.arriving_home_trigger
    name: "🏠 Ich bin zurück"
    tap_action:
      action: toggle
```

---

## 🔧 Anpassungs-Tipps

### Temperaturen ändern
```yaml
# Original:
temperature: 16

# Angepasst (falls dir 16°C zu kalt ist):
temperature: 18
```

### Zeiten anpassen
```yaml
# Original:
at: "23:00:00"

# Angepasst (früher schlafen):
at: "22:30:00"
```

### Bestimmte Lichter NICHT ausschalten
```yaml
# Entferne Zeile oder kommentiere aus:
# - light.flur  # ← Bleibt jetzt an
```

### Trigger-Methode wechseln
Jedes Template hat mehrere Trigger-Optionen. Entferne `#` vor der gewünschten Option:

```yaml
# OPTION A: Manueller Button (Standard)
- platform: state
  entity_id: input_boolean.leaving_home_trigger
  to: "on"

# OPTION B: Device Tracker (aktivieren)
# Entferne # vor diesen Zeilen:
# - platform: state
#   entity_id: device_tracker.dein_handy
#   from: "home"
#   to: "not_home"
```

---

## 🆘 Troubleshooting

### Problem: "Entity not available"
**Lösung:** Entity-ID falsch geschrieben oder Gerät offline
```bash
# Prüfen in Developer Tools → States
# Suche nach dem Entity-Namen
```

### Problem: Automation triggert nicht
**Lösung:** Prüfe Conditions
```yaml
# Füge Debug-Log hinzu:
- service: logbook.log
  data:
    name: "DEBUG"
    message: "Automation wurde getriggert"
```

### Problem: "Helper not found"
**Lösung:** Helper muss erst erstellt werden
```
Configuration → Helpers → Create Helper → Toggle
Name: leaving_home_trigger (genau so!)
```

### Problem: Automation triggert zu oft
**Lösung:** Füge Debouncing hinzu
```yaml
trigger:
  - platform: state
    entity_id: binary_sensor.presence
    to: "off"
    for: "00:05:00"  # ← 5 Min warten vor Trigger
```

---

## 📊 Welches Template zuerst?

**Empfohlene Reihenfolge:**

1. **01_leaving_home.yaml** (größter Nutzen!)
   - Spart am meisten Zeit & Energie
   - Einfach zu implementieren

2. **02_good_night.yaml** (täglich!)
   - Wird jeden Tag genutzt
   - Großer Komfort-Gewinn

3. **Weitere Templates** (auf Anfrage)
   - Gaming-Modus
   - Duschen-Modus
   - Vergessene Lichter-Killer
   - Heizungs-Schutz
   - etc.

---

## 📚 Weitere Hilfe

**Detaillierte Beschreibungen:** Siehe `AUTOMATION_RECOMMENDATIONS.md`

**Installation Guide:** Siehe `AUTOMATION_INSTALLATION_GUIDE.md` (wird noch erstellt)

**Fragen?** Öffne ein Issue im GitHub-Repository!

---

## ✨ Pro-Tipps

### Trace aktivieren für Debugging
```yaml
mode: single
trace:
  stored_traces: 10  # Speichere letzte 10 Ausführungen
```

### Benachrichtigungen bei Fehlern
```yaml
- service: notify.persistent_notification
  data:
    title: "Automation Fehler"
    message: "{{ trigger.entity_id }} hat einen Fehler"
```

### Conditions für bestimmte Tageszeiten
```yaml
condition:
  - condition: time
    after: "06:00:00"
    before: "23:00:00"  # Nur zwischen 6-23 Uhr
```

---

**Viel Erfolg!** 🎉

**Template-Version:** 1.0 (2025-01-28)
