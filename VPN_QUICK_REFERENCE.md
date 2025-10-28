# 🚀 VPN-Gateway Quick Reference

**Schnellzugriff für die wichtigsten Befehle und Troubleshooting**

---

## 📍 Verbindung zum Gateway

```bash
# SSH-Verbindung
ssh pi@192.168.178.2

# Alternative (via Hostname)
ssh pi@vpngateway.local
```

---

## 📊 Status-Checks

### WireGuard Status

```bash
# Alle WireGuard-Interfaces anzeigen
sudo wg show

# Nur Server (wg0)
sudo wg show wg0

# Nur Client/Mullvad (wg1)
sudo wg show wg1

# Mit Details (Transfer, Latest Handshake)
sudo wg show all transfer
sudo wg show all latest-handshakes
```

**Erwartete Ausgabe:**
```
interface: wg0
  public key: AbC...123
  private key: (hidden)
  listening port: 51820

peer: XyZ...789
  endpoint: 1.2.3.4:12345
  allowed ips: 10.10.10.2/32
  latest handshake: 1 minute, 23 seconds ago  ← Sollte < 3 Minuten sein!
  transfer: 1.25 MiB received, 890.12 KiB sent
```

---

### Systemd Services

```bash
# Service-Status prüfen
sudo systemctl status wg-quick@wg0  # Server
sudo systemctl status wg-quick@wg1  # Client

# Kurz-Status (nur Active/Inactive)
sudo systemctl is-active wg-quick@wg0
sudo systemctl is-active wg-quick@wg1
```

---

### IP & Routing

```bash
# Aktuelle IP-Adressen
ip addr show

# Routing-Tabelle
ip route show

# Policy-Routing (für Split-Tunnel)
ip rule show
ip route show table 100

# IP-Forwarding prüfen (sollte "1" sein)
cat /proc/sys/net/ipv4/ip_forward
```

---

### Mullvad-Verbindung testen

```bash
# Einfacher Check
curl https://am.i.mullvad.net/connected

# Erwartete Ausgabe:
# You are connected to Mullvad (server de-fra). Your IP address is X.X.X.X

# Alternative IP-Checks
curl https://ipinfo.io/ip
curl https://ifconfig.me
```

---

## 🔧 Service-Management

### Services starten/stoppen

```bash
# Starten
sudo systemctl start wg-quick@wg0   # Server
sudo systemctl start wg-quick@wg1   # Client

# Stoppen
sudo systemctl stop wg-quick@wg0
sudo systemctl stop wg-quick@wg1

# Neu starten
sudo systemctl restart wg-quick@wg0
sudo systemctl restart wg-quick@wg1

# Status prüfen
sudo systemctl status wg-quick@wg0
```

---

### Autostart aktivieren/deaktivieren

```bash
# Autostart aktivieren
sudo systemctl enable wg-quick@wg0
sudo systemctl enable wg-quick@wg1

# Autostart deaktivieren
sudo systemctl disable wg-quick@wg0
sudo systemctl disable wg-quick@wg1

# Prüfen ob Autostart aktiv
sudo systemctl is-enabled wg-quick@wg0
```

---

## 📝 Logs anschauen

### Systemd Journal (empfohlen)

```bash
# Live-Logs (folgt neuen Einträgen)
sudo journalctl -u wg-quick@wg0 -f  # Server
sudo journalctl -u wg-quick@wg1 -f  # Client

# Letzte 50 Zeilen
sudo journalctl -u wg-quick@wg0 -n 50
sudo journalctl -u wg-quick@wg1 -n 50

# Logs seit heute 00:00 Uhr
sudo journalctl -u wg-quick@wg0 --since today

# Logs seit gestern
sudo journalctl -u wg-quick@wg0 --since yesterday

# Bestimmter Zeitraum
sudo journalctl -u wg-quick@wg0 --since "2025-01-15 10:00" --until "2025-01-15 12:00"
```

---

### Firewall / iptables Logs

```bash
# Kernel-Logs (Firewall-Drops, etc.)
sudo dmesg | tail -50

# Live Kernel-Logs
sudo dmesg -w

# iptables-Regeln anzeigen
sudo iptables -L -n -v
sudo iptables -t nat -L -n -v
sudo iptables -t mangle -L -n -v
```

---

## 🛠️ Troubleshooting

### Problem: Kein Zugriff von außen (VPN-Server)

```bash
# 1. Service läuft?
sudo systemctl status wg-quick@wg0

# 2. Port offen?
sudo netstat -tulpn | grep 51820
# Sollte zeigen: udp ... :51820 ... LISTEN

# 3. Firewall-Regeln korrekt?
sudo iptables -t nat -L POSTROUTING -n -v | grep MASQUERADE

# 4. Client-Key in Server-Config?
sudo wg show wg0 | grep peer

# 5. Fritz!Box Port-Forwarding prüfen!
# http://fritz.box → Internet → Freigaben → Portfreigaben
```

**Test von außen:**
```bash
# Auf externem Gerät (mit Mobile-Daten):
nc -u -v <DEINE_DYNDNS_DOMAIN> 51820
# Sollte "Connected" zeigen
```

