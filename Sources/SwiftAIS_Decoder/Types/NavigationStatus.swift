//
//  NavigationStatus.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/8/26.
//

enum NavigationStatus: UInt8 {
    case underWayUsingEngine = 0
    case atAnchor = 1
    case notUnderCommand = 2
    case restrictedManoeuverability = 3
    case constrainedByHerDraught = 4
    case moored = 5
    case aground = 6
    case engagedInFishing = 7
    case underWaySailing = 8
    case reservedForFutureHSC = 9
    case reservedForFutureWIG = 10
    case powerDrivenVesselTowingAstern = 11
    case powerDrivenVesselPushingAheadOrTowingAlongside = 12
    case reservedForFutureUse = 13
    case aisSARTIsActive = 14
    case undefined = 15

    var description: String {
        switch self {
        case .underWayUsingEngine:
            return "Under way using engine"
        case .atAnchor:
            return "At anchor"
        case .notUnderCommand:
            return "Not under command"
        case .restrictedManoeuverability:
            return "Restricted manoeuverability"
        case .constrainedByHerDraught:
            return "Constrained by her draught"
        case .moored:
            return "Moored"
        case .aground:
            return "Aground"
        case .engagedInFishing:
            return "Engaged in Fishing"
        case .underWaySailing:
            return "Under way sailing"
        case .reservedForFutureHSC:
            return "Reserved for future amendment of Navigational Status for HSC"
        case .reservedForFutureWIG:
            return "Reserved for future amendment of Navigational Status for WIG"
        case .powerDrivenVesselTowingAstern:
            return "Power-driven vessel towing astern (regional use)"
        case .powerDrivenVesselPushingAheadOrTowingAlongside:
            return "Power-driven vessel pushing ahead or towing alongside (regional use)"
        case .reservedForFutureUse:
            return "Reserved for future use"
        case .aisSARTIsActive:
            return "AIS-SART is active"
        case .undefined:
            return "Undefined (default)"
        }
    }
}
