# WireGuard Client Configuration Templates

Dieser Ordner enthält vorgefertigte WireGuard-Konfigurationen für verschiedene Geräte und Use-Cases.

---

## 📁 Verfügbare Templates

### 1. `client-handy-TEMPLATE.conf`
**Für:** Smartphone (Android/iOS)
**Tunnel-Typ:** Split-Tunnel (nur Heimnetzwerk über VPN)
**IP-Adresse:** 10.10.10.2/24

**Verwendung:**
- Zugriff auf Home Assistant von unterwegs
- Sichere Verbindung zu Heimnetzwerk-Geräten
- Minimal Batterieeinfluss
- Rest des Traffics geht normal

**Import:**
- QR-Code generieren und in WireGuard App scannen
- Oder `.conf`-Datei direkt importieren

---

### 2. `client-laptop-TEMPLATE.conf`
**Für:** Laptop/Desktop (Windows/Mac/Linux)
**Tunnel-Typ:** Split-Tunnel
**IP-Adresse:** 10.10.10.3/24

**Verwendung:**
- Arbeit von außerhalb
- Remote-Zugriff auf Heimnetzwerk
- Datei-Zugriff auf NAS
- Home Assistant Kontrolle

**Import:**
- Windows/Mac: WireGuard App → "Import from file"
- Linux: `sudo cp client-laptop.conf /etc/wireguard/wg0.conf`

---

### 3. `client-full-tunnel-TEMPLATE.conf`
**Für:** Alle Geräte (spezieller Use-Case)
**Tunnel-Typ:** Full-Tunnel (ALLER Traffic über VPN)
**IP-Adresse:** 10.10.10.10/24

**Verwendung:**
- Öffentliche WiFi-Hotspots (Hotel, Flughafen)
- Maximaler Schutz vor lokalen Angriffen
- Geo-Blocking umgehen (nutzt Heimnetzwerk-IP)

**⚠️ Achtung:**
- Langsamer (begrenzt durch Heimnetzwerk-Upload)
- Höherer Datenverbrauch auf Heimleitung
- Nur bei Bedarf verwenden!

---

## 🛠️ Anleitung: Template verwenden

### Schritt 1: Template kopieren
```bash
# Beispiel für Handy-Config:
cp client-handy-TEMPLATE.conf client-handy.conf
```

### Schritt 2: Platzhalter ersetzen

Öffne die Datei in einem Texteditor und ersetze:

| Platzhalter | Beschreibung | Beispiel |
|-------------|--------------|----------|
| `<CLIENT_PRIVATE_KEY>` | Private Key des Clients | `aB3xY9...yA8=` |
| `<SERVER_PUBLIC_KEY>` | Public Key des VPN-Servers | `xY7mN3...bC8=` |
| `<DEINE_DYNDNS_DOMAIN>` | Deine DynDNS-Adresse oder feste IP | `meinheim.myfritz.net` |

**Wo finde ich diese Werte?**

#### Client Private Key:
```bash
# Auf dem VPN-Gateway Pi (SSH):
cd /etc/wireguard/keys
sudo cat client1_private.key  # Für Handy
sudo cat client2_private.key  # Für Laptop
```

#### Server Public Key:
```bash
# Auf dem VPN-Gateway Pi:
cd /etc/wireguard/keys
sudo cat server_public.key
```

#### DynDNS-Domain:
```
# In Fritz!Box nachsehen:
http://fritz.box → Internet → Freigaben → DynDNS
# Dort steht deine Domain, z.B.: meinheim.myfritz.net
```

### Schritt 3: Config importieren

**Android/iOS:**
```bash
# QR-Code generieren (auf VPN-Gateway Pi):
qrencode -t ansiutf8 < client-handy.conf

# In WireGuard App scannen
```

**Windows/Mac:**
```
1. WireGuard App öffnen
2. "Import tunnel(s) from file" / "Import tunnel from file"
3. client-laptop.conf auswählen
4. Aktivieren
```

**Linux:**
```bash
# Config auf Server kopieren:
sudo cp client-laptop.conf /etc/wireguard/wg0.conf
sudo chmod 600 /etc/wireguard/wg0.conf

# Aktivieren:
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0

# Status:
sudo wg show
```

---

## 🔑 Keys generieren (für neue Clients)

### Auf dem VPN-Gateway Pi:

```bash
# SSH-Verbindung:
ssh pi@192.168.178.2

# Keys für neuen Client generieren:
cd /etc/wireguard/keys
wg genkey | sudo tee client_neu_private.key | wg pubkey | sudo tee client_neu_public.key

# Keys anzeigen:
echo "Private Key:"
sudo cat client_neu_private.key
echo ""
echo "Public Key:"
sudo cat client_neu_public.key
```

### Public Key in Server-Config eintragen:

```bash
# Server-Config öffnen:
sudo nano /etc/wireguard/wg0.conf

# Neuen [Peer]-Block hinzufügen:
[Peer]
PublicKey = <NEU_GENERIERTER_PUBLIC_KEY>
AllowedIPs = 10.10.10.X/32  # X = freie IP (z.B. 5, 6, 7...)

# Speichern: Strg+O, Enter, Strg+X

# Server neu laden (ohne Disconnect):
sudo wg syncconf wg0 <(wg-quick strip wg0)
```

