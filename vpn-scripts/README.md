# VPN Gateway Scripts

Dieser Ordner enthält Automatisierungs- und Hilfs-Scripts für das VPN-Gateway.

---

## 📁 Verfügbare Scripts

### 1. `vpn-status.sh` ⭐
**Zweck:** Umfassender Status-Monitor für alle VPN-Komponenten

**Zeigt an:**
- WireGuard Server-Status (wg0)
- WireGuard Client-Status (wg1 - Mullvad)
- Verbundene Clients mit Handshake-Zeiten
- System-Ressourcen (CPU, RAM, Temperatur)
- Netzwerk-Konfiguration
- NAT/Firewall-Regeln
- Fehlerdiagnose

**Installation:**
```bash
sudo cp vpn-status.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/vpn-status.sh
```

**Verwendung:**
```bash
vpn-status.sh
```

**Beispiel-Output:**
```
=================================
   VPN Gateway Status Monitor
=================================

━━━ WireGuard Server (wg0) ━━━
  Status: ✓ ONLINE
  Interface: wg0
  Port: 51820
  Clients konfiguriert: 2

  Verbundene Clients:
    Client 1:
      Public Key: aB3xY9mN2pQ...
      Handshake: vor 1m 23s
      Traffic: ↓ 124 MB / ↑ 89 MB

━━━ WireGuard Client (wg1 - Mullvad) ━━━
  Status: ✓ ONLINE
  Server: de-fra.mullvad.net:51820
  Handshake: vor 0m 45s (aktiv)

  Mullvad-Verbindungstest:
    ✓ Mit Mullvad verbunden
    IP-Adresse: 185.x.x.x

━━━ Zusammenfassung ━━━
  ✓ Alle Systeme operationsbereit!
```

---

### 2. `vpn-add-client.sh`
**Zweck:** Automatisiertes Hinzufügen neuer VPN-Clients

**Funktionen:**
- Keys automatisch generieren
- Server-Config aktualisieren
- Client-Config erstellen
- QR-Code generieren (für mobile Geräte)
- Server ohne Disconnect neu laden

**Installation:**
```bash
sudo cp vpn-add-client.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/vpn-add-client.sh
```

**Verwendung:**
```bash
sudo vpn-add-client.sh <client-name> <client-ip>
```

**Beispiele:**
```bash
# Handy hinzufügen
sudo vpn-add-client.sh handy 10.10.10.2

# Laptop hinzufügen
sudo vpn-add-client.sh laptop 10.10.10.3

# Tablet hinzufügen
sudo vpn-add-client.sh tablet 10.10.10.4
```

**Ablauf:**
1. Keys generieren (automatisch)
2. Server-Config aktualisieren
3. Client-Config erstellen
4. QR-Code anzeigen
5. Server neu laden (ohne Disconnect)

**Output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   VPN Add Client Helper
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Neuer Client:
  Name: tablet
  IP: 10.10.10.4

Fortfahren? (y/n) y

✓ Keys generiert
✓ Peer zur Server-Config hinzugefügt
✓ Client-Config erstellt: /etc/wireguard/clients/tablet.conf
✓ Server-Config erfolgreich neu geladen

[QR-Code wird angezeigt]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Client 'tablet' erfolgreich hinzugefügt!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### 3. `gateway-rules.sh`
**Zweck:** Firewall-Regeln und Routing für VPN-Gateway konfigurieren

**Funktionen:**
- IP-Forwarding aktivieren (persistent)
- NAT/Masquerading für Mullvad-Traffic
- Split-Routing (VPN-Server direkt, Rest über Mullvad)
- Policy-Based Routing
- Validierung der Konfiguration

**Installation:**
```bash
sudo cp gateway-rules.sh /etc/wireguard/gateway-rules.sh
sudo chmod +x /etc/wireguard/gateway-rules.sh
```

**Autostart einrichten:**
```bash
sudo crontab -e
# Diese Zeile hinzufügen:
@reboot /etc/wireguard/gateway-rules.sh
```

**Manuelle Verwendung:**
```bash
sudo /etc/wireguard/gateway-rules.sh
```

**Was macht es:**
1. **IP-Forwarding:** Aktiviert Weiterleitung zwischen Interfaces
2. **NAT:** Übersetzt LAN-Adressen für VPN-Traffic
3. **Split-Routing:**
   - VPN-Server-Traffic (wg0) → Direkt über Fritz!Box
   - Anderer Traffic → Über Mullvad (wg1)
4. **Validierung:** Prüft ob alle Regeln korrekt angewendet wurden

**Output:**
```
═══════════════════════════════════════════
  VPN Gateway Firewall Rules Setup
═══════════════════════════════════════════

[INFO] Aktiviere IP-Forwarding...
[OK] IP-Forwarding aktiv

[INFO] Konfiguriere NAT für Mullvad-Client...
[OK] NAT-Regeln konfiguriert

[INFO] Konfiguriere Split-Routing...
[OK] Split-Routing konfiguriert
  VPN-Server-Traffic (wg0) → Direkt über Fritz!Box
  Anderer Traffic → Über Mullvad (wg1)

═══════════════════════════════════════════
  Firewall-Regeln erfolgreich angewendet!
═══════════════════════════════════════════

[OK] Alle Checks bestanden!
[OK] Gateway ist betriebsbereit.
```

