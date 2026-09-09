//
//  StationType.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/8/26.
//

enum StationType: UInt8 {
    case allTypes = 0
    case reserved1 = 1
    case allClassB = 2
    case sarMobile = 3
    case aton = 4
    case classBShipborneMobile = 5
    case regionalUse = 6
    case reserved7 = 7
    
    var description: String {
        switch self {
        case .allTypes:
            return "All types of mobiles (default)"
        case .reserved1:
            return "Reserved for future use"
        case .allClassB:
            return "All types of Class B mobile stations"
        case .sarMobile:
            return "SAR airborne mobile station"
        case .aton:
            return "Aid to Navigation station"
        case .classBShipborneMobile:
            return "Class B shipborne mobile station"
        case .regionalUse:
            return "Regional use & inland waterways"
        case .reserved7:
            return "Reserved for future use"
        }
    }
    
}
