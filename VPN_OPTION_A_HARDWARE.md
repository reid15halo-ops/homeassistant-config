# Option A: Raspberry Pi als dediziertes VPN-Gateway

## 🛒 Einkaufsliste (~40-70€)

### Minimal-Setup (empfohlen für Einsteiger)
```
✅ Raspberry Pi Zero 2 W (16€)
   - 4x ARM Cortex-A53 @ 1 GHz
   - 512 MB RAM
   - Integriertes WiFi + Bluetooth
   - Ausreichend für 100-200 Mbit/s VPN-Durchsatz

✅ MicroSD-Karte 16-32 GB (8-12€)
   - Mindestens Class 10 / UHS-I
   - Empfehlung: SanDisk Ultra oder Samsung EVO

✅ USB-C Netzteil 5V/2.5A (10€)
   - Offizielles Raspberry Pi Netzteil empfohlen

✅ Optional: USB-Ethernet-Adapter (12€)
   - Für stabilere Verbindung als WiFi
   - USB 3.0 Gigabit Adapter empfohlen

GESAMT: ~40-50€
```

### Performance-Setup (für höhere Geschwindigkeiten)
```
✅ Raspberry Pi 4 Model B (2GB RAM) (50€)
   - 4x ARM Cortex-A72 @ 1.5 GHz
   - 2-8 GB RAM
   - Gigabit Ethernet onboard
   - VPN-Durchsatz: 300-500 Mbit/s

✅ MicroSD-Karte 32 GB (12€)

✅ USB-C Netzteil 5V/3A (15€)

✅ Optional: Gehäuse mit Lüfter (8€)

GESAMT: ~70-85€
```

---

## 📦 Installation (Schritt-für-Schritt)

### Phase 1: Raspberry Pi OS installieren (30 Minuten)

#### 1.1 Raspberry Pi Imager herunterladen
- Windows: https://www.raspberrypi.com/software/
- Installieren und starten

#### 1.2 OS auf SD-Karte schreiben
```
Raspberry Pi Imager öffnen
↓
"Operating System" → "Raspberry Pi OS Lite (64-bit)" auswählen
↓
"Storage" → Deine SD-Karte auswählen
↓
⚙️ (Settings) → Erweiterte Optionen:
   ✅ Hostname setzen: "vpngateway"
   ✅ SSH aktivieren
   ✅ Benutzername: "pi"
   ✅ Passwort: [dein sicheres Passwort]
   ✅ WiFi konfigurieren (falls kein Ethernet)
      SSID: [dein WiFi-Name]
      Passwort: [WiFi-Passwort]
   ✅ Locale: Europe/Berlin, de_DE
↓
"Write" klicken → Warten (~5 Minuten)
```

#### 1.3 Erster Start
```bash
# SD-Karte in Raspberry Pi einlegen
# Netzteil anschließen
# Warten (~2 Minuten bis Boot abgeschlossen)

# IP-Adresse finden (von deinem PC aus):
ping vpngateway.local

# Oder IP im Fritz!Box-Webinterface nachsehen
# → Heimnetz → Netzwerk → Geräte und Benutzer
```

#### 1.4 SSH-Verbindung testen
```bash
# Von deinem PC aus:
ssh pi@vpngateway.local
# Passwort eingeben

# System updaten:
sudo apt update && sudo apt upgrade -y
sudo reboot

# Nach Reboot erneut einloggen
```

---

### Phase 2: Netzwerk-Konfiguration (30 Minuten)

#### 2.1 Statische IP-Adresse vergeben

**Variante A: Über Fritz!Box (empfohlen)**
```
Fritz!Box Webinterface öffnen (http://fritz.box)
↓
Heimnetz → Netzwerk → Geräte und Benutzer
↓
"vpngateway" finden → Stift-Symbol (Bearbeiten)
↓
"Diesem Netzwerkgerät immer die gleiche IPv4-Adresse zuweisen" aktivieren
↓
IP-Adresse z.B.: 192.168.178.2 (möglichst niedrig, außerhalb DHCP-Range)
↓
Speichern
```

**Variante B: Manuell auf dem Pi**
```bash
# /etc/dhcpcd.conf bearbeiten
sudo nano /etc/dhcpcd.conf

# Am Ende hinzufügen:
interface eth0
static ip_address=192.168.178.2/24
static routers=192.168.178.1
static domain_name_servers=192.168.178.1

# Speichern: Strg+O, Enter, Strg+X

# Reboot
sudo reboot
```

#### 2.2 IP-Forwarding aktivieren
```bash
# Dauerhaft aktivieren
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

# Sofort anwenden
sudo sysctl -p

# Prüfen
cat /proc/sys/net/ipv4/ip_forward
# Output sollte "1" sein
```

