//
//  TransmitPower.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/8/26.
//

enum TransmitPower: UInt8 {
    case lowPower = 0
    case highPower = 1
    
    var description: String {
        switch self {
        case .lowPower:
            return "Low Power"
        case .highPower:
            return "High Power"
        }
    }
}
