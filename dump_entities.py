import json
import os

REMOTE_STORAGE_PATH = r"\\192.168.178.70\config\.storage"

def main():
    try:
        with open(os.path.join(REMOTE_STORAGE_PATH, "core.entity_registry"), 'r', encoding='utf-8') as f:
            data = json.load(f)
            for entity in data['data']['entities']:
                print(f"{entity['entity_id']} ({entity.get('original_name', '')})")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
