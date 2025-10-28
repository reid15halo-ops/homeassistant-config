# Dual WireGuard VPN Setup für Home Assistant OS

**Ziel:** VPN-Server (Zugriff von außen) + VPN-Client (Privacy über Mullvad) auf einem Raspberry Pi

**System:** Home Assistant OS auf Raspberry Pi 4
**Technologie:** WireGuard (Server + Client)
**Zeitaufwand:** 4-5 Stunden
**Schwierigkeit:** Fortgeschritten

---

## ⚠️ Wichtige Hinweise VOR dem Start

### Home Assistant OS Einschränkungen
Home Assistant OS ist **kein vollständiges Linux** - es ist ein stark eingeschränktes Container-System.

**Das bedeutet:**
- ❌ Kein `apt install` verfügbar
- ❌ Keine persistenten System-Änderungen außerhalb `/config`
- ❌ Kernel-Module können nicht dauerhaft geladen werden
- ✅ Nur Add-ons und Container funktionieren zuverlässig

### Empfohlene Architektur-Änderung

**ORIGINAL-PLAN (auf Home Assistant OS schwierig):**
```
Internet → Fritz!Box → Raspberry Pi (HA + Dual-WireGuard) → Netzwerk-Geräte
```

**EMPFOHLENE LÖSUNG (stabiler und performanter):**

#### Option A: Zweiter Raspberry Pi als Gateway (BESTE Lösung)
```
Internet → Fritz!Box → Raspberry Pi Zero 2 W (Dual-WireGuard Gateway)
                              ↓
                     Raspberry Pi 4 (Home Assistant)
                              ↓
                     Alle anderen Netzwerk-Geräte
```

**Vorteile:**
- ✅ Vollständige Kontrolle über System
- ✅ Keine Performance-Probleme für Home Assistant
- ✅ Einfacheres Troubleshooting
- ✅ Kosten: ~40€ für Raspberry Pi Zero 2 W

**Nachteile:**
- 🔴 Zusätzliche Hardware erforderlich

---

#### Option B: WireGuard Add-on + Custom Container (KOMPROMISS)
```
Home Assistant OS
├── Home Assistant Core (Container)
├── WireGuard Add-on (Server-Funktionalität)
└── Custom WireGuard-Client Container (Privacy-VPN)
```

**Vorteile:**
- ✅ Keine zusätzliche Hardware
- ✅ WireGuard Server über offizielles Add-on (stabil)
- ⚠️ Client-Container möglich aber komplex

**Nachteile:**
- 🔴 Gateway-Funktionalität eingeschränkt (nur Geräte die Raspberry Pi als Gateway setzen)
- 🔴 Performance-Impact auf Home Assistant möglich
- 🔴 Split-Routing sehr komplex

---

#### Option C: Migration zu Raspberry Pi OS (MAXIMAL flexibel)
```
Raspberry Pi OS (statt Home Assistant OS)
├── Home Assistant Core (Docker Container)
├── WireGuard Server (nativ)
├── WireGuard Client (nativ)
└── Vollständige Gateway-Funktionalität
```

**Vorteile:**
- ✅ Vollständige Linux-Umgebung
- ✅ Original-Plan 1:1 umsetzbar
- ✅ Maximale Kontrolle

**Nachteile:**
- 🔴 Migration erforderlich (Backup → Neuinstallation → Restore)
- 🔴 Mehraufwand initial (~2-3 Stunden)
- 🔴 Home Assistant Supervisor Features teilweise eingeschränkt

---

## 🎯 Entscheidungshilfe

| Kriterium | Option A (2. Pi) | Option B (Container) | Option C (Migration) |
|-----------|------------------|----------------------|----------------------|
| **Kosten** | ~40€ | 0€ | 0€ |
| **Setup-Zeit** | 3-4h | 5-6h | 6-8h |
| **Stabilität** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Performance** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Wartung** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ |
| **Gateway für alle Geräte** | ✅ Ja | ⚠️ Eingeschränkt | ✅ Ja |
| **HA-Impact** | ✅ Keiner | 🔴 Mittel | ⚠️ Gering |

**Meine Empfehlung: Option A (Zweiter Raspberry Pi)**

---

## 📋 Detaillierte Implementierung nach Option

### Fortsetzung für gewählte Option:

Bitte wähle eine der drei Optionen, dann erstelle ich die detaillierten Implementierungs-Schritte:

1. **Option A:** Raspberry Pi Zero 2 W als Gateway (Einkaufsliste + Setup-Anleitung)
2. **Option B:** Dual-Container auf Home Assistant OS (Add-on + Custom-Container)
3. **Option C:** Migration zu Raspberry Pi OS (Migrations-Anleitung)

---

## 🔍 Quick-Check: Was ist bereits auf deinem System?

Führe im **Terminal & SSH Add-on** der Home Assistant UI folgende Befehle aus:

```bash
# 1. Home Assistant Version
ha core info

# 2. Installierte Add-ons
ha addons

# 3. Verfügbare Ressourcen
free -h

# 4. CPU Last
uptime

# 5. Kernel-Module prüfen (wahrscheinlich eingeschränkt)
lsmod | grep wireguard || echo "WireGuard-Modul nicht geladen oder nicht verfügbar"

# 6. Netzwerk-Konfiguration
ip addr show
```

**Teile mir die Ausgabe mit**, dann kann ich die beste Option für dein spezifisches System wählen.

---

## 📞 Support

Wenn du Fragen hast oder Hilfe bei der Entscheidung brauchst:
- Führe die Quick-Check-Befehle aus
- Teile mir deine Prioritäten mit (Kosten vs. Stabilität vs. Zeit)
- Wir passen den Plan entsprechend an

**Nächster Schritt:** Entscheide dich für eine Option oder teile die Quick-Check-Ergebnisse.
