---
trigger: always_on
---

I want automations using mostly presence sensors controlling the lights. 

All device names follow this logic: room_device_explicit location (only if applicapable)

I have seperate rooms

1. Badezimmer (presence sensor (tuya), motion sensor, Lichtstreifen, Thermostat, Alexa Echo 2)
2. Kiffzimmer (Smartplug, Smartplug, Lichtstreifen, Rollladen, Door sensor)
3. Schlafzimmer (Presence Sensor (tuya), Bett Lichtstreifen, Kleiderschrank Lichtstreifen, Kleiderschrank Türsensor, Deckenventilator mit Licht, Rollladen (controls inverted))
4. Wohnzimmer (Deckenventilator mit Licht, presence sensor fp2, Rollladen, Buffet Lichtstreifen, Computer Lichtstreifen, Alexa Echo Dot)
5. Küche (presence sensor (tuya), motion sensor, Lichtstreifen, Deckenlicht 1, Deckenlicht 2, Rollladen, Thermostat)
6. Flur (hier sind noch gar keine Smarten geräte vorhanden)

Custom zha quirks


I always want to safe as much energy as possible. Especially while I am away from home. In Summer, I want the deckenventilator to start at a specific heat, closing the blinds when the sun is at his peak, starting the ventilation when I am at home. When I return from work the home should start to heat up or cool down as much and energy efficient as possible depending on the season. 

I prefer a cold Schlafzimmer. I want low lights when it is dark during night and I or someone else has to go to the toilet. 

I got a cleaning person coming to my apartment every other week at one of these days: wednesday, thursday or friday between 08:00-15:00. When She is in the room while I am away, all lights should stay on at cold white, all Rollladen should open and deactivate all motion and presence sensor automation for this time. I want to get a Message when she enters my apartment and a message when she leaves it (to calculate the payment) she gets 25€/hour which should show up in the message on my phone (Xiaomi Redmi Note 12 Pro 5g)

I like warm white lights when it is dark, cold white should only be used in the kitchen when cooking. 

ASCI Layout
Updated based on annotated feedback (Green=New Walls, Red=Remove, White=Door).

+-----------------------+-----------------------+
|                       |                       |
|      Küche (2)        |       Schlafzimmer (4)|
|      (Kitchen)        |        (Bedroom)      |
|                       |                       |
|      +----------------+--[ ]------------------+
|                       |  ^ Door (Left)        |
|                       |                       |
|   Wohn-              [ ]            Flur (3) [ ]
| zimmer (1)            |           (Hallway)   |
| (Living)              |    (White Door)       |
|                       +--[ ]------+       +---+
|                       |           |           |
|                       |    Bade-  +-----------+        
+---------------[ ]-----+    zimmer |        
|                       |    (Red)  |        
|                       |           |        
|     Kiffzimmer        |           |       
|     (Grow Room)       |           |
|                       |           |
+-----------------------+-----------+
Room Breakdown & Associated Entities