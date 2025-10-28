#!/bin/bash
################################################################################
# VPN Add Client Helper Script
#
# Automatisiert das Hinzufügen neuer WireGuard-Clients
#
# Installation:
#   sudo cp vpn-add-client.sh /usr/local/bin/
#   sudo chmod +x /usr/local/bin/vpn-add-client.sh
#
# Verwendung:
#   sudo vpn-add-client.sh <client-name> <client-ip>
#   Beispiel: sudo vpn-add-client.sh tablet 10.10.10.4
#
# Autor: Claude Code
# Version: 1.0
################################################################################

set -euo pipefail

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Konfiguration
KEYS_DIR="/etc/wireguard/keys"
SERVER_CONFIG="/etc/wireguard/wg0.conf"
CONFIGS_DIR="/etc/wireguard/clients"
DYNDNS_DOMAIN=""  # Wird automatisch aus Server-Config gelesen

# Root-Check
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Fehler: Bitte als root ausführen (sudo)${NC}"
    exit 1
fi

# ============================================================================
# FUNKTIONEN
# ============================================================================

print_usage() {
    echo "Usage: $0 <client-name> <client-ip>"
    echo ""
    echo "Beispiele:"
    echo "  $0 handy 10.10.10.2"
    echo "  $0 laptop 10.10.10.3"
    echo "  $0 tablet 10.10.10.4"
    echo ""
    echo "IP-Adresse-Schema:"
    echo "  10.10.10.1  - Server (Gateway)"
    echo "  10.10.10.2  - Handy"
    echo "  10.10.10.3  - Laptop"
    echo "  10.10.10.4+ - Weitere Clients"
}

generate_keys() {
    local client_name=$1
    local private_key_file="${KEYS_DIR}/${client_name}_private.key"
    local public_key_file="${KEYS_DIR}/${client_name}_public.key"

    echo -e "${BLUE}Generiere Keys für Client '${client_name}'...${NC}"

    # Keys generieren
    wg genkey | tee "$private_key_file" | wg pubkey > "$public_key_file"
    chmod 600 "$private_key_file"

    echo -e "${GREEN}✓ Keys generiert${NC}"
    echo -e "  Private Key: ${private_key_file}"
    echo -e "  Public Key: ${public_key_file}"
}

add_peer_to_server() {
    local client_name=$1
    local client_ip=$2
    local public_key=$(cat "${KEYS_DIR}/${client_name}_public.key")

    echo -e "${BLUE}Füge Peer zur Server-Config hinzu...${NC}"

    # Prüfe ob Peer bereits existiert
    if grep -q "$public_key" "$SERVER_CONFIG"; then
        echo -e "${YELLOW}⚠ Peer existiert bereits in Server-Config${NC}"
        return 1
    fi

    # Füge Peer-Block hinzu
    cat >> "$SERVER_CONFIG" <<EOF

# Client: ${client_name}
[Peer]
PublicKey = ${public_key}
AllowedIPs = ${client_ip}/32
EOF

    echo -e "${GREEN}✓ Peer zur Server-Config hinzugefügt${NC}"
}

create_client_config() {
    local client_name=$1
    local client_ip=$2
    local private_key=$(cat "${KEYS_DIR}/${client_name}_private.key")
    local server_public_key=$(cat "${KEYS_DIR}/server_public.key")

    # Erstelle Configs-Verzeichnis falls nicht vorhanden
    mkdir -p "$CONFIGS_DIR"

    local config_file="${CONFIGS_DIR}/${client_name}.conf"

    echo -e "${BLUE}Erstelle Client-Config: ${config_file}${NC}"

    # DynDNS-Domain automatisch ermitteln (falls nicht gesetzt)
    if [ -z "$DYNDNS_DOMAIN" ]; then
        echo -e "${YELLOW}⚠ DynDNS-Domain nicht konfiguriert${NC}"
        read -p "Bitte DynDNS-Domain oder öffentliche IP eingeben (z.B. meinheim.myfritz.net): " DYNDNS_DOMAIN
    fi

    # Client-Config erstellen
    cat > "$config_file" <<EOF
[Interface]
# Client: ${client_name}
PrivateKey = ${private_key}
Address = ${client_ip}/24
DNS = 192.168.178.1

[Peer]
# VPN-Server
PublicKey = ${server_public_key}
Endpoint = ${DYNDNS_DOMAIN}:51820
AllowedIPs = 192.168.178.0/24, 10.10.10.0/24
PersistentKeepalive = 25
EOF

    chmod 600 "$config_file"

    echo -e "${GREEN}✓ Client-Config erstellt: ${config_file}${NC}"
}

reload_server() {
    echo -e "${BLUE}Lade WireGuard Server-Config neu...${NC}"

    # Reload ohne Verbindungsabbruch
    wg syncconf wg0 <(wg-quick strip wg0)

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Server-Config erfolgreich neu geladen${NC}"
    else
        echo -e "${RED}✗ Fehler beim Neuladen der Config${NC}"
        echo -e "${YELLOW}Alternativer Neustart: systemctl restart wg-quick@wg0${NC}"
        return 1
    fi
}

