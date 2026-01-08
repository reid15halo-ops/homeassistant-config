"""
ULTIMATE FIRE FLICKER EFFECT
Realistic fire simulation using AppDaemon for smooth, continuous flickering
Optimized for TP-Link WiFi devices (KL430 Kasa & Tapo L900)
"""

import appdaemon.plugins.hass.hassapi as hass
import random
import time


class FireEffect(hass.Hass):
    
    def initialize(self):
        """Initialize the fire effect"""
        self.log("🔥 Fire Effect Initialized!")
        
        # Configuration
        self.lights = self.args.get("lights", [
            "light.buffet_licht",
            "light.computer_licht_2"
        ])
        self.fire_hue = 35  # Orange fire color
        self.fire_saturation = 100
        
        # State tracking
        self.running = False
        self.current_brightness = {}
        for light in self.lights:
            self.current_brightness[light] = 50
        
        # Listen for script activation
        self.listen_state(self.toggle_fire, "input_boolean.fire_effect")
        
        self.log(f"Fire effect ready for lights: {self.lights}")
    
    def toggle_fire(self, entity, attribute, old, new, kwargs):
        """Toggle fire effect on/off"""
        if new == "on":
            self.start_fire()
        else:
            self.stop_fire()
    
    def start_fire(self):
        """Start the fire effect"""
        if self.running:
            return
        
        self.running = True
        self.log("🔥 Starting fire effect!")
        self.run_fire_loop()
    
    def stop_fire(self):
        """Stop the fire effect"""
        self.running = False
        self.log("Fire effect stopped")
    
    def run_fire_loop(self):
        """Main fire effect loop with varied segments"""
        if not self.running:
            return
        
        # Choose random fire pattern
        pattern = random.choice([
            self.flare_up,
            self.rapid_flicker,
            self.dim_down,
            self.ember_glow,
            self.wild_burst,
            self.steady_burn,
            self.pulsing,
            self.crash_down
        ])
        
        # Execute pattern
        pattern()
        
        # Schedule next iteration (30-50ms for TP-Link devices)
        delay = random.uniform(0.03, 0.05)
        self.run_in(lambda kwargs: self.run_fire_loop(), delay)
    
    def set_fire_light(self, brightness):
        """Set all lights to fire color with given brightness"""
        for light in self.lights:
            self.call_service("light/turn_on",
                entity_id=light,
                hs_color=[self.fire_hue, self.fire_saturation],
                brightness_pct=brightness,
                transition=0
            )
            self.current_brightness[light] = brightness
    
    def adjust_brightness(self, light, delta, min_val=10, max_val=100):
        """Adjust brightness by delta, keeping within bounds"""
        current = self.current_brightness.get(light, 50)
        new_brightness = max(min_val, min(max_val, current + delta))
        
        self.call_service("light/turn_on",
            entity_id=light,
            hs_color=[self.fire_hue, self.fire_saturation],
            brightness_pct=new_brightness,
            transition=0
        )
        
        self.current_brightness[light] = new_brightness
        return new_brightness
    
    # Fire Patterns
    
    def flare_up(self):
        """Sudden bright flare"""
        delta = random.randint(15, 25)
        for light in self.lights:
            self.adjust_brightness(light, delta)
    
    def rapid_flicker(self):
        """Quick random changes"""
        delta = random.randint(-15, 15)
        for light in self.lights:
            self.adjust_brightness(light, delta)
    
    def dim_down(self):
        """Gradual dimming"""
        delta = random.randint(-10, -5)
        for light in self.lights:
            self.adjust_brightness(light, delta)
    
    def ember_glow(self):
        """Low, subtle glow"""
        delta = random.randint(-3, 3)
        for light in self.lights:
            self.adjust_brightness(light, delta, min_val=10, max_val=40)
    
    def wild_burst(self):
        """Explosive brightness spike"""
        delta = random.randint(20, 35)
        for light in self.lights:
            self.adjust_brightness(light, delta)
    
    def steady_burn(self):
        """Medium stable flame"""
        delta = random.randint(-8, 8)
        for light in self.lights:
            self.adjust_brightness(light, delta, min_val=40, max_val=75)
    
    def pulsing(self):
        """Gentle breathing effect"""
        delta = random.randint(-6, 6)
        for light in self.lights:
            self.adjust_brightness(light, delta, min_val=30, max_val=80)
    
    def crash_down(self):
        """Rapid drop in brightness"""
        delta = random.randint(-18, -10)
        for light in self.lights:
            self.adjust_brightness(light, delta)
