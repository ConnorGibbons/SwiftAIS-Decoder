//
//  BinaryBroadcastMessage.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 8/6/26.
//
//  Type 8
//  Won't see many of these either

import SignalTools

class BinaryBroadcastMessage: AISMessage {
    let nmeaSentence: AISNMEA0183Sentence
    let messageType: AISMessageType
    let mmsiNumber: MMSI
    
    var spare: UInt8 // Pretty much nothing, just here because it's in the spec.
    var areaCode: AreaCode?
    var functionalID: UInt8
    var additionalSentences: [AISNMEA0183Sentence]?
    var payload: BitBuffer
    var payloadString: AISText? // Almost every message will not properly decode AISText here. Most payloads are a mixture of data types, far too many to write individual parsers for.
    
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
        
        guard bits.count >= 57 else { return nil } // Functional ID ends at bit 55, so this guard ensures there's at least 1 payload bit

        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard messageTypeBits == 8 else { return nil }
        self.messageType = .binaryBroadcastMessage
        
        guard let mmsiBits: UInt32 = bits[8...37] else { return nil }
        guard let mmsi: MMSI = .init(value: mmsiBits) else { return nil }
        self.mmsiNumber = mmsi
        
        guard let spareBits: UInt8 = bits[38...39] else { return nil }
        self.spare = spareBits
        
        guard let areaCodeBits: UInt16 = bits[40...49] else { return nil }
        if let areaCode: AreaCode = .init(rawValue: areaCodeBits) { self.areaCode = areaCode } else { self.areaCode = nil }
        
        guard let functionalIDBits: UInt8 = bits[50...55] else { return nil }
        self.functionalID = functionalIDBits
        
        guard let payloadBits: BitBuffer = bits[56..<bits.count] else { return nil }
        self.payload = payloadBits
        
        if let payloadText = AISText(raw: payloadBits) {
            self.payloadString = payloadText
        } else {
            self.payloadString = nil
        }
    }
    
    func description() -> String {
        return ([
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Area Code (DAC):", "\(areaCode?.description ?? "Unknown") (\(areaCode != nil ? String(areaCode!.rawValue) : "N/A"))"),
            row("Functional ID:", "\(functionalID)"),
            row("Payload:", payloadString?.text ?? "\(payload.count) bits")
        ] as [String]).joined(separator: "\n")
    }
    
    
}
