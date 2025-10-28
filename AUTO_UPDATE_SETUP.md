# Home Assistant Auto-Update Setup Guide

## Overview

This system automatically pulls the latest configuration from GitHub every night at 03:00 AM and safely applies changes with:
- ✅ Automatic backup before update
- ✅ YAML validation before restart
- ✅ Auto-rollback on errors
- ✅ Notifications on success/failure
- ✅ Detailed logging

---

## Installation (One-Time Setup)

### Step 1: Copy Files to Raspberry Pi

```bash
# SSH into your Home Assistant
ssh reid15@192.168.178.71

# Navigate to config directory
cd /config

# Create scripts directory if not exists
mkdir -p /config/scripts
mkdir -p /config/logs
mkdir -p /config/backups/auto
```

### Step 2: Upload Scripts

Copy these files to your Raspberry Pi:
- `scripts/auto_update_from_github.sh` → `/config/scripts/`
- `scripts/test_auto_update.sh` → `/config/scripts/`
- `scripts/ha-auto-update.cron` → `/config/scripts/`

**Using SCP:**
```bash
# From your local machine
scp scripts/auto_update_from_github.sh reid15@192.168.178.71:/config/scripts/
scp scripts/test_auto_update.sh reid15@192.168.178.71:/config/scripts/
scp scripts/ha-auto-update.cron reid15@192.168.178.71:/config/scripts/
```

**Or manually via File Editor add-on in Home Assistant UI**

### Step 3: Make Scripts Executable

```bash
ssh reid15@192.168.178.71

chmod +x /config/scripts/auto_update_from_github.sh
chmod +x /config/scripts/test_auto_update.sh
```

### Step 4: Test the System

Run the test script to verify everything is set up correctly:

```bash
/config/scripts/test_auto_update.sh
```

**Expected output:**
```
==================================
Auto-Update System Test
==================================

1. Checking if auto_update_from_github.sh exists... ✓
2. Checking if script is executable... ✓
3. Checking if git is available... ✓
   Git version: git version 2.x.x
4. Checking if /config is a git repository... ✓
   Current branch: arbeit-updates
   Remote: https://github.com/reid15halo-ops/homeassistant-config.git
5. Checking if Home Assistant CLI (ha) is available... ✓
6. Checking if backup directory exists... ✓
7. Checking if log directory exists... ✓
8. Checking if cron job is installed... ⚠ Not installed
9. Testing git fetch (checking for updates)... ✓
10. Testing Home Assistant config check... ✓

All critical tests passed!
```

### Step 5: Install Cron Job

```bash
# Copy cron file to system cron directory
sudo cp /config/scripts/ha-auto-update.cron /etc/cron.d/ha-auto-update

# Set correct permissions
sudo chmod 644 /etc/cron.d/ha-auto-update

# Verify it's installed
ls -la /etc/cron.d/ha-auto-update
```

### Step 6: Manual Test Run (Optional but Recommended)

Before waiting for the automatic run at 03:00 AM, test it manually:

```bash
# Run the update script manually
/config/scripts/auto_update_from_github.sh

# Watch the log output in real-time
tail -f /config/logs/auto_update.log
```

**Expected behavior:**
- Script checks for updates
- If no updates: "No updates available. System is up to date."
- If updates found: Creates backup → Pulls → Validates → Restarts

---

## How It Works

### Daily Schedule
- **Time:** 03:00 AM (every night)
- **Branch:** `arbeit-updates`
- **Duration:** ~1-3 minutes

### Process Flow

```
┌─────────────────────────────────────┐
│ 03:00 AM - Cron Job Starts Script  │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Check for Updates                   │
│ (git fetch origin arbeit-updates)   │
└──────────────┬──────────────────────┘
               │
         ┌─────┴─────┐
         │ Updates?  │
         └─────┬─────┘
               │
        No ────┤──── Yes
               │         │
         Log + Exit      │
                         ▼
              ┌────────────────────────┐
              │ Create Backup          │
              │ config_backup_<time>   │
              └──────────┬─────────────┘
                         │
                         ▼
              ┌────────────────────────┐
              │ Git Pull               │
              └──────────┬─────────────┘
                         │
                   ┌─────┴─────┐
                   │ Success?  │
                   └─────┬─────┘
                         │
                  No ────┤──── Yes
                         │         │
                  Rollback +       │
                  Notify           │
                         │         ▼
                         │  ┌────────────────────┐
                         │  │ Validate YAML      │
                         │  │ (ha core check)    │
                         │  └──────────┬─────────┘
                         │             │
                         │       ┌─────┴─────┐
                         │       │ Valid?    │
                         │       └─────┬─────┘
                         │             │
                         │      No ────┤──── Yes
                         │             │         │
                         │      Rollback +       │
                         │      Notify           │
                         │             │         ▼
                         │             │  ┌────────────────────┐
                         │             │  │ Restart HA         │
                         │             │  │ (ha core restart)  │
                         │             │  └──────────┬─────────┘
                         │             │             │
                         │             │             ▼
                         │             │  ┌────────────────────┐
                         │             │  │ Success Notify     │
                         │             │  └────────────────────┘
                         │             │
                         └─────────────┘
```

