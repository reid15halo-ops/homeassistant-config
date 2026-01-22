
import os

def clean_null_bytes(filename):
    print(f"Cleaning {filename}...")
    with open(filename, 'rb') as f:
        data = f.read()
    
    null_count = data.count(b'\x00')
    if null_count > 0:
        print(f"Found {null_count} null bytes.")
        # Remove null bytes
        cleaned_data = data.replace(b'\x00', b'')
        
        # Also check for other common corruption signs
        # If the file was UTF-16LE, it might have a BOM or lots of nulls.
        # But if it's just a few nulls, simple replacement is safer.
        
        with open(filename + '.clean', 'wb') as f:
            f.write(cleaned_data)
        print(f"Cleaned file saved as {filename}.clean")
        
        # Try to decode as UTF-8 to verify
        try:
            cleaned_data.decode('utf-8')
            print("Cleaned data is valid UTF-8.")
        except UnicodeDecodeError as e:
            print(f"Cleaned data still has UTF-8 errors: {e}")
    else:
        print("No null bytes found.")

if __name__ == "__main__":
    clean_null_bytes('automations.yaml')
