# ✅ VPN-Gateway Setup Checkliste

**Gesamtdauer:** ~6-7 Stunden über 2 Tage
**Schwierigkeit:** Mittel
**Hardware:** Raspberry Pi Zero 2 W + Zubehör

---

## 📦 Phase 0: Vorbereitung (Vor Hardware-Ankunft)

### Mullvad-Account vorbereiten
- [ ] https://mullvad.net/de besuchen
- [ ] "Konto erstellen" klicken
- [ ] **Account-Nummer notieren** (16 Ziffern) → sicher aufbewahren!
- [ ] 5€ einzahlen (Kreditkarte/PayPal/Bitcoin)
- [ ] Account-Status prüfen: "Aktiv" sollte angezeigt werden

### Software auf PC vorbereiten
- [ ] Raspberry Pi Imager herunterladen: https://www.raspberrypi.com/software/
- [ ] Raspberry Pi Imager installieren
- [ ] SSH-Client prüfen (Windows: Terminal, Mac/Linux: eingebaut)

### Fritz!Box-Informationen notieren
- [ ] Fritz!Box Webinterface öffnen: http://fritz.box
- [ ] Aktuellen DHCP-Range prüfen (Heimnetz → Netzwerk → Netzwerkeinstellungen)
- [ ] Notiere: DHCP von `192.168.178.___` bis `192.168.178.___`
- [ ] Wähle freie IP für VPN-Gateway: `192.168.178.2` (empfohlen)

### DynDNS einrichten (falls keine feste IP)
- [ ] Fritz!Box → Internet → Freigaben → DynDNS
- [ ] DynDNS-Anbieter auswählen (z.B. MyFritz, No-IP, DynDNS.org)
- [ ] Domain registrieren
- [ ] **Domain-Name notieren:** `_______________.myfritz.net`

---

## 💻 Phase 1: Raspberry Pi OS Installation (30 Minuten)

### SD-Karte vorbereiten
- [ ] MicroSD-Karte in PC-Kartenleser einlegen
- [ ] Raspberry Pi Imager starten

### OS installieren
- [ ] "Operating System" → **"Raspberry Pi OS Lite (64-bit)"** auswählen
- [ ] "Storage" → Deine SD-Karte auswählen
- [ ] ⚙️ (Zahnrad) → Erweiterte Optionen konfigurieren:

#### Erweiterte Optionen ausfüllen:
- [ ] ✅ **Hostname setzen:** `vpngateway`
- [ ] ✅ **SSH aktivieren:** "Passwort-Authentifizierung verwenden"
- [ ] ✅ **Benutzername:** `pi`
- [ ] ✅ **Passwort:** `____________` (sicheres Passwort, notieren!)
- [ ] ✅ **WiFi konfigurieren** (falls kein Ethernet-Adapter):
  - SSID: `____________` (dein WiFi-Name)
  - Passwort: `____________` (WiFi-Passwort)
  - Land: `DE`
- [ ] ✅ **Locale:** `Europe/Berlin`, Tastatur: `de`

- [ ] "Speichern" klicken
- [ ] "Schreiben" klicken
- [ ] Warten (~5 Minuten)
- [ ] "Fertig" → SD-Karte aus PC entfernen

### Erster Boot
- [ ] MicroSD-Karte in Raspberry Pi einlegen
- [ ] USB-C Netzteil anschließen
- [ ] ⏱️ Warten (~2-3 Minuten für ersten Boot)
- [ ] Grüne LED blinkt = Boot läuft

### IP-Adresse finden
**Option A: Per Hostname** (einfachste Methode)
- [ ] Terminal öffnen (Windows: `cmd` oder Windows Terminal)
- [ ] `ping vpngateway.local` eingeben
- [ ] IP-Adresse wird angezeigt (z.B. `192.168.178.123`)
- [ ] **IP notieren:** `192.168.178.___`

**Option B: Fritz!Box-Webinterface**
- [ ] http://fritz.box öffnen
- [ ] Heimnetz → Netzwerk → Geräte und Benutzer
- [ ] "vpngateway" suchen
- [ ] IP-Adresse notieren

### SSH-Verbindung testen
- [ ] Terminal öffnen
- [ ] `ssh pi@vpngateway.local` eingeben (oder `ssh pi@192.168.178.___`)
- [ ] Bei Fingerprint-Warnung: `yes` eingeben
- [ ] Passwort eingeben (das vorhin gesetzte)
- [ ] Prompt sollte zeigen: `pi@vpngateway:~ $` ✅

