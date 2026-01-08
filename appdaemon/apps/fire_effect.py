import appdaemon.plugins.hass.hassapi as hass
import random

class FireEffect(hass.Hass):
    def initialize(self):
        self.log("🔥 CAMPFIRE RELOADED!")
        self.lights = self.args.get("lights", ["light.buffet_licht", "light.computer_licht_2"])
        self.fire_hue = 35
        self.fire_saturation = 100
        self.running = False
        self.current_brightness = {l: 60 for l in self.lights}
        self.listen_state(self.toggle_fire, "input_boolean.fire_effect")
    
    def toggle_fire(self, entity, attribute, old, new, kwargs):
        if new == "on":
            self.start_fire()
        else:
            self.stop_fire()
    
    def start_fire(self):
        if not self.running:
            self.running = True
            self.log("🔥 Campfire started")
            self.loop()
    
    def stop_fire(self):
        self.running = False
        self.log("🔥 Campfire stopped")
    
    def loop(self):
        if not self.running: return
        
        # Random pattern selection
        pattern = random.choice([self.gentle, self.pulse, self.glow])
        pattern()
        
        # Next run in 0.2 - 0.5 seconds
        self.run_in(lambda k: self.loop(), random.uniform(0.2, 0.5))
    
    def adjust(self, delta, mn=45, mx=80):
        for l in self.lights:
            cur = self.current_brightness.get(l, 60)
            new_val = max(mn, min(mx, cur + delta))
            
            self.call_service("light/turn_on", 
                entity_id=l,
                hs_color=[self.fire_hue, self.fire_saturation],
                brightness_pct=new_val, 
                transition=0.4
            )
            self.current_brightness[l] = new_val
    
    def gentle(self): 
        self.adjust(random.randint(-4, 6))
        
    def pulse(self): 
        self.adjust(random.randint(-3, 3), 50, 70)
        
    def glow(self): 
        self.adjust(random.randint(-2, 2), 45, 60)
