"""
Tuya TS0601 24GHz mmWave Radar Presence Sensor
Manufacturer: _TZE284_iadro9bf
Model: TS0601

Features:
- Human presence detection (occupancy)
- Adjustable sensitivity (1-9)
- Target distance measurement (0-10m)
- Ambient light sensing (0-100000 lux)
- Motion state classification

Datapoint Details:
- DP 1: Occupancy (bool) - Human presence detected
- DP 2: Sensitivity (int 1-9) - Detection sensitivity level
- DP 9: Target Distance (int cm) - Distance to detected target
- DP 104: Illuminance (int lux) - Ambient light level
- DP 101: Motion State (int) - 0=none, 1=large, 2=small, 3=static

Known Issues:
- DP 9 may report 0 when no target detected
- DP 104 updates slower than occupancy (~30s delay)
- Sensitivity changes require a few seconds to take effect

Compatible with zigpy.quirks.v2 API (ZHA 2023.4+)
"""

from typing import Any
from enum import IntEnum
from zigpy.quirks.v2 import QuirkBuilder
from zigpy.quirks.v2.homeassistant import EntityPlatform, EntityType
import zigpy.types as t


class MotionState(IntEnum):
    """Motion state classification for radar sensor."""
    NONE = 0
    LARGE_MOTION = 1
    SMALL_MOTION = 2
    STATIC = 3


def convert_occupancy(value: Any) -> bool:
    """
    Convert occupancy value to boolean with robust type handling.

    Args:
        value: Input value from sensor (bool, int, or string)

    Returns:
        bool: True if occupied, False otherwise
    """
    if isinstance(value, bool):
        return value
    if isinstance(value, int):
        return value != 0
    if isinstance(value, str):
        return value.lower() in ('true', '1', 'on', 'occupied')
    return False


def convert_illuminance(value: Any) -> int:
    """
    Convert and validate illuminance value with range clamping.

    Args:
        value: Input value from sensor

    Returns:
        int: Illuminance in lux (0-100000), 0 on error
    """
    try:
        lux = int(value)
        # Clamp to reasonable range for indoor sensors
        return max(0, min(lux, 100000))
    except (TypeError, ValueError, AttributeError):
        return 0


def convert_distance(value: Any) -> int:
    """
    Convert and validate distance value in centimeters.

    Args:
        value: Input value from sensor (cm)

    Returns:
        int: Distance in centimeters (0-1000), 0 on error
    """
    try:
        cm = int(value)
        # Clamp to sensor max range (typically 10m = 1000cm)
        return max(0, min(cm, 1000))
    except (TypeError, ValueError, AttributeError):
        return 0


def convert_sensitivity(value: Any) -> int:
    """
    Convert and validate sensitivity value.

    Args:
        value: Input value from sensor

    Returns:
        int: Sensitivity level (1-9), default 5 on error
    """
    try:
        sensitivity = int(value)
        return max(1, min(sensitivity, 9))
    except (TypeError, ValueError, AttributeError):
        return 5  # Default to medium sensitivity


def convert_motion_state(value: Any) -> int:
    """
    Convert and validate motion state value.

    Args:
        value: Input value from sensor

    Returns:
        int: MotionState enum value (0-3), 0 on error
    """
    try:
        state = int(value)
        return max(0, min(state, 3))
    except (TypeError, ValueError, AttributeError):
        return 0


# Build and register the quirk
(
    QuirkBuilder("_TZE284_iadro9bf", "TS0601")

    # Occupancy - Binary Sensor
    .tuya_binary_sensor(
        dp_id=1,
        attribute_name="occupancy",
        device_class="occupancy",
        converter=convert_occupancy,
    )

    # Sensitivity - Number Entity (Configuration)
    .tuya_number(
        dp_id=2,
        attribute_name="sensitivity",
        min_value=1,
        max_value=9,
        step=1,
        converter=convert_sensitivity,
        entity_category=EntityType.CONFIG,
    )

    # Target Distance - Sensor with unit
    .tuya_sensor(
        dp_id=9,
        attribute_name="target_distance",
        converter=convert_distance,
        device_class="distance",
        state_class="measurement",
        unit="cm",
    )

    # Illuminance - Sensor with device class
    .tuya_sensor(
        dp_id=104,
        attribute_name="illuminance",
        converter=convert_illuminance,
        device_class="illuminance",
        state_class="measurement",
        unit="lx",
    )

    # Motion State - Sensor (Diagnostic)
    .tuya_sensor(
        dp_id=101,
        attribute_name="motion_state",
        converter=convert_motion_state,
        entity_category=EntityType.DIAGNOSTIC,
        translation_key="motion_state",
    )

    .skip_configuration()
    .add_to_registry()
)
