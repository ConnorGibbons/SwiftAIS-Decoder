//
//  PositionAccuracy.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/14/26.
//

enum PositionAccuracy: UInt8 {
    case lowAccuracy = 0
    case highAccuracy = 1
    
    var description: String {
        switch self {
        case .lowAccuracy:
            return "Low Accuracy (> 10m)"
        case .highAccuracy:
            return "High Accuracy (< 10m)"
        }
    }
}