### System updaten
```bash
sudo apt update && sudo apt upgrade -y
```
- [ ] Befehl eingeben und warten (~5-10 Minuten)
- [ ] `sudo reboot` eingeben
- [ ] ⏱️ Warten (1 Minute)
- [ ] Erneut einloggen: `ssh pi@vpngateway.local`

---

## 🌐 Phase 2: Netzwerk-Konfiguration (30 Minuten)

### Statische IP-Adresse vergeben

**Via Fritz!Box (empfohlen):**
- [ ] http://fritz.box → Heimnetz → Netzwerk → Geräte und Benutzer
- [ ] "vpngateway" finden → Stift-Symbol (Bearbeiten)
- [ ] ✅ "Diesem Netzwerkgerät immer die gleiche IPv4-Adresse zuweisen"
- [ ] IP-Adresse: `192.168.178.2`
- [ ] "OK" klicken
- [ ] Raspberry Pi neu starten: `sudo reboot`
- [ ] Nach Neustart mit neuer IP verbinden: `ssh pi@192.168.178.2`

### IP-Forwarding aktivieren
```bash
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sudo sysctl -p
```
- [ ] Befehle ausführen
- [ ] Prüfen: `cat /proc/sys/net/ipv4/ip_forward` → sollte `1` zeigen

---

## 🔐 Phase 3: WireGuard Server Setup (1,5 Stunden)

### WireGuard installieren
```bash
sudo apt install wireguard wireguard-tools qrencode -y
```
- [ ] Befehl ausführen (Dauer ~2 Minuten)

### Server-Keys generieren
```bash
sudo mkdir -p /etc/wireguard/keys
cd /etc/wireguard/keys
wg genkey | sudo tee server_private.key | wg pubkey | sudo tee server_public.key
sudo chmod 600 server_private.key
```
- [ ] Befehle ausführen
- [ ] Keys anzeigen und **sicher notieren:**

```bash
echo "Server Private Key:"
sudo cat server_private.key
echo ""
echo "Server Public Key:"
sudo cat server_public.key
```

**Hier notieren:**
- Server Private Key: `___________________________`
- Server Public Key: `___________________________`

### Client-Keys generieren (für jedes Gerät)

**Client 1 (Handy):**
```bash
cd /etc/wireguard/keys
wg genkey | sudo tee client1_private.key | wg pubkey | sudo tee client1_public.key
sudo cat client1_private.key
sudo cat client1_public.key
```
- [ ] Keys generieren
- **Client 1 Private Key:** `___________________________`
- **Client 1 Public Key:** `___________________________`

**Client 2 (Laptop):**
```bash
wg genkey | sudo tee client2_private.key | wg pubkey | sudo tee client2_public.key
sudo cat client2_private.key
sudo cat client2_public.key
```
- [ ] Keys generieren
- **Client 2 Private Key:** `___________________________`
- **Client 2 Public Key:** `___________________________`

**Optional: Client 3 (Tablet):**
- [ ] Wiederholen für weitere Clients

### Server-Config erstellen
```bash
sudo nano /etc/wireguard/wg0.conf
```
- [ ] Nano-Editor öffnet sich
- [ ] Folgende Config einfügen (Keys von oben einsetzen!):

```ini
[Interface]
Address = 10.10.10.1/24
ListenPort = 51820
PrivateKey = <DEIN_SERVER_PRIVATE_KEY>

PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# Client 1: Handy
[Peer]
PublicKey = <CLIENT_1_PUBLIC_KEY>
AllowedIPs = 10.10.10.2/32

# Client 2: Laptop
[Peer]
PublicKey = <CLIENT_2_PUBLIC_KEY>
AllowedIPs = 10.10.10.3/32

# Client 3: Tablet (optional)
[Peer]
PublicKey = <CLIENT_3_PUBLIC_KEY>
AllowedIPs = 10.10.10.4/32
```

- [ ] Keys ersetzen (ohne `< >`)
- [ ] Speichern: `Strg+O` → `Enter` → `Strg+X`

### WireGuard Server starten
```bash
sudo chmod 600 /etc/wireguard/wg0.conf
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
sudo systemctl status wg-quick@wg0
```
- [ ] Befehle ausführen
- [ ] Status sollte zeigen: `active (running)` ✅
- [ ] Prüfen: `sudo wg show` → zeigt Server-Interface

### Fritz!Box Port-Forwarding
- [ ] http://fritz.box → Internet → Freigaben → Portfreigaben
- [ ] "Gerät für Freigaben hinzufügen" → "vpngateway" (192.168.178.2)
- [ ] Neue Portfreigabe:
  - Bezeichnung: `WireGuard VPN`
  - Protokoll: **UDP**
  - Port: `51820` an Port `51820`
  - Für alle IPv4-Adressen
