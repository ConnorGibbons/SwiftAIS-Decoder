//
//  StationType.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/8/26.
//

public enum StationType: RawRepresentable, Equatable, Hashable {
    public typealias RawValue = UInt8

    case allTypes
    case allClassB
    case sarMobile
    case aton
    case classBShipborneMobile
    case regionalUseAndInlandWaterways(UInt8)
    case reserved(UInt8)

    public init(rawValue: UInt8) {
        switch rawValue {
        case 0: self = .allTypes
        case 2: self = .allClassB
        case 3: self = .sarMobile
        case 4: self = .aton
        case 5: self = .classBShipborneMobile
        case 6...9: self = .regionalUseAndInlandWaterways(rawValue)
        default: self = .reserved(rawValue)
        }
    }

    public var rawValue: UInt8 {
        switch self {
        case .allTypes: 0
        case .allClassB: 2
        case .sarMobile: 3
        case .aton: 4
        case .classBShipborneMobile: 5
        case .regionalUseAndInlandWaterways(let value): value
        case .reserved(let value): value
        }
    }

    public var description: String {
        switch self {
        case .allTypes:
            return "All types of mobiles (default)"
        case .allClassB:
            return "All types of Class B mobile stations"
        case .sarMobile:
            return "SAR airborne mobile station"
        case .aton:
            return "Aid to Navigation station"
        case .classBShipborneMobile:
            return "Class B shipborne mobile station (IEC62287 only)"
        case .regionalUseAndInlandWaterways(let value):
            return "Regional use & inland waterways (\(value))"
        case .reserved(let value):
            return "Reserved for future use (\(value))"
        }
    }

}


