//
//  AISSatelliteMessage.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/18/26.
//
//  Type 27: AIS Satellite Message
//  Payload Character: K
//
//  Short message that occupies less than a full slot, intended to be compact for long range reception.

public struct AISSatelliteMessage: AISMessage {
    public let nmeaSentence: AISNMEA0183Sentence
    public let messageType: AISMessageType
    public let mmsiNumber: MMSI
    
    public let positionAccuracy: PositionAccuracy
    public let raimFlag: RAIMFlag
    public let navigationStatus: NavigationStatus
    public let longitude: Longitude
    public let latitude: Latitude
    public let speedOverGround: SpeedOverGroundCompact
    public let courseOverGround: CourseOverGroundCompact
    public let positionLatency: PositionLatency
    public let spare: UInt8?
    
    public init(nmea: AISNMEA0183Sentence) throws(AISDecodingError) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits

        let messageType: AISMessageType = try bits.read(0...5, "messageType")
        guard messageType.rawValue == 27 else { throw .unexpectedMessageType(messageType.rawValue, expected: [27]) }
        self.messageType = messageType

        let mmsiBits: UInt32 = try bits.read(8...37, "mmsiNumber")
        guard let mmsi = MMSI(value: mmsiBits) else { throw .invalidValue(field: "mmsiNumber", rawValue: UInt64(mmsiBits)) }
        self.mmsiNumber = mmsi

        self.positionAccuracy = try bits.read(38...38, "positionAccuracy")
        self.raimFlag = try bits.read(39...39, "raimFlag")
        self.navigationStatus = try bits.read(40...43, "navigationStatus")
        self.longitude = Longitude(rawValue: try bits.read(44...61, "longitude"), isTenths: true)
        self.latitude = Latitude(rawValue: try bits.read(62...78, "latitude"), isTenths: true)

        let speedOverGroundBits: UInt8 = try bits.read(79...84, "speedOverGround")
        guard let speedOverGround = SpeedOverGroundCompact(rawValue: speedOverGroundBits) else { throw .invalidValue(field: "speedOverGround", rawValue: UInt64(speedOverGroundBits)) }
        self.speedOverGround = speedOverGround

        let courseOverGroundBits: UInt16 = try bits.read(85...93, "courseOverGround")
        guard let courseOverGround = CourseOverGroundCompact(rawValue: courseOverGroundBits) else { throw .invalidValue(field: "courseOverGround", rawValue: UInt64(courseOverGroundBits)) }
        self.courseOverGround = courseOverGround

        self.positionLatency = try bits.read(94...94, "positionLatency")

        if let spareBit: UInt8 = bits[95...95] {
            self.spare = spareBit
        } else {
            self.spare = nil
        }
    }
    
    public func description() -> String {
        return ([
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Navigation Status:", navigationStatus.description),
            row("Speed Over Ground:", speedOverGround.description),
            row("Position Accuracy:", positionAccuracy.description),
            row("Latitude:", latitude.description),
            row("Longitude:", longitude.description),
            row("Course Over Ground:", courseOverGround.description),
            row("Position Latency:", positionLatency.description),
            row("RAIM:", raimFlag.description)
        ] as [String]).joined(separator: "\n")
    }
    
    
}
