//
//  ManeuverIndicator.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/14/26.
//

public enum ManeuverIndicator: RawRepresentable, Equatable, Hashable {
    public typealias RawValue = UInt8

    case notAvailable
    case noSpecialManeuver
    case specialManeuver
    case invalid(UInt8)

    public init(rawValue: UInt8) {
        switch rawValue {
        case 0: self = .notAvailable
        case 1: self = .noSpecialManeuver
        case 2: self = .specialManeuver
        default: self = .invalid(rawValue)
        }
    }

    public var rawValue: UInt8 {
        switch self {
        case .notAvailable: 0
        case .noSpecialManeuver: 1
        case .specialManeuver: 2
        case .invalid(let value): value
        }
    }

    public var isValid: Bool {
        if case .invalid = self { return false }
        return true
    }

    public var description: String {
        switch self {
        case .notAvailable:
            "Not available"
        case .noSpecialManeuver:
            "No special maneuver"
        case .specialManeuver:
            "Special maneuver"
        case .invalid(let value):
            "Invalid (\(value))"
        }
    }
}

