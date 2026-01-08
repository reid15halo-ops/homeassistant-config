# Plan: Perfekt Smoothe Fire-Übergänge

## Problem
- **Aktuell**: Sichtbare Farbsprünge (rot → orange in 2 Sekunden)
- **Transitions zu kurz**: 0.2-0.8s
- **Delays zu lang**: 300-800ms
- **Resultat**: Stufenweise, ruckartige Übergänge

## Ziel
**Unsichtbare Übergänge** - Du darfst keine einzelnen Farbwechsel erkennen können, nur ein kontinuierliches Flackern.

---

## Lösung: 6-Punkte-System für Smooth Fire

### 1. LÄNGERE Transitions
**Problem**: 0.2-0.8s ist zu kurz
**Lösung**: 
- Transitions: **1.5-3.0 Sekunden**
- Der Übergang muss LÄNGER sein als der Delay
- So überlappt die nächste Änderung mit der vorherigen

```yaml
transition: "{{ (range(15, 30) | random) / 10 }}"  # 1.5-3.0s
```

### 2. KÜRZERE Delays
**Problem**: 300-800ms lässt die Transition beenden
**Lösung**:
- Delays: **600-1200ms** (kürzer als Transition!)
- Neue Änderung startet BEVOR die alte fertig ist
- Dadurch konstante Bewegung, keine "Ruhephasen"

```yaml
delay:
  milliseconds: "{{ range(600, 1200) | random }}"
```

### 3. KLEINERE Farbänderungen
**Problem**: Hue 15-35° ist zu großer Sprung (rot → orange)
**Lösung**:
- Kleinerer Hue-Bereich: **20-30°** (nur Orange-Töne)
- Oder: ZWEI separate Bereiche für Variation
  - Primär: 22-28° (enges Spektrum)
  - Akzent: Gelegentlich 18-32° (breiteres Spektrum)

```yaml
hs_color:
  - "{{ range(22, 28) | random }}"  # Enger Bereich
  - "{{ range(90, 100) | random }}" # Hohe Sättigung
```

### 4. KLEINERE Brightness-Schritte
**Problem**: 40-85% = 45% Sprung ist zu viel
**Lösung**:
- Reduziere Range auf: **50-75%** (25% Sprung)
- Oder nutze "Gleitenden Durchschnitt"-Ansatz

```yaml
brightness_pct: "{{ range(50, 75) | random }}"
```

### 5. Smooth Transitions aktivieren
**Prüfen**: Ist in den Licht-Einstellungen "Fließende Übergänge" aktiv?

```yaml
# Entity-Level Check
switch.buffet_licht_fliessende_ubergange: on
switch.computer_licht_2_fliessende_ubergange: on  # Falls vorhanden
```

### 6. Transition-Mode Optimization
**Zusätzlich**: Nutze `transition: 0` für initiale State, dann lange Transitions

---

## Implementation Plan

### Phase 1: Quick Fix (Sofort)
```yaml
data:
  hs_color:
    - "{{ range(22, 28) | random }}"      # Enger Farbbereich
    - "{{ range(95, 100) | random }}"     # Sehr hohe Sättigung
  brightness_pct: "{{ range(55, 75) | random }}"  # Kleinere Sprünge
  transition: "{{ (range(20, 35) | random) / 10 }}"  # 2.0-3.5s
delay:
  milliseconds: "{{ range(800, 1500) | random }}"  # Länger, aber < Transition
```

### Phase 2: Advanced Smoothing
**Option A: Micro-Steps**
- Kleine, sehr häufige Änderungen
- Transition: 1.5s
- Delay: 800ms
- Hue: ±2° pro Schritt
- Brightness: ±5% pro Schritt

**Option B: Dual-Light Offset**
- Beide Lichter getrennt steuern
- Versatz von ~500ms
- Erzeugt "Tiefen"-Effekt

**Option C: Template Sensor für Gleitenden Durchschnitt**
- Berechne nächsten Wert als Durchschnitt des aktuellen
- Verhindert große Sprünge mathematisch

### Phase 3: Ultimate Solution - AppDaemon
```python
import appdaemon.plugins.hass.hassapi as hass
import random

class SmoothFire(hass.Hass):
    def initialize(self):
        self.current_hue = 25
        self.current_brightness = 65
        self.run_every(self.smooth_flicker, "now", 1)
    
    def smooth_flicker(self, kwargs):
        # Kleine Änderungen vom aktuellen Zustand
        self.current_hue += random.uniform(-2, 2)
        self.current_hue = max(20, min(30, self.current_hue))
        
        self.current_brightness += random.uniform(-5, 5)
        self.current_brightness = max(50, min(75, self.current_brightness))
        
        self.call_service("light/turn_on",
            entity_id=["light.buffet_licht", "light.computer_licht_2"],
            hs_color=[self.current_hue, random.randint(95, 100)],
            brightness_pct=int(self.current_brightness),
            transition=2.5)
```

---

## Sofortige Anpassungen - Priority List

1. ✅ **Transition auf 2-3.5s erhöhen**
2. ✅ **Delay auf 800-1500ms setzen**
3. ✅ **Hue-Range auf 22-28° reduzieren**
4. ✅ **Brightness auf 55-75% begrenzen**
5. ⚙️ **Fließende Übergänge aktivieren** (Entity-Einstellungen)
6. 🔧 **Test & Tune**: Werte schrittweise optimieren

---

## Erwartetes Ergebnis

Nach Implementierung:
- ✅ **Keine sichtbaren Farbsprünge**
- ✅ **Kontinuierliches, fließendes Flackern**
- ✅ **Realistischer "Feuer-Glow" Effekt**
- ✅ **Pro 2 Sekunden: ~2-3 überlappende Transitions = smooth**

---

## Test-Methode

1. Script starten
2. Für 30 Sekunden beobachten
3. Fragen:
   - Siehst du einzelne Farbwechsel?
   - Gibt es "Sprünge"?
   - Ist es ein fließendes Gesamtbild?

Wenn NEIN zu Frage 3 → Weiter optimieren mit kleineren Ranges.

---

## Mathematik dahinter

**Warum Transition > Delay?**
```
Zeit:    0s    0.8s   1.6s   2.4s   3.2s
Trans1:  [==========]
Trans2:         [==========]
Trans3:                  [==========]
Trans4:                           [==========]

Resultat: Immer 2-3 Transitions aktiv = smooth!
```

**Wenn Delay > Transition:**
```
Zeit:    0s    0.8s   1.6s   2.4s   3.2s
Trans1:  [====]
Trans2:         [====]
Trans3:                  [====]
                ^ GAP! ^ GAP!

Resultat: Lücken = sichtbare Sprünge!
```

---

## Next Steps

1. Implementiere Quick Fix (Phase 1)
2. Reload Script
3. Teste 60 Sekunden
4. Feedback geben
5. Feintuning basierend auf Ergebnis
