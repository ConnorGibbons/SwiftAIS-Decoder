//
//  ShipType.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/24/26.
//

enum ShipType: UInt8 {
    case notAvailable = 0

    // 1-19: Reserved for future use
    case reserved1 = 1
    case reserved2 = 2
    case reserved3 = 3
    case reserved4 = 4
    case reserved5 = 5
    case reserved6 = 6
    case reserved7 = 7
    case reserved8 = 8
    case reserved9 = 9
    case reserved10 = 10
    case reserved11 = 11
    case reserved12 = 12
    case reserved13 = 13
    case reserved14 = 14
    case reserved15 = 15
    case reserved16 = 16
    case reserved17 = 17
    case reserved18 = 18
    case reserved19 = 19

    // 20-29: Wing in ground (WIG)
    case wingInGround = 20
    case wingInGroundHazardousA = 21
    case wingInGroundHazardousB = 22
    case wingInGroundHazardousC = 23
    case wingInGroundHazardousD = 24
    case wingInGroundReserved25 = 25
    case wingInGroundReserved26 = 26
    case wingInGroundReserved27 = 27
    case wingInGroundReserved28 = 28
    case wingInGroundReserved29 = 29

    // 30-39
    case fishing = 30
    case towing = 31
    case towingLarge = 32
    case dredgingOrUnderwaterOps = 33
    case divingOps = 34
    case militaryOps = 35
    case sailing = 36
    case pleasureCraft = 37
    case reserved38 = 38
    case reserved39 = 39

    // 40-49: High speed craft (HSC)
    case highSpeedCraft = 40
    case highSpeedCraftHazardousA = 41
    case highSpeedCraftHazardousB = 42
    case highSpeedCraftHazardousC = 43
    case highSpeedCraftHazardousD = 44
    case highSpeedCraftReserved45 = 45
    case highSpeedCraftReserved46 = 46
    case highSpeedCraftReserved47 = 47
    case highSpeedCraftReserved48 = 48
    case highSpeedCraftNoAdditionalInfo = 49

    // 50-59
    case pilotVessel = 50
    case searchAndRescueVessel = 51
    case tug = 52
    case portTender = 53
    case antiPollutionEquipment = 54
    case lawEnforcement = 55
    case spareLocalVessel56 = 56
    case spareLocalVessel57 = 57
    case medicalTransport = 58
    case noncombatant = 59

    // 60-69: Passenger
    case passenger = 60
    case passengerHazardousA = 61
    case passengerHazardousB = 62
    case passengerHazardousC = 63
    case passengerHazardousD = 64
    case passengerReserved65 = 65
    case passengerReserved66 = 66
    case passengerReserved67 = 67
    case passengerReserved68 = 68
    case passengerNoAdditionalInfo = 69

    // 70-79: Cargo
    case cargo = 70
    case cargoHazardousA = 71
    case cargoHazardousB = 72
    case cargoHazardousC = 73
    case cargoHazardousD = 74
    case cargoReserved75 = 75
    case cargoReserved76 = 76
    case cargoReserved77 = 77
    case cargoReserved78 = 78
    case cargoNoAdditionalInfo = 79

    // 80-89: Tanker
    case tanker = 80
    case tankerHazardousA = 81
    case tankerHazardousB = 82
    case tankerHazardousC = 83
    case tankerHazardousD = 84
    case tankerReserved85 = 85
    case tankerReserved86 = 86
    case tankerReserved87 = 87
    case tankerReserved88 = 88
    case tankerNoAdditionalInfo = 89

    // 90-99: Other Type
    case otherType = 90
    case otherTypeHazardousA = 91
    case otherTypeHazardousB = 92
    case otherTypeHazardousC = 93
    case otherTypeHazardousD = 94
    case otherTypeReserved95 = 95
    case otherTypeReserved96 = 96
    case otherTypeReserved97 = 97
    case otherTypeReserved98 = 98
    case otherTypeNoAdditionalInfo = 99

