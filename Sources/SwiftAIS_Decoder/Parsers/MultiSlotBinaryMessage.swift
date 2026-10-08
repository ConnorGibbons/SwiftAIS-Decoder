//
//  MultiSlotBinaryMessage.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/10/26.
//
//  Type 26: Multi Slot Binary Message
//  Listed as "extremely rare" https://gpsd.gitlab.io/gpsd/AIVDM.html
//  Payload character: J

import SignalTools

public struct MultiSlotBinaryMessage: AISMessage {
    public let nmeaSentence: AISNMEA0183Sentence
    public let messageType: AISMessageType
    public let mmsiNumber: MMSI
    
    public let addressed: Addressed
    public let structuredFlag: StructuredFlag
    public let payload: BitBuffer
    public let text: AISText?
    public let radioStatus: RadioStatus
    
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
        guard messageType.rawValue == 26 else { throw .unexpectedMessageType(messageType.rawValue, expected: [26]) }
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
            // Same 0/2-bit spare as message 25 (ITU-R M.1371-5 Table 79): present only when the
            // destination ID is used.
            _ = ptrAdvance(ptr: &ptr, advanceBy: 2)
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
        
        // Without this, a message too short for the trailing 20-bit radio status would build an inverted range below and crash.
        guard bits.count - 20 >= ptr else { throw .payloadTooShort(field: "radioStatus", bits: ptr..<(ptr + 20), available: bits.count) }
        let payloadBits: BitBuffer = try bits.read(ptr..<(bits.count-20), "payload")
        self.payload = payloadBits
        
        // Fill bits can leave a partial character at the end of the payload, so only whole characters are decoded.
        // It's also entirely possible that the data isn't encoded in 6-bit ASCII, making this text garbage.
        if let textBits: BitBuffer = payloadBits[0..<((payloadBits.count / 6) * 6)] {
            self.text = AISText(raw: textBits)
        }
        else {
            self.text = nil
        }
        
        let radioStatusType: RadioStatusType = try bits.read(bits.count-20...bits.count-20, "radioStatusType")
        self.radioStatus = RadioStatus(rawValue: try bits.read(bits.count-19..<bits.count, "radioStatus"), statusType: radioStatusType)
        
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
        rows.append(row("Radio Status:", radioStatus.description))

        return rows.joined(separator: "\n")
    }
    
    
}
