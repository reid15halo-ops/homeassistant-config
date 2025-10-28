# 🛒 VPN-Gateway Shopping List

## Empfohlenes Setup (~40-50€)

### ✅ Pflicht-Komponenten

#### 1. Raspberry Pi Zero 2 W (~16€)
**Warum dieser?**
- 4x ARM Cortex-A53 @ 1 GHz (ausreichend für VPN)
- 512 MB RAM
- Integriertes WiFi & Bluetooth
- VPN-Durchsatz: **100-200 Mbit/s**
- Sehr stromsparend (~2-3W)

**Kaufempfehlungen:**
- Amazon: "Raspberry Pi Zero 2 W"
- Alternate.de: https://www.alternate.de (oft auf Lager)
- Berrybase.de: https://www.berrybase.de
- Pi-Shop.ch: https://www.pi-shop.ch (für Schweiz)

**Preis:** ~15-18€

---

#### 2. MicroSD-Karte 32 GB (~10€)
**Mindestanforderungen:**
- Kapazität: 16-32 GB (32 GB empfohlen)
- Klasse: Class 10 / UHS-I (U1)
- Schreibgeschwindigkeit: min. 10 MB/s

**Empfohlene Modelle:**
- ✅ **SanDisk Ultra 32GB** (zuverlässig, günstig)
- ✅ **Samsung EVO Select 32GB** (schneller)
- ⚠️ NICHT: No-Name-Karten (Korruptionsgefahr!)

**Kaufempfehlungen:**
- Amazon: "SanDisk Ultra 32GB microSDHC"
- MediaMarkt / Saturn (oft im Angebot)

**Preis:** ~8-12€

---

#### 3. USB-C Netzteil 5V / 2.5A (~10€)
**Wichtig:** Raspberry Pi Zero 2 W benötigt **USB-C** (nicht Micro-USB wie Zero 1!)

**Empfohlene Netzteile:**
- ✅ **Offizielles Raspberry Pi Netzteil 5.1V/2.5A** (beste Wahl)
- ✅ Hochwertige Handy-Netzteile (min. 2A, USB-C)

**Kaufempfehlungen:**
- Amazon: "Raspberry Pi Zero 2 Netzteil"
- Berrybase: Offizielles Netzteil

**Preis:** ~8-12€

---

### 📦 Minimal-Setup Zusammenfassung
```
Raspberry Pi Zero 2 W        16€
MicroSD-Karte 32GB           10€
USB-C Netzteil 2.5A          10€
─────────────────────────────────
GESAMT:                      ~36€
```

---

## 🔌 Optionale Komponenten

### 4. USB-Ethernet-Adapter (~12€) - EMPFOHLEN für Stabilität
**Warum?**
- WiFi kann instabil sein unter Last
- Ethernet = niedrigere Latenz
- Zuverlässigere Verbindung

**Empfohlene Modelle:**
- ✅ **TP-Link UE300** (USB 3.0, Gigabit, ~12€)
- ✅ **AmazonBasics USB 3.0 Ethernet Adapter** (~10€)
- ⚠️ Achte auf: "USB 3.0" und "Gigabit"

**Wichtig:** Pi Zero 2 W hat nur Micro-USB (OTG), du brauchst zusätzlich:
- **Micro-USB OTG Adapter** (~3€) ODER
- **USB-C to USB-A Adapter** (~3€)

**Preis:** ~12-15€ (Adapter + OTG-Kabel)

---

### 5. Gehäuse (~5-8€) - EMPFOHLEN für Langlebigkeit
**Warum?**
- Schützt vor Staub und Beschädigung
- Verhindert Kurzschlüsse
- Optional mit Kühlkörper

**Empfohlene Modelle:**
- ✅ Offizielles Raspberry Pi Zero Case (~5€)
- ✅ Flirc Case (passiver Kühler, ~15€) - bei hoher Last
- ✅ Transparentes Acryl-Gehäuse (~6€)

**Preis:** ~5-15€

---

### 6. Zubehör
- **Micro-USB OTG Kabel** (~3€) - falls Ethernet-Adapter verwendet wird
- **HDMI-Mini-zu-HDMI-Kabel** (~5€) - nur für Debugging, nicht im Betrieb nötig
- **Heatsink-Set** (~3€) - bei Überhitzungsproblemen

---

## 💎 Premium-Setup (bessere Performance)

### Alternative: Raspberry Pi 4 Model B (2GB) (~50€)

**Vorteile gegenüber Zero 2 W:**
- 4x ARM Cortex-A72 @ 1.5 GHz (schneller)
- 2 GB RAM (mehr Headroom)
- **Gigabit Ethernet onboard** (kein USB-Adapter nötig!)
- VPN-Durchsatz: **300-500 Mbit/s**
- USB 3.0 Ports

