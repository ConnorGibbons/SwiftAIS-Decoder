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
    
    public init?(nmeaSentences: [AISNMEA0183Sentence]) {
        guard nmeaSentences.count > 0 else { return nil }
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
        
        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageTypeBits)) else { return nil }
        guard messageType.rawValue == 12 else { return nil }
        self.messageType = messageType
        
        guard let mmsiBits: UInt32 = bits[8...37] else { return nil }
        guard let mmsi = MMSI(value: mmsiBits) else { return nil  }
        self.mmsiNumber = mmsi
        
        guard let seqNumberBits: UInt8 = bits[38...39] else { return nil }
        self.sequenceNumber = seqNumberBits
        
        guard let destinationMMSIBits: UInt32 = bits[40...69] else { return nil }
        guard let destinationMMSI = MMSI(value: destinationMMSIBits) else { return nil  }
        self.destinationMMSI = destinationMMSI
        
        guard let retransmitBits: UInt8 = bits[70...70] else { return nil }
        guard let retransmit = RetransmitFlag(rawValue: retransmitBits == 1) else { return nil }
        self.retransmit = retransmit
        
        guard let spareBit: UInt8 = bits[71...71] else { return nil }
        self.spare = spareBit == 1
        
        guard let payloadBits: BitBuffer = bits[72..<bits.count] else { return nil }
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