- [ ] "OK" → Speichern

### Client-Configs erstellen

**Handy-Config (`client1-handy.conf`):**
```bash
sudo nano /etc/wireguard/client1-handy.conf
```

Inhalt (Keys von oben einsetzen!):
```ini
[Interface]
PrivateKey = <CLIENT_1_PRIVATE_KEY>
Address = 10.10.10.2/24
DNS = 192.168.178.1

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
Endpoint = <DEINE_DYNDNS_DOMAIN>:51820
AllowedIPs = 192.168.178.0/24, 10.10.10.0/24
PersistentKeepalive = 25
```

- [ ] Config erstellen und speichern
- [ ] QR-Code generieren: `qrencode -t ansiutf8 < /etc/wireguard/client1-handy.conf`
- [ ] QR-Code wird angezeigt

**Laptop-Config (`client2-laptop.conf`):**
```bash
sudo nano /etc/wireguard/client2-laptop.conf
```

Inhalt (nur IP-Adresse ändern):
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

- [ ] Config erstellen
- [ ] Auf PC runterladen: `scp pi@192.168.178.2:/etc/wireguard/client2-laptop.conf ~/Desktop/`

### Test von außen (Handy)
- [ ] WireGuard App installieren (Android/iOS App Store)
- [ ] QR-Code scannen (oder Config-Datei importieren)
- [ ] WiFi **ausschalten**, Mobile-Daten **einschalten**
- [ ] VPN aktivieren
- [ ] Browser öffnen: `http://192.168.178.71:8123` (Home Assistant)
- [ ] Home Assistant sollte laden ✅
- [ ] VPN deaktivieren

---

## 🔒 Phase 4: Mullvad Client Setup (1 Stunde)

### Mullvad-Config herunterladen
- [ ] Browser auf PC: https://mullvad.net/de/account/ (einloggen)
- [ ] → "WireGuard-Konfiguration"
- [ ] → "Gerät hinzufügen"
- [ ] Name: `vpngateway`
- [ ] Key wird automatisch generiert
- [ ] Land auswählen: **"Deutschland - Frankfurt"** (oder andere Stadt)
- [ ] "Konfiguration herunterladen" klicken
- [ ] Datei speichern als: `mullvad-de-fra.conf`

### Config auf Pi hochladen
**Von deinem PC aus:**
```bash
scp ~/Downloads/mullvad-de-fra.conf pi@192.168.178.2:/tmp/
```
- [ ] Befehl ausführen (Pfad anpassen!)

**Auf dem Pi:**
```bash
ssh pi@192.168.178.2
sudo mv /tmp/mullvad-de-fra.conf /etc/wireguard/wg1.conf
sudo chmod 600 /etc/wireguard/wg1.conf
```
- [ ] Config verschieben

### Config anpassen
```bash
sudo nano /etc/wireguard/wg1.conf
```
- [ ] Datei öffnet sich
- [ ] Prüfen ob `AllowedIPs = 0.0.0.0/0, ::/0` vorhanden ist (sollte sein)
- [ ] Optional Kill-Switch hinzufügen (am Ende):
```ini
PostUp = iptables -I FORWARD -i eth0 -o eth0 -j DROP
PostDown = iptables -D FORWARD -i eth0 -o eth0 -j DROP
```
- [ ] Speichern: `Strg+O` → `Enter` → `Strg+X`

### Mullvad-Client starten
```bash
sudo systemctl enable wg-quick@wg1
sudo systemctl start wg-quick@wg1
sudo systemctl status wg-quick@wg1
```
- [ ] Befehle ausführen
- [ ] Status sollte: `active (running)` zeigen ✅

### Verbindung testen
```bash
curl https://am.i.mullvad.net/connected
```
- [ ] Befehl ausführen
- [ ] **Erwartete Ausgabe:** `You are connected to Mullvad (server de-fra). Your IP address is X.X.X.X` ✅
- [ ] Falls nicht verbunden → Logs prüfen: `sudo journalctl -u wg-quick@wg1 -f`

---

## 🌉 Phase 5: Gateway-Routing (1,5 Stunden)

### Firewall-Regeln erstellen
```bash
sudo nano /etc/wireguard/gateway-rules.sh
```

Inhalt:
```bash
#!/bin/bash
# VPN Gateway Firewall Rules

LAN_IF="eth0"
VPN_IF="wg1"
VPN_SERVER_IF="wg0"
LAN_NET="192.168.178.0/24"

# IPv4 Forwarding
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

echo "Gateway-Regeln angewendet"
```

