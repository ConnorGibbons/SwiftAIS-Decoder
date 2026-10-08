//
//  AtoNOnStationStatus.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 10/7/26.
//
//  Describes the current state of an Aid to Navigation

public enum AtoNOnStationStatus: UInt8 {
    case onStation = 0
    case onStationOrOnCourse = 1 // For mobile AtoNs
    case onStationNotVisible = 2 // Damaged, occulted, submerged or otherwise not properly visible
    case offStationVirtualLocation = 3 // "A virtual AtoN reporting the intended position of this AtoN that is reporting itself off-position".
    case offStationUnknownLocation = 4
    case offStationCurrentLocation = 5
    case offStationAdrift = 6
    case offStationRemoved = 7
    case onStationTemporaryOrNew = 8
    case unmarkedHazard = 9
    case unmarkedObstruction = 10
    case reserved11 = 11
    case reserved12 = 12
    case reserved13 = 13
    case reserved14 = 14
    case reserved15 = 15

    public var description: String {
        switch self {
        case .onStation:
            return "On-station"
        case .onStationOrOnCourse:
            return "On-station or on course (mobile AtoN)"
        case .onStationNotVisible:
            return "On-station, but damaged, occulted, submerged or otherwise not properly visible"
        case .offStationVirtualLocation:
            return "Off-station, virtual AtoN reporting the intended position of an AtoN that is off-position"
        case .offStationUnknownLocation:
            return "Off-station, location unknown"
        case .offStationCurrentLocation:
            return "Off-station, reporting current position"
        case .offStationAdrift:
            return "Off-station, adrift"
        case .offStationRemoved:
            return "Off-station, removed or relocated"
        case .onStationTemporaryOrNew:
            return "On-station, new or temporary AtoN"
        case .unmarkedHazard:
            return "Unmarked navigation hazard"
        case .unmarkedObstruction:
            return "Unmarked obstruction"
        case .reserved11, .reserved12, .reserved13, .reserved14, .reserved15:
            return "Reserved for future use"
        }
    }
}
