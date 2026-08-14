//
//  UTCDateInquiry.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 8/11/26.
//
//  Type 10: UTC/Date Inquiry

class UTCDateInquiry: AISMessage {
    let nmeaSentence: AISNMEA0183Sentence
    let messageType: AISMessageType
    let mmsiNumber: MMSI
    
    let spare1: UInt8
    let destinationMMSI: MMSI
    let spare2: UInt8

    
    init?(nmea: AISNMEA0183Sentence) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits
        
        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageTypeBits)) else { return nil }
        guard messageType.rawValue == 10 else { return nil }
        self.messageType = messageType
                
        guard let mmsiBits: UInt32 = bits[8...37] else { return nil }
        guard let mmsi = MMSI(value: mmsiBits) else { return nil }
        self.mmsiNumber = mmsi
        
        guard let spareBits1: UInt8 = bits[38...39] else { return nil }
        self.spare1 = spareBits1
        
        guard let destinationMMSIBits: UInt32 = bits[40...69] else { return nil }
        guard let destinationMMSI = MMSI(value: destinationMMSIBits) else { return nil }
        self.destinationMMSI = destinationMMSI
        
        guard let spareBits2: UInt8 = bits[70...71] else { return nil }
        self.spare2 = spareBits2
    }
    
    func description() -> String {
        return ([
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Destination MMSI:", "\(destinationMMSI.country) - \(destinationMMSI.description)")
        ] as [String]).joined(separator: "\n")
    }
    
    
}
