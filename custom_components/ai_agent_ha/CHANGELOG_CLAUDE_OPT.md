# AI Agent HA - Änderungsprotokoll: Claude Sonnet 3.7 Optimierung

## Version 0.99.5-claude-optimized

### Hauptänderungen

#### 1. Claude Sonnet 3.7 als Standard-Provider
- **Standardmodell geändert:** `claude-3-7-sonnet-latest` (vorher: `claude-3-5-sonnet-20241022`)
- **Timeout erhöht:** 120 Sekunden (vorher: 30s) für komplexe Automationen
- **Max Tokens erhöht:** 4096 (vorher: 2048) für umfangreiche Automation-Definitionen
- **Optimierung:** Beste JSON-Struktur-Einhaltung bei Automation-Generierung

#### 2. GPT-5 / o3-mini Vollständige Unterstützung
- **Automatische Erkennung** von restricted models:
  - `gpt-5`, `o3-mini`, `o3`, `o1-mini`, `o1-preview`, `o1`
- **Parameter-Anpassung:**
  - Verwendet `max_completion_tokens` statt `max_tokens`
  - Deaktiviert `temperature` und `top_p` bei restricted models
- **API-Key-Validierung:** Prüft auf `sk-` Präfix

#### 3. Gemini 2.5 / 2.0 Experimentelle Unterstützung
- **Standardmodell:** `gemini-2.0-flash-exp` (vorher: `gemini-1.5-flash`)
- **Kompatibel mit:**
  - `gemini-2.5-pro-exp` (experimentell)
  - `gemini-2.0-flash-exp` (experimentell, schnell)
  - `gemini-1.5-pro` (stabil)
- **System-Message-Handling:** Automatische Konvertierung zu User-Messages mit "System:" Präfix

### Geänderte Dateien

#### `custom_components/ai_agent_ha/agent.py`
- **Zeile ~580:** `AnthropicClient.__init__` ? Standard `claude-3-7-sonnet-latest`
- **Zeile ~585:** `AnthropicClient.get_response` ? `max_tokens: 4096`, `timeout: 120s`
- **Zeile ~390:** `OpenAIClient.__init__` ? Standard `gpt-4o-mini` (kompatibel mit gpt-5)
- **Zeile ~395-420:** `OpenAIClient._get_token_parameter()` und `_is_restricted_model()` erweitert
- **Zeile ~730:** `GeminiClient.__init__` ? Standard `gemini-2.0-flash-exp`
- **Zeile ~1100-1180:** `__init__` und `process_query` Provider-Defaults aktualisiert
- **Zeile 10-28:** Dokumentation Header aktualisiert

#### Neu erstellte Dateien
- **`CLAUDE_OPTIMIZATION.md`:** Vollständige Dokumentation der Optimierungen
- **`example_configuration.yaml`:** Beispiel-Konfiguration mit allen Providern

### Kompatibilität

#### Abwärtskompatibel
? Alle bestehenden Konfigurationen funktionieren weiterhin
? Standard-Provider kann in UI gewechselt werden
? Alte Modell-Namen werden unterstützt

#### Breaking Changes
? Keine - nur neue Defaults und Erweiterungen

### Testing Empfohlen

#### Claude Sonnet 3.7
```yaml
ai_agent_ha:
  ai_provider: anthropic
  anthropic_token: !secret anthropic_api_key
  models:
    anthropic: "claude-3-7-sonnet-latest"
```

**Test-Prompt:**
```
Erstelle eine Präsenz-Licht-Automation für den Raum "Wohnzimmer":
- Trigger: binary_sensor.presence_sensor_fp2_f9cf_presence_sensor_1
- Bedingung: Helligkeit < 400 lux
- Aktion: light.wohnzimmer einschalten mit 80% brightness
- Mode: restart
Gib als automation_suggestion zurück.
```

#### GPT-5 / o3-mini
```yaml
ai_agent_ha:
  ai_provider: openai
  openai_token: !secret openai_api_key
  models:
    openai: "gpt-5"  # oder "o3-mini"
```

**Test-Prompt:**
```
Task: Generate blind control automation
Entity: cover.rollladen_computer_vorhang
Conditions: sun azimuth 120-240 AND lux > 600
Action: Close to position 20
Output: automation_suggestion JSON
```

#### Gemini 2.5
```yaml
ai_agent_ha:
  ai_provider: gemini
  gemini_token: !secret gemini_api_key
  models:
    gemini: "gemini-2.5-pro-exp"
```

**Test-Prompt:**
```
Erstelle eine Gute-Nacht-Automation:
- Alle Lichter aus (domain: light)
- Alle Cover schließen (domain: cover)
- Benachrichtigung: "Gute Nacht"
Trigger: 22:30 Uhr
Format: automation_suggestion
```

### Performance Verbesserungen

| Provider | Timeout | Max Tokens | Context Window |
|----------|---------|------------|----------------|
| Claude 3.7 | 120s ?? | 4096 ?? | 200k |
| GPT-5 | 300s | 16k | 128k |
| Gemini 2.5 | 300s | 8k | 1M+ |

### Fehlerbehandlung

#### Neue Fehlermeldungen
- `"Invalid token parameter for model {model}"` ? GPT-5/o3-mini Konfigurationsfehler
- `"Anthropic timeout - request too complex"` ? Prompt vereinfachen oder splitten
- `"Gemini system role converted"` ? Debug-Info, kein Fehler

#### Retry-Mechanismus
- Anthropic: 10 Retries mit exponential backoff
- OpenAI: 10 Retries, API-Key-Validierung
- Gemini: 10 Retries, Rate-Limit-Handling (60 req/min)

### Known Issues

#### Claude Sonnet 3.7
- ?? Bei sehr langen Entity-Listen (>200): Timeout möglich
  - **Lösung:** Prompt splitten oder `entity_limit` in Service-Call setzen

#### GPT-5 / o3-mini
- ?? Restricted models haben keine Temperatur-Kontrolle
  - **Kein Problem:** Automatisch deaktiviert, Models sind dennoch deterministisch

#### Gemini 2.5
- ?? Experimentelle Modelle mit `-exp` Suffix können instabil sein
  - **Lösung:** Fallback auf `gemini-1.5-pro` bei Problemen

### Migration von vorherigen Versionen

#### Schritt 1: Backup
```bash
cp custom_components/ai_agent_ha/agent.py custom_components/ai_agent_ha/agent.py.bak
```

#### Schritt 2: Neue Datei überschreiben
```bash
# Neue agent.py in custom_components/ai_agent_ha/ kopieren
```

#### Schritt 3: Configuration aktualisieren (optional)
```yaml
ai_agent_ha:
  ai_provider: anthropic  # Neu: Standard auf Claude
  models:
    anthropic: "claude-3-7-sonnet-latest"  # Neu: Sonnet 3.7
```

#### Schritt 4: Home Assistant neu starten
```bash
ha core restart
```

### Weiterführende Ressourcen

- **Anthropic API Docs:** https://docs.anthropic.com/en/docs/models-overview
- **OpenAI GPT-5 Docs:** https://platform.openai.com/docs/models/gpt-5
- **Gemini 2.5 Docs:** https://ai.google.dev/models/gemini

---

**Datum:** Januar 2025  
**Author:** reid15halo-ops  
**Version:** 0.99.5-claude-optimized
