//
//  ClassBPositionReport.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/2/26.
//
//  Type 18: Standard Class B Position Report
//  Payload character: "B"

public struct ClassBPositionReport: AISMessage {
    public let nmeaSentence: AISNMEA0183Sentence
    public let messageType: AISMessageType
    public let mmsiNumber: MMSI
    
    public let regionalReserved1: UInt8 // I'm not sure what this field is actually used for but it's here
    public let speedOverGround: SpeedOverGround
    public let positionAccuracy: PositionAccuracy
    public let longitude: Longitude
    public let latitude: Latitude
    public let courseOverGround: CourseOverGround
    public let heading: TrueHeading
    public let timestamp: TimeStamp
    public let regionalReserved2: UInt8
    public let csUnit: CSUnit
    public let visualDisplay: VisualDisplay
    public let dscFlag: DSCFlag
    public let bandFlag: BandFlag
    public let type22Flag: Type22Flag
    public let assignedFlag: AssignedFlag
    public let raimFlag: RAIMFlag
    public let radioStatus: RadioStatus
    
    public init(nmea: AISNMEA0183Sentence) throws(AISDecodingError) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits

        let messageType: AISMessageType = try bits.read(0...5, "messageType")
        guard messageType.rawValue == 18 else { throw .unexpectedMessageType(messageType.rawValue, expected: [18]) }
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

        self.heading = TrueHeading(rawValue: try bits.read(124...132, "heading"))
        self.timestamp = TimeStamp(rawValue: try bits.read(133...138, "timestamp"))
        self.regionalReserved2 = try bits.read(139...140, "regionalReserved2")
        self.csUnit = try bits.read(141...141, "csUnit")
        self.visualDisplay = VisualDisplay(rawValue: try bits.read(142, "visualDisplay"))
        self.dscFlag = DSCFlag(rawValue: try bits.read(143, "dscFlag"))
        self.bandFlag = BandFlag(rawValue: try bits.read(144, "bandFlag"))
        self.type22Flag = Type22Flag(rawValue: try bits.read(145, "type22Flag"))
        self.assignedFlag = AssignedFlag(rawValue: try bits.read(146, "assignedFlag"))
        self.raimFlag = try bits.read(147...147, "raimFlag")

        // Bit 148 selects whether the radio status is SOTDMA or ITDMA. Only SOTDMA fields are decoded; ITDMA statuses are kept raw.
        let radioStatusType: RadioStatusType = try bits.read(148...148, "radioStatusType")
        self.radioStatus = RadioStatus(rawValue: try bits.read(149...167, "radioStatus"), statusType: radioStatusType)
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
            row("True Heading:", heading.description),
            row("Timestamp:", timestamp.description),
            row("CS Unit:", csUnit.description),
            row("Visual Display:", visualDisplay.description),
            row("DSC:", dscFlag.description),
            row("Band:", bandFlag.description),
            row("Message 22:", type22Flag.description),
            row("Assigned:", assignedFlag.description),
            row("RAIM:", raimFlag.description),
            row("Radio Status:", radioStatus.description)
        ] as [String]).joined(separator: "\n")
    }
    
    
}
