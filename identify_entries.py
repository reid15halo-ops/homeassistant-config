import json
import os

REMOTE_STORAGE_PATH = r"\\192.168.178.70\config\.storage"

def main():
    target_ids = ['01KF1NRBCES6JQPJ3S0EJQNRN0', '01KF1NTFDZADWWS1GP94MT35TZ']
    try:
        with open(os.path.join(REMOTE_STORAGE_PATH, "core.config_entries"), 'r', encoding='utf-8') as f:
            data = json.load(f)
            for entry in data['data']['entries']:
                if entry['entry_id'] in target_ids:
                    print(f"ID: {entry['entry_id']}, Domain: {entry['domain']}, Title: {entry['title']}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
