# AI Agent HA - Optimiert für Claude Sonnet 3.7

Dieser Agent ist primär optimiert für **Claude Sonnet 3.7** (aktuell neueste Version: `claude-3-7-sonnet-latest`) und vollständig kompatibel mit **GPT-5/o3-mini** und **Gemini 2.5**.

## Empfohlene Konfiguration

### 1. Claude Sonnet 3.7 (Primär empfohlen)

```yaml
ai_agent_ha:
  ai_provider: anthropic
  anthropic_token: !secret anthropic_api_key
  models:
    anthropic: "claude-3-7-sonnet-latest"  # Oder: "claude-3-5-sonnet-20241022"
```

**Vorteile:**
- Beste JSON-Struktur-Einhaltung für Automations-Generierung
- Längerer Context-Window (200k Tokens)
- Erhöhte max_tokens (4096) für komplexe Automationen
- Timeout auf 120s für komplexe Aufgaben erhöht
- Sehr genaue Entitäts-Referenzen

### 2. OpenAI GPT-5 / o3-mini (Kompatibilität)

```yaml
ai_agent_ha:
  ai_provider: openai
  openai_token: !secret openai_api_key
  models:
    openai: "gpt-5"  # Oder: "o3-mini", "gpt-4o-mini", "gpt-4-turbo"
```

**Besonderheiten:**
- Automatische Erkennung von GPT-5/o3-mini Modellen
- Verwendet `max_completion_tokens` statt `max_tokens`
- Deaktiviert `temperature` und `top_p` für restricted models (o3-mini, o1, gpt-5)
- Validierung des API-Key-Formats (`sk-...`)

**Unterstützte restricted models:**
- `o3-mini`
- `o3`
- `o1-mini`
- `o1-preview`
- `o1`
- `gpt-5`

### 3. Google Gemini 2.5 / 2.0 (Experimentell)

```yaml
ai_agent_ha:
  ai_provider: gemini
  gemini_token: !secret gemini_api_key
  models:
    gemini: "gemini-2.0-flash-exp"  # Oder: "gemini-2.5-pro-exp", "gemini-1.5-pro"
```

**Hinweise:**
- Experimentelle Modelle nutzen `-exp` Suffix
- Gemini hat kein natives "system" role ? wird als User-Message mit "System:" Präfix eingefügt
- Standardmäßig 2048 max_output_tokens

## Multi-Provider Setup

Du kannst mehrere Provider gleichzeitig konfigurieren und per UI wählen:

```yaml
ai_agent_ha:
  ai_provider: anthropic  # Standard
  anthropic_token: !secret anthropic_api_key
  openai_token: !secret openai_api_key
  gemini_token: !secret gemini_api_key
  openrouter_token: !secret openrouter_api_key
  
  models:
    anthropic: "claude-3-7-sonnet-latest"
    openai: "gpt-5"
    gemini: "gemini-2.0-flash-exp"
    openrouter: "anthropic/claude-3.7-sonnet"
```

Im Frontend-Panel kannst du dann zwischen den Providern wechseln.

## Automation-Generierung: Best Practices

### Für Claude Sonnet 3.7 optimierte Prompts:

```
Erstelle eine Präsenz-Licht-Automation für den Raum "Computer":
- Trigger: binary_sensor.presence_sensor_fp2_f9cf_presence_sensor_1
- Bedingung: Helligkeit < 400 lux (sensor.presence_sensor_fp2_f9cf_light_sensor_light_level)
- Aktion: light.computer_licht einschalten mit 80% brightness
- Mode: restart
- Beschreibung: Ausführlich und sprechend
Gib als automation_suggestion zurück.
```

### Für GPT-5/o3-mini optimierte Prompts:

```
Task: Generate a blind control automation
Context:
- Entity: cover.rollladen_computer_vorhang
- Sun sensor: sun.sun (azimuth, elevation)
- Light sensor: sensor.presence_sensor_fp2_f9cf_light_sensor_light_level
Requirements:
- Close partially (position: 20) when sun azimuth 120-240 AND lux > 600
- Open fully at sunset
- Mode: restart
Output: automation_suggestion JSON
```

### Für Gemini 2.5 optimierte Prompts:

```
Generiere bitte eine Gute-Nacht-Automation mit folgenden Schritten:
1. Alle Lichter ausschalten (domain: light)
2. Alle Cover schließen (domain: cover)
3. Benachrichtigung senden: "Gute Nacht - alle Geräte aus"
Trigger: um 22:30 Uhr täglich
Format: automation_suggestion
```

## Modell-Eigenschaften Vergleich

| Feature | Claude 3.7 | GPT-5 | Gemini 2.5 |
|---------|-----------|-------|------------|
| Context | 200k | 128k | 1M+ |
| Max Output | 4096 | 16k | 8k |
| JSON Strict | ? Exzellent | ? Sehr gut | ?? Gut |
| Deutsch | ? Native | ? Native | ? Native |
| Automation Quality | ?? Beste | ? Sehr gut | ? Gut |
| Kosten/1M tok | $3/$15 | $2.50/$10 | $0.15/$0.60 |

## Troubleshooting

### Claude-spezifisch:
- Bei Timeout: Prompt vereinfachen oder in mehrere Schritte aufteilen
- Bei JSON-Parsing-Fehler: Explizit "Gib NUR JSON zurück, kein zusätzlicher Text" im Prompt erwähnen

### GPT-5/o3-mini-spezifisch:
- Bei "Invalid token parameter": Modell korrekt konfiguriert? (Code erkennt automatisch)
- Bei "Empty response": Retry-Mechanismus greift (10 Versuche)

### Gemini-spezifisch:
- Bei "No system role": Normal, wird automatisch konvertiert
- Bei Rate-Limiting: Gemini hat niedrigere Limits (60 req/min), warte kurz

## Weitere Informationen

- [Anthropic Models](https://docs.anthropic.com/en/docs/models-overview)
- [OpenAI Models](https://platform.openai.com/docs/models)
- [Gemini Models](https://ai.google.dev/models/gemini)

---

**Version:** 0.99.5-claude-optimized  
**Letzte Aktualisierung:** Januar 2025