---

## 🚀 Schnellstart

### Nach der Erst-Installation:

```bash
# 1. Alle Scripts auf Gateway Pi kopieren
scp *.sh pi@192.168.178.2:~/

# 2. Auf Gateway Pi einloggen
ssh pi@192.168.178.2

# 3. vpn-status.sh installieren
sudo cp vpn-status.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/vpn-status.sh

# 4. vpn-add-client.sh installieren
sudo cp vpn-add-client.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/vpn-add-client.sh

# 5. gateway-rules.sh installieren
sudo cp gateway-rules.sh /etc/wireguard/
sudo chmod +x /etc/wireguard/gateway-rules.sh

# 6. Gateway-Regeln anwenden
sudo /etc/wireguard/gateway-rules.sh

# 7. Autostart einrichten
sudo crontab -e
# Hinzufügen: @reboot /etc/wireguard/gateway-rules.sh

# 8. Status prüfen
vpn-status.sh
```

---

## 📋 Tägliche Verwendung

### Status prüfen
```bash
vpn-status.sh
```

### Neuen Client hinzufügen
```bash
sudo vpn-add-client.sh mein-neues-geraet 10.10.10.5
```

### Gateway-Regeln neu anwenden
```bash
sudo /etc/wireguard/gateway-rules.sh
```

### Logs anschauen
```bash
# Server-Logs
sudo journalctl -u wg-quick@wg0 -f

# Client-Logs
sudo journalctl -u wg-quick@wg1 -f
```

---

## 🔧 Anpassung

### gateway-rules.sh anpassen

Öffne `/etc/wireguard/gateway-rules.sh` und ändere folgende Variablen:

```bash
# Netzwerk-Interfaces
LAN_IF="eth0"                   # Ändere zu "wlan0" falls WiFi
VPN_CLIENT_IF="wg1"             # WireGuard Client
VPN_SERVER_IF="wg0"             # WireGuard Server

# Netzwerke
LAN_NET="192.168.178.0/24"      # Dein Heimnetzwerk
VPN_NET="10.10.10.0/24"         # VPN-Netzwerk

# Fritz!Box Gateway
FRITZBOX_IP="192.168.178.1"     # Deine Router-IP
```

### vpn-add-client.sh anpassen

Öffne `/usr/local/bin/vpn-add-client.sh` und setze:

```bash
# DynDNS-Domain voreinstellen (optional)
DYNDNS_DOMAIN="meinheim.myfritz.net"  # Deine DynDNS-Domain
```

---

## 🆘 Troubleshooting

### Problem: "Permission denied" beim Ausführen

**Lösung:**
```bash
# Scripts ausführbar machen
chmod +x vpn-status.sh
chmod +x vpn-add-client.sh
chmod +x gateway-rules.sh

# Oder mit sudo wenn nötig
sudo chmod +x /usr/local/bin/vpn-status.sh
```

### Problem: "Command not found"

**Lösung:**
```bash
# Entweder mit vollem Pfad aufrufen:
/usr/local/bin/vpn-status.sh

# Oder ins aktuelle Verzeichnis wechseln:
cd ~/
./vpn-status.sh

# Oder Script nach /usr/local/bin/ kopieren:
sudo cp vpn-status.sh /usr/local/bin/
```

### Problem: gateway-rules.sh funktioniert nicht nach Reboot

**Lösung:**
```bash
# Prüfe Crontab:
sudo crontab -l
# Sollte enthalten: @reboot /etc/wireguard/gateway-rules.sh

# Falls nicht, hinzufügen:
sudo crontab -e
# Zeile hinzufügen: @reboot /etc/wireguard/gateway-rules.sh

# Alternative: Systemd-Service erstellen
sudo nano /etc/systemd/system/vpn-gateway-rules.service

# Inhalt:
[Unit]
Description=VPN Gateway Firewall Rules
After=network-online.target wg-quick@wg0.service wg-quick@wg1.service

[Service]
Type=oneshot
ExecStart=/etc/wireguard/gateway-rules.sh

[Install]
WantedBy=multi-user.target

# Aktivieren:
sudo systemctl enable vpn-gateway-rules.service
```

### Problem: vpn-add-client.sh findet Keys nicht

**Lösung:**
```bash
# Prüfe ob Keys-Verzeichnis existiert:
ls -la /etc/wireguard/keys/

# Falls nicht, erstellen:
sudo mkdir -p /etc/wireguard/keys

# Server-Keys sollten vorhanden sein:
sudo ls /etc/wireguard/keys/server_*
# Sollte zeigen: server_private.key, server_public.key
```

---

## 📞 Weitere Hilfe

**Siehe auch:**
- `VPN_SETUP_CHECKLIST.md` - Vollständige Installationsanleitung
- `VPN_QUICK_REFERENCE.md` - Wichtigste Befehle
- `VPN_OPTION_A_HARDWARE.md` - Hardware-Setup-Guide

**Bei Problemen:**
1. Status prüfen: `vpn-status.sh`
2. Logs anschauen: `sudo journalctl -u wg-quick@wg0 -xe`
3. Gateway-Regeln neu anwenden: `sudo /etc/wireguard/gateway-rules.sh`
4. Services neu starten: `sudo systemctl restart wg-quick@{wg0,wg1}`

---

**Script-Version:** 1.0 (2025-01-28)
