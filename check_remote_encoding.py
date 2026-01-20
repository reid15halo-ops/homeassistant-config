import os
filename = r'\\192.168.178.70\config\configuration.yaml'
try:
    with open(filename, 'r', encoding='utf-8') as f:
        f.read()
    print(f'{filename}: OK')
except UnicodeDecodeError as e:
    print(f'{filename}: ERROR at position {e.start}: {e.reason}')
    with open(filename, 'rb') as f:
        f.seek(max(0, e.start - 20))
        context = f.read(40)
        print(f'Context: {context}')
