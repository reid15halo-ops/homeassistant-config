
import sys

def repair_file(filename):
    with open(filename, 'rb') as f:
        content = f.read()
    
    # Find the first occurrence of a null byte followed by a character, 
    # which is typical for UTF-16LE of ASCII characters.
    # Or just try to decode as much as possible as UTF-8.
    
    good_utf8 = b""
    try:
        content.decode('utf-8')
        print("File is already valid UTF-8")
        return
    except UnicodeDecodeError as e:
        good_utf8 = content[:e.start]
        bad_part = content[e.start:]
        print(f"Found corruption at {e.start}")
    
    # Try to decode the bad part as UTF-16LE
    try:
        # We might need to skip a byte if the corruption started mid-character
        # but usually it starts at a fresh line.
        repaired_part = bad_part.decode('utf-16-le').encode('utf-8')
        print("Successfully decoded bad part as UTF-16LE")
    except UnicodeError:
        # If that fails, try skipping one byte
        try:
            repaired_part = bad_part[1:].decode('utf-16-le').encode('utf-8')
            print("Successfully decoded bad part as UTF-16LE (skipped 1 byte)")
        except UnicodeError:
            print("Failed to decode bad part as UTF-16LE")
            return

    with open(filename + '.fixed', 'wb') as f:
        f.write(good_utf8)
        f.write(repaired_part)
    print(f"Fixed file saved as {filename}.fixed")

if __name__ == "__main__":
    repair_file('automations.yaml')
