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
    
    init(rawValue: Bool) {
        self = rawValue ? .notReady : .ready // 0 = ready, 1 = not ready
    }
    
    var rawValue: Bool {
        switch self {
        case .ready:
            return false
        case .notReady:
            return true
        }
    }

    var description: String {
        if(self == .ready) { return "Data terminal ready" }
        return "Data terminal not ready"
    }
}