    var description: String {
        switch self {
        case .notAvailable:
            return "Not available (default)"
        case .reserved1, .reserved2, .reserved3, .reserved4, .reserved5,
             .reserved6, .reserved7, .reserved8, .reserved9, .reserved10,
             .reserved11, .reserved12, .reserved13, .reserved14, .reserved15,
             .reserved16, .reserved17, .reserved18, .reserved19,
             .reserved38, .reserved39:
            return "Reserved for future use"

        case .wingInGround:
            return "Wing in ground (WIG), all ships of this type"
        case .wingInGroundHazardousA:
            return "Wing in ground (WIG), Hazardous category A"
        case .wingInGroundHazardousB:
            return "Wing in ground (WIG), Hazardous category B"
        case .wingInGroundHazardousC:
            return "Wing in ground (WIG), Hazardous category C"
        case .wingInGroundHazardousD:
            return "Wing in ground (WIG), Hazardous category D"
        case .wingInGroundReserved25, .wingInGroundReserved26, .wingInGroundReserved27,
             .wingInGroundReserved28, .wingInGroundReserved29:
            return "Wing in ground (WIG), Reserved for future use"

        case .fishing:
            return "Fishing"
        case .towing:
            return "Towing"
        case .towingLarge:
            return "Towing: length exceeds 200m or breadth exceeds 25m"
        case .dredgingOrUnderwaterOps:
            return "Dredging or underwater ops"
        case .divingOps:
            return "Diving ops"
        case .militaryOps:
            return "Military ops"
        case .sailing:
            return "Sailing"
        case .pleasureCraft:
            return "Pleasure Craft"

        case .highSpeedCraft:
            return "High speed craft (HSC), all ships of this type"
        case .highSpeedCraftHazardousA:
            return "High speed craft (HSC), Hazardous category A"
        case .highSpeedCraftHazardousB:
            return "High speed craft (HSC), Hazardous category B"
        case .highSpeedCraftHazardousC:
            return "High speed craft (HSC), Hazardous category C"
        case .highSpeedCraftHazardousD:
            return "High speed craft (HSC), Hazardous category D"
        case .highSpeedCraftReserved45, .highSpeedCraftReserved46,
             .highSpeedCraftReserved47, .highSpeedCraftReserved48:
            return "High speed craft (HSC), Reserved for future use"
        case .highSpeedCraftNoAdditionalInfo:
            return "High speed craft (HSC), No additional information"

        case .pilotVessel:
            return "Pilot Vessel"
        case .searchAndRescueVessel:
            return "Search and Rescue vessel"
        case .tug:
            return "Tug"
        case .portTender:
            return "Port Tender"
        case .antiPollutionEquipment:
            return "Anti-pollution equipment"
        case .lawEnforcement:
            return "Law Enforcement"
        case .spareLocalVessel56, .spareLocalVessel57:
            return "Spare - Local Vessel"
        case .medicalTransport:
            return "Medical Transport"
        case .noncombatant:
            return "Noncombatant ship according to RR Resolution No. 18"

        case .passenger:
            return "Passenger, all ships of this type"
        case .passengerHazardousA:
            return "Passenger, Hazardous category A"
        case .passengerHazardousB:
            return "Passenger, Hazardous category B"
        case .passengerHazardousC:
            return "Passenger, Hazardous category C"
        case .passengerHazardousD:
            return "Passenger, Hazardous category D"
        case .passengerReserved65, .passengerReserved66,
             .passengerReserved67, .passengerReserved68:
            return "Passenger, Reserved for future use"
        case .passengerNoAdditionalInfo:
            return "Passenger, No additional information"

        case .cargo:
            return "Cargo, all ships of this type"
        case .cargoHazardousA:
            return "Cargo, Hazardous category A"
        case .cargoHazardousB:
            return "Cargo, Hazardous category B"
        case .cargoHazardousC:
            return "Cargo, Hazardous category C"
        case .cargoHazardousD:
            return "Cargo, Hazardous category D"
        case .cargoReserved75, .cargoReserved76, .cargoReserved77, .cargoReserved78:
            return "Cargo, Reserved for future use"
        case .cargoNoAdditionalInfo:
            return "Cargo, No additional information"

        case .tanker:
            return "Tanker, all ships of this type"
        case .tankerHazardousA:
            return "Tanker, Hazardous category A"
        case .tankerHazardousB:
            return "Tanker, Hazardous category B"
        case .tankerHazardousC:
            return "Tanker, Hazardous category C"
        case .tankerHazardousD:
            return "Tanker, Hazardous category D"
        case .tankerReserved85, .tankerReserved86, .tankerReserved87, .tankerReserved88:
            return "Tanker, Reserved for future use"
        case .tankerNoAdditionalInfo:
            return "Tanker, No additional information"

        case .otherType:
            return "Other Type, all ships of this type"
        case .otherTypeHazardousA:
            return "Other Type, Hazardous category A"
        case .otherTypeHazardousB:
            return "Other Type, Hazardous category B"
        case .otherTypeHazardousC:
            return "Other Type, Hazardous category C"
        case .otherTypeHazardousD:
            return "Other Type, Hazardous category D"
        case .otherTypeReserved95, .otherTypeReserved96, .otherTypeReserved97, .otherTypeReserved98:
            return "Other Type, Reserved for future use"
        case .otherTypeNoAdditionalInfo:
            return "Other Type, No additional information"
        }
    }
}
