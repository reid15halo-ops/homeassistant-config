# Mullvad VPN - Registrierung & Einrichtung

**Mullvad** ist ein Privacy-fokussierter VPN-Anbieter aus Schweden mit nativer WireGuard-Unterstützung.

**Kosten:** 5€ / Monat (keine Abos, Prepaid)
**Website:** https://mullvad.net/de/

---

## 🎯 Warum Mullvad?

### ✅ Vorteile
- **Native WireGuard-Unterstützung** - Beste Performance
- **No-Logs-Policy** - Keine Aktivitätsprotokolle
- **Keine E-Mail-Adresse nötig** - Maximale Anonymität
- **Anonyme Bezahlung** - Bitcoin, Bargeld per Post möglich
- **Open Source** - Apps und Code einsehbar
- **Servers in 40+ Ländern** - Inkl. Deutschland
- **Unlimited Devices** - Keine Gerätebeschränkung
- **Kill-Switch** - Verhindert Datenlecks
- **Port-Forwarding** - Optional verfügbar

### ⚠️ Nachteile
- Kein Streaming-Support (Netflix etc. blockt VPN-IPs)
- Weniger Server als große Anbieter (NordVPN, ExpressVPN)
- Keine Lifetime-Angebote

### Alternativen
- **ProtonVPN** - Schweizer Anbieter, ähnlich privacy-fokussiert
- **IVPN** - Noch anonymer, aber teurer (~10€/Monat)
- **NordVPN** - Mehr Features, aber weniger Privacy-fokussiert

**Empfehlung:** Für Privacy + WireGuard ist Mullvad die beste Wahl!

---

## 📝 Registrierung (5 Minuten)

### Schritt 1: Account erstellen

1. Öffne: **https://mullvad.net/de/**
2. Klicke: **"Konto erstellen"**
3. **Account-Nummer wird generiert** (16 Ziffern)

**WICHTIG:** Diese Nummer ist dein einziger "Benutzername"!

**Beispiel:** `1234 5678 9012 3456`

### Schritt 2: Account-Nummer speichern

**⚠️ UNBEDINGT SICHER AUFBEWAHREN!**

Speichere die Account-Nummer an einem sicheren Ort:
- ✅ Passwort-Manager (z.B. Bitwarden, 1Password)
- ✅ Verschlüsseltes Backup
- ✅ Ausgedruckt an sicherem Ort

**OHNE diese Nummer:**
- ❌ Kannst du nicht einloggen
- ❌ Kannst du kein Guthaben aufladen
- ❌ Kannst du Account nicht wiederherstellen

→ **Mullvad hat KEINE Möglichkeit, einen vergessenen Account wiederherzustellen!**

---

## 💳 Guthaben aufladen

Mullvad funktioniert **Prepaid** - du zahlst im Voraus für 1-12 Monate.

**Kosten:** 5€ pro Monat

### Zahlungsmethoden

#### Option 1: Kreditkarte / Debitkarte (schnellste Methode)
1. Einloggen: https://mullvad.net/de/account/
2. "Mehr Zeit kaufen" → "Kreditkarte"
3. Monate wählen (1-12)
4. Kartendaten eingeben
5. Bezahlen
6. **Sofort aktiv!** ✅

---

#### Option 2: PayPal
1. "Mehr Zeit kaufen" → "PayPal"
2. Monate wählen
3. PayPal-Login
4. Bezahlen
5. **Sofort aktiv!** ✅

---

#### Option 3: Bitcoin (Anonym)
1. "Mehr Zeit kaufen" → "Bitcoin"
2. Monate wählen
3. Bitcoin-Adresse wird angezeigt
4. Betrag überweisen
5. Nach 1-3 Bestätigungen aktiv (~10-60 Minuten)

**Vorteil:** Maximale Anonymität

---

#### Option 4: Bargeld per Post (100% Anonym)
1. "Mehr Zeit kaufen" → "Bargeld"
2. Account-Nummer auf Zettel schreiben
3. Bargeld (5€, 10€, 15€, ...) in Umschlag
4. Senden an:

```
Amagicom AB
Box 53049
40014 Göteborg
Schweden
```

5. **Achtung:** Dauer 1-3 Wochen!

**Vorteil:** 100% anonym, keine digitalen Spuren

---

## 🔑 WireGuard-Konfiguration herunterladen

### Schritt 1: Einloggen

1. https://mullvad.net/de/account/
2. Account-Nummer eingeben
3. Einloggen

### Schritt 2: Gerät hinzufügen

1. → **"WireGuard-Konfiguration"**
2. → **"Gerät hinzufügen"**

