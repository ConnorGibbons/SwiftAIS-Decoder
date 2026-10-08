//
//  AddresedSafetyMessage.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 8/14/26.
//
//  Type 12: Addressed Safety-Related Message
//  Payload character: <

import SignalTools

public struct AddresedSafetyMessage: AISMessage {
    public let nmeaSentence: AISNMEA0183Sentence
    public let messageType: AISMessageType
    public let mmsiNumber: MMSI
    
    public let additionalSentences: [AISNMEA0183Sentence]?
    public let sequenceNumber: UInt8
    public let destinationMMSI: MMSI
    public let retransmit: RetransmitFlag
    public let spare: Bool
    public let payload: BitBuffer
    public let text: AISText? // The payload is described as not always containing normally encoded text, and I don't want that to make this init fail.
    
    public init(nmeaSentences: [AISNMEA0183Sentence]) throws(AISDecodingError) {
        guard nmeaSentences.count > 0 else { throw .payloadTooShort(field: "messageType", bits: 0..<6, available: 0) }
        let nmea = nmeaSentences[0]
        self.nmeaSentence = nmea
        
        var bits: BitBuffer = .init()
        if nmeaSentences.count > 1 {
            self.additionalSentences = Array(nmeaSentences.dropFirst())
        }
        else {
            self.additionalSentences = nil
        }
        for sentence in nmeaSentences {
            bits.append(contentsOf: sentence.payloadBits)
        }
        
        let messageType: AISMessageType = try bits.read(0...5, "messageType")
        guard messageType.rawValue == 12 else { throw .unexpectedMessageType(messageType.rawValue, expected: [12]) }
        self.messageType = messageType

        let mmsiBits: UInt32 = try bits.read(8...37, "mmsiNumber")
        guard let mmsi = MMSI(value: mmsiBits) else { throw .invalidValue(field: "mmsiNumber", rawValue: UInt64(mmsiBits)) }
        self.mmsiNumber = mmsi

        self.sequenceNumber = try bits.read(38...39, "sequenceNumber")

        let destinationMMSIBits: UInt32 = try bits.read(40...69, "destinationMMSI")
        guard let destinationMMSI = MMSI(value: destinationMMSIBits) else { throw .invalidValue(field: "destinationMMSI", rawValue: UInt64(destinationMMSIBits)) }
        self.destinationMMSI = destinationMMSI

        self.retransmit = RetransmitFlag(rawValue: try bits.read(70, "retransmit"))
        self.spare = try bits.read(71, "spare")

        let payloadBits: BitBuffer = try bits.read(72..<bits.count, "payload")
        self.payload = payloadBits

        // Fill bits can leave a partial character at the end of the payload, so only whole characters are decoded.
        if let textBits: BitBuffer = payloadBits[0..<((payloadBits.count / 6) * 6)] {
            self.text = AISText(raw: textBits)
        }
        else {
            self.text = nil
        }
    }
    
    public func description() -> String {
        return ([
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Destination MMSI:", "\(destinationMMSI.country) - \(destinationMMSI.description)"),
            row("Sequence Number:", "\(sequenceNumber)"),
            row("Retransmit:", retransmit.description),
            row("Message:", text?.text ?? "\(payload.count) bits")
        ] as [String]).joined(separator: "\n")
    }
    
    
}
