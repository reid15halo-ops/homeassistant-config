with open('configuration.yaml', 'rb') as f:
    data = f.read()
    try:
        index = data.index(b'\xdf')
        print(f'Found 0xDF at position {index}')
    except ValueError:
        print('0xDF not found in configuration.yaml')

# Also check for other common non-utf8 bytes if any
