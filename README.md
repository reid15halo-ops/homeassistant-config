# Home Assistant Configuration - reid15halo-ops

Meine persönliche Home Assistant Konfiguration mit Fokus auf:
- **KI-gestützte Automation** (Claude Sonnet 3.7, GPT-5, Gemini 2.5)
- **Präsenzbasierte Beleuchtung** (Aqara FP2)
- **Intelligente Rollladensteuerung** (Sonnenstand + LUX)
- **Heizungsoptimierung** (Präsenz + Wetter)

## ?? System

- **Hardware:** Raspberry Pi 4
- **OS:** Home Assistant OS 16.2
- **Core:** Home Assistant 2025.9.3 (ziel: 2025.10.0)
- **Location:** 49.91°N, 9.08°E, 150m
- **Timezone:** Europe/Berlin

## ?? AI Agent HA - Claude Sonnet 3.7 Optimiert

### Features
? **Claude Sonnet 3.7** als primärer Provider (beste Automation-Qualität)
? **GPT-5 / o3-mini** vollständige Unterstützung (automatische Parameter-Anpassung)
? **Gemini 2.5** experimentelle Unterstützung (niedrige Kosten, hoher Context)
? **Multi-Provider Setup** - wechsle im UI zwischen Providern
? **Automation-Generierung** - erstellt YAML direkt in `automations.yaml`
? **Dashboard-Erstellung** - generiert Lovelace Dashboards

### Schnellstart

1. **Konfiguration** in `configuration.yaml`:
```yaml
ai_agent_ha:
  ai_provider: anthropic  # Empfohlen: Claude Sonnet 3.7
  anthropic_token: !secret anthropic_api_key
  models:
    anthropic: "claude-3-7-sonnet-latest"
```

2. **API-Keys** in `secrets.yaml`:
```yaml
anthropic_api_key: "sk-ant-api03-..."
openai_api_key: "sk-proj-..."
gemini_api_key: "AIzaSy..."
```

3. **Beispiel-Prompt** (Claude optimiert):
```
Erstelle eine Präsenz-Licht-Automation für den Raum "Wohnzimmer":
- Trigger: binary_sensor.presence_sensor_fp2_f9cf_presence_sensor_1
- Bedingung: Helligkeit < 400 lux (sensor.presence_sensor_fp2_f9cf_light_sensor_light_level)
- Aktion: light.wohnzimmer einschalten mit 80% brightness
- Mode: restart
Gib als automation_suggestion zurück.
```

### Dokumentation
- ?? [Claude Optimization Guide](custom_components/ai_agent_ha/CLAUDE_OPTIMIZATION.md)
- ?? [Prompt Templates](custom_components/ai_agent_ha/PROMPT_TEMPLATES.md)
- ?? [Example Configuration](custom_components/ai_agent_ha/example_configuration.yaml)
- ?? [Changelog](custom_components/ai_agent_ha/CHANGELOG_CLAUDE_OPT.md)

## ?? Wichtige Entitäten

### Beleuchtung (28)
- `light.bad`, `light.wohnzimmer`, `light.computer_licht`
- `light.buffet_lichtstreifen`, `light.kiffzimmer_lichtstreifen`
- `light.kuche_birne_1`, `light.kuche_birne_2`, `light.kuche_streifen`

### Rollläden (4)
- `cover.rollladen_computer_vorhang`
- `cover.kuche_blind_vorhang`
- `cover.schlafen_blind_vorhang`
- `cover.yoga_blind_vorhang`

### Präsenzsensoren
- `binary_sensor.presence_sensor_fp2_f9cf_presence_sensor_1` bis `_5` (Aqara FP2)
- `sensor.presence_sensor_fp2_f9cf_light_sensor_light_level` (LUX)

### Klimatisierung
- `climate.thermostat_bad`
- `climate.thermostat_computer`

### Wetter
- `sensor.openweathermap_temperature`
- `sensor.openweathermap_humidity`
- `sun.sun` (Azimut, Elevation)

## ?? Automation Best Practices

### Präsenz-Licht
```yaml
- id: presence_light_wohnzimmer
  alias: "Präsenz-Licht Wohnzimmer"
  mode: restart
  trigger:
    - platform: state
      entity_id: binary_sensor.presence_sensor_fp2_f9cf_presence_sensor_1
      to: "on"
  condition:
    - condition: numeric_state
      entity_id: sensor.presence_sensor_fp2_f9cf_light_sensor_light_level
      below: 400
  action:
    - service: light.turn_on
      target:
        entity_id: light.wohnzimmer
      data:
        brightness_pct: 80
```

