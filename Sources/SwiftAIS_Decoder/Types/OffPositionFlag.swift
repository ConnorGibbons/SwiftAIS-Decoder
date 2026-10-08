//
//  OffPositionFlag.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/3/26.
//

public enum OffPositionFlag: RawRepresentable {
    public typealias RawValue = Bool
    
    case onPosition
    case offPosition
    
    public init(rawValue: Bool) {
        self = rawValue ? .offPosition : .onPosition
    }
    
    public var rawValue: Bool {
        switch self {
        case .offPosition:
            return true
        case .onPosition:
            return false
        }
    }
    
    public var description: String {
        if self.rawValue { return "Is Off Position" }
        else { return "Not Off Position" }
    }
    
}
