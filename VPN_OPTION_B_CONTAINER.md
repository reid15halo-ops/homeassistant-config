# Option B: Dual-WireGuard auf Home Assistant OS (Container-basiert)

## ⚠️ Warnung vorab

Diese Option ist **technisch anspruchsvoll** und hat **Einschränkungen**:
- ❌ Gateway-Funktionalität nur eingeschränkt (nur Geräte die Pi als Gateway setzen)
- ❌ Performance-Impact auf Home Assistant möglich
- ❌ Split-Routing sehr komplex
- ✅ Keine zusätzliche Hardware nötig
- ✅ WireGuard Server über offizielles Add-on (stabil)

**Empfehlung:** Wenn möglich, nutze **Option A** (zweiter Raspberry Pi) statt dieser Lösung!

---

## 📋 Setup-Übersicht

```
Home Assistant OS
├── Home Assistant Core (läuft)
├── Terminal & SSH Add-on (installiert)
├── WireGuard Add-on (Server) ← Installieren wir
└── Custom Docker Container (Mullvad Client) ← Bauen wir
```

---

## Phase 1: WireGuard Add-on (Server) - 30 Minuten

### 1.1 Add-on installieren
```
Home Assistant UI → Settings → Add-ons → Add-on Store
↓
Suche "WireGuard"
↓
"WireGuard" von Home Assistant Community Add-ons auswählen
↓
"INSTALL" klicken (Dauer ~2-3 Minuten)
```

### 1.2 Add-on konfigurieren

**Configuration Tab:**
```yaml
server:
  host: <DEINE_DYNDNS_DOMAIN>  # z.B. meinzuhause.myfritz.net
  addresses:
    - 10.10.10.1
  port: 51820
  peers:
    - name: handy
      allowed_ips:
        - 10.10.10.2/32
      client_allowed_ips:
        - 192.168.178.0/24  # Heimnetzwerk-Zugriff
    - name: laptop
      allowed_ips:
        - 10.10.10.3/32
      client_allowed_ips:
        - 192.168.178.0/24

log_level: info
```

**Speichern und "START" klicken**

### 1.3 Client-Konfigurationen herunterladen

**Log Tab öffnen:**
```
Add-on → Log Tab

# Du siehst QR-Codes in ASCII-Form!
# Oder unter /config/wireguard/ findest du die .conf-Dateien
```

**Config-Dateien kopieren:**
```bash
# Im Terminal & SSH Add-on:
ls /config/wireguard/

# Dateien anzeigen:
cat /config/wireguard/peer_handy.conf
cat /config/wireguard/peer_laptop.conf

# Diese Configs kannst du auf deine Geräte übertragen
```

### 1.4 Fritz!Box Port-Forwarding
```
Fritz!Box → Internet → Freigaben → Portfreigaben
↓
Gerät: 192.168.178.71 (Home Assistant)
↓
Port: UDP 51820 → 51820
↓
Speichern
```

### 1.5 Test von außen
```
Auf deinem Handy:
1. WireGuard App installieren
2. Config importieren (QR-Code scannen oder Datei)
3. Mobile-Daten aktivieren (WiFi aus!)
4. VPN aktivieren
5. Browser: http://192.168.178.71:8123

Sollte Home Assistant zeigen! ✅
```

---

## Phase 2: Mullvad WireGuard Client (Custom Container) - 2 Stunden

### 2.1 Mullvad Account & Config
```
1. https://mullvad.net/de/ → Konto erstellen
2. Account-Nummer notieren
3. 5€ bezahlen
4. WireGuard-Konfiguration herunterladen:
   → Konto → WireGuard
   → Gerät hinzufügen: "homeassistant"
   → Land: Deutschland - Frankfurt
   → Config herunterladen
```

### 2.2 Config auf Home Assistant hochladen

**Via File Editor Add-on (falls installiert):**
```
Settings → Add-ons → File Editor
↓
/config/mullvad/
↓
Neue Datei: mullvad-de.conf
↓
Inhalt der heruntergeladenen Config einfügen
```

**Oder via Terminal & SSH Add-on:**
```bash
# Verzeichnis erstellen
mkdir -p /config/mullvad

# Config per SCP hochladen (von deinem PC):
scp ~/Downloads/mullvad-de-fra.conf reid15@192.168.178.71:/config/mullvad/mullvad.conf
```

### 2.3 Docker Compose für Mullvad-Client erstellen

**PROBLEM:** Home Assistant OS erlaubt **keine** direkten Docker-Container außerhalb der Add-on-Infrastruktur!

**Lösung:** Wir müssen ein **Custom Add-on** erstellen.

