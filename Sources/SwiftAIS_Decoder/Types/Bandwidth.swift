//
//  Bandwidth.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/8/26.
//

public enum Bandwidth: UInt8 {
    case `default` = 0
    case narrow = 1
    
    public var description: String {
        switch self {
        case .default:
            return "25 kHz (default)"
        case .narrow:
            return "12.5 kHz"
        }
    }
}