---

## 📱 IP-Adressen-Schema

| Gerät | IP-Adresse | Template |
|-------|------------|----------|
| **Server (VPN-Gateway)** | 10.10.10.1 | - |
| Handy | 10.10.10.2 | `client-handy-TEMPLATE.conf` |
| Laptop | 10.10.10.3 | `client-laptop-TEMPLATE.conf` |
| Tablet | 10.10.10.4 | (eigene Config erstellen) |
| Zweit-Handy | 10.10.10.5 | (eigene Config erstellen) |
| Full-Tunnel | 10.10.10.10 | `client-full-tunnel-TEMPLATE.conf` |

**Wichtig:** Jeder Client braucht eine **eindeutige** IP-Adresse!

---

## 🆘 Troubleshooting

### Problem: "Unable to connect" / "Handshake failed"

**Mögliche Ursachen:**
1. **Falsche Keys**
   - Prüfe ob Client Private Key und Server Public Key korrekt sind
   - Keys dürfen keine Leerzeichen oder Zeilenumbrüche haben

2. **Falsche Endpoint-Adresse**
   - DynDNS-Domain prüfen: `ping meinheim.myfritz.net`
   - Port 51820 prüfen: `nc -u -v meinheim.myfritz.net 51820`

3. **Fritz!Box Port-Forwarding fehlt**
   - http://fritz.box → Internet → Freigaben → Portfreigaben
   - UDP Port 51820 sollte auf 192.168.178.2 weitergeleitet sein

4. **Server läuft nicht**
   ```bash
   # Auf VPN-Gateway Pi:
   sudo systemctl status wg-quick@wg0
   # Sollte "active (running)" zeigen
   ```

---

### Problem: "Verbunden, aber kein Zugriff auf Heimnetzwerk"

**Lösung:**
```bash
# Auf VPN-Gateway Pi:
# IP-Forwarding prüfen:
cat /proc/sys/net/ipv4/ip_forward
# Sollte "1" sein

# NAT-Regeln prüfen:
sudo iptables -t nat -L POSTROUTING -n -v | grep MASQUERADE
# Sollte Regeln anzeigen

# Gateway-Regeln neu anwenden:
sudo /etc/wireguard/gateway-rules.sh
```

---

### Problem: "Langsame Verbindung"

**Lösung:**
1. **MTU anpassen**
   ```ini
   # In Client-Config unter [Interface] hinzufügen:
   MTU = 1420
   ```

2. **Server-Performance prüfen**
   ```bash
   # Auf VPN-Gateway Pi:
   top  # CPU-Last prüfen
   free -h  # RAM prüfen
   vcgencmd measure_temp  # Temperatur prüfen (Raspberry Pi)
   ```

3. **Andere Verbindung testen**
   - Von WiFi zu Mobile-Daten wechseln (oder umgekehrt)
   - Speedtest: https://speedtest.net

---

### Problem: "DNS funktioniert nicht"

**Symptom:** Kann per IP zugreifen (http://192.168.178.71:8123), aber nicht per Name (http://homeassistant.local)

**Lösung:**
```ini
# In Client-Config DNS anpassen:
[Interface]
...
DNS = 192.168.178.1

# Alternative (öffentliche DNS):
DNS = 8.8.8.8, 1.1.1.1
```

---

## 📊 Vergleich: Split vs. Full Tunnel

| Kriterium | Split-Tunnel | Full-Tunnel |
|-----------|--------------|-------------|
| **Performance** | ⭐⭐⭐⭐⭐ Normal | ⭐⭐⭐ Langsamer |
| **Batterielaufzeit** | ⭐⭐⭐⭐⭐ Minimal | ⭐⭐⭐ Höher |
| **Datenverbrauch (Heim)** | ⭐⭐⭐⭐⭐ Sehr gering | ⭐⭐ Hoch |
| **Sicherheit (öffentlich WiFi)** | ⭐⭐⭐ Mittel | ⭐⭐⭐⭐⭐ Maximal |
| **Heimnetzwerk-Zugriff** | ✅ Ja | ✅ Ja |
| **Normal surfen** | ✅ Normale Geschwindigkeit | ❌ Über Heimleitung |

**Empfehlung:**
- **Standard:** Split-Tunnel (client-handy.conf / client-laptop.conf)
- **Nur bei Bedarf:** Full-Tunnel (öffentliches WiFi, Geo-Blocking)

---

## 📞 Weitere Hilfe

**Detaillierte Anleitungen:**
- Setup: `VPN_SETUP_CHECKLIST.md`
- Täglicher Betrieb: `VPN_QUICK_REFERENCE.md`
- Hardware: `VPN_OPTION_A_HARDWARE.md`

**Bei Problemen:**
1. Status-Check auf Server: `vpn-status.sh` (siehe Quick Reference)
2. Logs prüfen: `sudo journalctl -u wg-quick@wg0 -f`
3. Client neu verbinden (VPN aus/an)
4. Server neu starten: `sudo systemctl restart wg-quick@wg0`

---

**Template Version:** 1.0 (2025-01-28)
