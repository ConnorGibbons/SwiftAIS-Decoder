//
//  DTE.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/24/26.
//

enum DTE: RawRepresentable {
    typealias RawValue = Bool
    
    case ready
    case notReady
    
    init?(rawValue: Bool) {
        self = rawValue ? .ready : .notReady
    }
    
    var rawValue: Bool {
        switch self {
        case .ready:
            return true
        case .notReady:
            return false
        }
    }

    var description: String {
        if(self == .ready) { return "Data terminal ready" }
        return "Data terminal not ready"
    }
}
