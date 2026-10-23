//
//  StaticDataReportPart.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/9/26.
//
//  Static Data Report Part

public enum StaticDataReportPart: RawRepresentable, Equatable, Hashable {
    public typealias RawValue = UInt8

    case a
    case b
    case invalid(UInt8)

    public init(rawValue: UInt8) {
        switch rawValue {
        case 0: self = .a
        case 1: self = .b
        default: self = .invalid(rawValue)
        }
    }

    public var rawValue: UInt8 {
        switch self {
        case .a: 0
        case .b: 1
        case .invalid(let value): value
        }
    }

    public var isValid: Bool {
        if case .invalid = self { return false }
        return true
    }

    public var description: String {
        switch self {
        case .a:
            return "A"
        case .b:
            return "B"
        case .invalid(let value):
            return "Invalid (\(value))"
        }
    }
}
