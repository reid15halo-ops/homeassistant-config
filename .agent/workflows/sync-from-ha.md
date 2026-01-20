---
description: Sync configuration files from Home Assistant to local repository
---

# Sync from Home Assistant

This workflow fetches the current state of all configuration files from the Raspberry Pi Home Assistant instance and updates the local repository.

## Prerequisites
- Home Assistant running on Raspberry Pi at `192.168.178.70`
- Samba Share addon installed and running on Home Assistant
- Network access to `\\192.168.178.70\config`

## Steps

### 1. Verify Connection
```powershell
Test-Path "\\192.168.178.70\config"
```
If this returns `False`, ensure Samba Share addon is running in Home Assistant.

// turbo
### 2. Sync Configuration Files
```powershell
$HA_CONFIG_PATH = "\\192.168.178.70\config"
$REPO_PATH = "C:\Users\reid1\Documents\homeassistant-config"
$filesToSync = @("automations.yaml", "scripts.yaml", "scenes.yaml", "configuration.yaml", "input_boolean.yaml", "ui-lovelace.yaml")
foreach ($file in $filesToSync) {
    $sourcePath = Join-Path $HA_CONFIG_PATH $file
    $destPath = Join-Path $REPO_PATH $file
    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        Write-Host "Synced: $file" -ForegroundColor Green
    }
}
```

// turbo
### 3. Sync Directories
```powershell
$HA_CONFIG_PATH = "\\192.168.178.70\config"
$REPO_PATH = "C:\Users\reid1\Documents\homeassistant-config"
Copy-Item -Path "$HA_CONFIG_PATH\appdaemon" -Destination $REPO_PATH -Force -Recurse -ErrorAction SilentlyContinue
Copy-Item -Path "$HA_CONFIG_PATH\custom_zha_quirks" -Destination $REPO_PATH -Force -Recurse -ErrorAction SilentlyContinue
Copy-Item -Path "$HA_CONFIG_PATH\dashboards" -Destination $REPO_PATH -Force -Recurse -ErrorAction SilentlyContinue
Copy-Item -Path "$HA_CONFIG_PATH\blueprints" -Destination $REPO_PATH -Force -Recurse -ErrorAction SilentlyContinue
Write-Host "Synced all directories" -ForegroundColor Green
```

### 4. Commit and Push to GitHub
```powershell
git add -A
git commit -m "Sync from Home Assistant - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git push origin main
```

## Files Synced
| Type | Files |
|------|-------|
| Core Config | `configuration.yaml`, `automations.yaml`, `scripts.yaml`, `scenes.yaml` |
| Helpers | `input_boolean.yaml` |
| UI | `ui-lovelace.yaml` |
| Folders | `appdaemon/`, `custom_zha_quirks/`, `dashboards/`, `blueprints/` |

## Alternative: Use Script
You can also run the sync script directly:
```powershell
powershell -ExecutionPolicy Bypass -File "sync_from_ha.ps1"
```
