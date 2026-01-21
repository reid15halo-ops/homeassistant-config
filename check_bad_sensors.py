
def check_entities():
    required_entities = [
        "binary_sensor.motion_sensor_bad_bewegung",
        "binary_sensor.badezimmer_motion_sensor",
        "binary_sensor.presence_bad_bewegung"
    ]
    
    found_entities = []
    
    try:
        with open("entities_new.txt", "r", encoding="utf-8") as f:
            content = f.read()
            for entity in required_entities:
                if entity in content:
                    found_entities.append(entity)
                    
        print("Found entities:")
        for entity in found_entities:
            print(f"- {entity}")
            
        print("\nMissing entities:")
        for entity in required_entities:
            if entity not in found_entities:
                print(f"- {entity}")
                
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    check_entities()
