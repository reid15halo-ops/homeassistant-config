---
description: How adaptive/flux lighting works to automatically adjust color temperature
---

# Adaptive Lighting System

This setup uses a manual "flux" system with input_number helpers to control light color temperature and brightness based on time of day.

## Configuration Helpers

Located in `configuration.yaml` under `input_number:`:

```yaml
input_number:
  flux_kelvin:
    name: "Flux Target Kelvin"
    min: 2000
    max: 6500
    initial: 2700
    
  flux_brightness:
    name: "Flux Target Brightness"
    min: 1
    max: 100
    initial: 80
```

## Using in Automations

```yaml
action:
  - action: light.turn_on
    target:
      entity_id: light.wohnzimmer_licht
    data:
      brightness_pct: "{{ states('input_number.flux_brightness')|int }}"
      kelvin: "{{ states('input_number.flux_kelvin')|int }}"
      transition: 2
```

## Recommended Kelvin Values

| Time | Kelvin | Brightness |
|------|--------|------------|
| 06:00 | 2700K | 60% |
| 10:00 | 5000K | 100% |
| 19:00 | 3000K | 80% |
| 22:00 | 2200K | 30% |
