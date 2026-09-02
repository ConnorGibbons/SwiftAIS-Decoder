//
//  Type22Flag.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/2/26.
//

enum Type22Flag: RawRepresentable {
    typealias RawValue = Bool
    
    case supported
    case unsupported
    
    init(rawValue: Bool) {
        self = rawValue ? .supported : .unsupported
    }
    
    var rawValue: Bool {
        switch self {
        case .supported:
            return true
        case .unsupported:
            return false
        }
    }

    var description: String {
        if self.rawValue { return "Supports Message Type 22" }
        else { return "Does Not Support Message Type 22" }
    }
    
}
