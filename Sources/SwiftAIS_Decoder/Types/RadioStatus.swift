//
//  RadioStatus.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/14/26.
//
//  Decodes the 19-bit SOTDMA communication state carried by message types 1, 2,
//  and 4. The field layout and sub-message interpretation are defined by
//  Recommendation ITU-R M.1371-5 (02/2014), Annex 2:
//    - § 3.3.7.2.2, Table 18 — communication state structure (sync state / slot
//      time-out / sub message).
//    - § 3.3.7.2.3, Table 19 — how the 14-bit sub message is interpreted based on
//      the current slot time-out value.
//  Source PDF: https://www.itu.int/rec/R-REC-M.1371 (M.1371-5, p. 46).
//
//  NOTE: Message type 3 uses the ITDMA communication state (§ 3.3.7.3), which has a
//  different sub-message structure and is NOT modeled here.
//
//  Another Note! This was generated with Claude Agent, and I haven't had the chance to compare it with the spec yet.
//  Should take these values with a grain of salt.

// Synchronization state — Table 18, "Sync state" (2 bits).
enum SyncState: UInt8 {
    case utcDirect = 0            // § 3.1.1.1
    case utcIndirect = 1          // § 3.1.1.2
    case baseStationDirect = 2    // § 3.1.1.3 — synchronized to a base station
    case otherStation = 3         // § 3.1.1.3 / § 3.1.1.4 — synchronized to another station

    var description: String {
        switch self {
        case .utcDirect:
            return "UTC direct"
        case .utcIndirect:
            return "UTC indirect"
        case .baseStationDirect:
            return "Synchronized to a base station"
        case .otherStation:
            return "Synchronized to another station"
        }
    }
}

// Sub message — Table 19. Which case applies is determined by the slot time-out value.
enum SOTDMASubMessage {
    case receivedStations(UInt16)                    // slot time-out 3, 5, 7 (0...16383)
    case slotNumber(UInt16)                          // slot time-out 2, 4, 6 (0...2249)
    case utcHourAndMinute(hour: UInt8, minute: UInt8) // slot time-out 1
    case slotOffset(UInt16)                          // slot time-out 0

    var description: String {
        switch self {
        case .receivedStations(let count):
            return "Received stations: \(count)"
        case .slotNumber(let slot):
            return "Slot number: \(slot)"
        case .utcHourAndMinute(let hour, let minute):
            return "UTC \(hour):\(String(format: "%02d", minute))"
        case .slotOffset(let offset):
            return "Slot offset: \(offset)"
        }
    }
}

struct RadioStatus {
    let rawValue: UInt32

    init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    // Table 18: the 19-bit field is [sync state (2) | slot time-out (3) | sub message (14)],
    // most-significant bit first.
    var syncState: SyncState {
        // Bits 18-17. A 2-bit field always maps onto a SyncState case, so this is safe.
        SyncState(rawValue: UInt8((rawValue >> 17) & 0b11))!
    }

    // Bits 16-14. "Specifies frames remaining until a new slot is selected."
    var slotTimeout: UInt8 {
        UInt8((rawValue >> 14) & 0b111)
    }

    // Bits 13-0, interpreted per Table 19 according to the slot time-out.
    var subMessage: SOTDMASubMessage {
        let sub = UInt16(rawValue & 0x3FFF)
        switch slotTimeout {
        case 3, 5, 7:
            return .receivedStations(sub)
        case 2, 4, 6:
            return .slotNumber(sub)
        case 1:
            // Table 19: hour (0-23) in bits 13-9 (bit 13 MSB), minute (0-59) in bits 8-2
            // (bit 8 MSB); bits 1 and 0 are unused.
            let hour = UInt8((sub >> 9) & 0b11111)
            let minute = UInt8((sub >> 2) & 0b111111)
            return .utcHourAndMinute(hour: hour, minute: minute)
        default: // 0
            return .slotOffset(sub)
        }
    }

    var description: String {
        return "\(syncState.description); slot time-out \(slotTimeout); \(subMessage.description)"
    }
}
