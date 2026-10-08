//
//  RestrictedUseIndicator.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/23/26.
//

public enum RestrictedUseIndicator: UInt8 {
    case notRestricted = 0
    case restrictedTerritorially = 1
    case restrictedToExclusiveEconomicZone = 2
    case restrictionByFlagState = 3
    
    public var description: String {
        switch self {
        case .notRestricted:
            "Not restricted"
        case .restrictedTerritorially:
            "Use restricted to territorial waters of flag state"
        case .restrictedToExclusiveEconomicZone:
            "Use restricted to the flag state's exclusive economic zone"
        case .restrictionByFlagState:
            "Use restricted by the flag state"
        }
    }
}
