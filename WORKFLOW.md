# Home Assistant Git Workflow

Dieses Dokument beschreibt, wie du mit diesem Git-Repository arbeitest, um deine Home Assistant Konfiguration zu verwalten.

## Repository-Übersicht

- **GitHub Repository:** https://github.com/reid15halo-ops/homeassistant-config
- **Lokaler Pfad (Windows):** `C:\Users\reid1\source\repos\homeassistant-config`
- **Raspberry Pi Pfad:** `/config` (auf 192.168.178.71)
- **Privates Repository** (deine sensiblen Daten sind geschützt)

## Workflow für Änderungen

### Option 1: Entwicklung auf Windows → Deploy auf Pi (Empfohlen)

Dieser Workflow ist ideal für größere Änderungen, Automatisierungen und wenn du mit Claude Code zusammenarbeitest.

#### 1. Änderungen lokal vornehmen

```bash
cd /c/Users/reid1/source/repos/homeassistant-config

# Mit Claude Code arbeiten, z.B.:
# - Neue Automatisierungen in automations.yaml
# - Scripts in scripts.yaml
# - Packages hinzufügen
```

#### 2. Änderungen testen (optional, vor Commit)

```bash
# YAML-Syntax prüfen (wenn du einen YAML-Validator installiert hast)
yamllint automations.yaml

# Oder einfach in VS Code öffnen und Syntax prüfen
code automations.yaml
```

#### 3. Änderungen committen

```bash
git add .
git commit -m "Add: Neue Automation für Rollladen"
git push
```

#### 4. Auf Raspberry Pi pullen und anwenden

```bash
# Via SSH auf dem Pi
ssh reid15@192.168.178.71

# In das config-Verzeichnis wechseln
cd /config

# Änderungen vom Repository holen
sudo git pull

# Home Assistant Konfiguration neu laden (ohne Neustart)
ha core reload

# Oder nur Automationen neu laden:
# ha automation reload
```

#### 5. In Home Assistant testen

- Öffne Home Assistant UI: http://192.168.178.70:8123
- Gehe zu Entwicklertools → YAML → Konfiguration prüfen
- Teste die neuen Automatisierungen

### Option 2: Direkte Änderungen auf Pi → Sync zurück

Wenn du über die Home Assistant UI Änderungen machst (z.B. Automatisierungen über den UI-Editor), werden diese direkt in die YAML-Dateien geschrieben.

#### 1. UI-Änderungen committen

```bash
# Via SSH auf dem Pi
ssh reid15@192.168.178.71
cd /config

# Status prüfen
sudo git status

# Änderungen committen
sudo git add automations.yaml  # oder andere geänderte Dateien
sudo git commit -m "UI: Automation für Licht angepasst"
sudo git push
```

#### 2. Auf Windows pullen

```bash
cd /c/Users/reid1/source/repos/homeassistant-config
git pull
```

## Wichtige Git-Befehle

### Auf Windows (lokale Entwicklung)

```bash
# Status anzeigen
git status

# Änderungen anzeigen
git diff

# Änderungen stagen
git add .
git add automations.yaml  # oder spezifische Datei

# Committen
git commit -m "Beschreibung der Änderung"

# Pushen
git push

# Pullen (Änderungen vom Pi holen)
git pull

# Log anzeigen
git log --oneline -10
```

### Auf Raspberry Pi (via SSH)

```bash
ssh reid15@192.168.178.71

# Alle Befehle mit sudo ausführen!
cd /config

# Status
sudo git status

# Pullen
sudo git pull

# Committen
sudo git add .
sudo git commit -m "Beschreibung"
sudo git push

# Log
sudo git log --oneline -10
```

## Best Practices

### Do's ✓

- **Immer vor Änderungen pullen:** `git pull` bevor du anfängst
- **Beschreibende Commit-Messages:** "Add: Rollladen-Automation für Sonnenschutz"
- **Kleine, fokussierte Commits:** Lieber öfter committen als alles auf einmal
- **Testen vor dem Push:** Konfiguration in HA prüfen
- **Backup-Strategie:** Das Repository ist dein Backup, committe regelmäßig

### Don'ts ✗

- **Niemals secrets.yaml committen** (ist bereits in .gitignore)
- **Keine API-Keys, Passwörter oder Tokens** ins Repository
- **Nicht auf Pi UND Windows gleichzeitig arbeiten** ohne zu pullen (Merge-Konflikte)
- **Keine direkten Datei-Edits auf Pi UND Windows** ohne Sync

## Typische Szenarien

### Szenario 1: Neue Automation mit Claude Code erstellen

