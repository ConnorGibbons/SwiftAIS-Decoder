//
//  StructuredFlag.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/10/26.
//

public enum StructuredFlag: RawRepresentable {
    public typealias RawValue = Bool
    
    case structured
    case unstructured
    
    public init(rawValue: Bool) {
        self = rawValue ? .structured : .unstructured
    }
    
    public var rawValue: Bool {
        switch self {
        case .structured:
            return true
        case .unstructured:
            return false
        }
    }
    
    public var description: String {
        if self.rawValue { return "Is structured" }
        else { return "Not structured" }
    }
    
}
