//
//  EPFDFixType.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/21/26.
//
// EPFD -- Electronic Position Fix Device

enum EPFDFixType: UInt8 {
    case undefined = 0
    case gps = 1
    case glonass = 2
    case combinedGPSGLONASS = 3
    case loranC = 4
    case chayka = 5
    case integratedNavigationSystem = 6
    case surveyed = 7
    case galileo = 8
    case reserved9 = 9
    case reserved10 = 10
    case reserved11 = 11
    case reserved12 = 12
    case reserved13 = 13
    case reserved14 = 14
    case internalGNSS = 15

    var description: String {
        switch self {
        case .undefined:
            return "Undefined (default)"
        case .gps:
            return "GPS"
        case .glonass:
            return "GLONASS"
        case .combinedGPSGLONASS:
            return "Combined GPS/GLONASS"
        case .loranC:
            return "Loran-C"
        case .chayka:
            return "Chayka"
        case .integratedNavigationSystem:
            return "Integrated navigation system"
        case .surveyed:
            return "Surveyed"
        case .galileo:
            return "Galileo"
        case .reserved9, .reserved10, .reserved11, .reserved12, .reserved13, .reserved14:
            return "Reserved"
        case .internalGNSS:
            return "Internal GNSS"
        }
    }
}
