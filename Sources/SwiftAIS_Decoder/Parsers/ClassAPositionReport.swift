//
//  ClassAPositionReport.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/14/26.
//

public struct ClassAPositionReport: AISMessage {
    public let nmeaSentence: AISNMEA0183Sentence
    public let messageType: AISMessageType
    public let mmsiNumber: MMSI
    
    public let navStatus: NavigationStatus
    public let rateOfTurn: RateOfTurn
    public let speedOverGround: SpeedOverGround
    public let positionAccuracy: PositionAccuracy
    public let longitude: Longitude
    public let latitude: Latitude
    public let courseOverGround: CourseOverGround
    public let trueHeading: TrueHeading
    public let timestamp: TimeStamp
    public let maneuverIndicator: ManeuverIndicator
    public let spare: SpareData
    public let raimFlag: RAIMFlag
    public let radioStatus: RadioStatus
    
    public init(nmea: AISNMEA0183Sentence) throws(AISDecodingError) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits

        let messageType: AISMessageType = try bits.read(0...5, "messageType")
        guard [1,2,3].contains(messageType.rawValue) else {
            throw .unexpectedMessageType(messageType.rawValue, expected: [1,2,3])
        }
        self.messageType = messageType

        let mmsiBits: UInt32 = try bits.read(8...37, "mmsiNumber")
        guard let mmsi = MMSI(value: mmsiBits) else { throw .invalidValue(field: "mmsiNumber", rawValue: UInt64(mmsiBits)) }
        self.mmsiNumber = mmsi

        self.navStatus = try bits.read(38...41, "navStatus")
        self.rateOfTurn = RateOfTurn(value: Int8(bitPattern: try bits.read(42...49, "rateOfTurn"))) // 8-bit signed field (I3)

        let sogBits: UInt16 = try bits.read(50...59, "speedOverGround")
        guard let speedOverGround = SpeedOverGround(rawValue: sogBits) else { throw .invalidValue(field: "speedOverGround", rawValue: UInt64(sogBits)) }
        self.speedOverGround = speedOverGround

        self.positionAccuracy = try bits.read(60...60, "positionAccuracy")
        self.longitude = Longitude(rawValue: try bits.read(61...88, "longitude")) // 28-bit signed, sign-extended in init
        self.latitude = Latitude(rawValue: try bits.read(89...115, "latitude")) // 27-bit signed, sign-extended in init

        let courseBits: UInt16 = try bits.read(116...127, "courseOverGround")
        guard let courseOverGround = CourseOverGround(rawValue: courseBits) else { throw .invalidValue(field: "courseOverGround", rawValue: UInt64(courseBits)) }
        self.courseOverGround = courseOverGround

        self.trueHeading = TrueHeading(rawValue: try bits.read(128...136, "trueHeading"))
        self.timestamp = TimeStamp(rawValue: try bits.read(137...142, "timestamp"))
        self.maneuverIndicator = try bits.read(143...144, "maneuverIndicator")
        self.spare = SpareData(rawValue: try bits.read(145...147, "spare"))
        self.raimFlag = try bits.read(148...148, "raimFlag")

        let radioBits: UInt32 = try bits.read(149...167, "radioStatus")
        if(self.messageType.rawValue == 3) {
            self.radioStatus = RadioStatus(rawValue: radioBits, statusType: .itdma)
        } else {
            self.radioStatus = RadioStatus(rawValue: radioBits, statusType: .sotdma)
        }
    }
    
    
    
    public func description() -> String {
        return ([
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Navigation Status:", navStatus.description),
            row("Rate of Turn:", rateOfTurn.description),
            row("Speed Over Ground:", speedOverGround.description),
            row("Position Accuracy:", positionAccuracy.description),
            row("Latitude:", latitude.description),
            row("Longitude:", longitude.description),
            row("Course Over Ground:", courseOverGround.description),
            row("True Heading:", trueHeading.description),
            row("Timestamp:", timestamp.description),
            row("Maneuver:", maneuverIndicator.description),
            row("RAIM:", raimFlag.description),
            row("Radio Status:", radioStatus.description)
        ] as [String]).joined(separator: "\n")
    }
    
}
