
import sys

def find_invalid_utf8(filename):
    with open(filename, 'rb') as f:
        data = f.read()
    
    try:
        data.decode('utf-8')
        print("File is valid UTF-8")
    except UnicodeDecodeError as e:
        print(f"Error: {e}")
        start = max(0, e.start - 20)
        end = min(len(data), e.end + 20)
        context = data[start:end]
        print(f"Context (hex): {context.hex()}")
        print(f"Context (bytes): {context}")

if __name__ == "__main__":
    find_invalid_utf8('automations.yaml.fixed')
