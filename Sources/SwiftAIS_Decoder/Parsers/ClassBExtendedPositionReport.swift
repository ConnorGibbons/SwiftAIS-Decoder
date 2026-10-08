//
//  ClassBExtendedPositionReport.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/2/26.
//
//  Type 19: Extended Class B Positon Report
//  Payload Character: C

import SignalTools

public struct ClassBExtendedPositionReport: AISMessage {
    public let nmeaSentence: AISNMEA0183Sentence
    public let messageType: AISMessageType
    public let mmsiNumber: MMSI
    
    public let regionalReserved1: UInt8 // As with non-extended (type 18), not sure what this is used for
    public let speedOverGround: SpeedOverGround
    public let positionAccuracy: PositionAccuracy
    public let longitude: Longitude
    public let latitude: Latitude
    public let courseOverGround: CourseOverGround
    public let trueHeading: TrueHeading
    public let timeStamp: TimeStamp
    public let regionalReserved2: UInt8
    public let name: AISText
    public let shipType: ShipType
    public let dimensionToBow: UInt16
    public let dimensionToStern: UInt16
    public let dimensionToPort: UInt8
    public let dimensionToStarboard: UInt8
    public let fixType: EPFDFixType
    public let raimFlag: RAIMFlag
    public let dte: DTE
    public let assignedFlag: AssignedFlag
    public let spare: UInt8
    
    public init(nmea: AISNMEA0183Sentence) throws(AISDecodingError) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits

        let messageType: AISMessageType = try bits.read(0...5, "messageType")
        guard messageType.rawValue == 19 else { throw .unexpectedMessageType(messageType.rawValue, expected: [19]) }
        self.messageType = messageType

        let mmsiBits: UInt32 = try bits.read(8...37, "mmsiNumber")
        guard let mmsi = MMSI(value: mmsiBits) else { throw .invalidValue(field: "mmsiNumber", rawValue: UInt64(mmsiBits)) }
        self.mmsiNumber = mmsi

        self.regionalReserved1 = try bits.read(38...45, "regionalReserved1")

        let speedOverGroundBits: UInt16 = try bits.read(46...55, "speedOverGround")
        guard let speedOverGround = SpeedOverGround(rawValue: speedOverGroundBits) else { throw .invalidValue(field: "speedOverGround", rawValue: UInt64(speedOverGroundBits)) }
        self.speedOverGround = speedOverGround

        self.positionAccuracy = try bits.read(56...56, "positionAccuracy")
        self.longitude = Longitude(rawValue: try bits.read(57...84, "longitude"))
        self.latitude = Latitude(rawValue: try bits.read(85...111, "latitude"))

        let courseOverGroundBits: UInt16 = try bits.read(112...123, "courseOverGround")
        guard let courseOverGround = CourseOverGround(rawValue: courseOverGroundBits) else { throw .invalidValue(field: "courseOverGround", rawValue: UInt64(courseOverGroundBits)) }
        self.courseOverGround = courseOverGround

        self.trueHeading = TrueHeading(rawValue: try bits.read(124...132, "trueHeading"))
        self.timeStamp = TimeStamp(rawValue: try bits.read(133...138, "timeStamp"))
        self.regionalReserved2 = try bits.read(139...142, "regionalReserved2")

        let nameBits: BitBuffer = try bits.read(143...262, "name")
        guard let name = AISText(raw: nameBits) else { throw .invalidText(field: "name") }
        self.name = name

        self.shipType = try bits.read(263...270, "shipType")
        self.dimensionToBow = try bits.read(271...279, "dimensionToBow")
        self.dimensionToStern = try bits.read(280...288, "dimensionToStern")
        self.dimensionToPort = try bits.read(289...294, "dimensionToPort")
        self.dimensionToStarboard = try bits.read(295...300, "dimensionToStarboard")
        self.fixType = try bits.read(301...304, "fixType")
        self.raimFlag = try bits.read(305...305, "raimFlag")
        self.dte = DTE(rawValue: try bits.read(306, "dte"))
        self.assignedFlag = AssignedFlag(rawValue: try bits.read(307, "assignedFlag"))
        self.spare = try bits.read(308...311, "spare")
    }
    
    public func description() -> String {
        return ([
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Speed Over Ground:", speedOverGround.description),
            row("Position Accuracy:", positionAccuracy.description),
            row("Latitude:", latitude.description),
            row("Longitude:", longitude.description),
            row("Course Over Ground:", courseOverGround.description),
            row("True Heading:", trueHeading.description),
            row("Timestamp:", timeStamp.description),
            row("Name:", name.text),
            row("Ship Type:", shipType.description),
            row("Dimensions (m):", "Bow \(dimensionToBow), Stern \(dimensionToStern), Port \(dimensionToPort), Starboard \(dimensionToStarboard)"),
            row("EPFD Fix Type:", fixType.description),
            row("RAIM:", raimFlag.description),
            row("DTE:", dte.description),
            row("Assigned:", assignedFlag.description)
        ] as [String]).joined(separator: "\n")
    }
    
    
}
