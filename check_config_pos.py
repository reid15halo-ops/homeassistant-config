with open('configuration.yaml', 'rb') as f:
    f.seek(4944)
    data = f.read(50)
    print(f'Bytes: {data}')
    print(f'Text: {data.decode("latin-1")}')
