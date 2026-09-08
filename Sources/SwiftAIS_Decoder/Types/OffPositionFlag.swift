//
//  OffPositionFlag.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/3/26.
//

enum OffPositionFlag: RawRepresentable {
    typealias RawValue = Bool
    
    case onPosition
    case offPosition
    
    init(rawValue: Bool) {
        self = rawValue ? .offPosition : .onPosition
    }
    
    var rawValue: Bool {
        switch self {
        case .offPosition:
            return true
        case .onPosition:
            return false
        }
    }
    
    var description: String {
        if self.rawValue { return "Is Off Position" }
        else { return "Not Off Position" }
    }
    
}
