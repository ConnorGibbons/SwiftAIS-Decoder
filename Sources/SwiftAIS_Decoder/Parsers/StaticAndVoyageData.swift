//
//  StaticAndVoyageData.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/23/26.
//


class StaticAndVoyageData: AISMessage {
    let nmeaSentence: AISNMEA0183Sentence
    let messageType: AISMessageType
    let mmsiNumber: MMSI
    
    let nmeaSentence2: AISNMEA0183Sentence
    let aisVersion: AISVersion
    let imoNumber: UInt32
    
    init?(nmea1: AISNMEA0183Sentence, nmea2: AISNMEA0183Sentence) {
        self.nmeaSentence = nmea1
        self.nmeaSentence2 = nmea2
        
        var bits = nmea1.payloadBits
        bits.append(contentsOf: nmea2.payloadBits)
        
        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageTypeBits)) else { return nil }
        guard messageType.rawValue == 5 else { return nil }
        self.messageType = messageType

        guard let mmsiBits: UInt32 = bits[8...37] else { return nil }
        guard let mmsi = MMSI(value: mmsiBits) else { return nil }
        self.mmsiNumber = mmsi
        
        guard let aisVersionBits: UInt8 = bits[38...39] else { return nil }
        guard let aisVersion = AISVersion(rawValue: aisVersionBits) else { return nil }
        self.aisVersion = aisVersion
        
        guard let imoNumberBits: UInt32 = bits[40...69] else { return nil }
        self.imoNumber = imoNumberBits >> 2
        
        
        
    }
    
    func description() -> String {
        "Bruh"
    }
    
    
}

