"""
Tuya TS0601 24GHz mmWave Radar Presence Sensor
Manufacturer: _TZE284_iadro9bf
Model: TS0601
Using zigpy.quirks.v2 API for better compatibility
"""

from zigpy.quirks.v2 import QuirkBuilder
from zigpy.quirks.v2.homeassistant import EntityPlatform, EntityType
import zigpy.types as t

# Tuya datapoint IDs (these are standard for most Tuya mmWave sensors)
(
    QuirkBuilder("_TZE284_iadro9bf", "TS0601")
    .tuya_dp(
        dp_id=1,
        ep_attribute=EntityType.STANDARD,
        attribute_name="occupancy",
        converter=lambda x: 1 if x else 0,
    )
    .tuya_dp(
        dp_id=2,
        ep_attribute=EntityType.STANDARD,
        attribute_name="sensitivity",
        converter=lambda x: x,
    )
    .tuya_dp(
        dp_id=9,
        ep_attribute=EntityType.STANDARD,
        attribute_name="target_distance",
        converter=lambda x: x,
    )
    .tuya_dp(
        dp_id=104,
        ep_attribute=EntityType.STANDARD,
        attribute_name="illuminance",
        converter=lambda x: x,
    )
    .tuya_dp(
        dp_id=101,
        ep_attribute=EntityType.STANDARD,
        attribute_name="motion_state",
        converter=lambda x: x,
    )
    .skip_configuration()
    .add_to_registry()
)
