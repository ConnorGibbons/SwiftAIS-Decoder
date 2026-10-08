//
//  DSCFlag.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/2/26.
//
//  Used to signify whether the radio is DSC call capable
//  Check out SwiftDSC :^)

public enum DSCFlag: RawRepresentable {
    public typealias RawValue = Bool
    
    case hasDSC
    case noDSC
    
    public init(rawValue: Bool) {
        self = rawValue ? .hasDSC : .noDSC
    }
    
    public var rawValue: Bool {
        switch self {
        case .hasDSC:
            return true
        case .noDSC:
            return false
        }
    }

    public var description: String {
        if self.rawValue { return "Has DSC" }
        else { return "Does Not Have DSC" }
    }
    
}