- [ ] Script erstellen und speichern
- [ ] Ausführbar machen: `sudo chmod +x /etc/wireguard/gateway-rules.sh`
- [ ] Testen: `sudo /etc/wireguard/gateway-rules.sh`
- [ ] Sollte ausgeben: `Gateway-Regeln angewendet` ✅

### Autostart bei Boot
```bash
sudo crontab -e
```
- [ ] Editor öffnet sich (wähle `nano` falls gefragt)
- [ ] Am Ende hinzufügen:
```
@reboot /etc/wireguard/gateway-rules.sh
```
- [ ] Speichern und beenden

### Fritz!Box als Gateway konfigurieren (WICHTIG!)

**Option A: Alle Geräte automatisch (empfohlen)**
- [ ] http://fritz.box → Heimnetz → Netzwerk → Netzwerkeinstellungen
- [ ] IPv4-Adressen → "Weitere Einstellungen"
- [ ] ⚠️ **ACHTUNG:** Alle Geräte verlieren kurz Internet!
- [ ] "Anderen Standard-Gateway verwenden"
- [ ] Gateway-IP: `192.168.178.2` (VPN-Gateway Pi)
- [ ] DNS-Server: `192.168.178.1` (Fritz!Box)
- [ ] "OK" → Speichern
- [ ] ⏱️ Warten (30 Sekunden)

**Option B: Manuell pro Gerät**
- [ ] Auf jedem Gerät (PC, Handy) Netzwerkeinstellungen öffnen
- [ ] Gateway manuell setzen: `192.168.178.2`
- [ ] DNS: `192.168.178.1`

---

## ✅ Phase 6: Testing (1 Stunde)

### Test 1: VPN-Server (Zugriff von außen)
- [ ] Handy: WiFi aus, Mobile-Daten an
- [ ] WireGuard VPN aktivieren
- [ ] Browser: `http://192.168.178.71:8123`
- [ ] **Erwartet:** Home Assistant lädt ✅

### Test 2: Mullvad-IP (Privacy-VPN)
- [ ] PC: Netzwerkeinstellungen → Gateway auf `192.168.178.2` setzen
- [ ] Browser: `https://mullvad.net/check`
- [ ] **Erwartet:** "You are connected to Mullvad" ✅
- [ ] Alternative: `https://ipinfo.io/ip` → zeigt Mullvad-IP

### Test 3: Split-Routing (VPN-Server direkt)
- [ ] Handy: VPN aktivieren (über Mobile-Daten)
- [ ] Auf VPN-Gateway Pi:
```bash
sudo tcpdump -i wg1 port 51820 -n
```
- [ ] **Erwartet:** KEIN Traffic auf Port 51820 sichtbar ✅
- [ ] Das bedeutet: VPN-Server-Traffic geht NICHT über Mullvad

### Test 4: Performance
- [ ] Auf PC: `https://speedtest.net` öffnen
- [ ] Speedtest durchführen
- [ ] Notiere Werte:
  - Download: `_____` Mbit/s (sollte ~80-150 Mbit/s sein)
  - Upload: `_____` Mbit/s (sollte ~30-80 Mbit/s sein)
  - Ping: `_____` ms (sollte +10-30ms gegenüber normal sein)

### Test 5: Home Assistant Performance
- [ ] Home Assistant UI öffnen: `http://192.168.178.71:8123`
- [ ] Prüfe Ladezeit (sollte normal sein)
- [ ] Automation ausführen (z.B. Licht ein/aus)
- [ ] **Erwartet:** Keine Verzögerung ✅

---

## 🎉 SETUP ABGESCHLOSSEN!

### Was du jetzt hast:
✅ VPN-Server für sicheren Zugriff von außen
✅ VPN-Client für Privacy (Mullvad)
✅ Gateway für alle Netzwerk-Geräte
✅ Split-Routing (Server-Traffic direkt)
✅ Automatischer Start bei Boot

### Nächste Schritte:
- [ ] Weitere Client-Configs erstellen (Tablet, etc.)
- [ ] Optional: Pi-hole installieren (Ad-Blocking)
- [ ] Monitoring einrichten (siehe QUICK_REFERENCE.md)
- [ ] Backup der Configs erstellen

### Wichtige Commands:
```bash
# VPN-Status prüfen
sudo wg show

# Logs anschauen
sudo journalctl -u wg-quick@wg0 -f  # Server
sudo journalctl -u wg-quick@wg1 -f  # Client

# Services neu starten
sudo systemctl restart wg-quick@wg0  # Server
sudo systemctl restart wg-quick@wg1  # Client

# Firewall-Regeln neu anwenden
sudo /etc/wireguard/gateway-rules.sh
```

**Herzlichen Glückwunsch! 🎊**