**Name eingeben:**
```
vpngateway
```

(Du kannst auch mehrere Geräte hinzufügen: `vpngateway`, `laptop`, `handy`, etc.)

3. **Key wird automatisch generiert** ✅

### Schritt 3: Server-Standort auswählen

**Deutschland:**
- `de-fra` - Frankfurt (niedrigste Latenz für Deutschland)
- `de-ber` - Berlin
- `de-dus` - Düsseldorf

**Andere Länder:**
- `ch-zrh` - Zürich (Schweiz - hohe Privatsphäre)
- `se-sto` - Stockholm (Schweden - Mullvad-Hauptsitz)
- `nl-ams` - Amsterdam (Niederlande)
- `at-vie` - Wien (Österreich)

**Empfehlung:** `de-fra` (Frankfurt) für beste Performance

### Schritt 4: Konfiguration herunterladen

1. Server auswählen (z.B. "Deutschland - Frankfurt")
2. **"Konfiguration herunterladen"** klicken
3. Datei wird gespeichert: `mullvad-de-fra.conf` (oder ähnlich)

**Speicherort:** `~/Downloads/mullvad-de-fra.conf`

---

## 📤 Konfiguration auf Gateway Pi hochladen

### Methode 1: SCP (Secure Copy)

**Von deinem PC aus:**
```bash
# Datei auf Gateway Pi kopieren
scp ~/Downloads/mullvad-de-fra.conf pi@192.168.178.2:/tmp/

# Auf Gateway Pi einloggen
ssh pi@192.168.178.2

# Datei an richtige Stelle verschieben
sudo mv /tmp/mullvad-de-fra.conf /etc/wireguard/wg1.conf
sudo chmod 600 /etc/wireguard/wg1.conf
```

### Methode 2: Manuell kopieren

**Auf Gateway Pi:**
```bash
# Datei erstellen
sudo nano /etc/wireguard/wg1.conf

# Inhalt der heruntergeladenen Datei einfügen (Strg+Shift+V)
# Speichern: Strg+O, Enter, Strg+X

# Rechte setzen
sudo chmod 600 /etc/wireguard/wg1.conf
```

---

## ✅ Mullvad-Client starten

### Service aktivieren und starten
```bash
# Autostart aktivieren
sudo systemctl enable wg-quick@wg1

# Starten
sudo systemctl start wg-quick@wg1

# Status prüfen
sudo systemctl status wg-quick@wg1
```

**Erwartete Ausgabe:**
```
● wg-quick@wg1.service - WireGuard via wg-quick(8) for wg1
   Loaded: loaded
   Active: active (exited) since ...
```

### Verbindung testen
```bash
# IP-Check (sollte Mullvad-IP zeigen)
curl https://am.i.mullvad.net/connected
```

**Erwartete Ausgabe:**
```
You are connected to Mullvad (server de-fra). Your IP address is 185.x.x.x
```

✅ **Verbindung funktioniert!**

---

## 🔍 Mullvad-Account verwalten

### Account-Status prüfen
```
https://mullvad.net/de/account/
→ Zeigt: Verbleibendes Guthaben, z.B. "30 Tage"
```

### Mehr Guthaben aufladen
```
→ "Mehr Zeit kaufen"
→ Zahlungsmethode wählen
```

### Geräte verwalten
```
→ "WireGuard-Konfiguration"
→ Zeigt alle hinzugefügten Geräte
→ Löschen via "Gerät entfernen"
```

### Server wechseln

**Neue Config herunterladen:**
```
1. Account → WireGuard → Gerät auswählen
2. Anderes Land/Stadt wählen
3. Neue Config herunterladen
4. Auf Gateway Pi ersetzen:
   sudo mv /tmp/mullvad-neu.conf /etc/wireguard/wg1.conf
5. Service neu starten:
   sudo systemctl restart wg-quick@wg1
```

### Account kündigen

**Es gibt KEINE Kündigung!**
- Mullvad ist Prepaid (kein Abo)
- Guthaben läuft einfach ab
- Account bleibt bestehen (kann später wieder aufgeladen werden)

---

## 🌐 Erweiterte Funktionen

### Port-Forwarding (optional)

**Verwendung:** Für Torrents, Gaming-Server, Self-Hosting

**Aktivieren:**
```
1. https://mullvad.net/de/account/
2. → "Port-Forwarding"
3. → "Zufälligen Port anfordern"
4. Port wird zugewiesen (z.B. 51234)
5. Nutzen in Firewall/Router-Config
```

### Multihop (Double-VPN)

**Zweck:** Traffic über 2 VPN-Server (maximale Privatsphäre)

