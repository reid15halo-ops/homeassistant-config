# ▶️ [UMGEBUNG: Home Assistant | Datei: /config/custom_zha_quirks/zhaquirks/tuya/ts0601_iadro9bf_presence.py | Aktion: NEU ANLEGEN]
from zigpy.profiles import zha, zgp
from zigpy.zcl.clusters.general import Basic, Groups, Identify, Scenes, Ota, GreenPowerProxy
from zigpy.zcl.clusters.measurement import IlluminanceMeasurement, OccupancySensing
from zigpy.quirks import CustomDevice
import zigpy.types as t

from zhaquirks.tuya import TuyaLocalCluster
from zhaquirks.tuya.mcu import (
    TuyaMCUCluster,
    DPToAttributeMapping,
    TuyaDPType,
)

# ---- Virtuelle Cluster, die echte ZHA-Entities bereitstellen ----
class TuyaIlluminanceCluster(TuyaLocalCluster, IlluminanceMeasurement):
    """Illuminance aus Tuya-DP spiegeln (measured_value)."""

class TuyaOccupancyCluster(TuyaLocalCluster, OccupancySensing):
    """Occupancy aus Tuya-DP spiegeln (occupancy)."""
    # Report "occupied" als Bit 0
    OCCUPANCY_ATTR = 0x0000

# ---- Tuya MCU Cluster mit DP→Attribut-Mapping ----
class TuyaPresenceMCU(TuyaMCUCluster):
    """Mappt Tuya-Datenpunkte auf Standard-Cluster-Attribute."""
    dp_to_attribute = {
        # Präsenz (BOOL/ENUM) → OccupancySensing.occupancy (Bitfeld)
        1: DPToAttributeMapping(
            TuyaDPType.BOOL,
            TuyaOccupancyCluster.cluster_id,
            TuyaOccupancyCluster.OCCUPANCY_ATTR,
            lambda x: 1 if bool(x) else 0,  # 1=occupied, 0=clear
        ),
        # Lux → IlluminanceMeasurement.measured_value (ZCL: 0..65534 in "lux * 100")
        # Viele TS0601 nutzen 103 statt 104:
        103: DPToAttributeMapping(
            TuyaDPType.VALUE,
            TuyaIlluminanceCluster.cluster_id,
            0x0000,                         # measured_value
            lambda raw: max(1, int(raw)),   # simple passthru; just in case clamp to >=1
        ),
        # 👉 Weitere DPs (Empfindlichkeit, min/max Range, Delay, Fading, Entfernung) kannst du
        # später problemlos hinzufügen, sobald die IDs sicher sind.
    }

# ---- Gerätesignatur deiner Variante ----
class TuyaTS0601Presence(CustomDevice):
    signature = {
        "models_info": [("_TZE284_iadro9bf", "TS0601")],
        "endpoints": {
            1: {
                "profile_id": zha.PROFILE_ID,
                "device_type": 0x0051,
                "input_clusters": [Basic.cluster_id, Identify.cluster_id, Groups.cluster_id, Scenes.cluster_id, 0xED00, 0xEF00],
                "output_clusters": [0x000A, Ota.cluster_id],
            },
            242: {
                "profile_id": zgp.PROFILE_ID,
                "device_type": 0x0061,
                "input_clusters": [],
                "output_clusters": [GreenPowerProxy.cluster_id],
            },
        },
    }

    replacement = {
        "endpoints": {
            1: {
                "input_clusters": [
                    Basic.cluster_id,
                    Identify.cluster_id,
                    Groups.cluster_id,
                    Scenes.cluster_id,
                    TuyaPresenceMCU,          # ersetzt 0xEF00
                    TuyaIlluminanceCluster,   # Standard-Lux
                    TuyaOccupancyCluster,     # Standard-Occupancy
                ],
                "output_clusters": [0x000A, Ota.cluster_id],
            },
            242: {
                "input_clusters": [],
                "output_clusters": [GreenPowerProxy.cluster_id],
            },
        },
    }
