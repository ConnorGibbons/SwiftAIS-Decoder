//
//  NavaidType.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/3/26.
//

enum NavaidType: UInt8 {
    case unspecified = 0
    case referencePoint = 1
    case racon = 2 // Short for "Radar Beacon", radar transponder marking hazard
    case fixedOffshoreStructure = 3
    case spare = 4
    case lightWithoutSectors = 5
    case lightWithSectors = 6
    case leadingLightFront = 7 // Leading lights are two lights stacked on top of eachother. If they're vertically aligned from your perspective, you're on centerline
    case leadingLightRear = 8
    case beaconCardinalNorth = 9
    case beaconCardinalEast = 10
    case beaconCardinalSouth = 11
    case beaconCardinalWest = 12
    case beaconPortHand = 13
    case beaconStarboardHand = 14
    case beaconPreferredChannelPortHand = 15
    case beaconPreferredChannelStarboardHand = 16
    case beaconIsolatedDanger = 17
    case beaconSafeWater = 18
    case beaconSpecialMark = 19
    case cardinalMarkNorth = 20 // Cardinal marks are buoys marking which direction you need to pass on to be in safe water. Neat
    case cardinalMarkEast = 21
    case cardinalMarkSouth = 22
    case cardinalMarkWest = 23
    case portHandMark = 24
    case starboardHandMark = 25
    case preferredChannelPortHand = 26
    case preferredChannelStarboardHand = 27
    case isolatedDanger = 28
    case safeWater = 29
    case specialMark = 30
    case lightVesselOrLANBYOrRigs = 31 // LANBY: Large Automatic Navigational Buoy

    var description: String {
        switch self {
        case .unspecified:
            return "Default, Type of Aid to Navigation not specified"
        case .referencePoint:
            return "Reference point"
        case .racon:
            return "RACON (radar transponder marking a navigation hazard)"
        case .fixedOffshoreStructure:
            return "Fixed structure off shore, such as oil platforms, wind farms, rigs"
        case .spare:
            return "Spare, Reserved for future use"
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
        }
    }
}
