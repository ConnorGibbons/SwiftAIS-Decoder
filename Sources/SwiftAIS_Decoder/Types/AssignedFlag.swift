//
//  Assigned.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 8/6/26.
//

enum AssignedFlag: RawRepresentable {
    typealias RawValue = Bool
    
    case assignedMode
    case notAssignedMode
    
    init(rawValue: Bool) {
        self = rawValue ? .assignedMode : .notAssignedMode
    }
    
    var rawValue: Bool {
        switch self {
        case .assignedMode:
            return true
        case .notAssignedMode:
            return false
        }
    }

    var description: String {
        if(self == .assignedMode) { return "Assigned mode" }
        return "Not in assigned mode"
    }
}
