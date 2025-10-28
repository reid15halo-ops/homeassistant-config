#!/bin/bash
################################################################################
# VPN Gateway Firewall Rules
#
# Konfiguriert NAT/Masquerading und Split-Routing für VPN-Gateway
#
# Installation:
#   sudo cp gateway-rules.sh /etc/wireguard/gateway-rules.sh
#   sudo chmod +x /etc/wireguard/gateway-rules.sh
#
# Autostart einrichten:
#   sudo crontab -e
#   @reboot /etc/wireguard/gateway-rules.sh
#
# Manuelles Anwenden:
#   sudo /etc/wireguard/gateway-rules.sh
#
# Autor: Claude Code
# Version: 1.0
################################################################################

set -eo pipefail

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================================================
# KONFIGURATION
# ============================================================================

# Netzwerk-Interfaces
LAN_IF="eth0"                   # LAN-Interface (oder wlan0 für WiFi)
VPN_CLIENT_IF="wg1"             # WireGuard Client (Mullvad)
VPN_SERVER_IF="wg0"             # WireGuard Server (für Zugriff von außen)

# Netzwerke
LAN_NET="192.168.178.0/24"      # Heimnetzwerk
VPN_NET="10.10.10.0/24"         # VPN-Netzwerk

# Fritz!Box Gateway
FRITZBOX_IP="192.168.178.1"

# Policy-Routing Tabelle
RT_TABLE_ID=100

# ============================================================================
# LOGGING
# ============================================================================

log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    case $level in
        INFO)
            echo -e "${BLUE}[${timestamp}] [INFO]${NC} ${message}"
            ;;
        SUCCESS)
            echo -e "${GREEN}[${timestamp}] [OK]${NC} ${message}"
            ;;
        WARN)
            echo -e "${YELLOW}[${timestamp}] [WARN]${NC} ${message}"
            ;;
        ERROR)
            echo -e "${RED}[${timestamp}] [ERROR]${NC} ${message}"
            ;;
    esac
}

# ============================================================================
# PRE-FLIGHT CHECKS
# ============================================================================

log INFO "═══════════════════════════════════════════"
log INFO "  VPN Gateway Firewall Rules Setup"
log INFO "═══════════════════════════════════════════"
echo ""

# Root-Check
if [ "$EUID" -ne 0 ]; then
    log ERROR "Bitte als root ausführen (sudo)"
    exit 1
fi

# Interface-Check
for iface in $LAN_IF $VPN_CLIENT_IF $VPN_SERVER_IF; do
    if ! ip link show $iface &>/dev/null; then
        log WARN "Interface $iface nicht gefunden (möglicherweise noch nicht gestartet)"
    fi
done

# ============================================================================
# IP-FORWARDING AKTIVIEREN
# ============================================================================

log INFO "Aktiviere IP-Forwarding..."

# Sofort aktivieren
echo 1 > /proc/sys/net/ipv4/ip_forward

# Persistent machen (falls noch nicht gesetzt)
if ! grep -q "^net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    log SUCCESS "IP-Forwarding persistent konfiguriert"
else
    log SUCCESS "IP-Forwarding bereits persistent"
fi

sysctl -p > /dev/null 2>&1

# Prüfen
if [ "$(cat /proc/sys/net/ipv4/ip_forward)" = "1" ]; then
    log SUCCESS "IP-Forwarding aktiv"
else
    log ERROR "IP-Forwarding konnte nicht aktiviert werden!"
    exit 1
fi

echo ""

# ============================================================================
# FIREWALL-REGELN AUFRÄUMEN (ALTE REGELN ENTFERNEN)
# ============================================================================

log INFO "Entferne alte Firewall-Regeln..."

# Nur VPN-spezifische Regeln löschen (nicht alle!)
iptables -t nat -D POSTROUTING -o $VPN_CLIENT_IF -j MASQUERADE 2>/dev/null || true
iptables -t nat -D POSTROUTING -s $LAN_NET -d $LAN_NET -j ACCEPT 2>/dev/null || true
iptables -D FORWARD -i $LAN_IF -o $VPN_CLIENT_IF -j ACCEPT 2>/dev/null || true
iptables -D FORWARD -i $VPN_CLIENT_IF -o $LAN_IF -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true
iptables -t mangle -D PREROUTING -i $VPN_SERVER_IF -j MARK --set-mark 100 2>/dev/null || true

log SUCCESS "Alte Regeln entfernt"
echo ""

# ============================================================================
# NAT/MASQUERADING FÜR MULLVAD-CLIENT
# ============================================================================

log INFO "Konfiguriere NAT für Mullvad-Client..."

# Ausgehender Traffic über Mullvad → MASQUERADE
iptables -t nat -A POSTROUTING -o $VPN_CLIENT_IF -j MASQUERADE

# Lokaler Traffic (LAN ↔ LAN) direkt, NICHT über VPN
iptables -t nat -I POSTROUTING -s $LAN_NET -d $LAN_NET -j ACCEPT

log SUCCESS "NAT-Regeln konfiguriert"
echo ""

# ============================================================================
# FORWARDING-REGELN
# ============================================================================

log INFO "Konfiguriere Forwarding-Regeln..."

# LAN → Mullvad VPN erlauben
iptables -A FORWARD -i $LAN_IF -o $VPN_CLIENT_IF -j ACCEPT

