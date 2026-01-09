# Blinds Anti-Jamming Solution

## Problem
Blinds were getting stuck when automations tried to open them twice in a row. Multiple close operations are fine, but consecutive opens cause mechanical jamming.

## Solution Overview
Implemented a tracking system using **input booleans** and **safe scripts** to prevent double-open operations while allowing multiple closes.

## Components

### 1. Tracking Input Booleans (`input_boolean.yaml`)
Added 4 tracking booleans (one per blind):
- `blind_computer_last_opened`
- `blind_schlafen_last_opened`
- `blind_kuche_last_opened`
- `blind_yoga_last_opened`

**State Logic:**
- `on` (true) = Last action was OPEN → **Cannot open again**
- `off` (false) = Last action was CLOSE → **Safe to open**

### 2. Safe Control Scripts (`scripts.yaml`)

#### `safe_open_blind`
**What it does:**
- Checks the tracker boolean before opening
- If tracker is `off` → Opens blind + sets tracker to `on`
- If tracker is `on` → Skips operation + logs warning

**Usage:**
```yaml
- service: script.safe_open_blind
  data:
    cover_entity: cover.rollladen_computer_vorhang
    tracker_entity: input_boolean.blind_computer_last_opened
```

#### `safe_close_blind`
**What it does:**
- Always closes (multiple closes are safe)
- Sets tracker to `off` (allows future opens)

**Usage:**
```yaml
- service: script.safe_close_blind
  data:
    cover_entity: cover.rollladen_computer_vorhang
    tracker_entity: input_boolean.blind_computer_last_opened
```

## Updated Automations

### Already Updated
1. **`bedroom_wakeup_weekday`** (`automations.yaml` line 445)
   - Changed from `cover.open_cover` → `script.safe_open_blind`
   - Blind: `cover.schlafen_blind_vorhang`

2. **`gaming_restore_shutter`** (`automations_gaming.yaml` line 108)
   - Changed from `cover.open_cover` → `script.safe_open_blind`
   - Blind: `cover.rollladen_computer_vorhang`

### Still Need Updates
Any other automations that use:
- `cover.open_cover` → Should use `script.safe_open_blind`
- `cover.close_cover` → Should use `script.safe_close_blind` (optional but recommended for consistency)

## Blind → Tracker Mapping

| Cover Entity | Tracker Boolean |
|---|---|
| `cover.rollladen_computer_vorhang` | `input_boolean.blind_computer_last_opened` |
| `cover.schlafen_blind_vorhang` | `input_boolean.blind_schlafen_last_opened` |
| `cover.rollladen_kuche_vorhang` | `input_boolean.blind_kuche_last_opened` |
| `cover.rollladen_yoga_vorhang` | `input_boolean.blind_yoga_last_opened` |

## Testing

1. **Test Safe Open:**
   - Close blind manually
   - Run automation that opens → Should work
   - Run automation again → Should skip (log warning)

2. **Test Safe Close:**
   - Open blind
   - Run automation that closes → Should work
   - Run automation again → Should work (multiple closes OK)
   - Now try to open → Should work (tracker reset by close)

## Next Steps

1. Search for all remaining `cover.open_cover` calls:
   ```
   grep -r "cover.open_cover" automations*.yaml
   ```

2. Update them to use `script.safe_open_blind`

3. Optionally update `cover.close_cover` calls to use `script.safe_close_blind` for consistency

## Benefits

✅ **Prevents jamming** - Blinds can't open twice in a row
✅ **Allows multiple closes** - No restriction on closing
✅ **Centralized logic** - Easy to maintain in scripts.yaml
✅ **Logging** - Warns when skipping duplicate opens
✅ **No hardware changes** - Pure software solution
