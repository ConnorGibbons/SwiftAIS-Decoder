//
//  DGNSSBroadcastBinaryMessage.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/1/26.
//
//  Type 17: DGNSS Broadcast Binary Message
//  Sends out "differential correction" information allowing supporting receivers to have a more accurate fix.

import SignalTools

class DGNSSBroadcastBinaryMessage: AISMessage {
    let nmeaSentence: AISNMEA0183Sentence
    let messageType: AISMessageType
    let mmsiNumber: MMSI
    
    let additionalSentences: [AISNMEA0183Sentence]?
    let spare1: UInt8
    let longitude: Longitude
    let latitude: Latitude
    let spare2: UInt8
    let data: BitBuffer
    
    // These fields are the header fields of RTCM 2.X. I'm putting them in here because they're interesting to decode, but they won't always work.
    // I wouldn't put full faith into these being accurate, and I won't pretend I fully understand them either!
    
    let messageTypeIdentifier: UInt8?
    let stationID: UInt16?
    let zCount: UInt16? // Given in 0.6 second increments
    let sequenceNumber: UInt8?
    let length: UInt8? // Given in 24-bit words
    let stationHealth: UInt8?
    
    
    
    
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
        
        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageTypeBits)) else { return nil }
        guard messageType.rawValue == 17 else { return nil }
        self.messageType = messageType
        
        guard let mmsiBits: UInt32 = bits[8...37] else { return nil }
        guard let mmsiNumber = MMSI(value: mmsiBits) else { return nil }
        self.mmsiNumber = mmsiNumber
        
        guard let spare1Bits: UInt8 = bits[38...39] else { return nil }
        self.spare1 = spare1Bits
        
        guard let longitudeBits: UInt32 = bits[40...57] else { return nil }
        let longitude = Longitude(rawValue: longitudeBits, isTenths: true)
        self.longitude = longitude
        
        guard let latitudeBits: UInt32 = bits[58...74] else { return nil }
        let latitude = Latitude(rawValue: latitudeBits, isTenths: true)
        self.latitude = latitude
        
        guard let spare2Bits: UInt8 = bits[75...79] else { return nil }
        self.spare2 = spare2Bits
        
        guard let dataBits: BitBuffer = bits[80..<bits.count] else { return nil }
        self.data = dataBits
        
        if let messageTypeIdentifierBits: UInt8 = bits[80...85] {
            self.messageTypeIdentifier = messageTypeIdentifierBits
        } else {
            self.messageTypeIdentifier = nil
        }
        
        if let stationIDBits: UInt16 = bits[86...95] {
            self.stationID = stationIDBits
        } else {
            self.stationID = nil
        }
        
        if let zCountBits: UInt16 = bits[96...108] {
            self.zCount = zCountBits
        } else {
            self.zCount = nil
        }
        
        if let sequenceNumberBits: UInt8 = bits[109...111] {
            self.sequenceNumber = sequenceNumberBits
        } else {
            self.sequenceNumber = nil
        }
        
        if let lengthBits: UInt8 = bits[112...116] {
            self.length = lengthBits
        } else {
            self.length = nil
        }
        
        if let stationHealthBits: UInt8 = bits[117...119] {
            self.stationHealth = stationHealthBits
        } else {
            self.stationHealth = nil
        }
    }
    
    func description() -> String {
        var rows: [String] = [
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Latitude:", latitude.description),
            row("Longitude:", longitude.description),
            row("Data:", "\(data.count) bits")
        ]

        // The RTCM 2.X header fields are only decoded when the payload is long enough to hold them,
        // so each one is listed only when it's actually present.
        if let messageTypeIdentifier = messageTypeIdentifier {
            rows.append(row("RTCM Message Type:", "\(messageTypeIdentifier)"))
        }
        if let stationID = stationID {
            rows.append(row("RTCM Station ID:", "\(stationID)"))
        }
        if let zCount = zCount {
            rows.append(row("Z-Count:", "\(zCount) (\((Double(zCount) * 0.6).rounded(toPlaces: 1)) seconds)"))
        }
        if let sequenceNumber = sequenceNumber {
            rows.append(row("Sequence Number:", "\(sequenceNumber)"))
        }
        if let length = length {
            rows.append(row("Length:", "\(length) words (\(Int(length) * 24) bits)"))
        }
        if let stationHealth = stationHealth {
            rows.append(row("Station Health:", "\(stationHealth)"))
        }

        return rows.joined(separator: "\n")
    }
    
    
}

