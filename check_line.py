with open('configuration.yaml', 'rb') as f:
    lines = f.readlines()
    for i, line in enumerate(lines):
        if b'G' in line and b'ste' in line:
            print(f'Line {i+1}: {line}')
            print(f'Hex: {line.hex()}')
