---
description: Systematic process for identifying and repairing broken automations
---

This workflow guides you through debugging and fixing automations in Home Assistant.

1. **Identify the Issue**
   - Check `home-assistant.log` (via `read_url_content` or `read_resource` if available, or ask user to check UI).
   - Look for "Automation failed to trigger" or "Entity not found" errors.
- Check all automations which never have been triggered

2. **Refresh Inventory**
   - Run the inventory workflow to ensure you have the latest device/entity list.
   ```powershell
   python inventory_ha.py | Out-File inventory_report.md -Encoding utf8
   ```

3. **Analyze `automations.yaml`**
   - Open `automations.yaml`.
   - Search for the broken automation by its `alias` or `id`.
   - **Check Entity IDs**: Compare used IDs against `inventory_report.md`.
     - *Common fix*: Devices often get renamed after re-pairing (e.g., `light.hue_bulb_1` vs `light.wohnzimmer_stehlampe`).
   - **Check Syntax**: Ensure modern syntax is used (e.g., `action:` instead of `service:`).

4. **Apply Fixes**
   - Edit `automations.yaml` with the correct Entity IDs.
   - Ensure the automation has a unique `id:` (generate a UUID if missing).
   - Ensure `mode:` is set correctly (e.g., `restart` for motion lights).

5. **Validate Configuration**
   - Run a quick syntax check (if possible locally) or ensure YAML is valid.

6. **Deploy and Reload**
   - Run the deploy script to push changes to the Pi.
   ```powershell
   ./sync_to_ha.ps1
   ```
   - This script will automatically reload automations on the Pi.

7. **Verify**
   - Trigger the automation manually in the UI or perform the physical action (e.g., walk in front of sensor).