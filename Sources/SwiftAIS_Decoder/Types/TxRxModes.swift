//
//  TxRxModes.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/8/26.
//

public enum TxRxModes: RawRepresentable, Equatable, Hashable {
    public typealias RawValue = UInt8

    case TxATxBRxARxB
    case TxARxARxB
    case TxBRxARxB
    case reserved
    case invalid(UInt8) // Only reachable from type 22, whose field is 4 bits wide

    public init(rawValue: UInt8) {
        switch rawValue {
        case 0: self = .TxATxBRxARxB
        case 1: self = .TxARxARxB
        case 2: self = .TxBRxARxB
        case 3: self = .reserved
        default: self = .invalid(rawValue)
        }
    }

    public var rawValue: UInt8 {
        switch self {
        case .TxATxBRxARxB: 0
        case .TxARxARxB: 1
        case .TxBRxARxB: 2
        case .reserved: 3
        case .invalid(let value): value
        }
    }

    public var isValid: Bool {
        if case .invalid = self { return false }
        return true
    }

    public var description: String {
        switch self {
        case .TxATxBRxARxB:
            return "Transmit: A,B  Receive: A,B"
        case .TxARxARxB:
            return "Transmit: A  Receive: A,B"
        case .TxBRxARxB:
            return "Transmit: B  Receive: A,B"
        case .reserved:
            return "Reserved"
        case .invalid(let value):
            return "Invalid (\(value))"
        }
    }
}
