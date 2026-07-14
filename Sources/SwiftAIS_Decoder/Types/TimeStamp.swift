//
//  TimeStamp.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/14/26.
//

struct TimeStamp {
    let rawValue: UInt8
    
    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    var description: String {
        switch rawValue {
        case 60:
            return "Not available"
        case 61:
            return "Positioning System in Manual Input Mode"
        case 62:
            return "Position Fixing System in Estimated (Dead Reckoning) Mode"
        case 63:
            return "Positioning System Inoperative"
        default:
            return "\(rawValue) seconds"
        }
    }
}
