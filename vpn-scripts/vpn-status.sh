#!/bin/bash
################################################################################
# VPN Gateway Status Monitor
#
# Zeigt den Status aller VPN-Komponenten auf einen Blick
#
# Installation:
#   sudo cp vpn-status.sh /usr/local/bin/
#   sudo chmod +x /usr/local/bin/vpn-status.sh
#
# Verwendung:
#   vpn-status.sh
#
# Autor: Claude Code
# Version: 1.0
################################################################################

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Header
echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}   VPN Gateway Status Monitor${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""

# Timestamp
echo -e "${BLUE}Zeit:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# ============================================================================
# WIREGUARD SERVER STATUS (wg0)
# ============================================================================

echo -e "${BLUE}━━━ WireGuard Server (wg0) ━━━${NC}"

# Service Status
if sudo systemctl is-active --quiet wg-quick@wg0; then
    echo -e "  Status: ${GREEN}✓ ONLINE${NC}"
else
    echo -e "  Status: ${RED}✗ OFFLINE${NC}"
    echo -e "  ${YELLOW}Starten mit: sudo systemctl start wg-quick@wg0${NC}"
fi

# Interface Details
if sudo wg show wg0 &>/dev/null; then
    echo -e "  Interface: ${GREEN}wg0${NC}"
    echo -e "  Port: $(sudo wg show wg0 listen-port)"

    # Anzahl aktiver Peers
    PEER_COUNT=$(sudo wg show wg0 peers | wc -l)
    echo -e "  Clients konfiguriert: ${PEER_COUNT}"

    # Peer-Details
    if [ $PEER_COUNT -gt 0 ]; then
        echo ""
        echo -e "  ${BLUE}Verbundene Clients:${NC}"

        PEER_NUM=1
        for peer in $(sudo wg show wg0 peers); do
            echo -e "    ${GREEN}Client ${PEER_NUM}:${NC}"
            echo -e "      Public Key: ${peer:0:16}...${peer: -8}"

            # Letzter Handshake
            HANDSHAKE=$(sudo wg show wg0 latest-handshakes | grep $peer | awk '{print $2}')
            if [ -n "$HANDSHAKE" ] && [ "$HANDSHAKE" != "0" ]; then
                CURRENT_TIME=$(date +%s)
                TIME_DIFF=$((CURRENT_TIME - HANDSHAKE))

                if [ $TIME_DIFF -lt 180 ]; then
                    MINUTES=$((TIME_DIFF / 60))
                    SECONDS=$((TIME_DIFF % 60))
                    echo -e "      Handshake: ${GREEN}vor ${MINUTES}m ${SECONDS}s${NC}"
                else
                    echo -e "      Handshake: ${YELLOW}vor $(($TIME_DIFF / 60))m (inaktiv?)${NC}"
                fi
            else
                echo -e "      Handshake: ${RED}nie (Client nicht verbunden)${NC}"
            fi

            # Transfer
            TRANSFER=$(sudo wg show wg0 transfer | grep $peer)
            if [ -n "$TRANSFER" ]; then
                RX=$(echo $TRANSFER | awk '{print $2}')
                TX=$(echo $TRANSFER | awk '{print $3}')
                RX_MB=$((RX / 1024 / 1024))
                TX_MB=$((TX / 1024 / 1024))
                echo -e "      Traffic: ↓ ${RX_MB} MB / ↑ ${TX_MB} MB"
            fi

            echo ""
            ((PEER_NUM++))
        done
    fi
else
    echo -e "  ${RED}Interface wg0 nicht gefunden!${NC}"
fi

echo ""

# ============================================================================
# WIREGUARD CLIENT STATUS (wg1 - Mullvad)
# ============================================================================

echo -e "${BLUE}━━━ WireGuard Client (wg1 - Mullvad) ━━━${NC}"

# Service Status
if sudo systemctl is-active --quiet wg-quick@wg1; then
    echo -e "  Status: ${GREEN}✓ ONLINE${NC}"
else
    echo -e "  Status: ${RED}✗ OFFLINE${NC}"
    echo -e "  ${YELLOW}Starten mit: sudo systemctl start wg-quick@wg1${NC}"
fi

# Interface Details
if sudo wg show wg1 &>/dev/null; then
    echo -e "  Interface: ${GREEN}wg1${NC}"

    # Mullvad Server
    ENDPOINT=$(sudo wg show wg1 endpoints | awk '{print $2}')
    if [ -n "$ENDPOINT" ]; then
        echo -e "  Server: ${ENDPOINT}"
    fi

    # Letzter Handshake
    HANDSHAKE=$(sudo wg show wg1 latest-handshakes | awk '{print $2}')
    if [ -n "$HANDSHAKE" ] && [ "$HANDSHAKE" != "0" ]; then
        CURRENT_TIME=$(date +%s)
        TIME_DIFF=$((CURRENT_TIME - HANDSHAKE))

        if [ $TIME_DIFF -lt 180 ]; then
            MINUTES=$((TIME_DIFF / 60))
            SECONDS=$((TIME_DIFF % 60))
            echo -e "  Handshake: ${GREEN}vor ${MINUTES}m ${SECONDS}s (aktiv)${NC}"
        else
            echo -e "  Handshake: ${YELLOW}vor $(($TIME_DIFF / 60))m (Verbindungsproblem?)${NC}"
        fi
    else
        echo -e "  Handshake: ${RED}nie (nicht verbunden!)${NC}"
    fi

    # Transfer
    TRANSFER=$(sudo wg show wg1 transfer | tail -1)
    if [ -n "$TRANSFER" ]; then
        RX=$(echo $TRANSFER | awk '{print $2}')
        TX=$(echo $TRANSFER | awk '{print $3}')
        RX_GB=$((RX / 1024 / 1024 / 1024))
        TX_GB=$((TX / 1024 / 1024 / 1024))
        RX_MB=$(( (RX / 1024 / 1024) % 1024 ))
        TX_MB=$(( (TX / 1024 / 1024) % 1024 ))
        echo -e "  Traffic: ↓ ${RX_GB}.${RX_MB} GB / ↑ ${TX_GB}.${TX_MB} GB"
    fi

    # Mullvad IP-Check
    echo ""
    echo -e "  ${BLUE}Mullvad-Verbindungstest:${NC}"
    MULLVAD_CHECK=$(curl -s --max-time 5 https://am.i.mullvad.net/connected)
    if echo "$MULLVAD_CHECK" | grep -q "You are connected to Mullvad"; then
        echo -e "    ${GREEN}✓ Mit Mullvad verbunden${NC}"
        MULLVAD_IP=$(echo "$MULLVAD_CHECK" | grep -oP '\d+\.\d+\.\d+\.\d+')
        echo -e "    IP-Adresse: ${MULLVAD_IP}"
    else
        echo -e "    ${RED}✗ NICHT mit Mullvad verbunden!${NC}"
        echo -e "    ${YELLOW}Prüfe Verbindung oder starte Service neu${NC}"
    fi
else
    echo -e "  ${RED}Interface wg1 nicht gefunden!${NC}"
fi

echo ""

# ============================================================================
# SYSTEM STATUS
# ============================================================================

echo -e "${BLUE}━━━ System-Ressourcen ━━━${NC}"

# IP-Forwarding
IP_FORWARD=$(cat /proc/sys/net/ipv4/ip_forward)
if [ "$IP_FORWARD" = "1" ]; then
    echo -e "  IP-Forwarding: ${GREEN}✓ Aktiviert${NC}"
else
    echo -e "  IP-Forwarding: ${RED}✗ Deaktiviert!${NC}"
    echo -e "  ${YELLOW}Aktivieren mit: echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward${NC}"
fi

# NAT/Masquerading
NAT_RULES=$(sudo iptables -t nat -L POSTROUTING -n | grep -c MASQUERADE)
if [ $NAT_RULES -gt 0 ]; then
    echo -e "  NAT-Regeln: ${GREEN}✓ ${NAT_RULES} Regeln aktiv${NC}"
else
    echo -e "  NAT-Regeln: ${RED}✗ Keine Regeln!${NC}"
    echo -e "  ${YELLOW}Regeln anwenden: sudo /etc/wireguard/gateway-rules.sh${NC}"
fi

# CPU & RAM
echo ""
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
echo -e "  CPU-Auslastung: ${CPU_USAGE}%"

MEM_TOTAL=$(free -m | grep Mem | awk '{print $2}')
MEM_USED=$(free -m | grep Mem | awk '{print $3}')
MEM_PERCENT=$((MEM_USED * 100 / MEM_TOTAL))
echo -e "  RAM-Nutzung: ${MEM_USED} MB / ${MEM_TOTAL} MB (${MEM_PERCENT}%)"

# Temperatur (nur Raspberry Pi)
if command -v vcgencmd &> /dev/null; then
    TEMP=$(vcgencmd measure_temp | cut -d'=' -f2 | cut -d"'" -f1)
    TEMP_INT=${TEMP%.*}
    if [ "$TEMP_INT" -lt 60 ]; then
        echo -e "  Temperatur: ${GREEN}${TEMP}°C (OK)${NC}"
    elif [ "$TEMP_INT" -lt 70 ]; then
        echo -e "  Temperatur: ${YELLOW}${TEMP}°C (warm)${NC}"
    else
        echo -e "  Temperatur: ${RED}${TEMP}°C (HOCH! Kühlung prüfen!)${NC}"
    fi
fi

echo ""

# ============================================================================
# NETZWERK
# ============================================================================

echo -e "${BLUE}━━━ Netzwerk-Info ━━━${NC}"

# IP-Adressen
ETH_IP=$(ip addr show eth0 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d'/' -f1)
WLAN_IP=$(ip addr show wlan0 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d'/' -f1)

if [ -n "$ETH_IP" ]; then
    echo -e "  Ethernet (eth0): ${GREEN}${ETH_IP}${NC}"
elif [ -n "$WLAN_IP" ]; then
    echo -e "  WiFi (wlan0): ${GREEN}${WLAN_IP}${NC}"
else
    echo -e "  ${RED}Keine Netzwerkverbindung!${NC}"
fi

# Default Gateway
DEFAULT_GW=$(ip route | grep default | awk '{print $3}')
if [ -n "$DEFAULT_GW" ]; then
    echo -e "  Default Gateway: ${DEFAULT_GW}"
fi

# DNS
DNS_SERVERS=$(grep nameserver /etc/resolv.conf | awk '{print $2}' | tr '\n' ', ' | sed 's/,$//')
if [ -n "$DNS_SERVERS" ]; then
    echo -e "  DNS-Server: ${DNS_SERVERS}"
fi

echo ""

# ============================================================================
# ZUSAMMENFASSUNG
# ============================================================================

echo -e "${BLUE}━━━ Zusammenfassung ━━━${NC}"

# Gesamtstatus
ERRORS=0

# WireGuard Server
if ! sudo systemctl is-active --quiet wg-quick@wg0; then
    echo -e "  ${RED}✗ WireGuard Server offline${NC}"
    ((ERRORS++))
fi

# WireGuard Client
if ! sudo systemctl is-active --quiet wg-quick@wg1; then
    echo -e "  ${RED}✗ WireGuard Client offline${NC}"
    ((ERRORS++))
fi

# Mullvad-Verbindung
if ! echo "$MULLVAD_CHECK" | grep -q "You are connected to Mullvad"; then
    echo -e "  ${RED}✗ Mullvad nicht verbunden${NC}"
    ((ERRORS++))
fi

# IP-Forwarding
if [ "$IP_FORWARD" != "1" ]; then
    echo -e "  ${RED}✗ IP-Forwarding deaktiviert${NC}"
    ((ERRORS++))
fi

# NAT-Regeln
if [ $NAT_RULES -eq 0 ]; then
    echo -e "  ${RED}✗ NAT-Regeln fehlen${NC}"
    ((ERRORS++))
fi

if [ $ERRORS -eq 0 ]; then
    echo -e "  ${GREEN}✓ Alle Systeme operationsbereit!${NC}"
else
    echo -e "  ${YELLOW}⚠ ${ERRORS} Problem(e) gefunden${NC}"
    echo ""
    echo -e "${YELLOW}Empfohlene Aktionen:${NC}"
    echo -e "  1. Services neu starten: sudo systemctl restart wg-quick@{wg0,wg1}"
    echo -e "  2. Gateway-Regeln anwenden: sudo /etc/wireguard/gateway-rules.sh"
    echo -e "  3. Logs prüfen: sudo journalctl -u wg-quick@wg0 -n 50"
fi

echo ""
echo -e "${BLUE}=================================${NC}"
