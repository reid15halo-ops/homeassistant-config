# Reid's Flat - Smart Home Layout

## Floor Plan Overview

```
                    🪟 = Window with Roller Shutter (Rollladen)
                    ┄┄┄ = Half wall (open plan)

┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   🪟┌══════════════┐       🪟🪟🪟🪟🪟🪟🪟🪟              │
│    ║ ═══ (strip)  │  ┌══════════════════════════┐          │
│    ║    KÜCHE     │  │  ═══════════ (behind bed)│          │
│    ║  (Kitchen)   │  │     SCHLAFZIMMER        │          │
│    ║              │  │      (Bedroom)          │          │
│    ║ 🔵🟡🟡      │  │  🔵  🟢     [Bed RIGHT] │          │
│    └──────┄┄┄┄┄┄┄┄┘  └──────────────────────────┘          │
│    ┄┄┄ OPEN PLAN ┄┄┄                                       │
│   🪟┌──────────────────────────┐  ┌──────────┐              │
│    ║                          │  │          │              │
│    ║      WOHNZIMMER          │  │   FLUR   │  ┌────────┐ │
│    ║     (Living Room)        │  │(Hallway) │  │  BAD   │ │
│    ║                          │  │          │  │(Bath)  │ │
│    ║  🔴  🔵                  │  │   🔵     │  │ 🔴🔵   │ │
│    ║  ═══════ (Light Strips)  │  │          │  │ ═════  │ │
│    ║  (Computer + Buffet)     │  └──────────┘  │(bottom)│ │
│    └──────────────────────────┘                └────────┘ │
│                                                             │
│   🪟┌══════════════════════════┐                            │
│    ║ ═══ (Light Strip - top)  │                            │
│    ║      KIFFZIMMER          │                            │
│    ║                          │                            │
│    ║  (Door sensor)           │                            │
│    └──────────────────────────┘                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘

Note: KÜCHE + WOHNZIMMER = Open-plan living/kitchen area (half wall, no door)
      The Aqara FP2 in Wohnzimmer may also detect presence in Küche area.
      Each room has its own window with roller shutter.
```

## Legend

| Symbol | Device Type | German |
|--------|-------------|--------|
| 🔴 | Presence Sensor | Präsenzsensor |
| 🔵 | Motion Sensor | Bewegungssensor |
| 🟡 | Smart Bulbs | Smarte Birnen |
| 🟢 | Ceiling Fan with Light | Deckenventilator mit Licht |
| ═══ | LED Light Strip | Lichtstreifen |
| 🪟 | Window with Roller Shutter | Fenster mit Rollladen |
| ┄┄┄ | Half Wall / Open Plan | Halbe Wand / Offen |

## Room Details

### 1. Wohnzimmer + Küche (Open-Plan Living/Kitchen)
> **Note:** These two areas are connected with only a half wall between them.
> The Aqara FP2 presence sensor may detect both areas.

#### Wohnzimmer (Living Room)
- **Window:** 🪟 Left side
- **Sensors:** 
  - 🔴 **Aqara FP2** Presence sensor (mmWave radar)
  - 🔵 Motion sensor
- **Lights:**
  - ═══ LED Light Strip - Computer area (`light.computer_licht`)
  - ═══ LED Light Strip - Buffet (`light.buffet_lichtstreifen`)
- **Covers:**
  - Roller shutter (`cover.rollladen_computer_vorhang`)
- **Automations:**
  - Light on after sunset when presence detected
  - Ambient fire flicker script

#### Küche (Kitchen)
- **Window:** 🪟 Left side (separate from Wohnzimmer)
- **Sensors:**
  - 🔵 Motion sensor
- **Lights:**
  - 🟡 Smart bulbs x2 (`light.kuche_birne_1`, `light.kuche_birne_2`)
  - ═══ Light strip (top of room)
- **Covers:**
  - Roller shutter (`cover.rollladen_kuche_vorhang`)
- **Automations:**
  - Light on with motion
  - Light off after 30s no motion

### 2. Schlafzimmer (Bedroom)
- **Window:** 🪟🪟🪟 Top side (multiple windows)
- **Note:** Bed is on the RIGHT side of the room
- **Sensors:**
  - 🔵 Motion sensor
- **Lights:**
  - 🟢 Ceiling fan with light (`light.schlafzimmer_licht`)
  - ═══ Light strip (behind/beyond bed)
- **Covers:**
  - Roller shutter (`cover.rollladen_schlafen_vorhang`)
- **Automations:**
  - Light on with motion
  - Light off after 30s no motion

### 3. Flur (Hallway)
- **Sensors:**
  - 🔵 Motion sensor
- **Lights:**
  - (Check entity)
- **Automations:**
  - (To be configured)

### 4. Bad (Bathroom)
- **Sensors:**
  - 🔴 Presence sensor
  - 🔵 Motion sensor
- **Lights:**
  - Bathroom light(s)
  - ═══ Light strip (bottom of room)
- **Automations:**
  - Light on with presence/motion
  - Light off after 2 minutes no motion

### 5. Kiffzimmer
- **Window:** 🪟 Left side
- **Sensors:**
  - Door sensor (open/close)
- **Lights:**
  - Room light
  - ═══ Light strip (top of room)
- **Automations:**
  - Light ON when door OPENS
  - Light OFF when door CLOSES

## Roller Shutters (Rollläden)

| Room | Entity | Position Tracker |
|------|--------|------------------|
| Wohnzimmer (Computer) | `cover.rollladen_computer_vorhang` | `input_number.pos_computer` |
| Küche | `cover.rollladen_kuche_vorhang` | `input_number.pos_kuche` |
| Yoga (?) | `cover.rollladen_yoga_vorhang` | `input_number.pos_yoga` |
| Schlafzimmer | `cover.rollladen_schlafen_vorhang` | `input_number.pos_schlafen` |

## Heating System

- **Comfort Temperature:** `input_number.heizung_solltemperatur_komfort` (default: 21°C)
- **Eco Temperature:** `input_number.heizung_solltemperatur_eco` (default: 18°C)
- **Night Temperature:** `input_number.heizung_solltemperatur_nacht` (default: 17°C)
- **Eco Mode:** `input_boolean.heizung_eco_mode`
- **Winter Mode:** `input_boolean.heizung_winter_mode`

## Known Issues (from logs)

1. **Missing entities:** Some TP-Link/Kasa lights are offline
2. **Roborock Q7 Max:** MQTT connection failing
3. **Kasa device (192.168.178.72):** Timeout errors

## Network Info

- **Home Assistant IP:** 192.168.178.70
- **DuckDNS Domain:** reid15.duckdns.org
- **External URL:** https://reid15.duckdns.org:8123
- **Router:** Fritz!Box 6690 Cable
