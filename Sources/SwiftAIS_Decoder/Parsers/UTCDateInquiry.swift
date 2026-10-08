//
//  UTCDateInquiry.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 8/11/26.
//
//  Type 10: UTC/Date Inquiry

public struct UTCDateInquiry: AISMessage {
    public let nmeaSentence: AISNMEA0183Sentence
    public let messageType: AISMessageType
    public let mmsiNumber: MMSI
    
    public let spare1: UInt8
    public let destinationMMSI: MMSI
    public let spare2: UInt8

    
    public init(nmea: AISNMEA0183Sentence) throws(AISDecodingError) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits

        let messageType: AISMessageType = try bits.read(0...5, "messageType")
        guard messageType.rawValue == 10 else { throw .unexpectedMessageType(messageType.rawValue, expected: [10]) }
        self.messageType = messageType

        let mmsiBits: UInt32 = try bits.read(8...37, "mmsiNumber")
        guard let mmsi = MMSI(value: mmsiBits) else { throw .invalidValue(field: "mmsiNumber", rawValue: UInt64(mmsiBits)) }
        self.mmsiNumber = mmsi

        self.spare1 = try bits.read(38...39, "spare1")

        let destinationMMSIBits: UInt32 = try bits.read(40...69, "destinationMMSI")
        guard let destinationMMSI = MMSI(value: destinationMMSIBits) else { throw .invalidValue(field: "destinationMMSI", rawValue: UInt64(destinationMMSIBits)) }
        self.destinationMMSI = destinationMMSI

        self.spare2 = try bits.read(70...71, "spare2")
    }
    
    public func description() -> String {
        return ([
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Destination MMSI:", "\(destinationMMSI.country) - \(destinationMMSI.description)")
        ] as [String]).joined(separator: "\n")
    }
    
    
}
