//
//  BinaryAddressedMessage.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/28/26.
//
//  Type 6
//  Probably won't see many of these.

import SignalTools

class BinaryAddressedMessage: AISMessage {
    let nmeaSentence: AISNMEA0183Sentence
    let messageType: AISMessageType
    let mmsiNumber: MMSI
    
    var destinationMMSI: MMSI
    var retransmit: RetransmitFlag // 0 = no retransmit, 1 = retransmitted
    var spare: Bool // Pretty much nothing, just here because it's in the spec.
    var areaCode: AreaCode?
    var functionalID: UInt8
    var additionalSentences: [AISNMEA0183Sentence]?
    var payload: BitBuffer
    var text: AISText? // Almost every message will not properly decode AISText here. Most payloads are a mixture of data types, far too many to write individual parsers for.
    
    init?(nmeaSentences: [AISNMEA0183Sentence]) {
        guard nmeaSentences.count > 0 else { return nil }
        self.nmeaSentence = nmeaSentences[0]
        
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
        
        guard bits.count >= 89 else { return nil } // Functional ID is bit 87, so this guard is to ensure there's at least 1 payload bit
        
        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard messageTypeBits == 6 else { return nil }
        self.messageType = .binaryAddressedMessage
        
        guard let mmsiBits: UInt32 = bits[8...37] else { return nil }
        guard let mmsi: MMSI = .init(value: mmsiBits) else { return nil }
        self.mmsiNumber = mmsi
        
        guard let destinationMMSIBits: UInt32 = bits[40...69] else { return nil }
        guard let destinationMMSI: MMSI = .init(value: destinationMMSIBits) else { return nil }
        self.destinationMMSI = destinationMMSI
        
        let retransmitBits: Int = bits[70]
        guard let retransmitFlag = RetransmitFlag(rawValue: retransmitBits == 1) else { return nil }
        self.retransmit = retransmitFlag
        
        let spareBits: Int = bits[71]
        self.spare = spareBits == 1
        
        guard let areaCodeBits: UInt16 = bits[72...81] else { return nil }
        if let areaCode: AreaCode = .init(rawValue: areaCodeBits) { self.areaCode = areaCode } else { self.areaCode = nil }
        
        guard let functionalIDBits: UInt8 = bits[82...87] else { return nil }
        self.functionalID = functionalIDBits
        
        guard let payloadBits: BitBuffer = bits[88..<bits.count] else { return nil }
        self.payload = payloadBits
        
        // Fill bits can leave a partial character at the end of the payload, so only whole characters are decoded.
        if let textBits: BitBuffer = payloadBits[0..<((payloadBits.count / 6) * 6)] {
            self.text = AISText(raw: textBits)
        }
        else {
            self.text = nil
        }
    }
    
    func description() -> String {
        return ([
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Destination MMSI:", "\(destinationMMSI.country) - \(destinationMMSI.description)"),
            row("Retransmit:", retransmit.description),
            row("Area Code (DAC):", "\(areaCode?.description ?? "Unknown") (\(areaCode != nil ? String(areaCode!.rawValue) : "N/A"))"),
            row("Functional ID:", "\(functionalID)"),
            row("Payload:", text?.text ?? "\(payload.count) bits")
        ] as [String]).joined(separator: "\n")
    }
    
    
}
