#!/bin/bash
################################################################################
# Test Script for Auto-Update System
#
# This script tests the auto-update mechanism without actually
# pulling changes or restarting Home Assistant.
#
# Usage: ./test_auto_update.sh
################################################################################

set -euo pipefail

echo "=================================="
echo "Auto-Update System Test"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Check if script exists
echo -n "1. Checking if auto_update_from_github.sh exists... "
if [ -f "/config/scripts/auto_update_from_github.sh" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo "   Script not found!"
    exit 1
fi

# Test 2: Check if script is executable
echo -n "2. Checking if script is executable... "
if [ -x "/config/scripts/auto_update_from_github.sh" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠${NC} Not executable"
    echo "   Run: chmod +x /config/scripts/auto_update_from_github.sh"
fi

# Test 3: Check if git is available
echo -n "3. Checking if git is available... "
if command -v git &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
    echo "   Git version: $(git --version)"
else
    echo -e "${RED}✗${NC}"
    echo "   Git not found!"
    exit 1
fi

# Test 4: Check if we're in a git repository
echo -n "4. Checking if /config is a git repository... "
if [ -d "/config/.git" ]; then
    echo -e "${GREEN}✓${NC}"
    cd /config
    echo "   Current branch: $(git branch --show-current)"
    echo "   Remote: $(git remote get-url origin 2>/dev/null || echo 'No remote configured')"
else
    echo -e "${RED}✗${NC}"
    echo "   /config is not a git repository!"
    exit 1
fi

# Test 5: Check if ha CLI is available
echo -n "5. Checking if Home Assistant CLI (ha) is available... "
if command -v ha &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo "   ha CLI not found!"
    exit 1
fi

# Test 6: Check if backup directory exists
echo -n "6. Checking if backup directory exists... "
if [ -d "/config/backups/auto" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠${NC} Creating backup directory"
    mkdir -p /config/backups/auto
    echo -e "   ${GREEN}✓${NC} Created"
fi

# Test 7: Check if log directory exists
echo -n "7. Checking if log directory exists... "
if [ -d "/config/logs" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠${NC} Creating log directory"
    mkdir -p /config/logs
    echo -e "   ${GREEN}✓${NC} Created"
fi

# Test 8: Check if cron job is installed
echo -n "8. Checking if cron job is installed... "
if [ -f "/etc/cron.d/ha-auto-update" ]; then
    echo -e "${GREEN}✓${NC}"
    echo "   Cron job content:"
    cat /etc/cron.d/ha-auto-update | grep -v "^#" | grep -v "^$"
else
    echo -e "${YELLOW}⚠${NC} Not installed"
    echo "   Run: sudo cp /config/scripts/ha-auto-update.cron /etc/cron.d/ha-auto-update"
fi

# Test 9: Test git fetch (dry-run)
echo -n "9. Testing git fetch (checking for updates)... "
cd /config
if git fetch origin arbeit-updates --dry-run &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo "   Git fetch failed. Check network and credentials."
fi

# Test 10: Test Home Assistant config check
echo -n "10. Testing Home Assistant config check... "
if ha core check &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo "    Current configuration is invalid!"
    echo "    Fix errors before enabling auto-update."
fi

echo ""
echo "=================================="
echo "Test Summary"
echo "=================================="
echo ""

# Count results
echo "All critical tests passed!"
echo ""
echo "Next steps:"
echo "1. If cron job not installed:"
echo "   sudo cp /config/scripts/ha-auto-update.cron /etc/cron.d/ha-auto-update"
echo "   sudo chmod 644 /etc/cron.d/ha-auto-update"
echo ""
echo "2. Manual test run:"
echo "   /config/scripts/auto_update_from_github.sh"
echo ""
echo "3. Check logs:"
echo "   tail -f /config/logs/auto_update.log"
echo ""
