//
//  AtoNType.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/3/26.
//

public enum AtoNType: RawRepresentable, Equatable, Hashable {
    public typealias RawValue = UInt8

    case unspecified
    case referencePoint
    case racon // Short for "Radar Beacon", radar transponder marking hazard
    case fixedOffshoreStructure
    case emergencyWreckMarkingBuoy
    case lightWithoutSectors
    case lightWithSectors
    case leadingLightFront // Leading lights are two lights stacked on top of eachother. If they're vertically aligned from your perspective, you're on centerline
    case leadingLightRear
    case beaconCardinalNorth
    case beaconCardinalEast
    case beaconCardinalSouth
    case beaconCardinalWest
    case beaconPortHand
    case beaconStarboardHand
    case beaconPreferredChannelPortHand
    case beaconPreferredChannelStarboardHand
    case beaconIsolatedDanger
    case beaconSafeWater
    case beaconSpecialMark
    case cardinalMarkNorth // Cardinal marks are buoys marking which direction you need to pass on to be in safe water. Neat
    case cardinalMarkEast
    case cardinalMarkSouth
    case cardinalMarkWest
    case portHandMark
    case starboardHandMark
    case preferredChannelPortHand
    case preferredChannelStarboardHand
    case isolatedDanger
    case safeWater
    case specialMark
    case lightVesselOrLANBYOrRigs // LANBY: Large Automatic Navigational Buoy

    // Codes 32+ are the mobile AtoN types added in Rec. ITU-R M.1371-6 (Table 85), and seemingly can only occur in message type 28
    // since message type 28 has an AtoN type field wide enough to accomodate values of this size
    case oceanDataAcquisitionSystem // ODAS
    case waterSamplingOrMonitoringEquipment
    case researchEquipment
    case towedCablePipeOrSemiSubmergedObjectMarker
    case towedVesselOrObject
    case flotsamMarkerLarge // Flotsam: floating wreckage or cargo. "Large" is >5m
    case flotsamMarkerSmall // <5m
    case navigationHazard
    case syntheticTargetMarker
    case protectedSpeciesMarker
    case militaryOperationTargetMarker
    case dangerousObject
    case pollutionSpillMarker
    case searchAndRescueDatumMark
    case datumMark
    case operatingUnderwater
    case underwaterOperationsMarker
    case militaryOperationOrRestrictedArea
    case dynamicArea
    case reserved(UInt8)
    case regionalUse(UInt8)

    public init(rawValue: UInt8) {
        switch rawValue {
        case 0: self = .unspecified
        case 1: self = .referencePoint
        case 2: self = .racon
        case 3: self = .fixedOffshoreStructure
        case 4: self = .emergencyWreckMarkingBuoy
        case 5: self = .lightWithoutSectors
        case 6: self = .lightWithSectors
        case 7: self = .leadingLightFront
        case 8: self = .leadingLightRear
        case 9: self = .beaconCardinalNorth
        case 10: self = .beaconCardinalEast
        case 11: self = .beaconCardinalSouth
        case 12: self = .beaconCardinalWest
        case 13: self = .beaconPortHand
        case 14: self = .beaconStarboardHand
        case 15: self = .beaconPreferredChannelPortHand
        case 16: self = .beaconPreferredChannelStarboardHand
        case 17: self = .beaconIsolatedDanger
        case 18: self = .beaconSafeWater
        case 19: self = .beaconSpecialMark
        case 20: self = .cardinalMarkNorth
        case 21: self = .cardinalMarkEast
        case 22: self = .cardinalMarkSouth
        case 23: self = .cardinalMarkWest
        case 24: self = .portHandMark
        case 25: self = .starboardHandMark
        case 26: self = .preferredChannelPortHand
        case 27: self = .preferredChannelStarboardHand
        case 28: self = .isolatedDanger
        case 29: self = .safeWater
        case 30: self = .specialMark
        case 31: self = .lightVesselOrLANBYOrRigs
        case 32: self = .oceanDataAcquisitionSystem
        case 33: self = .waterSamplingOrMonitoringEquipment
        case 34: self = .researchEquipment
        case 35: self = .towedCablePipeOrSemiSubmergedObjectMarker
        case 36: self = .towedVesselOrObject
        case 37: self = .flotsamMarkerLarge
        case 38: self = .flotsamMarkerSmall
        case 39: self = .navigationHazard
        case 40: self = .syntheticTargetMarker
        case 41: self = .protectedSpeciesMarker
        case 42: self = .militaryOperationTargetMarker
        case 43: self = .dangerousObject
        case 44: self = .pollutionSpillMarker
        case 45: self = .searchAndRescueDatumMark
        case 46: self = .datumMark
        case 47: self = .operatingUnderwater
        case 48: self = .underwaterOperationsMarker
        case 49: self = .militaryOperationOrRestrictedArea
        case 50: self = .dynamicArea
        case 51...63: self = .reserved(rawValue)
        default: self = .regionalUse(rawValue)
        }
    }