---

### Problem: Kein Internet über Mullvad

```bash
# 1. Service läuft?
sudo systemctl status wg-quick@wg1

# 2. Handshake aktiv? (< 3 Minuten)
sudo wg show wg1 | grep "latest handshake"

# 3. Verbindung testen
curl https://am.i.mullvad.net/connected

# 4. DNS-Auflösung funktioniert?
nslookup google.com 10.64.0.1

# 5. Mullvad-Server erreichbar?
ping -c 3 de-fra.mullvad.net

# 6. Service neu starten
sudo systemctl restart wg-quick@wg1
```

---

### Problem: Split-Routing funktioniert nicht

```bash
# 1. Routing-Regeln prüfen
ip rule show
# Sollte enthalten: "from all fwmark 0x64 lookup 100"

ip route show table 100
# Sollte Default-Route über Fritz!Box zeigen: default via 192.168.178.1

# 2. Mangle-Regeln prüfen
sudo iptables -t mangle -L PREROUTING -n -v
# Sollte Mark-Regel für wg0 zeigen

# 3. Gateway-Regeln neu anwenden
sudo /etc/wireguard/gateway-rules.sh

# 4. Test: VPN-Server-Traffic darf NICHT über Mullvad
# Handy über VPN verbinden, dann auf Gateway:
sudo tcpdump -i wg1 port 51820 -n
# Sollte KEINEN Traffic zeigen!
```

---

### Problem: Keine Geräte nutzen das Gateway

```bash
# 1. Fritz!Box Gateway-Einstellung prüfen
# http://fritz.box → Heimnetz → Netzwerk → Netzwerkeinstellungen
# → "Anderer Standard-Gateway" sollte 192.168.178.2 sein

# 2. IP-Forwarding aktiv?
cat /proc/sys/net/ipv4/ip_forward
# Sollte "1" sein

# 3. NAT-Regeln aktiv?
sudo iptables -t nat -L POSTROUTING -n -v | grep MASQUERADE

# 4. Test von Client-PC:
traceroute 8.8.8.8
# Erster Hop sollte 192.168.178.2 sein!

# 5. Gateway-Regeln neu anwenden
sudo /etc/wireguard/gateway-rules.sh
```

---

### Problem: Performance zu langsam

```bash
# 1. CPU-Last prüfen
top
# WireGuard-Prozesse sollten < 50% CPU sein

# 2. RAM-Nutzung
free -h

# 3. Netzwerk-Statistiken
sudo wg show all transfer

# 4. MTU optimieren (falls Probleme)
sudo ip link set mtu 1420 dev wg1

# 5. Temperatur prüfen (Raspberry Pi)
vcgencmd measure_temp
# Sollte < 70°C sein

# 6. Falls Überhitzung: Lüfter/Kühlkörper nötig!
```

---

## 🔑 Config-Verwaltung

### Neue Client-Config erstellen

```bash
# 1. Keys generieren
cd /etc/wireguard/keys
wg genkey | sudo tee client_new_private.key | wg pubkey | sudo tee client_new_public.key

# 2. Public Key anzeigen
sudo cat client_new_public.key

# 3. In Server-Config eintragen
sudo nano /etc/wireguard/wg0.conf
# Neuen [Peer]-Block hinzufügen:
# [Peer]
# PublicKey = <NEW_CLIENT_PUBLIC_KEY>
# AllowedIPs = 10.10.10.5/32

# 4. Server neu laden (OHNE Disconnect!)
sudo wg syncconf wg0 <(wg-quick strip wg0)

# 5. Client-Config erstellen
sudo nano /etc/wireguard/client_new.conf
# (Template siehe unten)

# 6. QR-Code generieren
qrencode -t ansiutf8 < /etc/wireguard/client_new.conf
```

**Client-Config-Template:**
```ini
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.10.10.X/24
DNS = 192.168.178.1

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
Endpoint = <DEINE_DYNDNS_DOMAIN>:51820
AllowedIPs = 192.168.178.0/24, 10.10.10.0/24
PersistentKeepalive = 25
```

---

### Client entfernen

```bash
# 1. Server-Config öffnen
sudo nano /etc/wireguard/wg0.conf

# 2. Entsprechenden [Peer]-Block löschen

# 3. Server neu laden
sudo wg syncconf wg0 <(wg-quick strip wg0)

# 4. Prüfen
sudo wg show wg0
# Client sollte nicht mehr gelistet sein
```

---

## 🔒 Sicherheit

### Firewall-Regeln anzeigen

```bash
# NAT-Tabelle
sudo iptables -t nat -L -n -v

# Filter-Tabelle
sudo iptables -L -n -v

# Mangle-Tabelle
sudo iptables -t mangle -L -n -v

# Alle Regeln speichern (Backup)
sudo iptables-save > ~/iptables-backup-$(date +%Y%m%d).txt
```

---

### Keys rotieren (für Paranoia)

