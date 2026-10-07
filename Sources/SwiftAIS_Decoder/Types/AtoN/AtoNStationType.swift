//
//  AtoNStationType.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/23/26.
//


enum AtoNStationType: UInt8 {
    case physicalFloating = 0
    case physicalFixed = 1
    case syntheticPredicted = 2
    case syntheticMonitored = 3
    case virtual = 4
    case mobile = 5
    case reserved = 6
    case reserved2 = 7
    
    var description: String {
        switch self {
        case .physicalFloating:
            "Physical Aid To Navigation (Floating)"
        case .physicalFixed:
            "Physical Aid to Navigation (Fixed)"
        case .syntheticPredicted:
            "Synthetic Aid to Navigation (Predicted)"
        case .syntheticMonitored:
            "Synthetic Aid to Navigation (Monitored)"
        case .virtual:
            "Virtual Aid to Navigation"
        case .mobile:
            "Mobile Aid to Navigation"
        case .reserved:
            "Reserved"
        case .reserved2:
            "Reserved"
        }
    }
}