#### 2.3.1 Add-on-Repository erstellen
```bash
# Im Terminal & SSH Add-on:
mkdir -p /addons/wireguard-client
cd /addons/wireguard-client
```

#### 2.3.2 Add-on-Konfiguration

**`config.yaml`:**
```yaml
name: "WireGuard Client (Mullvad)"
version: "1.0.0"
slug: wireguard_client
description: "WireGuard client for privacy VPN (Mullvad)"
arch:
  - aarch64
  - amd64
  - armv7
boot: auto
startup: system
network_mode: host
privileged: true
ports: {}
options:
  config_file: "/config/mullvad/mullvad.conf"
schema:
  config_file: "str"
```

**`Dockerfile`:**
```dockerfile
FROM alpine:latest

# WireGuard installieren
RUN apk add --no-cache wireguard-tools openresolv iproute2 iptables

# Startup-Script
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
```

**`run.sh`:**
```bash
#!/bin/sh
set -e

CONFIG_FILE="$1"

echo "[INFO] Starting WireGuard Client..."
echo "[INFO] Using config: ${CONFIG_FILE}"

# IP-Forwarding aktivieren
echo 1 > /proc/sys/net/ipv4/ip_forward

# WireGuard starten
wg-quick up "${CONFIG_FILE}"

echo "[INFO] WireGuard Client is running"

# Keep container alive
tail -f /dev/null
```

**`README.md`:**
```markdown
# WireGuard Client Add-on

Provides WireGuard client functionality for privacy VPN (e.g., Mullvad).

## Configuration

Place your WireGuard config file in `/config/mullvad/mullvad.conf`.

## Usage

1. Install the add-on
2. Start the add-on
3. Check logs for connection status
```

#### 2.3.3 Add-on installieren
```bash
# Im Terminal & SSH:
ha addons reload

# Add-on sollte jetzt in Settings → Add-ons → Local Add-ons erscheinen
```

⚠️ **PROBLEM:** Home Assistant OS blockiert möglicherweise lokale Add-ons aus Sicherheitsgründen!

**Alternative: Portainer Add-on verwenden**

---

## Phase 3: Alternative mit Portainer (einfacher) - 1 Stunde

### 3.1 Portainer Add-on installieren
```
Settings → Add-ons → Add-on Store
↓
Suche "Portainer"
↓
"Portainer" installieren und starten
↓
Öffne Web UI (Port 9000)
```

### 3.2 WireGuard Container via Portainer

**In Portainer Web UI:**
```
Containers → Add container
↓
Name: wireguard-mullvad
Image: linuxserver/wireguard:latest

Network: host (wichtig!)

Privileged mode: ✅ ON

Environment Variables:
  PUID=0
  PGID=0
  TZ=Europe/Berlin

Volumes:
  /config/mullvad:/config
  /lib/modules:/lib/modules

Capabilities:
  NET_ADMIN
  SYS_MODULE

Restart policy: unless-stopped
↓
Deploy the container
```

### 3.3 Config anpassen
```bash
# Im Terminal & SSH:
nano /config/mullvad/wg0.conf

# Config von Mullvad einfügen (heruntergeladen)
```

### 3.4 Container starten
```bash
# In Portainer:
wireguard-mullvad → Start
↓
Logs prüfen → Sollte "WireGuard is running" zeigen
```

---

## Phase 4: Gateway-Routing (EINGESCHRÄNKT) - 1 Stunde

⚠️ **Wichtiger Hinweis:**
Home Assistant OS erlaubt **keine persistenten iptables-Regeln** außerhalb von Containern!

**Was möglich ist:**
- ✅ WireGuard Server funktioniert (via Add-on)
- ✅ WireGuard Client funktioniert (via Container)
- ❌ Automatisches Gateway für alle Netzwerk-Geräte **nicht** möglich
- ⚠️ Nur Geräte die **manuell** den Pi als Gateway setzen nutzen den VPN

### 4.1 Firewall-Regeln (temporär, nach Reboot weg!)

**Im Terminal & SSH:**
```bash
# IP-Forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# NAT für Mullvad-Traffic
iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE

# Lokaler Traffic direkt
iptables -t nat -I POSTROUTING -s 192.168.178.0/24 -d 192.168.178.0/24 -j ACCEPT

# Forwarding erlauben
iptables -A FORWARD -i eth0 -o wg0 -j ACCEPT
iptables -A FORWARD -i wg0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
```

**PROBLEM:** Diese Regeln sind nach Reboot **weg**!

