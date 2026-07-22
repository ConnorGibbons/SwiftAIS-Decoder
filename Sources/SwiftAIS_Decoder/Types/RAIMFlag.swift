//
//  RaimFlag.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/14/26.
//

// RAIM: Receiver Autonomous Integrity Monitoring
enum RAIMFlag: UInt8 {
    case notInUse = 0
    case inUse = 1
    
    var description: String {
        switch self {
            case .notInUse:
            return "Not in use"
        case .inUse:
            return "In use"
        }
    }
}
