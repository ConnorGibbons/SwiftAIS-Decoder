//
//  SpeedOverGround.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/8/26.
//

struct SpeedOverGround {
    var rawValue: UInt16
    var speedOverGround: Double? {
        if(rawValue == 1023) { return nil }
        return Double(rawValue) / 10
    }
    
    init?(rawValue: UInt16) {
        guard rawValue <= 0b1111111111 else { return nil } // Max val is 1023, field is only 10 bits wide.
        self.rawValue = rawValue
    }
    
    var description: String {
        switch rawValue {
        case 1023: return "Not available"
        case 1022: return "Over 102.2 knots"
        default: return "\(speedOverGround ?? 0) knots"
        }
    }
}