generate_qr_code() {
    local client_name=$1
    local config_file="${CONFIGS_DIR}/${client_name}.conf"

    if ! command -v qrencode &> /dev/null; then
        echo -e "${YELLOW}⚠ qrencode nicht installiert, QR-Code kann nicht erstellt werden${NC}"
        echo -e "${YELLOW}  Installation: apt install qrencode${NC}"
        return 1
    fi

    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}QR-Code für Client '${client_name}':${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    qrencode -t ansiutf8 < "$config_file"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_summary() {
    local client_name=$1
    local client_ip=$2

    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}   Client '${client_name}' erfolgreich hinzugefügt!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BLUE}Client-Informationen:${NC}"
    echo -e "  Name: ${client_name}"
    echo -e "  IP-Adresse: ${client_ip}"
    echo -e "  Config-Datei: ${CONFIGS_DIR}/${client_name}.conf"
    echo -e "  Private Key: ${KEYS_DIR}/${client_name}_private.key"
    echo -e "  Public Key: ${KEYS_DIR}/${client_name}_public.key"
    echo ""
    echo -e "${BLUE}Nächste Schritte:${NC}"
    echo ""
    echo -e "${YELLOW}Mobile Geräte (Handy/Tablet):${NC}"
    echo -e "  1. WireGuard App installieren (Android/iOS App Store)"
    echo -e "  2. QR-Code (siehe oben) in der App scannen"
    echo -e "  3. VPN aktivieren und testen"
    echo ""
    echo -e "${YELLOW}Computer (Windows/Mac/Linux):${NC}"
    echo -e "  1. Config-Datei runterladen:"
    echo -e "     scp pi@192.168.178.2:${CONFIGS_DIR}/${client_name}.conf ~/Desktop/"
    echo -e "  2. In WireGuard App importieren"
    echo -e "  3. VPN aktivieren und testen"
    echo ""
    echo -e "${YELLOW}Test:${NC}"
    echo -e "  1. VPN aktivieren"
    echo -e "  2. Browser: http://192.168.178.71:8123 (Home Assistant)"
    echo -e "  3. Sollte funktionieren = Erfolg!"
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# ============================================================================
# HAUPTPROGRAMM
# ============================================================================

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   VPN Add Client Helper${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Parameter prüfen
if [ $# -ne 2 ]; then
    print_usage
    exit 1
fi

CLIENT_NAME=$1
CLIENT_IP=$2

# Validierung Client-Name
if [[ ! $CLIENT_NAME =~ ^[a-z0-9_-]+$ ]]; then
    echo -e "${RED}Fehler: Client-Name darf nur Kleinbuchstaben, Zahlen, - und _ enthalten${NC}"
    exit 1
fi

# Validierung IP-Adresse
if [[ ! $CLIENT_IP =~ ^10\.10\.10\.[0-9]{1,3}$ ]]; then
    echo -e "${RED}Fehler: IP-Adresse muss im Format 10.10.10.X sein (X = 2-254)${NC}"
    exit 1
fi

# IP-Range prüfen
IP_LAST_OCTET=$(echo $CLIENT_IP | cut -d'.' -f4)
if [ $IP_LAST_OCTET -lt 2 ] || [ $IP_LAST_OCTET -gt 254 ]; then
    echo -e "${RED}Fehler: Letzte IP-Ziffer muss zwischen 2 und 254 liegen${NC}"
    exit 1
fi

# Prüfe ob IP bereits verwendet wird
if grep -q "$CLIENT_IP/32" "$SERVER_CONFIG"; then
    echo -e "${RED}Fehler: IP-Adresse ${CLIENT_IP} bereits in Verwendung!${NC}"
    echo -e "${YELLOW}Wähle eine andere IP oder prüfe Server-Config: ${SERVER_CONFIG}${NC}"
    exit 1
fi

# Bestätigung
echo -e "${YELLOW}Neuer Client:${NC}"
echo -e "  Name: ${CLIENT_NAME}"
echo -e "  IP: ${CLIENT_IP}"
echo ""
read -p "Fortfahren? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Abgebrochen.${NC}"
    exit 0
fi

# Schritt 1: Keys generieren
generate_keys "$CLIENT_NAME"
echo ""

# Schritt 2: Peer zur Server-Config hinzufügen
add_peer_to_server "$CLIENT_NAME" "$CLIENT_IP"
echo ""

# Schritt 3: Client-Config erstellen
create_client_config "$CLIENT_NAME" "$CLIENT_IP"
echo ""

# Schritt 4: Server neu laden
reload_server
echo ""

# Schritt 5: QR-Code generieren
generate_qr_code "$CLIENT_NAME"

# Schritt 6: Zusammenfassung
print_summary "$CLIENT_NAME" "$CLIENT_IP"
