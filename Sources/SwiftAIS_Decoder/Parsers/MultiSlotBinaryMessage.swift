//
//  SingleSlotBinaryMessage.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/10/26.
//
//  Type 25: Single Slot Binary Message
//  Listed as "extremely rare" https://gpsd.gitlab.io/gpsd/AIVDM.html
//  Payload character: I

import SignalTools

struct MultiSlotBinaryMessage: AISMessage {
    let nmeaSentence: AISNMEA0183Sentence
    let messageType: AISMessageType
    let mmsiNumber: MMSI
    
    let addressed: Addressed
    let structuredFlag: StructuredFlag
    let payload: BitBuffer
    let text: AISText?
    let radioStatus: RadioStatus
    
    // Only present if addressed
    let destinationMMSI: MMSI?
    
    // Only present if structuredFlag is true
    let appID: UInt16? // The following two values are derived from this
    let dac: DesignatedAreaCode?
    let fid: UInt8?
    
    init?(nmea: AISNMEA0183Sentence) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits
        
        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageTypeBits)) else { return nil }
        guard messageType.rawValue == 26 else { return nil }
        self.messageType = messageType
        
        guard let mmsiBits: UInt32 = bits[8...37] else { return nil }
        guard let mmsi = MMSI(value: mmsiBits) else { return nil }
        self.mmsiNumber = mmsi
        
        guard let addressedBit: UInt8 = bits[38...38] else { return nil }
        guard let addressed = Addressed(rawValue: addressedBit) else { return nil }
        self.addressed = addressed
        
        guard let structuredFlagBit: UInt8 = bits[39...39] else { return nil }
        let structuredFlag = StructuredFlag(rawValue: structuredFlagBit == 1)
        self.structuredFlag = structuredFlag
        
        var ptr = 40
        if(addressed == .addressed) {
            guard let destinationMMSIBits: UInt32 = bits[ptr..<ptrAdvance(ptr: &ptr, advanceBy: 30)] else { return nil }
            guard let destinationMMSI = MMSI(value: destinationMMSIBits) else { return nil }
            self.destinationMMSI = destinationMMSI
            // Same 0/2-bit spare as message 25 (ITU-R M.1371-5 Table 79): present only when the
            // destination ID is used.
            _ = ptrAdvance(ptr: &ptr, advanceBy: 2)
        }
        else {
            self.destinationMMSI = nil
        }
        
        if(structuredFlag.rawValue) {
            guard let appIDBits: UInt16 = bits[ptr..<ptrAdvance(ptr: &ptr, advanceBy: 16)] else { return nil }
            self.appID = appIDBits
            // The application ID is a 10-bit DAC followed by a 6-bit FI.
            self.dac = DesignatedAreaCode(rawValue: (appIDBits & 0b1111111111000000) >> 6)
            self.fid = UInt8(appIDBits & 0b111111)
        }
        else {
            self.appID = nil
            self.dac = nil
            self.fid = nil
        }
        
        guard let payloadBits: BitBuffer = bits[ptr..<(bits.count-20)] else { return nil }
        self.payload = payloadBits
        
        // Fill bits can leave a partial character at the end of the payload, so only whole characters are decoded.
        // It's also entirely possible that the data isn't encoded in 6-bit ASCII, making this text garbage.
        if let textBits: BitBuffer = payloadBits[0..<((payloadBits.count / 6) * 6)] {
            self.text = AISText(raw: textBits)
        }
        else {
            self.text = nil
        }
        
        guard let radioStatusTypeBit: UInt8 = bits[bits.count-20...bits.count-20] else { return nil }
        guard let radioStatusType = RadioStatusType(rawValue: radioStatusTypeBit) else { return nil }
        guard let radioStatusBits: UInt32 = bits[bits.count-19..<bits.count] else { return nil }
        self.radioStatus = RadioStatus(rawValue: radioStatusBits, statusType: radioStatusType)
        
    }
    
    func description() -> String {
        var rows: [String] = [
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Addressed:", addressed.description)
        ]

        // A broadcast message has no destination, and an unstructured payload carries no DAC/FID header.
        if let destinationMMSI {
            rows.append(row("Destination MMSI:", "\(destinationMMSI.country) - \(destinationMMSI.description)"))
        }

        rows.append(row("Structured:", structuredFlag.description))

        if let dac {
            rows.append(row("Area Code (DAC):", "\(dac.description) (\(dac.rawValue))"))
            rows.append(row("Functional ID:", fid.map { "\($0)" } ?? "Unavailable"))
        }

        rows.append(row("Payload:", text?.text ?? "\(payload.count) bits"))
        rows.append(row("Radio Status:", radioStatus.description))

        return rows.joined(separator: "\n")
    }
    
    
}
