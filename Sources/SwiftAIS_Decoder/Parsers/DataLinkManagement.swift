//
//  DataLinkManagement.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/3/26.
//
//  Type 20: Data Link Management Message
//  Payload Character: D

class DataLinkManagement: AISMessage {
    let nmeaSentence: AISNMEA0183Sentence
    let messageType: AISMessageType
    let mmsiNumber: MMSI
    
    let spare: UInt8
    let offset1: UInt16
    let reservedSlots1: UInt8
    let timeout1: UInt8
    let increment1: UInt16
    let offset2: UInt16?
    let reservedSlots2: UInt8?
    let timeout2: UInt8?
    let increment2: UInt16?
    let offset3: UInt16?
    let reservedSlots3: UInt8?
    let timeout3: UInt8?
    let increment3: UInt16?
    let offset4: UInt16?
    let reservedSlots4: UInt8?
    let timeout4: UInt8?
    let increment4: UInt16?
    
    init?(nmea: AISNMEA0183Sentence) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits
        
        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageTypeBits)) else { return nil }
        guard messageType.rawValue == 20 else { return nil }
        self.messageType = messageType
        
        guard let mmsiBits: UInt32 = bits[8...37] else { return nil }
        guard let mmsi = MMSI(value: mmsiBits) else { return nil }
        self.mmsiNumber = mmsi
        
        guard let spareBits: UInt8 = bits[38...39] else { return nil }
        self.spare = spareBits
        
        guard let offset1Bits: UInt16 = bits[40...51] else { return nil }
        self.offset1 = offset1Bits
        
        guard let reservedSlots1Bits: UInt8 = bits[52...55] else { return nil }
        self.reservedSlots1 = reservedSlots1Bits
        
        guard let timeout1Bits: UInt8 = bits[56...58] else { return nil }
        self.timeout1 = timeout1Bits
        
        guard let increment1Bits: UInt16 = bits[59...69] else { return nil }
        self.increment1 = increment1Bits
        
        if let offset2Bits: UInt16 = bits[70...81] {
            self.offset2 = offset2Bits
        } else {
            self.offset2 = nil
        }
        
        if let reservedSlots2Bits: UInt8 = bits[82...85] {
            self.reservedSlots2 = reservedSlots2Bits
        } else {
            self.reservedSlots2 = nil
        }
        
        if let timeout2Bits: UInt8 = bits[86...88] {
            self.timeout2 = timeout2Bits
        } else {
            self.timeout2 = nil
        }
        
        if let increment2Bits: UInt16 = bits[89...99] {
            self.increment2 = increment2Bits
        } else {
            self.increment2 = nil
        }
        
        if let offset3Bits: UInt16 = bits[100...111] {
            self.offset3 = offset3Bits
        } else {
            self.offset3 = nil
        }
        
        if let reservedSlots3Bits: UInt8 = bits[112...115] {
            self.reservedSlots3 = reservedSlots3Bits
        } else {
            self.reservedSlots3 = nil
        }
        
        if let timeout3Bits: UInt8 = bits[116...118] {
            self.timeout3 = timeout3Bits
        } else {
            self.timeout3 = nil
        }
        
        if let increment3Bits: UInt16 = bits[119...129] {
            self.increment3 = increment3Bits
        } else {
            self.increment3 = nil
        }
        
        if let offset4Bits: UInt16 = bits[130...141] {
            self.offset4 = offset4Bits
        } else {
            self.offset4 = nil
        }
        
        if let reservedSlots4Bits: UInt8 = bits[142...145] {
            self.reservedSlots4 = reservedSlots4Bits
        } else {
            self.reservedSlots4 = nil
        }
        
        if let timeout4Bits: UInt8 = bits[146...148] {
            self.timeout4 = timeout4Bits
        } else {
            self.timeout4 = nil
        }
        
        if let increment4Bits: UInt16 = bits[149...159] {
            self.increment4 = increment4Bits
        } else {
            self.increment4 = nil
        }
        
    }
    
    func description() -> String {
        var rows: [String] = [
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Slot 1:", slotDescription(offset: offset1, reservedSlots: reservedSlots1, timeout: timeout1, increment: increment1))
        ]

        // Slots 2-4 are optional -- a message can end after the first slot assignment, so these are only shown when present.
        if let offset2 = offset2, let reservedSlots2 = reservedSlots2, let timeout2 = timeout2, let increment2 = increment2 {
            rows.append(row("Slot 2:", slotDescription(offset: offset2, reservedSlots: reservedSlots2, timeout: timeout2, increment: increment2)))
        }

        if let offset3 = offset3, let reservedSlots3 = reservedSlots3, let timeout3 = timeout3, let increment3 = increment3 {
            rows.append(row("Slot 3:", slotDescription(offset: offset3, reservedSlots: reservedSlots3, timeout: timeout3, increment: increment3)))
        }

        if let offset4 = offset4, let reservedSlots4 = reservedSlots4, let timeout4 = timeout4, let increment4 = increment4 {
            rows.append(row("Slot 4:", slotDescription(offset: offset4, reservedSlots: reservedSlots4, timeout: timeout4, increment: increment4)))
        }

        return rows.joined(separator: "\n")
    }

    private func slotDescription(offset: UInt16, reservedSlots: UInt8, timeout: UInt8, increment: UInt16) -> String {
        "Offset \(offset), Reserved Slots \(reservedSlots), Timeout \(timeout), Increment \(increment)"
    }
    
    
}
