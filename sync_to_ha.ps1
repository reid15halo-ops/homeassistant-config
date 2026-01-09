# Sync TO Raspberry Pi
# Copies files from your local repo to the Raspberry Pi running Home Assistant

# CONFIGURATION
$HA_CONFIG_PATH = "\\192.168.178.70\config"  # Samba share on your Pi
$REPO_PATH = "C:\Users\reid1\Documents\homeassistant-config"

Write-Host "=== Deploy to Raspberry Pi ===" -ForegroundColor Cyan
Write-Host ""

# Check connection
if (-not (Test-Path $HA_CONFIG_PATH)) {
    Write-Host "❌ Cannot connect to Raspberry Pi at $HA_CONFIG_PATH" -ForegroundColor Red
    Write-Host "Make sure Samba Share addon is running!" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Connected to Raspberry Pi" -ForegroundColor Green
Write-Host ""
Write-Host "⚠️  WARNING: This will overwrite files on your Raspberry Pi!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Files to deploy:" -ForegroundColor Cyan
Write-Host "  - automations.yaml" -ForegroundColor White
Write-Host "  - scripts.yaml" -ForegroundColor White
Write-Host "  - input_boolean.yaml" -ForegroundColor White
Write-Host "  - appdaemon/" -ForegroundColor White
Write-Host ""

$confirmation = Read-Host "Continue? (yes/no)"
if ($confirmation -ne "yes") {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Deploying files..." -ForegroundColor Cyan

# Files to deploy
$filesToDeploy = @(
    "automations.yaml",
    "scripts.yaml",
    "input_boolean.yaml",
    "scenes.yaml"
)

foreach ($file in $filesToDeploy) {
    $sourcePath = Join-Path $REPO_PATH $file
    $destPath = Join-Path $HA_CONFIG_PATH $file
    
    if (Test-Path $sourcePath) {
        # Backup original first
        if (Test-Path $destPath) {
            Copy-Item -Path $destPath -Destination "$destPath.backup" -Force
        }
        
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        Write-Host "  ✓ Deployed: $file" -ForegroundColor Green
    }
    else {
        Write-Host "  ✗ Missing in repo: $file" -ForegroundColor Red
    }
}

# Deploy appdaemon folder
$appDaemonSource = Join-Path $REPO_PATH "appdaemon"
$appDaemonDest = Join-Path $HA_CONFIG_PATH "appdaemon"
if (Test-Path $appDaemonSource) {
    Copy-Item -Path $appDaemonSource -Destination $HA_CONFIG_PATH -Force -Recurse
    Write-Host "  ✓ Deployed: appdaemon/" -ForegroundColor Green
}

Write-Host ""
Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host ""
Write-Host "⚡ Next steps:" -ForegroundColor Yellow
Write-Host "  1. Go to Home Assistant web UI (http://192.168.178.70:8123)" -ForegroundColor White
Write-Host "  2. Developer Tools → YAML" -ForegroundColor White
Write-Host "  3. Click 'Reload Automations'" -ForegroundColor White
Write-Host "  4. Click 'Reload Scripts'" -ForegroundColor White
Write-Host "  5. Click 'Reload Helpers'" -ForegroundColor White
Write-Host ""
Write-Host "Or restart Home Assistant completely:" -ForegroundColor Cyan
Write-Host "  Settings → System → Restart" -ForegroundColor White
