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

public struct SingleSlotBinaryMessage: AISMessage {
    public let nmeaSentence: AISNMEA0183Sentence
    public let messageType: AISMessageType
    public let mmsiNumber: MMSI
    
    public let addressed: Addressed
    public let structuredFlag: StructuredFlag
    public let payload: BitBuffer
    public let text: AISText?
    
    // Only present if addressed
    public let destinationMMSI: MMSI?
    
    // Only present if structuredFlag is true
    public let appID: UInt16? // The following two values are derived from this
    public let dac: DesignatedAreaCode?
    public let fid: UInt8?
    
    public init(nmea: AISNMEA0183Sentence) throws(AISDecodingError) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits

        let messageType: AISMessageType = try bits.read(0...5, "messageType")
        guard messageType.rawValue == 25 else { throw .unexpectedMessageType(messageType.rawValue, expected: [25]) }
        self.messageType = messageType

        let mmsiBits: UInt32 = try bits.read(8...37, "mmsiNumber")
        guard let mmsi = MMSI(value: mmsiBits) else { throw .invalidValue(field: "mmsiNumber", rawValue: UInt64(mmsiBits)) }
        self.mmsiNumber = mmsi

        let addressed: Addressed = try bits.read(38...38, "addressed")
        self.addressed = addressed

        let structuredFlag = StructuredFlag(rawValue: try bits.read(39, "structuredFlag"))
        self.structuredFlag = structuredFlag

        var ptr = 40
        if(addressed == .addressed) {
            let destinationMMSIBits: UInt32 = try bits.read(ptr..<ptrAdvance(ptr: &ptr, advanceBy: 30), "destinationMMSI")
            guard let destinationMMSI = MMSI(value: destinationMMSIBits) else { throw .invalidValue(field: "destinationMMSI", rawValue: UInt64(destinationMMSIBits)) }
            self.destinationMMSI = destinationMMSI
            // ITU-R M.1371-5 Table 79 gives the spare a width of 0/2 bits: present only when the
            // destination ID is used. Some decoders (aggsoft, for one) skip it and read the payload
            // two bits early.
            _ = ptrAdvance(ptr: &ptr, advanceBy: 2)
            // The spare is skipped rather than read, so a message ending inside it would otherwise build an inverted payload range below and crash.
            guard ptr <= bits.count else { throw .payloadTooShort(field: "spare", bits: (ptr - 2)..<ptr, available: bits.count) }
        }
        else {
            self.destinationMMSI = nil
        }
        
        if(structuredFlag.rawValue) {
            let appIDBits: UInt16 = try bits.read(ptr..<ptrAdvance(ptr: &ptr, advanceBy: 16), "appID")
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
        
        let payloadBits: BitBuffer = try bits.read(ptr..<bits.count, "payload")
        self.payload = payloadBits
        
        // Fill bits can leave a partial character at the end of the payload, so only whole characters are decoded.
        // It's also entirely possible that the data isn't encoded in 6-bit ASCII, making this text garbage.
        if let textBits: BitBuffer = payloadBits[0..<((payloadBits.count / 6) * 6)] {
            self.text = AISText(raw: textBits)
        }
        else {
            self.text = nil
        }
        
    }
    
    public func description() -> String {
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

        return rows.joined(separator: "\n")
    }
    
    
}

func ptrAdvance(ptr: inout Int, advanceBy: Int) -> Int {
    ptr = ptr + advanceBy
    return ptr
}
