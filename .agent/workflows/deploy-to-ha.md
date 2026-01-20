---
description: Deploy configuration changes to Home Assistant and reload services
---

# Deploy to Home Assistant

This workflow deploys local configuration changes to the Raspberry Pi Home Assistant instance and reloads the affected services.

## Prerequisites
- Home Assistant running on Raspberry Pi at `192.168.178.70`
- Samba Share addon installed and running
- Long-lived access token configured

## API Token
```
HA_URL: http://192.168.178.70:8123
Token: (stored in sync_to_ha.ps1)
```

## Steps

### 1. Verify Connection
```powershell
Test-Path "\\192.168.178.70\config"
```

### 2. Deploy Configuration Files
```powershell
$HA_CONFIG_PATH = "\\192.168.178.70\config"
$REPO_PATH = "C:\Users\reid1\Documents\homeassistant-config"
$filesToDeploy = @("configuration.yaml", "automations.yaml", "scripts.yaml", "input_boolean.yaml", "scenes.yaml")
foreach ($file in $filesToDeploy) {
    $sourcePath = Join-Path $REPO_PATH $file
    $destPath = Join-Path $HA_CONFIG_PATH $file
    if (Test-Path $sourcePath) {
        # Backup first
        if (Test-Path $destPath) { Copy-Item -Path $destPath -Destination "$destPath.backup" -Force }
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        Write-Host "Deployed: $file" -ForegroundColor Green
    }
}
```

### 3. Reload Services via API
```powershell
$HA_URL = "http://192.168.178.70:8123"
$token = "YOUR_LONG_LIVED_ACCESS_TOKEN"
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type"  = "application/json"
}

# Reload automations
Invoke-RestMethod -Uri "$HA_URL/api/services/automation/reload" -Method POST -Headers $headers

# Reload scripts
Invoke-RestMethod -Uri "$HA_URL/api/services/script/reload" -Method POST -Headers $headers

# Reload input_boolean
Invoke-RestMethod -Uri "$HA_URL/api/services/input_boolean/reload" -Method POST -Headers $headers

# Reload template entities
Invoke-RestMethod -Uri "$HA_URL/api/services/template/reload" -Method POST -Headers $headers
```

### 4. For configuration.yaml Changes - Full Restart Required
Go to Home Assistant UI:
1. **Settings** → **System** → **Restart**

Or via API:
```powershell
Invoke-RestMethod -Uri "$HA_URL/api/services/homeassistant/restart" -Method POST -Headers $headers
```

## Alternative: Use Script
```powershell
powershell -ExecutionPolicy Bypass -File "sync_to_ha.ps1"
```

## What Can Be Reloaded Without Restart
| Component | Reload Method |
|-----------|---------------|
| Automations | `automation/reload` |
| Scripts | `script/reload` |
| Input Booleans | `input_boolean/reload` |
| Template Sensors | `template/reload` |
| Scenes | `scene/reload` |

## What Requires Restart
- `configuration.yaml` core changes
- New integrations
- ZHA configuration changes
- Logger configuration changes
