//
//  Type22Flag.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/2/26.
//

public enum Type22Flag: RawRepresentable {
    public typealias RawValue = Bool
    
    case supported
    case unsupported
    
    public init(rawValue: Bool) {
        self = rawValue ? .supported : .unsupported
    }
    
    public var rawValue: Bool {
        switch self {
        case .supported:
            return true
        case .unsupported:
            return false
        }
    }

    public var description: String {
        if self.rawValue { return "Supports Message Type 22" }
        else { return "Does Not Support Message Type 22" }
    }
    
}
