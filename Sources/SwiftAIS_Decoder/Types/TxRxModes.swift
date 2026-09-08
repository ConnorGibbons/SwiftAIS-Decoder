//
//  TxRxModes.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/8/26.
//

enum TxRxModes: UInt8 {
    case TxATxBRxARxB = 0
    case TxARxARxB = 1
    case TxBRxARxB = 2
    case reserved = 3
    
    var description: String {
        switch self {
        case .TxATxBRxARxB:
            return "Transmit: A,B  Receive: A,B"
        case .TxARxARxB:
            return "Transmit: A  Receive: A,B"
        case .TxBRxARxB:
            return "Transmit: B  Receive: A,B"
        case .reserved:
            return "Reserved"
        }
    }
}
