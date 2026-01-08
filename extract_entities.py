import json

try:
    with open('/config/.storage/core.entity_registry', 'r') as f:
        data = json.load(f)
    
    with open('/config/entity_list.txt', 'w') as f:
        f.write("ENTITY ID | FRIENDLY NAME\n")
        f.write("-" * 50 + "\n")
        for entity in data['data']['entities']:
            entity_id = entity['entity_id']
            name = entity.get('original_name') or entity.get('name') or "Unknown"
            f.write(f"{entity_id} | {name}\n")
            
    print("Success! Created /config/entity_list.txt")

except Exception as e:
    print(f"Error: {e}")
