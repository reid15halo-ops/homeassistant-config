import os

files = ['configuration.yaml', 'automations.yaml', 'scripts.yaml', 'input_boolean.yaml']

for filename in files:
    if not os.path.exists(filename): continue
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            f.read()
        print(f'{filename}: OK')
    except UnicodeDecodeError as e:
        print(f'{filename}: ERROR at position {e.start}: {e.reason}')
        # Read raw to show context
        with open(filename, 'rb') as f:
            f.seek(max(0, e.start - 20))
            context = f.read(40)
            print(f'Context: {context}')
