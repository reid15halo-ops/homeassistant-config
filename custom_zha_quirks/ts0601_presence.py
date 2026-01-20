"""Tuya TS0601 mmWave Presence Sensor Quirk for _TZE284_iadro9bf."""
from typing import Dict, Optional, Union

from zigpy.profiles import zha
import zigpy.types as t
from zigpy.zcl import foundation
from zigpy.zcl.clusters.general import Basic, Groups, Ota, Scenes, Time
from zigpy.zcl.clusters.measurement import OccupancySensing, IlluminanceMeasurement
from zigpy.zcl.clusters.security import IasZone

from zhaquirks import Bus, LocalDataCluster
from zhaquirks.const import (
    DEVICE_TYPE,
    ENDPOINTS,
    INPUT_CLUSTERS,
    MODELS_INFO,
    OUTPUT_CLUSTERS,
    PROFILE_ID,
)
from zhaquirks.tuya import (
    TuyaLocalCluster,
    TuyaNewManufCluster,
)
from zhaquirks.tuya.mcu import (
    DPToAttributeMapping,
    TuyaMCUCluster,
)


class TuyaOccupancySensing(OccupancySensing, TuyaLocalCluster):
    """Tuya local OccupancySensing cluster."""

    pass


class TuyaIlluminanceMeasurement(IlluminanceMeasurement, TuyaLocalCluster):
    """Tuya local IlluminanceMeasurement cluster."""

    pass


class TuyaMmwRadarCluster(TuyaMCUCluster):
    """Tuya mmWave Radar cluster with DP mappings."""

    attributes = TuyaMCUCluster.attributes.copy()
    attributes.update(
        {
            # Additional attributes for presence detection
            0xEF01: ("presence_state", t.uint32_t, True),
            0xEF02: ("motion_state", t.uint32_t, True),
            0xEF03: ("illuminance_value", t.uint32_t, True),
            0xEF04: ("target_distance", t.uint32_t, True),
            0xEF05: ("sensitivity", t.uint32_t, True),
            0xEF06: ("detection_delay", t.uint32_t, True),
            0xEF07: ("fading_time", t.uint32_t, True),
        }
    )

    dp_to_attribute: Dict[int, DPToAttributeMapping] = {
        # DP 1: Presence state (0=none, 1=presence)
        1: DPToAttributeMapping(
            TuyaOccupancySensing.ep_attribute,
            "occupancy",
        ),
        # DP 4: Illuminance (lux value)
        4: DPToAttributeMapping(
            TuyaIlluminanceMeasurement.ep_attribute,
            "measured_value",
            lambda x: x * 100,  # Convert to ZCL format (x100)
        ),
        # DP 9: Target distance (cm)
        9: DPToAttributeMapping(
            TuyaMCUCluster.ep_attribute,
            "target_distance",
        ),
        # DP 2: Sensitivity (1-10)
        2: DPToAttributeMapping(
            TuyaMCUCluster.ep_attribute,
            "sensitivity",
        ),
        # DP 101: Motion sensitivity or fading time
        101: DPToAttributeMapping(
            TuyaMCUCluster.ep_attribute,
            "fading_time",
        ),
        # DP 102: Detection delay
        102: DPToAttributeMapping(
            TuyaMCUCluster.ep_attribute,
            "detection_delay",
        ),
    }

    data_point_handlers = {
        1: "_dp_2_attr_update",
        2: "_dp_2_attr_update",
        4: "_dp_2_attr_update",
        9: "_dp_2_attr_update",
        101: "_dp_2_attr_update",
        102: "_dp_2_attr_update",
    }


class TuyaMmwRadarOccupancy(TuyaOccupancySensing):
    """Tuya MMW radar  occupancy cluster."""

    _CONSTANT_ATTRIBUTES = {
        OccupancySensing.AttributeDefs.occupancy_sensor_type.id: OccupancySensing.OccupancySensorType.PIR,
    }


class TuyaPresenceSensorTS0601(TuyaNewManufCluster):
    """Tuya Presence Sensor TS0601."""

    signature = {
        MODELS_INFO: [
            ("_TZE284_iadro9bf", "TS0601"),
            ("_TZE200_iadro9bf", "TS0601"),
            ("_TZE204_iadro9bf", "TS0601"),
        ],
        ENDPOINTS: {
            1: {
                PROFILE_ID: zha.PROFILE_ID,
                DEVICE_TYPE: zha.DeviceType.SMART_PLUG,
                INPUT_CLUSTERS: [
                    Basic.cluster_id,          # 0x0000
                    Groups.cluster_id,         # 0x0004
                    Scenes.cluster_id,         # 0x0005
                    0xED00,                    # Tuya specific
                    TuyaMCUCluster.cluster_id, # 0xEF00
                ],
                OUTPUT_CLUSTERS: [
                    Time.cluster_id,           # 0x000A
                    Ota.cluster_id,            # 0x0019
                ],
            },
            242: {
                PROFILE_ID: 41440,
                DEVICE_TYPE: 97,
                INPUT_CLUSTERS: [],
                OUTPUT_CLUSTERS: [0x0021],  # Green Power
            },
        },
    }

    replacement = {
        ENDPOINTS: {
            1: {
                PROFILE_ID: zha.PROFILE_ID,
                DEVICE_TYPE: zha.DeviceType.OCCUPANCY_SENSOR,
                INPUT_CLUSTERS: [
                    Basic.cluster_id,
                    Groups.cluster_id,
                    Scenes.cluster_id,
                    TuyaMmwRadarCluster,
                    TuyaMmwRadarOccupancy,
                    TuyaIlluminanceMeasurement,
                ],
                OUTPUT_CLUSTERS: [
                    Time.cluster_id,
                    Ota.cluster_id,
                ],
            },
            242: {
                PROFILE_ID: 41440,
                DEVICE_TYPE: 97,
                INPUT_CLUSTERS: [],
                OUTPUT_CLUSTERS: [0x0021],
            },
        },
    }
