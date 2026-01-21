import json
import os

REMOTE_STORAGE_PATH = r"\\192.168.178.70\config\.storage"

def main():
    try:
        with open(os.path.join(REMOTE_STORAGE_PATH, "core.config_entries"), 'r', encoding='utf-8') as f:
            data = json.load(f)
            for entry in data['data']['entries']:
                if 'homekit' in entry['domain'].lower():
                    print(f"Domain: {entry['domain']}, Title: {entry['title']}, ID: {entry['entry_id']}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
