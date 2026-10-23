//
//  ShipType.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/24/26.
//

public enum ShipType: RawRepresentable, Equatable, Hashable {
    public typealias RawValue = UInt8

    case notAvailable
    case reserved(UInt8)

    // 20-29: Wing in ground (WIG)
    case wingInGround
    case wingInGroundHazardousA
    case wingInGroundHazardousB
    case wingInGroundHazardousC
    case wingInGroundHazardousD
    case wingInGroundReserved(UInt8)

    // 30-39
    case fishing
    case towing
    case towingLarge
    case dredgingOrUnderwaterOps
    case divingOps
    case militaryOps
    case sailing
    case pleasureCraft

    // 40-49: High speed craft (HSC)
    case highSpeedCraft
    case highSpeedCraftHazardousA
    case highSpeedCraftHazardousB
    case highSpeedCraftHazardousC
    case highSpeedCraftHazardousD
    case highSpeedCraftReserved(UInt8)
    case highSpeedCraftNoAdditionalInfo

    // 50-59
    case pilotVessel
    case searchAndRescueVessel
    case tug
    case portTender
    case antiPollutionEquipment
    case lawEnforcement
    case spareLocalVessel(UInt8)
    case medicalTransport
    case noncombatant

    // 60-69: Passenger
    case passenger
    case passengerHazardousA
    case passengerHazardousB
    case passengerHazardousC
    case passengerHazardousD
    case passengerReserved(UInt8)
    case passengerNoAdditionalInfo

    // 70-79: Cargo
    case cargo
    case cargoHazardousA
    case cargoHazardousB
    case cargoHazardousC
    case cargoHazardousD
    case cargoReserved(UInt8)
    case cargoNoAdditionalInfo

    // 80-89: Tanker
    case tanker
    case tankerHazardousA
    case tankerHazardousB
    case tankerHazardousC
    case tankerHazardousD
    case tankerReserved(UInt8)
    case tankerNoAdditionalInfo

    // 90-99: Other Type
    case otherType
    case otherTypeHazardousA
    case otherTypeHazardousB
    case otherTypeHazardousC
    case otherTypeHazardousD
    case otherTypeReserved(UInt8)
    case otherTypeNoAdditionalInfo

    case invalid(UInt8)

    public init(rawValue: UInt8) {
        switch rawValue {
        case 0: self = .notAvailable
        case 1...19, 38, 39: self = .reserved(rawValue)
        case 20: self = .wingInGround
        case 21: self = .wingInGroundHazardousA
        case 22: self = .wingInGroundHazardousB
        case 23: self = .wingInGroundHazardousC
        case 24: self = .wingInGroundHazardousD
        case 25...29: self = .wingInGroundReserved(rawValue)
        case 30: self = .fishing
        case 31: self = .towing
        case 32: self = .towingLarge
        case 33: self = .dredgingOrUnderwaterOps
        case 34: self = .divingOps
        case 35: self = .militaryOps
        case 36: self = .sailing
        case 37: self = .pleasureCraft
        case 40: self = .highSpeedCraft
        case 41: self = .highSpeedCraftHazardousA
        case 42: self = .highSpeedCraftHazardousB
        case 43: self = .highSpeedCraftHazardousC
        case 44: self = .highSpeedCraftHazardousD
        case 45...48: self = .highSpeedCraftReserved(rawValue)
        case 49: self = .highSpeedCraftNoAdditionalInfo
        case 50: self = .pilotVessel
        case 51: self = .searchAndRescueVessel
        case 52: self = .tug
        case 53: self = .portTender
        case 54: self = .antiPollutionEquipment
        case 55: self = .lawEnforcement
        case 56, 57: self = .spareLocalVessel(rawValue)
        case 58: self = .medicalTransport
        case 59: self = .noncombatant
        case 60: self = .passenger
        case 61: self = .passengerHazardousA
        case 62: self = .passengerHazardousB
        case 63: self = .passengerHazardousC
        case 64: self = .passengerHazardousD
        case 65...68: self = .passengerReserved(rawValue)
        case 69: self = .passengerNoAdditionalInfo
        case 70: self = .cargo
        case 71: self = .cargoHazardousA
        case 72: self = .cargoHazardousB
        case 73: self = .cargoHazardousC
        case 74: self = .cargoHazardousD
        case 75...78: self = .cargoReserved(rawValue)
        case 79: self = .cargoNoAdditionalInfo
        case 80: self = .tanker
        case 81: self = .tankerHazardousA
        case 82: self = .tankerHazardousB
        case 83: self = .tankerHazardousC
        case 84: self = .tankerHazardousD
        case 85...88: self = .tankerReserved(rawValue)
        case 89: self = .tankerNoAdditionalInfo
        case 90: self = .otherType
        case 91: self = .otherTypeHazardousA
        case 92: self = .otherTypeHazardousB
        case 93: self = .otherTypeHazardousC
        case 94: self = .otherTypeHazardousD
        case 95...98: self = .otherTypeReserved(rawValue)
        case 99: self = .otherTypeNoAdditionalInfo
        default: self = .invalid(rawValue)
        }
    }

