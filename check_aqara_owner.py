import json
import os

REMOTE_STORAGE_PATH = r"\\192.168.178.70\config\.storage"

def main():
    try:
        with open(os.path.join(REMOTE_STORAGE_PATH, "core.device_registry"), 'r', encoding='utf-8') as f:
            data = json.load(f)
            for device in data['data']['devices']:
                if 'aqara' in str(device).lower():
                    print(f"Name: {device['name']}, Entry IDs: {device['config_entries']}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
