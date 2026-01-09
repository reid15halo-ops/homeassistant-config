# Complete Raspberry Pi Setup Guide

## Your Setup
- **Home Assistant**: Running on Raspberry Pi 4
- **IP Address**: 192.168.178.70
- **Web UI**: https://192.168.178.70:8123
- **Local Git Repo**: C:\Users\reid1\Documents\homeassistant-config

## Step 1: Install Samba Share Addon (First Time Only)

1. Open Home Assistant web UI: https://192.168.178.70:8123
2. Go to **Settings → Add-ons → Add-on Store**
3. Search for **"Samba share"**
4. Click **Install**
5. After installation, click **Configuration** tab
6. Set a password (or leave default)
7. Click **Start**
8. Enable **"Start on boot"**

## Step 2: Connect from Windows

### Option A: Direct Access (Quick)
1. Open File Explorer
2. In the address bar, type: `\\192.168.178.70\config`
3. Press Enter
4. If prompted, use credentials:
   - Username: `homeassistant`
   - Password: (from Samba addon config)

### Option B: Map Network Drive (Recommended)
1. Open File Explorer
2. Right-click **"This PC"** → **"Map network drive"**
3. Drive letter: **Z:** (or any available)
4. Folder: `\\192.168.178.70\config`
5. ✓ Check **"Reconnect at sign-in"**
6. Click **Finish**

Now you can access your Raspberry Pi's config at `Z:\`

## Step 3: Choose Your Workflow

### Workflow A: Work Directly on Pi (Simplest)
1. Map the network drive (see Option B above)
2. Open files directly from `Z:\` in VS Code
3. Edit, save → Changes are immediately on the Pi
4. Reload automations in HA web UI
5. Manually copy changed files to your git repo and commit

### Workflow B: Work in Repo + Sync (Recommended)
1. Edit files in your local repo: `C:\Users\reid1\Documents\homeassistant-config\`
2. Test and commit changes locally
3. Run `sync_to_ha.ps1` to deploy to Raspberry Pi
4. Reload automations in HA

### Workflow C: Bi-directional Sync (Advanced)
1. Make changes on Pi (via Samba or HA File Editor addon)
2. Run `sync_from_ha.ps1` to pull changes to repo
3. Commit and push to GitHub
4. When you pull from GitHub, run `sync_to_ha.ps1` to deploy

## Current Status

Your files are currently:
- ✅ **In Git Repo**: All seasonal automations, safe scripts, etc.
- ❓ **On Raspberry Pi**: Possibly older versions (needs verification)

## Next Action: Deploy Your Latest Changes

Run this to deploy everything to your Pi:
```powershell
cd C:\Users\reid1\Documents\homeassistant-config
.\sync_to_ha.ps1
```

This will copy:
- `automations.yaml` (with seasonal blinds, safe scripts)
- `scripts.yaml` (with safe blind controls, heating/fan scripts)
- `input_boolean.yaml` (with blind trackers)
- `appdaemon/` folder

Then restart Home Assistant or reload YAML in Developer Tools.

## Quick Reference

| Task | Command |
|------|---------|
| Pull changes FROM Pi | `.\sync_from_ha.ps1` |
| Push changes TO Pi | `.\sync_to_ha.ps1` |
| Access Pi files | `\\192.168.178.70\config` |
| HA Web UI | https://192.168.178.70:8123 |
| Reload Automations | Developer Tools → YAML → Reload Automations |

## Troubleshooting

**Can't access `\\192.168.178.70\config`?**
- Check Samba Share addon is started
- Verify Pi is reachable: `ping 192.168.178.70`
- Try with explicit credentials

**Sync script fails?**
- Ensure Samba Share addon is running
- Check network connectivity to Pi
- Verify credentials

**Changes not appearing in HA?**
- Make sure you ran the sync script
- Reload automations/scripts in Developer Tools
- Or restart Home Assistant completely
