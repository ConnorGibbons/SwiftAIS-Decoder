//
//  PositionLatency.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/18/26.
//

enum PositionLatency: UInt8 {
    case under5Seconds = 0
    case over5Seconds = 1 // This is the default

    var description: String {
        switch self {
        case .under5Seconds:
            return "Less than 5 seconds"
        case .over5Seconds:
            return "Greater than 5 seconds"
        }
    }
}