**Nachteile:**
- Höherer Stromverbrauch (~5-8W)
- Teurer (~50€ statt 16€)
- Größer (braucht mehr Platz)

**Empfehlung:** Nur wenn du >200 Mbit/s Internet-Leitung hast!

**Premium-Setup Zusammenfassung:**
```
Raspberry Pi 4 Model B (2GB)  50€
MicroSD-Karte 32GB            10€
USB-C Netzteil 5V/3A          15€
Gehäuse mit Lüfter             8€
─────────────────────────────────
GESAMT:                      ~83€
```

---

## 🌐 VPN-Provider: Mullvad

**Kosten:** 5€ / Monat (keine Abos, prepaid)
**Registrierung:** https://mullvad.net/de/

**Warum Mullvad?**
- ✅ Native WireGuard-Unterstützung
- ✅ No-Logs-Policy (datenschutzfreundlich)
- ✅ Keine E-Mail-Adresse nötig
- ✅ Bezahlung anonym möglich (Bitcoin, Cash)
- ✅ Servers in Deutschland verfügbar

**Alternativen:**
- **ProtonVPN** - Schweizer Anbieter, auch gut
- **IVPN** - Privacy-fokussiert, etwas teurer
- ⚠️ **NordVPN/ExpressVPN** - WireGuard-Support eingeschränkt

---

## 📦 Schnell-Bestellung

### Option A: Komplett-Paket
**Berrybase.de "Raspberry Pi Zero 2 W Set"** (~45€)
- Enthält: Pi, Netzteil, Gehäuse, SD-Karte
- Vorteil: Alles aus einer Hand, schnelle Lieferung
- Link: https://www.berrybase.de/sets

### Option B: Einzeln bestellen (günstiger)
```
Amazon:
  - Raspberry Pi Zero 2 W              16€
  - SanDisk Ultra 32GB                 10€
  - Offizielles RPi Netzteil USB-C     10€
  - TP-Link UE300 Ethernet-Adapter    12€
  - RPi Zero Case                       6€
  ─────────────────────────────────────────
  GESAMT:                              54€

Lieferzeit: 2-5 Werktage
```

---

## ✅ Bestell-Checkliste

**Vor der Bestellung prüfen:**
- [ ] Raspberry Pi Zero 2 W (nicht Zero 1!)
- [ ] **USB-C** Netzteil (nicht Micro-USB!)
- [ ] MicroSD-Karte mindestens 16 GB, Class 10
- [ ] Optional: Ethernet-Adapter + OTG-Kabel
- [ ] Optional: Gehäuse
- [ ] Mullvad-Account erstellt (oder Alternative gewählt)

**Nach Bestellung:**
- [ ] Lieferung abwarten (2-5 Tage)
- [ ] Mullvad-Account aufladen (5€)
- [ ] `VPN_OPTION_A_HARDWARE.md` durchlesen
- [ ] Raspberry Pi Imager auf PC installieren

---

## 🔍 Hardware-Vergleich

| Modell | CPU | RAM | Ethernet | VPN-Speed | Preis | Empfehlung |
|--------|-----|-----|----------|-----------|-------|------------|
| **Pi Zero 2 W** | 1.0 GHz | 512 MB | Via USB | 100-200 Mbit/s | ~16€ | ✅ Beste Wahl für die meisten |
| Pi 4 (2GB) | 1.5 GHz | 2 GB | Onboard | 300-500 Mbit/s | ~50€ | Nur bei >200 Mbit/s Internet |
| Pi 3 B+ | 1.4 GHz | 1 GB | 300 Mbit/s | 100-200 Mbit/s | ~35€ | OK, aber Zero 2 W ist besser |

**Entscheidungshilfe:**
- Internet ≤ 200 Mbit/s → **Pi Zero 2 W** (16€) ✅
- Internet > 200 Mbit/s → **Pi 4 Model B** (50€)
- Budget egal, maximale Performance → **Pi 4 4GB** (70€)

---

## 📞 Weitere Fragen?

**Wo kaufen in Deutschland?**
- Berrybase.de (spezialisiert auf Raspberry Pi)
- Reichelt.de
- Conrad.de
- Amazon.de

**Lieferzeit?**
- Deutschland: 2-5 Werktage
- Pi Zero 2 W oft ausverkauft → mehrere Shops prüfen!

**Bezahlung?**
- Alle gängigen Methoden (Kreditkarte, PayPal, Rechnung)
- Mullvad: Kreditkarte, PayPal, Bitcoin, Bargeld per Post

---

## 🎯 Nächster Schritt

Nach der Bestellung:
1. Warte auf Lieferung (2-5 Tage)
2. Mullvad-Account erstellen und aufladen
3. **Folge dann:** `VPN_OPTION_A_HARDWARE.md` für die Installation

**Viel Erfolg beim Setup!** 🚀