---

### Phase 3: WireGuard Installation (20 Minuten)

#### 3.1 WireGuard installieren
```bash
# Paket installieren
sudo apt install wireguard wireguard-tools qrencode -y

# Keys-Verzeichnis erstellen
sudo mkdir -p /etc/wireguard/keys
cd /etc/wireguard/keys

# Server-Keys generieren
wg genkey | sudo tee server_private.key | wg pubkey | sudo tee server_public.key
sudo chmod 600 server_private.key

# Keys anzeigen (für später notieren!)
echo "Server Private Key:"
sudo cat server_private.key
echo ""
echo "Server Public Key:"
sudo cat server_public.key
```

---

### Phase 4: WireGuard Server-Konfiguration (40 Minuten)

#### 4.1 Server-Config erstellen
```bash
sudo nano /etc/wireguard/wg-server.conf
```

**Inhalt:**
```ini
[Interface]
# VPN-Subnet für Clients
Address = 10.10.10.1/24

# WireGuard Port
ListenPort = 51820

# Server Private Key (von oben einfügen!)
PrivateKey = <DEIN_SERVER_PRIVATE_KEY>

# Firewall-Regeln beim Start/Stop
PostUp = iptables -A FORWARD -i wg-server -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg-server -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# DNS für Clients (Heimnetzwerk)
DNS = 192.168.178.1


# ============================================================================
# CLIENT-KONFIGURATIONEN
# ============================================================================

# Client 1: Handy
[Peer]
PublicKey = <CLIENT_1_PUBLIC_KEY>
AllowedIPs = 10.10.10.2/32

# Client 2: Laptop
[Peer]
PublicKey = <CLIENT_2_PUBLIC_KEY>
AllowedIPs = 10.10.10.3/32

# Client 3: Tablet
[Peer]
PublicKey = <CLIENT_3_PUBLIC_KEY>
AllowedIPs = 10.10.10.4/32
```

**Speichern:** Strg+O, Enter, Strg+X

#### 4.2 Client-Keys generieren

**Für jedes Client-Gerät (Handy, Laptop, etc.):**
```bash
# Client 1 Keys
cd /etc/wireguard/keys
wg genkey | sudo tee client1_private.key | wg pubkey | sudo tee client1_public.key

# Anzeigen und notieren!
echo "Client 1 Private Key:"
sudo cat client1_private.key
echo ""
echo "Client 1 Public Key:"
sudo cat client1_public.key

# Wiederholen für weitere Clients (client2, client3, ...)
```

#### 4.3 Client-Public-Keys in Server-Config eintragen
```bash
# Server-Config öffnen
sudo nano /etc/wireguard/wg-server.conf

# Bei jedem [Peer]-Eintrag den entsprechenden Public Key einfügen:
# PublicKey = <CLIENT_1_PUBLIC_KEY>  ← Hier einfügen
```

#### 4.4 WireGuard Server starten
```bash
# Rechte setzen
sudo chmod 600 /etc/wireguard/wg-server.conf

# Interface benennen
sudo mv /etc/wireguard/wg-server.conf /etc/wireguard/wg0.conf

# Aktivieren und starten
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0

# Status prüfen
sudo systemctl status wg-quick@wg0
sudo wg show

# Output sollte etwa so aussehen:
# interface: wg0
#   public key: (your server public key)
#   private key: (hidden)
#   listening port: 51820
```

---

### Phase 5: Fritz!Box Port-Forwarding (15 Minuten)

#### 5.1 Port-Forwarding einrichten
```
Fritz!Box Webinterface → Internet → Freigaben → Portfreigaben
↓
"Gerät für Freigaben hinzufügen" → "vpngateway" auswählen
↓
Neue Portfreigabe:
   - Bezeichnung: "WireGuard VPN"
   - Protokoll: UDP
   - Port: 51820 an Port 51820
   - Für alle IPv4-Adressen
↓
OK → Speichern
```

#### 5.2 DynDNS einrichten (falls keine feste IP)
```
Fritz!Box → Internet → Freigaben → DynDNS
↓
DynDNS aktivieren
↓
Anbieter auswählen (z.B. MyFritz!, No-IP, DynDNS.org)
↓
Domain-Name registrieren und eintragen
↓
Speichern

# Domain notieren für Client-Config!
# z.B.: meinzuhause.myfritz.net
```

---

### Phase 6: Client-Konfigurationsdateien erstellen (20 Minuten)

