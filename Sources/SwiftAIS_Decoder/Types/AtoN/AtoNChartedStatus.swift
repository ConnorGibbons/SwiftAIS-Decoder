//
//  AtoNChartedStatus.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 10/7/26.
//
// Aid to Navigation Charted status, used in message type 28
// "Indicates whether the AtoN is charted or not."
//  I'm assuming this means present on standard charts, but the spec doesn't give an actual definition.

enum AtoNChartedStatus: UInt8 {
    case uncharted = 0
    case charted = 1
    
    var description: String {
        switch self {
        case .uncharted:
            "Uncharted"
        case .charted:
            "Charted"
        }
    }
}
