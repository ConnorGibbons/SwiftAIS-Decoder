//
//  BinaryAcknowledge.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/29/26.
//
//  Type 7

class BinaryAcknowledge: AISMessage {
    let nmeaSentence: AISNMEA0183Sentence
    let messageType: AISMessageType
    let mmsiNumber: MMSI
    
    let mmsis: [MMSI]
    
    
    init?(nmea: AISNMEA0183Sentence) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits
        
        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageTypeBits)) else { return nil }
        guard messageType.rawValue == 7 else { return nil }
        self.messageType = messageType
        
        guard let mmsiBits: UInt32 = bits[8...37] else { return nil }
        guard let mmsi = MMSI(value: mmsiBits) else { return nil }
        self.mmsiNumber = mmsi
        
        var mmsis: [MMSI] = []
        var bitIndex: Int = 40
        while(bitIndex + 29 < bits.count) {
            if let mmsi: UInt32 = bits[bitIndex...bitIndex + 29] {
                if let mmsiValue = MMSI(value: mmsi) {
                    mmsis.append(mmsiValue)
                }
                bitIndex += 32
            }
        }
        self.mmsis = mmsis
    }
    
    
    
    func description() -> String {
        let acknowledged: String
        if mmsis.isEmpty {
            acknowledged = "None"
        } else {
            acknowledged = mmsis.map { "\($0.country) - \($0.description)" }.joined(separator: "\n" + row("", ""))
        }
        return ([
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Acknowledged MMSIs:", acknowledged)
        ] as [String]).joined(separator: "\n")
    }
    
    
}