**Server-Keys:**
```bash
cd /etc/wireguard/keys
wg genkey | sudo tee server_private_new.key | wg pubkey | sudo tee server_public_new.key

# In /etc/wireguard/wg0.conf eintragen
sudo nano /etc/wireguard/wg0.conf
# PrivateKey = <SERVER_PRIVATE_NEW_KEY>

# Alle Client-Configs müssen angepasst werden!
# PublicKey in [Peer]-Sektion → neuer Server Public Key

sudo systemctl restart wg-quick@wg0
```

---

## 📈 Monitoring-Script

Speichern als `/usr/local/bin/vpn-status.sh`:

```bash
#!/bin/bash
echo "=== VPN Gateway Status ==="
echo ""
echo "VPN-Server (wg0):"
sudo systemctl is-active wg-quick@wg0 || echo "OFFLINE!"
sudo wg show wg0 | grep -E "interface|peer|latest"
echo ""
echo "VPN-Client (wg1):"
sudo systemctl is-active wg-quick@wg1 || echo "OFFLINE!"
sudo wg show wg1 | grep -E "interface|peer|latest"
echo ""
echo "Mullvad-Verbindung:"
curl -s https://am.i.mullvad.net/connected
echo ""
echo "Aktive NAT-Regeln:"
sudo iptables -t nat -L POSTROUTING -n -v | grep -c MASQUERADE
echo ""
echo "CPU/RAM:"
top -bn1 | grep "Cpu(s)" | awk '{print "CPU: " $2}'
free -h | grep Mem | awk '{print "RAM: " $3 " / " $2}'
echo ""
echo "Temperatur:"
vcgencmd measure_temp
```

**Ausführbar machen:**
```bash
sudo chmod +x /usr/local/bin/vpn-status.sh

# Aufrufen mit:
vpn-status.sh
```

---

## 🔄 Backup & Restore

### Backup erstellen

```bash
# Alle WireGuard-Configs sichern
sudo tar -czf ~/vpn-backup-$(date +%Y%m%d).tar.gz \
  /etc/wireguard/ \
  /etc/sysctl.conf \
  /etc/crontab

# Backup runterladen (vom PC aus):
scp pi@192.168.178.2:~/vpn-backup-*.tar.gz ~/Desktop/
```

---

### Restore

```bash
# Backup hochladen (vom PC aus):
scp ~/Desktop/vpn-backup-20250128.tar.gz pi@192.168.178.2:~/

# Auf dem Pi:
ssh pi@192.168.178.2
sudo tar -xzf ~/vpn-backup-20250128.tar.gz -C /

# Services neu starten
sudo systemctl restart wg-quick@wg0
sudo systemctl restart wg-quick@wg1
```

---

## 📱 Client-Apps

### Android
- **App:** WireGuard (Google Play Store)
- **Config importieren:** QR-Code scannen oder `.conf`-Datei

### iOS
- **App:** WireGuard (App Store)
- **Config importieren:** QR-Code oder via AirDrop

### Windows
- **App:** WireGuard for Windows (https://www.wireguard.com/install/)
- **Config importieren:** `.conf`-Datei → "Import tunnel(s) from file"

### Linux
```bash
# WireGuard installieren
sudo apt install wireguard

# Config kopieren
sudo cp client.conf /etc/wireguard/wg0.conf

# Aktivieren
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
```

### macOS
- **App:** WireGuard (App Store)
- **Config importieren:** `.conf`-Datei

---

## 🆘 Notfall-Kommandos

### Alles stoppen (Notfall-Aus)
```bash
sudo systemctl stop wg-quick@wg0
sudo systemctl stop wg-quick@wg1
sudo iptables -F  # Achtung: Löscht ALLE Firewall-Regeln!
```

---

### Gateway deaktivieren (auf Fritz!Box zurück)
```bash
# Fritz!Box Webinterface:
# Heimnetz → Netzwerk → Netzwerkeinstellungen
# → "Standardgateway zurücksetzen" auf 192.168.178.1

# Oder manuell auf Clients:
# Gateway wieder auf 192.168.178.1 setzen
```

---

### Komplett neu starten
```bash
sudo reboot
```

---

## 📞 Support & Hilfe

**Bei Problemen:**
1. Status-Check: `vpn-status.sh`
2. Logs prüfen: `sudo journalctl -u wg-quick@wg0 -f`
3. Systemd-Status: `sudo systemctl status wg-quick@wg0`
4. Firewall-Regeln: `sudo iptables -L -n -v`

**Wichtige Dateien:**
- `/etc/wireguard/wg0.conf` - Server-Config
- `/etc/wireguard/wg1.conf` - Mullvad-Client-Config
- `/etc/wireguard/gateway-rules.sh` - Firewall-Regeln
- `/etc/sysctl.conf` - IP-Forwarding-Einstellung

**Nützliche Links:**
- WireGuard Docs: https://www.wireguard.com/quickstart/
- Mullvad Guide: https://mullvad.net/en/help/wireguard-and-mullvad-vpn/
- iptables Tutorial: https://www.frozentux.net/iptables-tutorial/iptables-tutorial.html

---

**Quick Reference Version:** 1.0 (2025-01-28)