    public var rawValue: UInt8 {
        switch self {
        case .notAvailable: 0
        case .wingInGround: 20
        case .wingInGroundHazardousA: 21
        case .wingInGroundHazardousB: 22
        case .wingInGroundHazardousC: 23
        case .wingInGroundHazardousD: 24
        case .fishing: 30
        case .towing: 31
        case .towingLarge: 32
        case .dredgingOrUnderwaterOps: 33
        case .divingOps: 34
        case .militaryOps: 35
        case .sailing: 36
        case .pleasureCraft: 37
        case .highSpeedCraft: 40
        case .highSpeedCraftHazardousA: 41
        case .highSpeedCraftHazardousB: 42
        case .highSpeedCraftHazardousC: 43
        case .highSpeedCraftHazardousD: 44
        case .highSpeedCraftNoAdditionalInfo: 49
        case .pilotVessel: 50
        case .searchAndRescueVessel: 51
        case .tug: 52
        case .portTender: 53
        case .antiPollutionEquipment: 54
        case .lawEnforcement: 55
        case .medicalTransport: 58
        case .noncombatant: 59
        case .passenger: 60
        case .passengerHazardousA: 61
        case .passengerHazardousB: 62
        case .passengerHazardousC: 63
        case .passengerHazardousD: 64
        case .passengerNoAdditionalInfo: 69
        case .cargo: 70
        case .cargoHazardousA: 71
        case .cargoHazardousB: 72
        case .cargoHazardousC: 73
        case .cargoHazardousD: 74
        case .cargoNoAdditionalInfo: 79
        case .tanker: 80
        case .tankerHazardousA: 81
        case .tankerHazardousB: 82
        case .tankerHazardousC: 83
        case .tankerHazardousD: 84
        case .tankerNoAdditionalInfo: 89
        case .otherType: 90
        case .otherTypeHazardousA: 91
        case .otherTypeHazardousB: 92
        case .otherTypeHazardousC: 93
        case .otherTypeHazardousD: 94
        case .otherTypeNoAdditionalInfo: 99
        case .reserved(let value),
             .wingInGroundReserved(let value),
             .highSpeedCraftReserved(let value),
             .spareLocalVessel(let value),
             .passengerReserved(let value),
             .cargoReserved(let value),
             .tankerReserved(let value),
             .otherTypeReserved(let value),
             .invalid(let value):
            value
        }
    }

    public var isValid: Bool {
        if case .invalid = self { return false }
        return true
    }

    public var description: String {
        switch self {
        case .notAvailable:
            return "Not available (default)"
        case .reserved:
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
        case .wingInGroundReserved:
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
        case .highSpeedCraftReserved:
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
        case .spareLocalVessel:
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
        case .passengerReserved:
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
        case .cargoReserved:
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
        case .tankerReserved:
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
        case .otherTypeReserved:
            return "Other Type, Reserved for future use"
        case .otherTypeNoAdditionalInfo:
            return "Other Type, No additional information"

        case .invalid(let value):
            return "Invalid (\(value))"
        }
    }
}
