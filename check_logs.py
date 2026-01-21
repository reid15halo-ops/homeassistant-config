import os

LOG_PATH = r"\\192.168.178.70\config\home-assistant.log"

def main():
    try:
        if os.path.exists(LOG_PATH):
            with open(LOG_PATH, 'r', encoding='utf-8') as f:
                lines = f.readlines()
                # Read last 200 lines to find recent errors
                for line in lines[-200:]:
                    if "homekit" in line.lower() or "error" in line.lower():
                        print(line.strip())
        else:
            print("Log file not found.")
    except Exception as e:
        print(f"Error reading log: {e}")

if __name__ == "__main__":
    main()
