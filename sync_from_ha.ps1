# Home Assistant Config Sync - Raspberry Pi Edition
# Your HA is running on Raspberry Pi 4 at 192.168.178.70

# STEP 1: First-time setup
# Install Samba Share addon in Home Assistant:
#   1. Go to Settings → Add-ons → Add-on Store
#   2. Search for "Samba share" and install it
#   3. Start the addon
#   4. Default username: homeassistant, password: (set in addon config)

# STEP 2: Mount the share in Windows
# Open File Explorer and go to:
#   \\192.168.178.70\config
# Or map it as a network drive (recommended):
#   Right-click "This PC" → Map network drive
#   Drive: Z:
#   Folder: \\192.168.178.70\config
#   ✓ Reconnect at sign-in

# CONFIGURATION
$HA_CONFIG_PATH = "\\192.168.178.70\config"  # Samba share on your Pi
$REPO_PATH = "C:\Users\reid1\Documents\homeassistant-config"

Write-Host "=== Home Assistant Config Sync (Raspberry Pi) ===" -ForegroundColor Cyan
Write-Host ""

# Check if Samba share is accessible
Write-Host "Checking connection to Raspberry Pi..." -ForegroundColor Yellow
if (-not (Test-Path $HA_CONFIG_PATH)) {
    Write-Host "❌ Cannot access: $HA_CONFIG_PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  1. Is Samba Share addon installed and started?" -ForegroundColor White
    Write-Host "  2. Can you ping 192.168.178.70?" -ForegroundColor White
    Write-Host "  3. Try accessing \\192.168.178.70\config in File Explorer" -ForegroundColor White
    Write-Host ""
    Write-Host "If prompted for credentials:" -ForegroundColor Cyan
    Write-Host "  Username: homeassistant" -ForegroundColor White
    Write-Host "  Password: (check Samba addon configuration)" -ForegroundColor White
    exit 1
}

Write-Host "✓ Connected to Raspberry Pi!" -ForegroundColor Green
Write-Host "Home Assistant config: $HA_CONFIG_PATH" -ForegroundColor Green
Write-Host "Git repository:        $REPO_PATH" -ForegroundColor Green
Write-Host ""

# Files to sync
$filesToSync = @(
    "automations.yaml",
    "scripts.yaml",
    "scenes.yaml",
    "configuration.yaml",
    "input_boolean.yaml",
    "customize.yaml",
    "groups.yaml"
)

# Additional directories
$dirsToSync = @(
    "appdaemon"
)

# Sync files FROM Raspberry Pi TO local repo
Write-Host "Syncing files from Raspberry Pi to local repo..." -ForegroundColor Cyan
foreach ($file in $filesToSync) {
    $sourcePath = Join-Path $HA_CONFIG_PATH $file
    $destPath = Join-Path $REPO_PATH $file
    
    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $destPath -Force
        Write-Host "  ✓ $file" -ForegroundColor Green
    }
    else {
        Write-Host "  - $file (not found on Pi)" -ForegroundColor Gray
    }
}

# Sync directories
foreach ($dir in $dirsToSync) {
    $sourcePath = Join-Path $HA_CONFIG_PATH $dir
    $destPath = Join-Path $REPO_PATH $dir
    
    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $destPath -Force -Recurse
        Write-Host "  ✓ $dir\" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "✅ Sync complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Ready to commit:" -ForegroundColor Yellow
Write-Host "  cd $REPO_PATH" -ForegroundColor White
Write-Host "  git add ." -ForegroundColor White
Write-Host "  git commit -m 'Sync from Raspberry Pi'" -ForegroundColor White
Write-Host "  git push" -ForegroundColor White