#### 6.1 Config für Handy (Android/iOS)
```bash
# Auf dem VPN-Gateway Pi:
sudo nano /etc/wireguard/client1-handy.conf
```

**Inhalt:**
```ini
[Interface]
# Client 1 Private Key
PrivateKey = <CLIENT_1_PRIVATE_KEY>

# VPN-IP des Clients
Address = 10.10.10.2/24

# DNS (nutzt Home-Netzwerk DNS)
DNS = 192.168.178.1


[Peer]
# Server Public Key
PublicKey = <SERVER_PUBLIC_KEY>

# Deine öffentliche IP/Domain + Port
Endpoint = <DEINE_DYNDNS_DOMAIN>:51820
# Beispiel: Endpoint = meinzuhause.myfritz.net:51820

# Nur Heimnetzwerk-Traffic über VPN (Split-Tunnel)
AllowedIPs = 192.168.178.0/24, 10.10.10.0/24

# Keepalive (hält Verbindung stabil)
PersistentKeepalive = 25
```

**Speichern und QR-Code generieren:**
```bash
# QR-Code für Handy-Import erstellen
qrencode -t ansiutf8 < /etc/wireguard/client1-handy.conf

# Oder als PNG speichern und per SSH runterladen:
qrencode -o /tmp/client1-qr.png < /etc/wireguard/client1-handy.conf

# Von deinem PC aus runterladen:
scp pi@vpngateway.local:/tmp/client1-qr.png ~/Desktop/
```

#### 6.2 Config für Laptop (Windows/Mac/Linux)
```bash
sudo nano /etc/wireguard/client2-laptop.conf
```

**Inhalt (identisch zu Handy, nur andere IP):**
```ini
[Interface]
PrivateKey = <CLIENT_2_PRIVATE_KEY>
Address = 10.10.10.3/24
DNS = 192.168.178.1

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
Endpoint = <DEINE_DYNDNS_DOMAIN>:51820
AllowedIPs = 192.168.178.0/24, 10.10.10.0/24
PersistentKeepalive = 25
```

**Datei runterladen:**
```bash
# Von deinem PC aus:
scp pi@vpngateway.local:/etc/wireguard/client2-laptop.conf ~/Desktop/
```

---

### Phase 7: WireGuard Client (Privacy-VPN via Mullvad) - 40 Minuten

#### 7.1 Mullvad Account erstellen
```
1. Besuche: https://mullvad.net/de/
2. Klicke "Konto erstellen"
3. Notiere die Account-Nummer (16 Ziffern)
4. Zahle per Kreditkarte/PayPal/Bitcoin (5€/Monat)
```

#### 7.2 Mullvad WireGuard-Config herunterladen
```
1. Einloggen auf https://mullvad.net/de/account/
2. → "WireGuard-Konfiguration"
3. → "Gerät hinzufügen": Name "vpngateway"
4. → Key wird automatisch generiert
5. → Land auswählen (z.B. "Deutschland - Frankfurt")
6. → "Konfiguration herunterladen"
7. Datei speichern als: mullvad-de-fra.conf
```

#### 7.3 Config auf Pi hochladen
```bash
# Von deinem PC aus (wo die Mullvad-Config liegt):
scp ~/Downloads/mullvad-de-fra.conf pi@vpngateway.local:/tmp/

# Auf dem Pi:
ssh pi@vpngateway.local

# Config verschieben
sudo mv /tmp/mullvad-de-fra.conf /etc/wireguard/wg1.conf

# Rechte setzen
sudo chmod 600 /etc/wireguard/wg1.conf
```

#### 7.4 Mullvad-Config anpassen für Gateway-Nutzung
```bash
sudo nano /etc/wireguard/wg1.conf
```

**Wichtig: `AllowedIPs` anpassen!**
```ini
[Interface]
PrivateKey = <MULLVAD_PRIVATE_KEY>
Address = 10.x.x.x/32
DNS = 10.64.0.1

[Peer]
PublicKey = <MULLVAD_SERVER_PUBLIC_KEY>
Endpoint = de-fra.mullvad.net:51820
AllowedIPs = 0.0.0.0/0, ::/0  # ← Aller Traffic über Mullvad

# Optional: Kill-Switch (blockiert Traffic bei VPN-Ausfall)
PostUp = iptables -I FORWARD -i eth0 -o eth0 -j DROP
PostDown = iptables -D FORWARD -i eth0 -o eth0 -j DROP
```

#### 7.5 Mullvad-Client starten
```bash
# Aktivieren und starten
sudo systemctl enable wg-quick@wg1
sudo systemctl start wg-quick@wg1

# Status prüfen
sudo systemctl status wg-quick@wg1
sudo wg show wg1
```

