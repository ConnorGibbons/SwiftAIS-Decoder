//
//  SafetyBroadcastMessage.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 8/18/26.
//
//  Type 14: Safety-Related Broadcast Message
//  Payload character: >

import SignalTools

class SafetyBroadcastMessage: AISMessage {
    let nmeaSentence: AISNMEA0183Sentence
    let messageType: AISMessageType
    let mmsiNumber: MMSI
    
    let spare: UInt8
    let additionalSentences: [AISNMEA0183Sentence]?
    let payload: BitBuffer
    let text: AISText?
    
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
        
        guard bits.count > 40 else { return nil } // Spare ends at 40th bit, so this ensures there's at least one payload bit
        
        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageTypeBits)) else { return nil }
        guard messageType.rawValue == 14 else { return nil }
        self.messageType = messageType
        
        guard let mmsiBits: UInt32 = bits[8...37] else { return nil }
        guard let mmsiNumber = MMSI(value: mmsiBits) else { return nil }
        self.mmsiNumber = mmsiNumber
        
        guard let spareBits: UInt8 = bits[38...39] else { return nil }
        self.spare = spareBits
        
        guard let payloadBits: BitBuffer = bits[40..<bits.count] else { return nil }
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
            row("Payload:", text?.text ?? "\(payload.count) bits")
        ] as [String]).joined(separator: "\n")
    }
    
    
}
