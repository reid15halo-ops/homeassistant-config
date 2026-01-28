---
description: How to perform a comprehensive system audit and optimization
---

# System Audit Workflow

This workflow describes how to audit the Home Assistant configuration for health, consistency, and performance.

## 1. Health Check
- **Check System Agent**: Ensure `sensor.unavailable_entities` is 0.
- **Check Logs**: Review `system_log` for errors.
- **Check Automations**: Ensure no automations are disabled unexpectedly.

## 2. Naming Convention Audit
- **Entities**: Must follow `domain.room_device_function` (e.g., `light.wohnzimmer_stehlampe`).
- **Friendly Names**: Must be in **German** (e.g., "Wohnzimmer Stehlampe").
- **IDs**: Must be in **English** (snake_case).

## 3. Code Quality Audit
- **Encoding**: Check for mojibake (e.g., `ÃƒÆ’Ã‚Â¤`).
- **Hardcoded Values**: Move hardcoded values to `input_number` or `input_select` helpers.
- **Duplication**: Refactor repeated logic into Scripts or Packages.

## 4. Verification
- **Static Analysis**: Use `grep` to find broken references.
- **Manual Testing**: Trigger automations to verify behavior.
