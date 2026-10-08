//
//  Assigned.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 8/6/26.
//

public enum AssignedFlag: RawRepresentable {
    public typealias RawValue = Bool
    
    case assignedMode
    case notAssignedMode
    
    public init(rawValue: Bool) {
        self = rawValue ? .assignedMode : .notAssignedMode
    }
    
    public var rawValue: Bool {
        switch self {
        case .assignedMode:
            return true
        case .notAssignedMode:
            return false
        }
    }

    public var description: String {
        if(self == .assignedMode) { return "Assigned mode" }
        return "Not in assigned mode"
    }
}
