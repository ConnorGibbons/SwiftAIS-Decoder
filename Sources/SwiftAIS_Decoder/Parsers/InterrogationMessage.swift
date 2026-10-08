//
//  InterrogationMessage.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 8/18/26.
//
//  Type 15: Interrogation message. Used to request 1 or 2 AIS stations send a particular message type.
//  Payload character: ?

public struct InterrogationMessage: AISMessage {
    public let nmeaSentence: AISNMEA0183Sentence
    public let messageType: AISMessageType
    public let mmsiNumber: MMSI
    
    public let spare_1: UInt8
    public let interrogatedMMSI_1: MMSI
    public let requestedMessageType_1: AISMessageType
    public let slotOffset_1: UInt16
    
    /// Anything beyond this point is optional because the message can end at 88 bits.
    public var spare_2: UInt8?
    public var requestedMessageType_2: AISMessageType?
    public var slotOffset_2: UInt16?
    
    public var spare_3: UInt8?
    public var interrogatedMMSI_2: MMSI?
    public var requestedMessageType_3: AISMessageType?
    public var slotOffset_3: UInt16?
    public var spare_4: UInt8?
    
    
    public init(nmea: AISNMEA0183Sentence) throws(AISDecodingError) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits

        let messageType: AISMessageType = try bits.read(0...5, "messageType")
        guard messageType.rawValue == 15 else { throw .unexpectedMessageType(messageType.rawValue, expected: [15]) }
        self.messageType = messageType

        let mmsiBits: UInt32 = try bits.read(8...37, "mmsiNumber")
        guard let mmsi = MMSI(value: mmsiBits) else { throw .invalidValue(field: "mmsiNumber", rawValue: UInt64(mmsiBits)) }
        self.mmsiNumber = mmsi

        self.spare_1 = try bits.read(38...39, "spare_1")

        let interrogatedMMSI1Bits: UInt32 = try bits.read(40...69, "interrogatedMMSI_1")
        guard let interrogatedMMSI_1 = MMSI(value: interrogatedMMSI1Bits) else { throw .invalidValue(field: "interrogatedMMSI_1", rawValue: UInt64(interrogatedMMSI1Bits)) }
        self.interrogatedMMSI_1 = interrogatedMMSI_1

        self.requestedMessageType_1 = try bits.read(70...75, "requestedMessageType_1")
        self.slotOffset_1 = try bits.read(76...87, "slotOffset_1")

        self.spare_2 = nil
        self.requestedMessageType_2 = nil
        self.slotOffset_2 = nil
        self.spare_3 = nil
        self.interrogatedMMSI_2 = nil
        self.requestedMessageType_3 = nil
        self.slotOffset_3 = nil
        self.spare_4 = nil
        
        guard let spare2Bits: UInt8 = bits[88...89] else { return }
        self.spare_2 = spare2Bits
        
        guard let requestedMessageType2Bits: UInt8 = bits[90...95] else { return }
        if(requestedMessageType2Bits != 0) { // If querying two stations for one type each, this field & slot offset will be 0
            guard let requestedMessageType_2 = AISMessageType(rawValue: Int(requestedMessageType2Bits)) else { return }
            self.requestedMessageType_2 = requestedMessageType_2
        }
        
        guard let slotOffset2Bits: UInt16 = bits[96...107] else { return }
        self.slotOffset_2 = slotOffset2Bits
        
        guard let spare3Bits: UInt8 = bits[108...109] else { return }
        self.spare_3 = spare3Bits
        
        guard let interrogatedMMSI2Bits: UInt32 = bits[110...139] else { return }
        if(interrogatedMMSI2Bits != 0) { // If it's zero, it's just sender zero filling empty fields.
            guard let interrogatedMMSI_2 = MMSI(value: interrogatedMMSI2Bits) else { return } // If there's this many bits in the message, the second MMSI is non-optional.
            self.interrogatedMMSI_2 = interrogatedMMSI_2
        }
        
        guard let requestedMessageType3Bits: UInt8 = bits[140...145] else { return }
        guard let requestedMessageType_3 = AISMessageType(rawValue: Int(requestedMessageType3Bits)) else { return }
        self.requestedMessageType_3 = requestedMessageType_3
        
        guard let slotOffset3Bits: UInt16 = bits[146...157] else { return }
        self.slotOffset_3 = slotOffset3Bits
        
        guard let spare4Bits: UInt8 = bits[158...159] else { return }
        self.spare_4 = spare4Bits
    }
    
    public func description() -> String {
        var rows: [String] = [
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Interrogated MMSI:", "\(interrogatedMMSI_1.country) - \(interrogatedMMSI_1.description)")
        ]
        
        // The first station can be asked for up to two message types, so its requests are listed one per line.
        var firstStationRequests: [String] = [requestDescription(requestedMessageType_1, slotOffset: slotOffset_1)]
        if let requestedMessageType_2 = requestedMessageType_2 {
            firstStationRequests.append(requestDescription(requestedMessageType_2, slotOffset: slotOffset_2))
        }
        rows.append(row("Requested:", firstStationRequests.joined(separator: "\n" + row("", ""))))

        // An interrogated MMSI of 0 addresses no station, so the second block is skipped here even though
        // the parsed values are still kept on the message.
        if let interrogatedMMSI_2 = interrogatedMMSI_2, interrogatedMMSI_2.value != 0 {
            rows.append(row("Interrogated MMSI:", "\(interrogatedMMSI_2.country) - \(interrogatedMMSI_2.description)"))
            if let requestedMessageType_3 = requestedMessageType_3 {
                rows.append(row("Requested:", requestDescription(requestedMessageType_3, slotOffset: slotOffset_3)))
            }
        }

        return rows.joined(separator: "\n")
    }

    private func requestDescription(_ requestedType: AISMessageType, slotOffset: UInt16?) -> String {
        let requested = "\(requestedType.description) (Type \(requestedType.rawValue))"
        guard let slotOffset = slotOffset, slotOffset != 0 else { return requested }
        return requested + ", Slot Offset \(slotOffset)"
    }

    
}