#### 7.6 Verbindung testen
```bash
# IP-Check (sollte Mullvad-IP zeigen)
curl https://am.i.mullvad.net/connected

# Erwartete Ausgabe:
# You are connected to Mullvad (server de-fra). Your IP address is X.X.X.X
```

---

### Phase 8: Gateway-Routing für Heimnetzwerk (45 Minuten)

#### 8.1 NAT/Masquerading konfigurieren
```bash
# Firewall-Regeln erstellen
sudo nano /etc/wireguard/gateway-rules.sh
```

**Inhalt:**
```bash
#!/bin/bash
# VPN Gateway Firewall Rules

# Variablen
LAN_IF="eth0"
VPN_IF="wg1"
VPN_SERVER_IF="wg0"
LAN_NET="192.168.178.0/24"

# IPv4 Forwarding (sollte schon aktiv sein)
echo 1 > /proc/sys/net/ipv4/ip_forward

# NAT für ausgehenden Traffic über Mullvad
iptables -t nat -A POSTROUTING -o ${VPN_IF} -j MASQUERADE

# Lokaler Traffic direkt (nicht über VPN)
iptables -t nat -I POSTROUTING -s ${LAN_NET} -d ${LAN_NET} -j ACCEPT

# VPN-Server Traffic direkt (nicht über Mullvad)
iptables -t mangle -A PREROUTING -i ${VPN_SERVER_IF} -j MARK --set-mark 100
ip rule add fwmark 100 lookup 100
ip route add default via 192.168.178.1 table 100

# Forwarding erlauben
iptables -A FORWARD -i ${LAN_IF} -o ${VPN_IF} -j ACCEPT
iptables -A FORWARD -i ${VPN_IF} -o ${LAN_IF} -m state --state RELATED,ESTABLISHED -j ACCEPT

# Logging (optional, für Troubleshooting)
# iptables -A FORWARD -j LOG --log-prefix "VPN-Gateway: " --log-level 4

echo "Gateway-Regeln angewendet"
```

**Ausführbar machen und testen:**
```bash
sudo chmod +x /etc/wireguard/gateway-rules.sh
sudo /etc/wireguard/gateway-rules.sh
```

#### 8.2 Regeln bei Boot automatisch laden
```bash
# Cron-Job erstellen
sudo crontab -e

# Diese Zeile hinzufügen:
@reboot /etc/wireguard/gateway-rules.sh

# Speichern und beenden
```

#### 8.3 Fritz!Box DHCP-Option anpassen

**Option A: Alle Geräte über Gateway (empfohlen)**
```
Fritz!Box → Heimnetz → Netzwerk → Netzwerkeinstellungen
↓
IPv4-Adressen → "Weitere Einstellungen"
↓
DHCP-Server → "Standardgateway überschreiben"
↓
Gateway-IP: 192.168.178.2 (VPN-Gateway Pi)
↓
Speichern

⚠️ ACHTUNG: Alle Geräte verlieren kurz Internet-Verbindung!
⚠️ Nur machen wenn VPN-Client läuft!
```

**Option B: Nur bestimmte Geräte (manuell auf Geräten)**
```
Auf jedem Gerät (z.B. Windows PC):
Netzwerkeinstellungen → Ethernet/WiFi-Adapter
→ IPv4-Einstellungen
→ Gateway: 192.168.178.2
→ DNS: 192.168.178.1 (oder 192.168.178.2 für Ad-Blocking via Pi-hole)
```

---

### Phase 9: Testing (30 Minuten)

#### 9.1 VPN-Server Test (Zugriff von außen)
```bash
# Auf deinem Handy:
1. WireGuard App installieren (Android/iOS)
2. QR-Code scannen oder Config-Datei importieren
3. VPN aktivieren
4. Mobile-Daten einschalten (WiFi aus!)
5. Browser öffnen: http://192.168.178.71:8123 (Home Assistant)

# Sollte funktionieren! ✅
```

#### 9.2 Privacy-VPN Test (Mullvad-IP)
```bash
# Auf deinem PC (mit Gateway 192.168.178.2):
curl https://am.i.mullvad.net/connected

# Sollte zeigen:
# You are connected to Mullvad...

# Alternative IP-Check:
curl https://ipinfo.io/ip

# Sollte Mullvad-IP zeigen (nicht deine echte IP)
```