**Setup:**
```
1. Account → WireGuard → "Multihop aktivieren"
2. Eingangs-Server wählen (z.B. Deutschland)
3. Ausgangs-Server wählen (z.B. Schweiz)
4. Config herunterladen
```

**Nachteile:**
- Doppelte Latenz
- Geringere Geschwindigkeit
- Nur für Paranoia nötig

---

## 🆘 Troubleshooting

### Problem: "Account number not found"

**Lösung:**
- Account-Nummer prüfen (16 Ziffern, nur Zahlen)
- Keine Leerzeichen eingeben
- Groß-/Kleinschreibung ist egal

### Problem: "No time left"

**Lösung:**
- Guthaben aufladen (siehe oben)
- Minimum 5€ für 1 Monat

### Problem: "Can't connect to Mullvad"

**Lösung:**
```bash
# Service-Status prüfen
sudo systemctl status wg-quick@wg1

# Logs anschauen
sudo journalctl -u wg-quick@wg1 -n 50

# Verbindung testen
ping de-fra.mullvad.net

# Service neu starten
sudo systemctl restart wg-quick@wg1
```

### Problem: "Connected but no internet"

**Lösung:**
```bash
# DNS prüfen
nslookup google.com 10.64.0.1

# Routing prüfen
ip route show

# Gateway-Regeln neu anwenden
sudo /etc/wireguard/gateway-rules.sh
```

### Problem: Langsame Verbindung

**Lösung:**
```bash
# 1. Anderen Server ausprobieren (z.B. Berlin statt Frankfurt)
# 2. MTU anpassen:
sudo ip link set mtu 1420 dev wg1

# 3. Speedtest
curl -s https://mullvad.net/en/check/ | grep Speed
```

---

## 📊 Mullvad vs. Alternativen

| Anbieter | Preis/Monat | WireGuard | No-Logs | Anonym | Empfehlung |
|----------|-------------|-----------|---------|--------|------------|
| **Mullvad** | 5€ | ✅ Native | ✅ Ja | ✅ Ja | ⭐⭐⭐⭐⭐ |
| ProtonVPN | 4-10€ | ✅ Native | ✅ Ja | ⚠️ E-Mail nötig | ⭐⭐⭐⭐ |
| IVPN | ~10€ | ✅ Native | ✅ Ja | ✅ Ja | ⭐⭐⭐⭐ (teurer) |
| NordVPN | 3-12€ | ⚠️ NordLynx | ⚠️ Claims | ❌ Nein | ⭐⭐⭐ |
| ExpressVPN | 8-13€ | ❌ Lightway | ⚠️ Claims | ❌ Nein | ⭐⭐⭐ |

**Legende:**
- ✅ = Voll unterstützt / Empfohlen
- ⚠️ = Eingeschränkt / Prüfen
- ❌ = Nicht verfügbar / Nicht empfohlen

---

## 📞 Mullvad Support

**Website:** https://mullvad.net/de/help/
**E-Mail:** support@mullvad.net
**Response-Zeit:** 1-3 Werktage

**Hilfreiche Links:**
- WireGuard-Setup: https://mullvad.net/en/help/wireguard-and-mullvad-vpn/
- Troubleshooting: https://mullvad.net/en/help/troubleshooting-guide/
- FAQ: https://mullvad.net/en/help/faq/

---

## ✅ Checkliste

**Account-Einrichtung:**
- [ ] Account erstellt
- [ ] Account-Nummer sicher gespeichert
- [ ] Guthaben aufgeladen (min. 5€)
- [ ] WireGuard-Gerät hinzugefügt (`vpngateway`)
- [ ] Server-Standort gewählt (z.B. `de-fra`)
- [ ] Config heruntergeladen

**Gateway-Konfiguration:**
- [ ] Config auf Gateway Pi hochgeladen (`/etc/wireguard/wg1.conf`)
- [ ] Service aktiviert (`systemctl enable wg-quick@wg1`)
- [ ] Service gestartet (`systemctl start wg-quick@wg1`)
- [ ] Verbindung getestet (`curl https://am.i.mullvad.net/connected`)

**Funktionstest:**
- [ ] Mullvad-IP wird angezeigt
- [ ] Internet funktioniert über VPN
- [ ] Heimnetzwerk-Geräte nutzen VPN (Gateway konfiguriert)
- [ ] Split-Routing funktioniert (VPN-Server direkt, Rest über Mullvad)

---

**Viel Erfolg mit Mullvad!** 🚀

**Nächster Schritt:** Siehe `VPN_SETUP_CHECKLIST.md` für vollständige Gateway-Einrichtung.
