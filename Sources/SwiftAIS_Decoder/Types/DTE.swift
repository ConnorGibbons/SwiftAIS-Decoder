//
//  DTE.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/24/26.
//

public enum DTE: RawRepresentable {
    public typealias RawValue = Bool
    
    case ready
    case notReady
    
    public init(rawValue: Bool) {
        self = rawValue ? .notReady : .ready // 0 = ready, 1 = not ready
    }
    
    public var rawValue: Bool {
        switch self {
        case .ready:
            return false
        case .notReady:
            return true
        }
    }

    public var description: String {
        if(self == .ready) { return "Data terminal ready" }
        return "Data terminal not ready"
    }
}
