---
trigger: always_on
---

# Home Assistant Configuration Rules & Best Practices

## 1. Project Philosophy & Context
- **Environment**: Local Windows development synced to Raspberry Pi 4 (`192.168.178.70`).
- **Source of Truth**: The **Raspberry Pi** is the source of truth for state. The **Git Repo** is the source of truth for configuration.
- **Deployment Strategy**: 
  1.  `powershell ./sync_from_ha.ps1` (Pull latest state)
  2.  Make changes locally
  3.  `powershell ./sync_to_ha.ps1` (Deploy and Reload)

## 2. Naming Conventions (Strict)
All entity IDs must follow the pattern: `domain.room_device_function`
- **Room**: `wohnzimmer`, `kuche`, `bad`, `schlafzimmer`, `kiffzimmer`, `flur`
- **Device**: `deckenlicht`, `stehlampe`, `bewegungsmelder`, `fenster`, `rollladen`
- **Function**: `level`, `temperature`, `humidity`, `battery`, `switch`

**Examples:**
- ✅ `light.wohnzimmer_stehlampe`
- ✅ `binary_sensor.kuche_bewegung`
- ✅ `cover.schlafzimmer_rollladen`
- ❌ `light.hue_color_lamp_1` (Too generic)
- ❌ `sensor.temp_living_room` (Wrong language/order)

**Friendly Names:**
- Use **German** for all UI-facing names.
- Format: "Room Device Function" (e.g., "Wohnzimmer Stehlampe").

## 3. Automation Standards
- **IDs**: Every automation MUST have a unique `id:` (use a UUID or descriptive slug).
- **Alias**: Format as `Room - Category - Action` (e.g., `Küche - Licht - An bei Bewegung`).
- **Modes**: Explicitly define `mode:`.
  - Use `single` (default) for simple triggers.
  - Use `restart` for motion-activated lights.
  - Use `queued` for notifications.
- **Triggers**: Give every trigger a `id:` to use in `choose` blocks.
- **Conditions**: Use `condition: state` over templates where possible for performance.

## 4. Scripting & Logic
- **Syntax**: Use `action:` instead of `service:` (HA 2024.8+ standard).
- **Templates (Jinja2)**:
  - Always provide defaults for filters: `{{ states('sensor.x') | float(0) }}`.
  - Use `state_attr('entity', 'attr')` instead of `states.entity.attributes.attr`.
  - Use `is_state('entity', 'on')` instead of `states('entity') == 'on'`.

## 5. Device-Specific Rules
### Zigbee (ZHA)
- **Pairing**: Always rename devices immediately after pairing via the HA UI, then run `/inventory` to update local records.
- **Sensors**: For "True Presence", combine PIR (`binary_sensor`) and mmWave entities in a template sensor.
