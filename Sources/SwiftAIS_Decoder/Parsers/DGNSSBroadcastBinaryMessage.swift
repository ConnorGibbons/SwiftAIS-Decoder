//
//  DGNSSBroadcastBinaryMessage.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/1/26.
//
//  Type 17: DGNSS Broadcast Binary Message
//  Sends out "differential correction" information allowing supporting receivers to have a more accurate fix.

import SignalTools

public struct DGNSSBroadcastBinaryMessage: AISMessage {
    public let nmeaSentence: AISNMEA0183Sentence
    public let messageType: AISMessageType
    public let mmsiNumber: MMSI
    
    public let additionalSentences: [AISNMEA0183Sentence]?
    public let spare1: UInt8
    public let longitude: Longitude
    public let latitude: Latitude
    public let spare2: UInt8
    public let data: BitBuffer
    
    // These fields are the header fields of RTCM 2.X. I'm putting them in here because they're interesting to decode, but they won't always work.
    // I wouldn't put full faith into these being accurate, and I won't pretend I fully understand them either!
    
    public let messageTypeIdentifier: UInt8?
    public let stationID: UInt16?
    public let zCount: UInt16? // Given in 0.6 second increments
    public let sequenceNumber: UInt8?
    public let length: UInt8? // Given in 24-bit words
    public let stationHealth: UInt8?
    
    
    
    
    public init(nmeaSentences: [AISNMEA0183Sentence]) throws(AISDecodingError) {
        guard nmeaSentences.count > 0 else { throw .payloadTooShort(field: "messageType", bits: 0..<6, available: 0) }
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
        
        let messageType: AISMessageType = try bits.read(0...5, "messageType")
        guard messageType.rawValue == 17 else { throw .unexpectedMessageType(messageType.rawValue, expected: [17]) }
        self.messageType = messageType

        let mmsiBits: UInt32 = try bits.read(8...37, "mmsiNumber")
        guard let mmsiNumber = MMSI(value: mmsiBits) else { throw .invalidValue(field: "mmsiNumber", rawValue: UInt64(mmsiBits)) }
        self.mmsiNumber = mmsiNumber

        self.spare1 = try bits.read(38...39, "spare1")
        self.longitude = Longitude(rawValue: try bits.read(40...57, "longitude"), isTenths: true)
        self.latitude = Latitude(rawValue: try bits.read(58...74, "latitude"), isTenths: true)
        self.spare2 = try bits.read(75...79, "spare2")
        self.data = try bits.read(80..<bits.count, "data")
        
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
    
    public func description() -> String {
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