---

## Monitoring & Logs

### View Logs

```bash
# View last 50 lines
tail -50 /config/logs/auto_update.log

# Follow logs in real-time
tail -f /config/logs/auto_update.log

# View cron execution log
tail -f /config/logs/auto_update_cron.log
```

### Log Format

```
[2025-10-28 03:00:01] [INFO] ==========================================
[2025-10-28 03:00:01] [INFO] Starting Auto-Update Process
[2025-10-28 03:00:01] [INFO] ==========================================
[2025-10-28 03:00:02] [INFO] Checking for updates on origin/arbeit-updates
[2025-10-28 03:00:03] [INFO] Local commit:  abc123...
[2025-10-28 03:00:03] [INFO] Remote commit: def456...
[2025-10-28 03:00:03] [INFO] Updates available!
[2025-10-28 03:00:04] [INFO] Creating backup: /config/backups/auto/config_backup_2025-10-28_03-00-04.tar.gz
[2025-10-28 03:00:10] [INFO] Backup created successfully
[2025-10-28 03:00:10] [INFO] Pulling changes from origin/arbeit-updates
[2025-10-28 03:00:12] [INFO] Git pull successful
[2025-10-28 03:00:12] [INFO] Validating Home Assistant configuration
[2025-10-28 03:00:15] [INFO] Configuration is valid ✓
[2025-10-28 03:00:15] [INFO] Restarting Home Assistant
[2025-10-28 03:00:16] [INFO] Home Assistant restart initiated
[2025-10-28 03:00:16] [INFO] ==========================================
[2025-10-28 03:00:16] [INFO] Auto-Update Completed Successfully!
[2025-10-28 03:00:16] [INFO] ==========================================
```

### Notifications

You'll receive notifications via Alexa Media Player (Wohnzimmer):

**Success:**
- Title: "HA Auto-Update SUCCESS"
- Message: "Configuration updated and restarted successfully."

**No Updates:**
- Title: "HA Auto-Update"
- Message: "No updates available. System is up to date."

**Failure:**
- Title: "HA Auto-Update FAILED"
- Message: Details about what went wrong (e.g., "Invalid YAML configuration. Rolling back to previous version.")

---

## Backup Management

### Backup Location
```
/config/backups/auto/
├── config_backup_2025-10-28_03-00-04.tar.gz
├── config_backup_2025-10-27_03-00-02.tar.gz
├── config_backup_2025-10-26_03-00-01.tar.gz
└── ...
```

### Automatic Cleanup
- **Retention:** 7 days
- Older backups are automatically deleted

### Manual Restore

If you need to manually restore from a backup:

```bash
# List available backups
ls -lh /config/backups/auto/

# Extract specific backup (replace with your timestamp)
cd /config
tar -xzf backups/auto/config_backup_2025-10-28_03-00-04.tar.gz

# Restart Home Assistant
ha core restart
```

---

## Troubleshooting

### Problem: Script doesn't run at 03:00 AM

**Check if cron job is installed:**
```bash
ls -la /etc/cron.d/ha-auto-update
cat /etc/cron.d/ha-auto-update
```

**Check cron service status:**
```bash
sudo systemctl status cron
```

**Manually trigger to test:**
```bash
/config/scripts/auto_update_from_github.sh
```

### Problem: "Git pull failed"

**Possible causes:**
- Network connectivity issues
- GitHub authentication problems
- Merge conflicts

**Check git status:**
```bash
cd /config
git status
git remote -v
```

**Resolve merge conflicts manually:**
```bash
cd /config
git status
# Resolve conflicts in affected files
git add .
git commit -m "Resolved merge conflicts"
```

### Problem: "Configuration validation failed"

**Check what's invalid:**
```bash
ha core check
```

**View detailed errors:**
```bash
ha core logs
```

