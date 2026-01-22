#!/usr/bin/env python3
"""Check automations.yaml for invalid entity IDs."""
import re

# Read automations.yaml
with open('automations.yaml', 'r', encoding='utf-8') as f:
    automations_content = f.read()

# Read known entities
with open('entities_new.txt', 'r', encoding='utf-8') as f:
    entities_content = f.read()

# Extract entity IDs from entities_new.txt (format: entity_id (friendly_name))
known_entities = set()
for line in entities_content.strip().split('\n'):
    if line.strip():
        match = re.match(r'^([a-z_]+\.[a-z0-9_]+)', line.strip())
        if match:
            known_entities.add(match.group(1))

# Extract entity_id references from automations.yaml
# Patterns to match:
# - entity_id: sensor.xyz
# - entity_id:
#     - sensor.xyz
# - entity_id: ["sensor.xyz", "sensor.abc"]
entity_pattern = re.compile(r'entity_id:\s*([a-z_]+\.[a-zA-Z0-9_]+)')
list_pattern = re.compile(r'-\s*([a-z_]+\.[a-zA-Z0-9_]+)')

used_entities = set()

# Find all entity_id: references
for match in entity_pattern.finditer(automations_content):
    entity = match.group(1).lower()
    if entity != 'all':  # 'all' is a special keyword
        used_entities.add(entity)

# Find all list items that look like entities
for match in list_pattern.finditer(automations_content):
    entity = match.group(1).lower()
    # Filter to only include things that look like entity IDs
    if '.' in entity and not entity.startswith('#'):
        used_entities.add(entity)

# Find missing entities
missing = sorted(used_entities - known_entities)

print(f"=== Entity Validation Report ===")
print(f"Known entities: {len(known_entities)}")
print(f"Used in automations: {len(used_entities)}")
print(f"Missing/Invalid: {len(missing)}")
print()

if missing:
    print("MISSING OR INVALID ENTITIES:")
    for entity in missing:
        print(f"  ❌ {entity}")
else:
    print("✅ All entities are valid!")