#### 9.3 Split-Routing Test
```bash
# Test 1: VPN-Server-Client kann Heimnetzwerk erreichen
# (Von deinem Handy über VPN):
ping 192.168.178.1  # Fritz!Box
ping 192.168.178.71 # Home Assistant

# Test 2: VPN-Server Traffic geht NICHT über Mullvad
# Auf dem Pi:
sudo tcpdump -i wg1 -n | grep 51820
# Sollte KEINEN WireGuard-Server-Traffic (Port 51820) zeigen!

# Test 3: Normaler Web-Traffic geht über Mullvad
# Auf dem PC:
curl https://ipinfo.io/ip
# Sollte Mullvad-IP zeigen
```

#### 9.4 Performance-Test
```bash
# Speedtest von deinem PC (über VPN-Gateway):
sudo apt install speedtest-cli
speedtest-cli

# Erwartete Werte (Raspberry Pi Zero 2 W):
# Download: 80-150 Mbit/s
# Upload: 30-80 Mbit/s
# Ping: +10-30ms gegenüber direkter Verbindung

# Erwartete Werte (Raspberry Pi 4):
# Download: 200-400 Mbit/s
# Upload: 100-250 Mbit/s
# Ping: +5-15ms
```

---

## 🎉 Setup abgeschlossen!

### Was du jetzt hast:
✅ VPN-Server für sicheren Zugriff von außen
✅ VPN-Client für Privacy (alle Geräte über Mullvad)
✅ Split-Routing (Server-Traffic direkt, Rest über VPN)
✅ Automatischer Start bei Boot
✅ Stabile und performante Lösung

---

## 🛠️ Wartung & Monitoring

### Logs anschauen
```bash
# WireGuard Server Logs
sudo journalctl -u wg-quick@wg0 -f

# WireGuard Client Logs
sudo journalctl -u wg-quick@wg1 -f

# Aktive Verbindungen
sudo wg show
```

### Status-Check Script
```bash
# Erstelle Monitoring-Script
sudo nano /usr/local/bin/vpn-status.sh
```

**Inhalt:**
```bash
#!/bin/bash
echo "=== VPN Gateway Status ==="
echo ""
echo "VPN-Server (wg0):"
sudo systemctl status wg-quick@wg0 | grep Active
sudo wg show wg0 | grep -E "interface|peer|latest"
echo ""
echo "VPN-Client (wg1):"
sudo systemctl status wg-quick@wg1 | grep Active
sudo wg show wg1 | grep -E "interface|peer|latest"
echo ""
echo "Mullvad-Verbindung:"
curl -s https://am.i.mullvad.net/connected
echo ""
echo "Aktive Forwarding-Regeln:"
sudo iptables -t nat -L POSTROUTING -n -v | grep MASQUERADE
```

**Ausführbar machen:**
```bash
sudo chmod +x /usr/local/bin/vpn-status.sh

# Aufrufen mit:
vpn-status.sh
```

---

## 🚨 Troubleshooting

### Problem: Kein Zugriff von außen (VPN-Server)
```bash
# Prüfen ob Server läuft
sudo systemctl status wg-quick@wg0

# Port-Check (von außen)
# Auf einem externen Gerät (Mobile Data):
nc -u -v <DEINE_DYNDNS_DOMAIN> 51820

# Fritz!Box Port-Forwarding prüfen
# → Internet → Freigaben → Portfreigaben
```

### Problem: Kein Internet über Mullvad
```bash
# Client-Status prüfen
sudo systemctl status wg-quick@wg1

# Verbindung testen
sudo wg show wg1 | grep "latest handshake"
# Sollte einen aktuellen Timestamp zeigen (< 2 Minuten)

# DNS-Test
nslookup google.com 10.64.0.1

# Client neu starten
sudo systemctl restart wg-quick@wg1
```

### Problem: Split-Routing funktioniert nicht
```bash
# Routing-Tabelle prüfen
ip rule show
# Sollte enthalten: "from all fwmark 0x64 lookup 100"

ip route show table 100
# Sollte Default-Route über Fritz!Box zeigen

# Firewall-Marks prüfen
sudo iptables -t mangle -L PREROUTING -n -v

# Neu anwenden
sudo /etc/wireguard/gateway-rules.sh
```

### Problem: Performance zu langsam
```bash
# CPU-Last prüfen
top

# Wenn >80%:
# → Möglicherweise zu viele Geräte im Netzwerk
# → Raspberry Pi 4 statt Zero 2 W verwenden

# WireGuard MTU optimieren
sudo ip link set mtu 1420 dev wg1
```

---

## 📞 Support & Hilfe

Bei Problemen:
1. Logs prüfen: `sudo journalctl -xe`
2. `vpn-status.sh` ausführen und Output teilen
3. Firewall-Regeln prüfen: `sudo iptables -L -n -v`

**Nächster Schritt:** Start mit Phase 1 - Raspberry Pi OS Installation!
