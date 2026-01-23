# 🔧 20-Step Fix Plan: Missing Automations in Home Assistant

**Problem**: Only 5 automations visible in UI despite 58+ defined in `automations.yaml`  
**Date**: 2026-01-23  
**Status**: IN PROGRESS

---

## Phase 1: Diagnostics (Steps 1-7)

### Step 1: ✅ Verify File Deployment
- [x] Local automations.yaml: 51,883 bytes, 1,612 lines
- [x] Remote automations.yaml: 51,883 bytes (matches)
- **Result**: Files are synced correctly

### Step 2: ⬜ Check YAML Syntax with Home Assistant Validator
```
Go to: Developer Tools → YAML → CHECK CONFIGURATION
```
- [ ] Record any errors shown
- [ ] Note specific line numbers if errors exist

### Step 3: ⬜ Check Home Assistant Logs for Automation Errors
```
Go to: Settings → System → Logs
Filter by: "automation" or "yaml"
```
- [ ] Look for any "Invalid config" messages
- [ ] Look for "duplicate key" warnings
- [ ] Note any entity errors

### Step 4: ⬜ Verify Configuration.yaml Include Statement
The `automation:` block should be:
```yaml
automation:
  - !include automations.yaml
  - !include automations_ai.yaml
```
NOT:
```yaml
automation: !include automations.yaml  # WRONG - single file only
```

### Step 5: ⬜ Check for UI-Created Automations Override
```
Path: \\192.168.178.70\config\.storage\core.config_entries
```
- [ ] Check if automations are stored in `.storage` instead of YAML

### Step 6: ⬜ Check Line Endings (CRLF vs LF)
- [ ] Verify automations.yaml uses Unix line endings (LF)
- [ ] Windows line endings (CRLF) can cause silent failures

### Step 7: ⬜ Check File Encoding
- [ ] Verify file is UTF-8 without BOM
- [ ] Special characters in German text might cause issues

---

## Phase 2: Quick Fixes (Steps 8-12)

### Step 8: ⬜ Convert Line Endings to Unix (LF)
```powershell
$content = Get-Content "automations.yaml" -Raw
$content = $content -replace "`r`n", "`n"
[System.IO.File]::WriteAllText("automations.yaml", $content)
```

### Step 9: ⬜ Remove BOM if Present
```powershell
$Utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("automations.yaml", (Get-Content "automations.yaml" -Raw), $Utf8NoBom)
```

### Step 10: ⬜ Re-deploy After Encoding Fix
```powershell
Copy-Item "automations.yaml" "\\192.168.178.70\config\automations.yaml" -Force
```

### Step 11: ⬜ Full Home Assistant Restart
```
Settings → System → RESTART (top-right corner)
Wait 2 minutes for full restart
```

### Step 12: ⬜ Check Automations After Restart
```
Settings → Automations & Scenes → Automations
```
- [ ] Count total automations visible
- [ ] Note if count changed

---

## Phase 3: Deep Diagnostics (Steps 13-16)

### Step 13: ⬜ Create Minimal Test Automation
Create a simple test file to verify includes work:
```yaml
# test_automation.yaml
- id: test_automation_123
  alias: "TEST - Simple Automation"
  trigger:
    - platform: time
      at: "00:00:00"
  action:
    - service: logger.log
      data:
        message: "Test automation triggered"
```

### Step 14: ⬜ Check for Duplicate Automation IDs
```powershell
# Find duplicate IDs
Select-String -Path "automations.yaml" -Pattern "^- id:" | 
  Group-Object Line | Where-Object Count -gt 1
```

### Step 15: ⬜ Validate Each Automation Individually
Split automations and test each one to find the breaking automation.

### Step 16: ⬜ Check Home Assistant Core Logs via SSH
```bash
ha core logs | grep -i automation
ha core logs | grep -i error
```

---

## Phase 4: Nuclear Options (Steps 17-20)

### Step 17: ⬜ Backup Current State
```powershell
Copy-Item "\\192.168.178.70\config\automations.yaml" "automations_pi_backup.yaml"
Copy-Item "\\192.168.178.70\config\.storage" ".storage_backup" -Recurse
```

### Step 18: ⬜ Clear Automation Cache
Delete any `.storage` automation cache files and restart.

### Step 19: ⬜ Re-create Configuration from Scratch
1. Rename `automations.yaml` to `automations_old.yaml`
2. Create new empty `automations.yaml` with just `[]`
3. Restart HA
4. Add automations one section at a time

### Step 20: ⬜ Full System Check
1. Check HA version compatibility
2. Verify no deprecated syntax
3. Ensure all entity_ids referenced exist
4. Validate against HA schema

---

## Current Status Tracking

| Step | Status | Notes |
|------|--------|-------|
| 1 | ✅ Done | Files synced correctly |
| 2 | ⬜ Pending | Need user to check |
| 3 | ⬜ Pending | Need log access |
| 4 | ⬜ Pending | Need to verify |
| 5-20 | ⬜ Pending | |

---

## Next Action Required

**USER ACTION NEEDED**: 
1. Go to Home Assistant → Developer Tools → YAML
2. Click "CHECK CONFIGURATION"
3. Report any errors shown
4. Then check Settings → System → Logs for automation errors
