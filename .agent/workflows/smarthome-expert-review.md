---
description: Perform a comprehensive expert review of the Home Assistant configuration to identify fixes, optimizations, and new features.
---

1. **Environment Discovery**
   - List all files in the configuration directory to understand the structure.
   - Read `configuration.yaml`, `automations.yaml`, `scripts.yaml`, and `scenes.yaml`.
   - Read `inventory_report.md` (if available) to get a quick overview of devices and entities.
   - Read `core.md` (if available) to understand user-defined rules and naming conventions.

2. **Entity & Device Audit**
   - Scan for entities that do not follow the naming convention `domain.room_device_function`.
   - Identify any hardcoded entity IDs in automations/scripts that might be broken or old.
   - Check for "ghost" entities defined in YAML but not present in the system (if verifiable).

3. **Code Quality & Performance Check**
   - Look for inefficient logic (e.g., `repeat` loops with high counts, excessive polling).
   - Check for deprecated configuration syntax.
   - Verify that `packages` are correctly structured and included.
   - Ensure secrets are used where appropriate.

4. **Automation Logic Analysis**
   - Analyze automations for missing conditions or triggers.
   - Check for conflicting automations (e.g., one turns light on, another turns it off immediately).
   - Verify that "modes" (Guest, Vacation, Sleep) are correctly integrated across all relevant automations.

5. **Feature & Improvement Proposal**
   - Identify gaps in the smart home setup (e.g., missing presence detection in some rooms, lack of notifications for critical events).
   - Propose new automations based on existing devices (e.g., "If window open for X mins, turn off heat").
   - Suggest dashboard improvements for better usability.

6. **Generate Report**
   - Compile all findings into a structured report (Artifact).
   - Categorize items into: **Critical Fixes**, **Optimizations**, and **New Features**.
   - Create a task list to address the approved items.
