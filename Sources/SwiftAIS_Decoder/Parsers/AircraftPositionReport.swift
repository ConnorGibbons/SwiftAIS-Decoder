//
//  AircraftPositionReport.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 8/6/26.
//
//  Type 9: Standard SAR Aircraft Position Report
//  SAR: "Search and Rescue"


public struct AircraftPositionReport: AISMessage {
    public let nmeaSentence: AISNMEA0183Sentence
    public let messageType: AISMessageType
    public let mmsiNumber: MMSI
    
    public let altitude: UInt16 // given in meters
    public let speedOverGround: UInt16
    public let positionAccuracy: PositionAccuracy
    public let longitude: Longitude
    public let latitude: Latitude
    public let courseOverGround: CourseOverGround
    public let timestamp: TimeStamp
    public let regionalReserved: UInt8 // No idea what this is used for
    public let dte: DTE
    public let spare: UInt8
    public let assigned: AssignedFlag
    public let raimFlag: RAIMFlag
    public let radioStatus: RadioStatus
    
    public init(nmea: AISNMEA0183Sentence) throws(AISDecodingError) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits

        let messageType: AISMessageType = try bits.read(0...5, "messageType")
        guard messageType.rawValue == 9 else { throw .unexpectedMessageType(messageType.rawValue, expected: [9]) }
        self.messageType = messageType

        let mmsiBits: UInt32 = try bits.read(8...37, "mmsiNumber")
        guard let mmsi = MMSI(value: mmsiBits) else { throw .invalidValue(field: "mmsiNumber", rawValue: UInt64(mmsiBits)) }
        self.mmsiNumber = mmsi

        self.altitude = try bits.read(38...49, "altitude")
        self.speedOverGround = try bits.read(50...59, "speedOverGround") // Unlike in position report, it's given in knots, so can use value directly
        self.positionAccuracy = try bits.read(60...60, "positionAccuracy")
        self.longitude = Longitude(rawValue: try bits.read(61...88, "longitude"))
        self.latitude = Latitude(rawValue: try bits.read(89...115, "latitude"))

        let cogBits: UInt16 = try bits.read(116...127, "courseOverGround")
        guard let courseOverGround = CourseOverGround(rawValue: cogBits) else { throw .invalidValue(field: "courseOverGround", rawValue: UInt64(cogBits)) }
        self.courseOverGround = courseOverGround

        self.timestamp = TimeStamp(rawValue: try bits.read(128...133, "timestamp"))
        self.regionalReserved = try bits.read(134...141, "regionalReserved")
        self.dte = DTE(rawValue: try bits.read(142, "dte"))
        self.spare = try bits.read(143...145, "spare")
        self.assigned = AssignedFlag(rawValue: try bits.read(146, "assigned"))
        self.raimFlag = try bits.read(147...147, "raimFlag")
        self.radioStatus = RadioStatus(rawValue: try bits.read(148...167, "radioStatus"))
    }
    
    
    public func description() -> String {
        return ([
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Altitude:", altitudeDescription),
            row("Speed Over Ground:", speedOverGroundDescription),
            row("Position Accuracy:", positionAccuracy.description),
            row("Latitude:", latitude.description),
            row("Longitude:", longitude.description),
            row("Course Over Ground:", courseOverGround.description),
            row("Timestamp:", timestamp.description),
            row("DTE:", dte.description),
            row("Assigned:", assigned.description),
            row("RAIM:", raimFlag.description),
            row("Radio Status:", radioStatus.description)
        ] as [String]).joined(separator: "\n")
    }

    // Altitude & SOG are stored as raw field values here, so their special-case encodings are spelled out at display time.
    private var altitudeDescription: String {
        switch altitude {
        case 4095: return "Not available (\(altitude))"
        case 4094: return "Over 4094 meters"
        default: return "\(altitude) meters"
        }
    }

    private var speedOverGroundDescription: String {
        switch speedOverGround {
        case 1023: return "Not available (\(speedOverGround))"
        case 1022: return "Over 1022 knots"
        default: return "\(speedOverGround) knots"
        }
    }
    
    
}
