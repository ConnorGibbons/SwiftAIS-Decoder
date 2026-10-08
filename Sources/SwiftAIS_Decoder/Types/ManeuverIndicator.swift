//
//  ManeuverIndicator.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/14/26.
//

public enum ManeuverIndicator: UInt8 {
    case notAvailable = 0
    case noSpecialManeuver = 1
    case specialManeuver = 2
    
    public var description: String {
        switch self {
        case .notAvailable:
            "Not available"
        case .noSpecialManeuver:
            "No special maneuver"
        case .specialManeuver:
            "Special maneuver"
        }
    }
}