```bash
# 1. Auf Windows
cd /c/Users/reid1/source/repos/homeassistant-config

# 2. Mit Claude Code arbeiten
# Claude erstellt/bearbeitet automations.yaml

# 3. Committen
git add automations.yaml
git commit -m "Add: Automatische Rollladen-Steuerung bei Sonnenstand"
git push

# 4. Auf Pi deployen
ssh reid15@192.168.178.71
cd /config
sudo git pull
ha automation reload

# 5. Testen in Home Assistant UI
```

### Szenario 2: UI-Änderung zurück ins Repository

```bash
# 1. Änderung über Home Assistant UI gemacht

# 2. Via SSH auf Pi
ssh reid15@192.168.178.71
cd /config
sudo git add automations.yaml
sudo git commit -m "UI: Zeitpunkt für Nachtmodus angepasst"
sudo git push

# 3. Auf Windows synchronisieren
cd /c/Users/reid1/source/repos/homeassistant-config
git pull
```

### Szenario 3: Fehlerhafte Änderung rückgängig machen

```bash
# Auf Pi: Letzte Änderung rückgängig (noch nicht gepusht)
sudo git reset --hard HEAD~1

# Oder: Bereits gepushte Änderung zurücknehmen
sudo git revert HEAD
sudo git push

# Auf Windows pullen
git pull
```

### Szenario 4: Merge-Konflikt lösen

Wenn du auf Pi UND Windows gearbeitet hast:

```bash
# Auf Windows
git pull
# -> Merge-Konflikt!

# Konflikt-Dateien öffnen und manuell lösen
code automations.yaml

# Suche nach:
# <<<<<<< HEAD
# ... deine Änderungen ...
# =======
# ... Änderungen vom Pi ...
# >>>>>>> [commit-hash]

# Bearbeiten, dann:
git add automations.yaml
git commit -m "Merge: Konflikt in automations.yaml gelöst"
git push
```

## Nützliche Aliases (optional)

Du kannst diese in deine Git-Konfiguration einfügen für schnellere Befehle:

```bash
# Auf Windows
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual 'log --oneline --graph --decorate --all'

# Dann kannst du verwenden:
git st      # statt git status
git ci -m   # statt git commit -m
git visual  # schöne Commit-Historie
```

## Troubleshooting

### Problem: "Permission denied" auf Pi

```bash
# Alle Git-Befehle auf dem Pi mit sudo ausführen!
sudo git pull
sudo git status
```

### Problem: "Your branch is behind 'origin/main'"

```bash
# Auf Windows
git pull

# Auf Pi
sudo git pull
```

### Problem: "untracked files would be overwritten"

```bash
# Lokale Änderungen verwerfen und pullen
git stash
git pull
git stash pop  # Wenn du die Änderungen wiederhaben willst
```

### Problem: Authentication failed

Das sollte nicht passieren, da der Token bereits konfiguriert ist. Falls doch:

```bash
# Auf Pi: Token neu setzen (nicht nötig, schon konfiguriert)
# Token ist bereits in /root/.git-credentials gespeichert
```

## GitHub Repository Features

### Auf github.com kannst du:

- **Historie durchsuchen:** Alle Commits ansehen
- **Dateien vergleichen:** Unterschiede zwischen Versionen
- **Issues erstellen:** Für geplante Features oder Bugs
- **Releases erstellen:** Stabile Konfigurationsstände markieren
- **README.md bearbeiten:** Dokumentation direkt auf GitHub

## Weitere Ressourcen

- **Git Grundlagen:** https://git-scm.com/book/de/v2
- **GitHub Docs:** https://docs.github.com/de
- **Home Assistant Git:** https://www.home-assistant.io/docs/configuration/

## Workflow-Diagramm

```
┌─────────────────┐
│  Windows        │
│  (Entwicklung)  │
│                 │
│  Claude Code    │
│  VS Code        │
└────────┬────────┘
         │
         │ git push
         ▼
┌─────────────────┐
│  GitHub         │
│  (Repository)   │
│                 │
│  Versionierung  │
│  Backup         │
└────────┬────────┘
         │
         │ git pull
         ▼
┌─────────────────┐
│  Raspberry Pi   │
│  (Produktion)   │
│                 │
│  Home Assistant │
│  Live System    │
└─────────────────┘
```

## Zusammenfassung

Du hast jetzt ein vollständiges Git-basiertes Entwicklungssystem für deine Home Assistant Konfiguration:

1. **Entwickle** auf Windows mit Claude Code
2. **Committe** deine Änderungen
3. **Pushe** zum GitHub Repository
4. **Deploye** auf dem Raspberry Pi mit `git pull`
5. **Teste** in Home Assistant
6. **Wiederhole** den Prozess

Viel Erfolg mit deinem automatisierten Home! 🏠
