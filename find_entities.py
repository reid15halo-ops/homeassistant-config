import json

with open('entity_registry.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

keywords = ['cannabis', 'zelt', 'mutter', 'permanent', 'cap', 'candy', 'aktiv', 'heiz', 'yoga']

for entity in data['data']['entities']:
    eid = entity['entity_id']
    if any(k in eid for k in keywords):
        print(f"{eid}")
