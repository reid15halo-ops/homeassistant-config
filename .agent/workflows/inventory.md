---
description: Generate a comprehensive inventory of the Home Assistant instance
---

This workflow generates a full inventory of your Home Assistant setup, including:
- Installed Integrations
- Connected Devices (Hardware)
- All Entities
- Automations and Scripts

It combines data from your local YAML configuration and the live registry files on your Home Assistant server (accessed via SMB).

1. Run the inventory script
   ```bash
   python inventory_ha.py | Out-File inventory_report.md -Encoding utf8
   ```
   
2. Review the generated report
   ```bash
   # You can open the file in your editor
   code inventory_report.md
   ```
