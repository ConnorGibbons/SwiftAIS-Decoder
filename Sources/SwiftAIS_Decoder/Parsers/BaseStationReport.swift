//
//  BaseStationReport.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/14/26.
//
//  Type 4: Base Station Report


public struct BaseStationReport: AISMessage {
    public let nmeaSentence: AISNMEA0183Sentence
    public let messageType: AISMessageType
    public let mmsiNumber: MMSI
    
    public let year: UTCYear
    public let month: UTCMonth
    public let day: UTCDay
    public let hour: UTCHour
    public let minute: UTCMinute
    public let second: TimeStamp
    public let positionAccuracy: PositionAccuracy
    public let longitude: Longitude
    public let latitude: Latitude
    public let fixType: EPFDFixType
    public let spareBits: UInt64
    public let raimFlag: RAIMFlag
    public let radioStatus: RadioStatus
    
    
    public init(nmea: AISNMEA0183Sentence) throws(AISDecodingError) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits

        let messageType: AISMessageType = try bits.read(0...5, "messageType")
        guard messageType.rawValue == 4 else { throw .unexpectedMessageType(messageType.rawValue, expected: [4]) }
        self.messageType = messageType

        let mmsiBits: UInt32 = try bits.read(8...37, "mmsiNumber")
        guard let mmsi = MMSI(value: mmsiBits) else { throw .invalidValue(field: "mmsiNumber", rawValue: UInt64(mmsiBits)) }
        self.mmsiNumber = mmsi

        self.year = UTCYear(rawValue: try bits.read(38...51, "year"))
        self.month = UTCMonth(rawValue: try bits.read(52...55, "month"))
        self.day = UTCDay(rawValue: try bits.read(56...60, "day"))
        self.hour = UTCHour(rawValue: try bits.read(61...65, "hour"))
        self.minute = UTCMinute(rawValue: try bits.read(66...71, "minute"))
        self.second = TimeStamp(rawValue: try bits.read(72...77, "second"))
        self.positionAccuracy = try bits.read(78...78, "positionAccuracy")
        self.longitude = Longitude(rawValue: try bits.read(79...106, "longitude"))
        self.latitude = Latitude(rawValue: try bits.read(107...133, "latitude"))
        self.fixType = try bits.read(134...137, "fixType")
        self.spareBits = try bits.read(138...147, "spareBits")
        self.raimFlag = try bits.read(148...148, "raimFlag")
        self.radioStatus = RadioStatus(rawValue: try bits.read(149...167, "radioStatus"))
    }
    
    public func description() -> String {
        return ([
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Time (UTC):", dateStringFromUTCElements(year: self.year, month: self.month, day: self.day, hour: self.hour, minute: self.minute, second: self.second)),
            row("Latitude:", latitude.description),
            row("Longitude:", longitude.description),
            row("Position Accuracy:", positionAccuracy.description),
            row("EPFD Fix Type:", fixType.description),
            row("RAIM:", raimFlag.description),
            row("Radio Status:", radioStatus.description)
        ] as [String]).joined(separator: "\n")
    }
    
    
}
