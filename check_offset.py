with open('configuration.yaml', 'rb') as f:
    data = f.read()
    pos = data.find('Gäste'.encode('utf-8'))
    print(f'Offset of Gäste: {pos}')
    print(f'Bytes at offset: {data[pos:pos+10]}')