**Rollback is automatic, but you can also:**
```bash
# Restore from latest backup
cd /config
tar -xzf backups/auto/config_backup_<latest>.tar.gz
ha core restart
```

### Problem: No notifications received

**Check notification service:**
```bash
# Test notification manually via REST API
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"message":"Test notification"}' \
  http://homeassistant.local:8123/api/services/notify/alexa_media_wohnzimmer
```

**Alternative: Check Home Assistant logs for notification errors**

---

## Customization

### Change Update Time

Edit the cron job:
```bash
sudo nano /etc/cron.d/ha-auto-update
```

Change this line:
```
0 3 * * * root /config/scripts/auto_update_from_github.sh
```

Examples:
- `0 6 * * *` - Every day at 06:00 AM
- `0 12 * * *` - Every day at 12:00 PM (noon)
- `0 0 * * 0` - Every Sunday at midnight

### Change Branch

Edit the script:
```bash
nano /config/scripts/auto_update_from_github.sh
```

Find this line:
```bash
BRANCH="arbeit-updates"
```

Change to:
```bash
BRANCH="main"  # or any other branch
```

### Change Notification Service

Edit the script:
```bash
nano /config/scripts/auto_update_from_github.sh
```

Find this line:
```bash
NOTIFY_SERVICE="notify.alexa_media_wohnzimmer"
```

Change to your preferred notification service:
```bash
NOTIFY_SERVICE="notify.mobile_app_your_phone"
```

### Change Backup Retention

Edit the script:
```bash
nano /config/scripts/auto_update_from_github.sh
```

Find this line:
```bash
BACKUP_RETENTION_DAYS=7
```

Change to desired number of days:
```bash
BACKUP_RETENTION_DAYS=14  # Keep 2 weeks
```

---

## Disable/Enable Auto-Update

### Temporarily Disable

```bash
# Remove cron job (keep script)
sudo rm /etc/cron.d/ha-auto-update
```

### Re-enable

```bash
# Reinstall cron job
sudo cp /config/scripts/ha-auto-update.cron /etc/cron.d/ha-auto-update
sudo chmod 644 /etc/cron.d/ha-auto-update
```

### Permanently Remove

```bash
# Remove cron job
sudo rm /etc/cron.d/ha-auto-update

# Remove scripts (optional)
rm /config/scripts/auto_update_from_github.sh
rm /config/scripts/test_auto_update.sh
rm /config/scripts/ha-auto-update.cron
```

---

## Security Considerations

### Git Credentials

The script uses the existing git credentials configured in `/config/.git/config`.

**If you need to update credentials:**
```bash
cd /config
git config user.name "Your Name"
git config user.email "your@email.com"

# For HTTPS with token
git config credential.helper store
git pull  # Enter credentials when prompted
```

### File Permissions

Ensure scripts are only writable by root:
```bash
sudo chown root:root /config/scripts/auto_update_from_github.sh
sudo chmod 755 /config/scripts/auto_update_from_github.sh
```

---

## FAQ

### Q: Will this overwrite my local changes?
**A:** If you have uncommitted local changes, they will be stashed before pulling. Check logs for details.

### Q: What happens if GitHub is down?
**A:** The script will log the error and exit. No changes will be made.

### Q: Can I run this more than once per day?
**A:** Yes! Modify the cron job. Example for every 12 hours:
```
0 3,15 * * * root /config/scripts/auto_update_from_github.sh
```

### Q: Will this update add-ons or HACS components?
**A:** No. This only updates your `/config` directory (YAML files, scripts, etc.). Add-ons and HACS need separate update mechanisms.

### Q: How much disk space do backups use?
**A:** Each backup is ~5-20 MB (compressed). With 7-day retention, expect ~50-150 MB total.

### Q: Can I test without actually restarting?
**A:** Yes! Comment out the restart line in the script:
```bash
# ${HA_RESTART_CMD} 2>&1 | tee -a "${LOG_FILE}"
```

---

## Support

If you encounter issues:
1. Check logs: `/config/logs/auto_update.log`
2. Run test script: `/config/scripts/test_auto_update.sh`
3. Check cron logs: `/config/logs/auto_update_cron.log`
4. Manually run script to see errors: `/config/scripts/auto_update_from_github.sh`

---

## Changelog

**Version 1.0 - 2025-10-28**
- Initial release
- Smart update with validation
- Automatic backup and rollback
- Notification integration
- Detailed logging

---

**Setup complete!** Your Home Assistant will now automatically update every night at 03:00 AM. 🎉
