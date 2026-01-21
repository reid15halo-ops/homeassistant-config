import json
import yaml
import os
from datetime import datetime

# Configuration
LOCAL_PATH = "."
REMOTE_STORAGE_PATH = r"\\192.168.178.70\config\.storage"

def load_json(path):
    try:
        with open(path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading {path}: {e}")
        return None

def load_yaml(path):
    try:
        with open(path, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f)
    except Exception as e:
        print(f"Error loading {path}: {e}")
        return None

def main():
    print(f"# Home Assistant Inventory Report")
    print(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

    # 1. Integrations (Config Entries)
    print("## Integrations")
    config_entries = load_json(os.path.join(REMOTE_STORAGE_PATH, "core.config_entries"))
    if config_entries:
        entries = config_entries['data']['entries']
        domains = set(e['domain'] for e in entries)
        for domain in sorted(domains):
            count = sum(1 for e in entries if e['domain'] == domain)
            print(f"- **{domain}**: {count} configured")
    else:
        print("Could not load config entries.")
    print("")

    # 2. Devices (Hardware)
    print("## Devices (Hardware)")
    device_registry = load_json(os.path.join(REMOTE_STORAGE_PATH, "core.device_registry"))
    if device_registry:
        devices = device_registry['data']['devices']
        print(f"Total Devices: {len(devices)}")
        
        # Group by Manufacturer
        by_manufacturer = {}
        for d in devices:
            man = d.get('manufacturer') or "Unknown"
            if man not in by_manufacturer:
                by_manufacturer[man] = []
            by_manufacturer[man].append(d)
        
        for man in sorted(by_manufacturer.keys()):
            print(f"\n### {man}")
            for d in by_manufacturer[man]:
                name = d.get('name_by_user') or d.get('name') or "Unknown Device"
                model = d.get('model') or "Unknown Model"
                print(f"- {name} ({model})")
    else:
        print("Could not load device registry.")
    print("")

    # 3. Entities
    print("## Entities")
    entity_registry = load_json(os.path.join(REMOTE_STORAGE_PATH, "core.entity_registry"))
    if entity_registry:
        entities = entity_registry['data']['entities']
        print(f"Total Entities: {len(entities)}")
        
        # Group by Domain
        by_domain = {}
        for e in entities:
            domain = e['entity_id'].split('.')[0]
            if domain not in by_domain:
                by_domain[domain] = []
            by_domain[domain].append(e)
            
        for domain in sorted(by_domain.keys()):
            print(f"- **{domain}**: {len(by_domain[domain])}")
    else:
        print("Could not load entity registry.")
    print("")

    # 4. Automations (Local YAML)
    print("## Automations (YAML)")
    automations = load_yaml(os.path.join(LOCAL_PATH, "automations.yaml"))
    if automations:
        print(f"Total Automations: {len(automations)}")
        for a in automations:
            alias = a.get('alias', 'Unnamed Automation')
            print(f"- {alias}")
    else:
        print("No automations found in automations.yaml")
    print("")

    # 5. Scripts (Local YAML)
    print("## Scripts (YAML)")
    scripts = load_yaml(os.path.join(LOCAL_PATH, "scripts.yaml"))
    if scripts:
        print(f"Total Scripts: {len(scripts)}")
        for key, value in scripts.items():
            alias = value.get('alias', key)
            print(f"- {alias}")
    else:
        print("No scripts found in scripts.yaml")
    print("")

if __name__ == "__main__":
    main()
