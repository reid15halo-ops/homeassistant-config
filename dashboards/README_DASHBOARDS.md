# ============================================================================
# LOVELACE DASHBOARDS CONFIGURATION
# ============================================================================
# Add this to your configuration.yaml to enable the custom dashboards

lovelace:
  mode: storage
  dashboards:
    home-control:
      mode: yaml
      title: Home Control
      icon: mdi:home-automation
      show_in_sidebar: true
      filename: dashboards/home_control.yaml
      
    climate-energy:
      mode: yaml
      title: Climate & Energy
      icon: mdi:leaf
      show_in_sidebar: true
      filename: dashboards/climate_energy.yaml
      
    automation-status:
      mode: yaml
      title: Automation Status
      icon: mdi:robot
      show_in_sidebar: true
      filename: dashboards/automation_status.yaml
