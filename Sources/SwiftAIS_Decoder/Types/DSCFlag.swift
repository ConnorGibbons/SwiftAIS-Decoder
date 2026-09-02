//
//  DSCFlag.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/2/26.
//
//  Used to signify whether the radio is DSC call capable
//  Check out SwiftDSC :^)

enum DSCFlag: RawRepresentable {
    typealias RawValue = Bool
    
    case hasDSC
    case noDSC
    
    init(rawValue: Bool) {
        self = rawValue ? .hasDSC : .noDSC
    }
    
    var rawValue: Bool {
        switch self {
        case .hasDSC:
            return true
        case .noDSC:
            return false
        }
    }

    var description: String {
        if self.rawValue { return "Has DSC" }
        else { return "Does Not Have DSC" }
    }
    
}