# Mullvad VPN → LAN (nur established/related)
iptables -A FORWARD -i $VPN_CLIENT_IF -o $LAN_IF -m state --state RELATED,ESTABLISHED -j ACCEPT

log SUCCESS "Forwarding-Regeln konfiguriert"
echo ""

# ============================================================================
# SPLIT-ROUTING (VPN-SERVER TRAFFIC DIREKT)
# ============================================================================

log INFO "Konfiguriere Split-Routing (Policy-Based Routing)..."

# Traffic vom VPN-Server-Interface mit Mark versehen
iptables -t mangle -A PREROUTING -i $VPN_SERVER_IF -j MARK --set-mark 100

# Policy-Routing-Regel: Markierter Traffic nutzt spezielle Routing-Tabelle
ip rule show | grep -q "fwmark 0x64 lookup $RT_TABLE_ID" || \
    ip rule add fwmark 100 lookup $RT_TABLE_ID

# Routing-Tabelle: Markierter Traffic geht direkt über Fritz!Box (NICHT über Mullvad)
ip route show table $RT_TABLE_ID | grep -q "default via $FRITZBOX_IP" || \
    ip route add default via $FRITZBOX_IP table $RT_TABLE_ID

log SUCCESS "Split-Routing konfiguriert"
log INFO "  VPN-Server-Traffic (wg0) → Direkt über Fritz!Box"
log INFO "  Anderer Traffic → Über Mullvad (wg1)"
echo ""

# ============================================================================
# OPTIONAL: LOGGING FÜR DEBUGGING
# ============================================================================

# Uncomment für detailliertes Firewall-Logging
# log INFO "Aktiviere Firewall-Logging..."
# iptables -A FORWARD -j LOG --log-prefix "VPN-Gateway: " --log-level 4
# log SUCCESS "Firewall-Logging aktiviert (siehe: dmesg | grep VPN-Gateway)"
# echo ""

# ============================================================================
# ZUSAMMENFASSUNG & VALIDIERUNG
# ============================================================================

log INFO "═══════════════════════════════════════════"
log INFO "  Firewall-Regeln erfolgreich angewendet!"
log INFO "═══════════════════════════════════════════"
echo ""

log INFO "Konfiguration:"
echo "  ├─ LAN-Interface: $LAN_IF"
echo "  ├─ VPN-Client: $VPN_CLIENT_IF (Mullvad)"
echo "  ├─ VPN-Server: $VPN_SERVER_IF (für Zugriff von außen)"
echo "  ├─ LAN-Netzwerk: $LAN_NET"
echo "  └─ Fritz!Box Gateway: $FRITZBOX_IP"
echo ""

log INFO "Aktive Regeln:"
NAT_RULES=$(iptables -t nat -L POSTROUTING -n | grep -c MASQUERADE)
FORWARD_RULES=$(iptables -L FORWARD -n | grep -c ACCEPT)
MANGLE_RULES=$(iptables -t mangle -L PREROUTING -n | grep -c MARK)

echo "  ├─ NAT-Regeln: $NAT_RULES"
echo "  ├─ Forward-Regeln: $FORWARD_RULES"
echo "  └─ Mangle-Regeln: $MANGLE_RULES"
echo ""

# ============================================================================
# VALIDIERUNG
# ============================================================================

log INFO "Validiere Konfiguration..."

ERRORS=0

# Check 1: IP-Forwarding
if [ "$(cat /proc/sys/net/ipv4/ip_forward)" != "1" ]; then
    log ERROR "IP-Forwarding nicht aktiv!"
    ((ERRORS++))
fi

# Check 2: NAT-Regeln
if [ $NAT_RULES -eq 0 ]; then
    log ERROR "Keine NAT-Regeln gefunden!"
    ((ERRORS++))
fi

# Check 3: Forward-Regeln
if [ $FORWARD_RULES -eq 0 ]; then
    log ERROR "Keine Forward-Regeln gefunden!"
    ((ERRORS++))
fi

# Check 4: Policy-Routing
if ! ip rule show | grep -q "fwmark 0x64"; then
    log ERROR "Policy-Routing-Regel fehlt!"
    ((ERRORS++))
fi

# Check 5: Routing-Tabelle
if ! ip route show table $RT_TABLE_ID | grep -q "default"; then
    log ERROR "Routing-Tabelle $RT_TABLE_ID nicht konfiguriert!"
    ((ERRORS++))
fi

if [ $ERRORS -eq 0 ]; then
    log SUCCESS "Alle Checks bestanden!"
    log SUCCESS "Gateway ist betriebsbereit."
else
    log ERROR "$ERRORS Fehler gefunden! Prüfe Konfiguration."
    exit 1
fi

echo ""
log INFO "═══════════════════════════════════════════"
log INFO "  Nächste Schritte:"
log INFO "═══════════════════════════════════════════"
echo ""
echo "1. Fritz!Box konfigurieren:"
echo "   → Heimnetz → Netzwerk → Netzwerkeinstellungen"
echo "   → Gateway auf 192.168.178.2 setzen"
echo ""
echo "2. Testen:"
echo "   → Auf Client-PC: curl https://am.i.mullvad.net/connected"
echo "   → Sollte: 'You are connected to Mullvad' zeigen"
echo ""
echo "3. Monitoring:"
echo "   → sudo iptables -t nat -L -n -v"
echo "   → sudo wg show"
echo ""
log INFO "═══════════════════════════════════════════"
