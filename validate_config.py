import yaml
import os
import sys

def validate_yaml(file_path):
    print(f"Validating {file_path}...")
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            yaml.safe_load(f)
        print("  OK")
        return True
    except Exception as e:
        print(f"  ERROR: {e}")
        return False

def main():
    files_to_check = [
        'automations.yaml',
        'scripts.yaml',
        'configuration.yaml',
        'packages/light_agent.yaml'
    ]
    
    success = True
    for file in files_to_check:
        if os.path.exists(file):
            if not validate_yaml(file):
                success = False
        else:
            print(f"Warning: {file} not found.")
            
    if success:
        print("\nAll files validated successfully.")
        sys.exit(0)
    else:
        print("\nValidation failed.")
        sys.exit(1)

if __name__ == "__main__":
    main()
