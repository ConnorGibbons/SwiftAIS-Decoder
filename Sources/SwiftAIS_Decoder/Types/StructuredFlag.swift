//
//  StructuredFlag.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/10/26.
//

enum StructuredFlag: RawRepresentable {
    typealias RawValue = Bool
    
    case structured
    case unstructured
    
    init(rawValue: Bool) {
        self = rawValue ? .structured : .unstructured
    }
    
    var rawValue: Bool {
        switch self {
        case .structured:
            return true
        case .unstructured:
            return false
        }
    }
    
    var description: String {
        if self.rawValue { return "Is structured" }
        else { return "Not structured" }
    }
    
}