**Workaround:** Script in Home Assistant Automation:
```yaml
# In automations.yaml:
- id: vpn_gateway_rules
  alias: "VPN Gateway: Apply Firewall Rules on Boot"
  trigger:
    - platform: homeassistant
      event: start
  action:
    - service: shell_command.vpn_gateway_rules

# In configuration.yaml:
shell_command:
  vpn_gateway_rules: >
    echo 1 > /proc/sys/net/ipv4/ip_forward &&
    iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE &&
    iptables -t nat -I POSTROUTING -s 192.168.178.0/24 -d 192.168.178.0/24 -j ACCEPT &&
    iptables -A FORWARD -i eth0 -o wg0 -j ACCEPT &&
    iptables -A FORWARD -i wg0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
```

⚠️ **Auch das ist unsauber und fehleranfällig!**

### 4.2 Manuelle Gateway-Konfiguration auf Clients

**Auf jedem Gerät (PC, Handy, etc.) das den VPN nutzen soll:**

**Windows:**
```
Netzwerkeinstellungen → Adapter-Optionen → Ethernet/WiFi
→ Eigenschaften → Internet Protocol Version 4 (TCP/IPv4)
→ Eigenschaften → Erweitert
→ Standardgateway: 192.168.178.71 hinzufügen (höhere Metrik als Standard)
```

**Android:**
```
Einstellungen → WLAN → Netzwerk
→ Erweiterte Optionen
→ IP-Einstellungen: Statisch
→ Gateway: 192.168.178.71
```

**Linux/Mac:**
```bash
# Route temporär hinzufügen
sudo ip route add default via 192.168.178.71 metric 50

# Dauerhaft in NetworkManager/System Preferences
```

---

## Phase 5: Testing - 30 Minuten

### 5.1 VPN-Server Test
```bash
# Von außen (Handy mit Mobile-Daten):
WireGuard App → VPN aktivieren
Browser: http://192.168.178.71:8123

Sollte funktionieren! ✅
```

### 5.2 Mullvad-Client Test
```bash
# Im Terminal & SSH:
curl https://am.i.mullvad.net/connected

# Sollte zeigen:
# You are connected to Mullvad...
```

### 5.3 Gateway Test (auf Client-PC)
```bash
# Auf deinem PC (mit Gateway 192.168.178.71 gesetzt):
curl https://ipinfo.io/ip

# Sollte Mullvad-IP zeigen (wenn Gateway richtig konfiguriert)
```

---

## 🚨 Bekannte Probleme & Einschränkungen

### Problem 1: Firewall-Regeln nicht persistent
**Symptom:** Nach Reboot funktioniert Gateway nicht mehr
**Lösung:** Home Assistant Automation (siehe oben) oder **Option A verwenden!**

### Problem 2: Split-Routing nicht zuverlässig
**Symptom:** VPN-Server-Traffic geht über Mullvad
**Lösung:** Policy-Based Routing in Home Assistant OS **nicht** möglich → **Option A verwenden!**

### Problem 3: Performance-Probleme
**Symptom:** Home Assistant reagiert langsam, hohe CPU-Last
**Lösung:** WireGuard-Container stoppen oder **Option A verwenden!**

### Problem 4: Container startet nicht nach Reboot
**Symptom:** WireGuard-Client-Container ist gestoppt nach Neustart
**Lösung:** Restart policy in Portainer prüfen, oder **Option A verwenden!**

---

## 📊 Vergleich Option A vs. B

| Kriterium | Option A (2. Pi) | Option B (Container) |
|-----------|------------------|----------------------|
| **Stabilität** | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| **Performance** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Gateway für alle Geräte** | ✅ Ja | ❌ Nur manuell |
| **Split-Routing** | ✅ Ja | ❌ Nicht zuverlässig |
| **Persistente Config** | ✅ Ja | ⚠️ Teilweise |
| **HA-Impact** | ✅ Keiner | 🔴 Mittel-Hoch |
| **Wartung** | ⭐⭐⭐⭐⭐ | ⭐⭐ |

**Fazit:** Option B ist **möglich**, aber mit vielen Einschränkungen. **Option A wird dringend empfohlen!**

---

## 📞 Nächste Schritte

**Wenn du trotzdem Option B nutzen möchtest:**
1. WireGuard Add-on installieren (Phase 1)
2. Portainer installieren (Phase 3.1-3.2)
3. Mullvad-Container erstellen (Phase 3.2-3.4)
4. Manuell Gateway auf jedem Gerät setzen (Phase 4.2)
5. Testing durchführen (Phase 5)

**Empfehlung:** Investiere ~40€ in einen Raspberry Pi Zero 2 W und nutze **Option A** für ein stabiles, zuverlässiges System!

**Fragen?** Teile mir deine Entscheidung mit, dann helfe ich dir weiter.