    public var rawValue: UInt8 {
        switch self {
        case .unspecified: 0
        case .referencePoint: 1
        case .racon: 2
        case .fixedOffshoreStructure: 3
        case .emergencyWreckMarkingBuoy: 4
        case .lightWithoutSectors: 5
        case .lightWithSectors: 6
        case .leadingLightFront: 7
        case .leadingLightRear: 8
        case .beaconCardinalNorth: 9
        case .beaconCardinalEast: 10
        case .beaconCardinalSouth: 11
        case .beaconCardinalWest: 12
        case .beaconPortHand: 13
        case .beaconStarboardHand: 14
        case .beaconPreferredChannelPortHand: 15
        case .beaconPreferredChannelStarboardHand: 16
        case .beaconIsolatedDanger: 17
        case .beaconSafeWater: 18
        case .beaconSpecialMark: 19
        case .cardinalMarkNorth: 20
        case .cardinalMarkEast: 21
        case .cardinalMarkSouth: 22
        case .cardinalMarkWest: 23
        case .portHandMark: 24
        case .starboardHandMark: 25
        case .preferredChannelPortHand: 26
        case .preferredChannelStarboardHand: 27
        case .isolatedDanger: 28
        case .safeWater: 29
        case .specialMark: 30
        case .lightVesselOrLANBYOrRigs: 31
        case .oceanDataAcquisitionSystem: 32
        case .waterSamplingOrMonitoringEquipment: 33
        case .researchEquipment: 34
        case .towedCablePipeOrSemiSubmergedObjectMarker: 35
        case .towedVesselOrObject: 36
        case .flotsamMarkerLarge: 37
        case .flotsamMarkerSmall: 38
        case .navigationHazard: 39
        case .syntheticTargetMarker: 40
        case .protectedSpeciesMarker: 41
        case .militaryOperationTargetMarker: 42
        case .dangerousObject: 43
        case .pollutionSpillMarker: 44
        case .searchAndRescueDatumMark: 45
        case .datumMark: 46
        case .operatingUnderwater: 47
        case .underwaterOperationsMarker: 48
        case .militaryOperationOrRestrictedArea: 49
        case .dynamicArea: 50
        case .reserved(let value), .regionalUse(let value): value
        }
    }

    public var description: String {
        switch self {
        case .unspecified:
            return "Default, Type of Aid to Navigation not specified"
        case .referencePoint:
            return "Reference point"
        case .racon:
            return "RACON (radar transponder marking a navigation hazard) or MAtoN"
        case .fixedOffshoreStructure:
            return "Fixed structure off shore, such as oil platforms, wind farms, rigs"
        case .emergencyWreckMarkingBuoy:
            return "Emergency Wreck Marking Buoy"
        case .lightWithoutSectors:
            return "Light, without sectors"
        case .lightWithSectors:
            return "Light, with sectors"
        case .leadingLightFront:
            return "Leading Light Front"
        case .leadingLightRear:
            return "Leading Light Rear"
        case .beaconCardinalNorth:
            return "Beacon, Cardinal N"
        case .beaconCardinalEast:
            return "Beacon, Cardinal E"
        case .beaconCardinalSouth:
            return "Beacon, Cardinal S"
        case .beaconCardinalWest:
            return "Beacon, Cardinal W"
        case .beaconPortHand:
            return "Beacon, Port hand"
        case .beaconStarboardHand:
            return "Beacon, Starboard hand"
        case .beaconPreferredChannelPortHand:
            return "Beacon, Preferred Channel port hand"
        case .beaconPreferredChannelStarboardHand:
            return "Beacon, Preferred Channel starboard hand"
        case .beaconIsolatedDanger:
            return "Beacon, Isolated danger"
        case .beaconSafeWater:
            return "Beacon, Safe water"
        case .beaconSpecialMark:
            return "Beacon, Special mark"
        case .cardinalMarkNorth:
            return "Cardinal Mark N"
        case .cardinalMarkEast:
            return "Cardinal Mark E"
        case .cardinalMarkSouth:
            return "Cardinal Mark S"
        case .cardinalMarkWest:
            return "Cardinal Mark W"
        case .portHandMark:
            return "Port hand Mark"
        case .starboardHandMark:
            return "Starboard hand Mark"
        case .preferredChannelPortHand:
            return "Preferred Channel Port hand"
        case .preferredChannelStarboardHand:
            return "Preferred Channel Starboard hand"
        case .isolatedDanger:
            return "Isolated danger"
        case .safeWater:
            return "Safe Water"
        case .specialMark:
            return "Special Mark"
        case .lightVesselOrLANBYOrRigs:
            return "Light Vessel / LANBY (Large Automatic Navigational Buoy) / Rigs"
        case .oceanDataAcquisitionSystem:
            return "Ocean Data Acquisition System (ODAS)"
        case .waterSamplingOrMonitoringEquipment:
            return "Water Sampling and/or Monitoring equipment"
        case .researchEquipment:
            return "Research equipment"
        case .towedCablePipeOrSemiSubmergedObjectMarker:
            return "Towed Cable, Pipe or Semi-submerged Object Marker"
        case .towedVesselOrObject:
            return "Towed Vessel or Object"
        case .flotsamMarkerLarge:
            return "Flotsam Marker, Large (greater than 5 metres)"
        case .flotsamMarkerSmall:
            return "Flotsam Marker, Small (less than 5 metres)"
        case .navigationHazard:
            return "Navigation hazard"
        case .syntheticTargetMarker:
            return "Synthetic Target Marker"
        case .protectedSpeciesMarker:
            return "Protected Species Marker"
        case .militaryOperationTargetMarker:
            return "Military Operation Target Marker"
        case .dangerousObject:
            return "Dangerous Object"
        case .pollutionSpillMarker:
            return "Pollution Spill Marker"
        case .searchAndRescueDatumMark:
            return "Search and Rescue Datum Mark"
        case .datumMark:
            return "Datum Mark"
        case .operatingUnderwater:
            return "Operating Underwater (at times)"
        case .underwaterOperationsMarker:
            return "Underwater Operations Marker"
        case .militaryOperationOrRestrictedArea:
            return "Military Operation or Restricted Area"
        case .dynamicArea:
            return "Dynamic Area"
        case .reserved(let value):
            return "Reserved for future use (\(value))"
        case .regionalUse(let value):
            return "Reserved for regional use (\(value))"
        }
    }
}