### Rolladen-Steuerung
```yaml
- id: blind_sun_protection
  alias: "Rolladen Blendschutz"
  mode: restart
  trigger:
    - platform: numeric_state
      entity_id: sensor.presence_sensor_fp2_f9cf_light_sensor_light_level
      above: 600
      for: "00:05:00"
  condition:
    - condition: template
      value_template: >
        {{ (state_attr('sun.sun','azimuth')|float(0) >= 120) and
           (state_attr('sun.sun','azimuth')|float(0) <= 240) }}
  action:
    - service: cover.set_cover_position
      target:
        entity_id: cover.rollladen_computer_vorhang
      data:
        position: 20
```

## ?? Integration

### Hauptintegrationen
- **ZHA** (Zigbee Home Automation) mit custom quirks
- **Bluetooth** für Proximity-Sensoren
- **OpenWeatherMap** für Wettervorhersage
- **AI Agent HA** für KI-gestützte Automationen

### Custom Components
- `ai_agent_ha` - KI-Agent (Claude/GPT-5/Gemini)
- `ai_automation_suggester` - Automation-Vorschlagsystem
- `extended_openai_conversation` - Erweiterte Konversation
- `hacs` - Home Assistant Community Store
- `localtuya` - Lokale Tuya-Integration
- `zha_toolkit` - Erweiterte ZHA-Funktionen

## ?? Dateien

```
homeassistant-config/
??? configuration.yaml           # Hauptkonfiguration
??? automations.yaml             # Alle Automationen
??? scripts.yaml                 # Wiederverwendbare Scripts
??? scenes.yaml                  # Szenen
??? secrets.yaml                 # API-Keys (nicht commitet)
??? blueprints/                  # Automation-Blueprints
??? custom_components/
?   ??? ai_agent_ha/            # KI-Agent (Claude optimiert)
?   ??? ai_automation_suggester/
?   ??? extended_openai_conversation/
?   ??? hacs/
?   ??? localtuya/
?   ??? zha_toolkit/
??? custom_zha_quirks/           # ZHA Device Quirks
??? packages/                    # Modulare Config-Pakete
??? www/                         # Statische Web-Ressourcen
??? zigbee2mqtt/                 # Zigbee2MQTT Config (falls verwendet)
```

## ?? Deployment

### SSH Zugriff
```bash
ssh reid15@192.168.178.71  # oder reidhomeassistant.local
```

### Nach Config-Änderungen
```bash
# Configuration prüfen
ha core check

# Automations neu laden (ohne Neustart)
ha core reload --area automation

# Vollständiger Neustart
ha core restart
```

### Git Workflow
```bash
# Lokale Änderungen commiten
git add .
git commit -m "Update automations"
git push origin main

# Auf HA Server pullen
cd /config
git pull origin main
ha core reload --area automation
```

## ?? Sicherheit

### Secrets Management
- Alle API-Keys in `secrets.yaml` (nicht im Git)
- SSH Key authentication (`~/.ssh/id_ed25519`)
- Firewall: Nur lokaler Zugriff auf Port 8123

### Beispiel secrets.yaml
```yaml
# AI Providers
anthropic_api_key: "sk-ant-api03-..."
openai_api_key: "sk-proj-..."
gemini_api_key: "AIzaSy..."
openrouter_api_key: "sk-or-v1-..."

# Integrations
openweathermap_api_key: "..."
```

## ?? Performance

### Claude Sonnet 3.7
- Context: 200k Tokens
- Output: 4096 Tokens
- Timeout: 120 Sekunden
- Beste Automation-Qualität

### GPT-5 / o3-mini
- Context: 128k Tokens
- Output: 16k Tokens
- Timeout: 300 Sekunden
- Automatische Parameter-Anpassung

### Gemini 2.5
- Context: 1M+ Tokens
- Output: 8k Tokens
- Timeout: 300 Sekunden
- Niedrigste Kosten

## ?? Troubleshooting

### AI Agent Fehler
```bash
# Logs prüfen
tail -f /config/home-assistant.log | grep ai_agent_ha

# Debug-Dateien
ls -la /config/ai_agent_ha_debug/
```

### Automation Fehler
```bash
# Letzte Automation Traces
# Settings ? Automations & Scenes ? [Automation] ? Traces
```

### ZHA Probleme
```bash
# ZHA Debug Logs
# Settings ? System ? Logs ? Filter: "zha"
```

## ?? Ressourcen

- [Home Assistant Docs](https://www.home-assistant.io/docs/)
- [Anthropic Claude Docs](https://docs.anthropic.com/)
- [OpenAI GPT-5 Docs](https://platform.openai.com/docs/models/gpt-5)
- [Gemini 2.5 Docs](https://ai.google.dev/models/gemini)
- [Community Forum](https://community.home-assistant.io/)

## ?? Lizenz

Diese Konfiguration ist für persönliche Nutzung. Teile können unter MIT-Lizenz stehen (siehe jeweilige Komponenten).

---

**Autor:** reid15halo-ops  
**Letzte Aktualisierung:** Januar 2025  
**Version:** HA 2025.9.3, AI Agent 0.99.5-claude-optimized
