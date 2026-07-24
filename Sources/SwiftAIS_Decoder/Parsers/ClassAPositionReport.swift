//
//  ClassAPositionReport.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/14/26.
//

class ClassAPositionReport: AISMessage {
    let nmeaSentence: AISNMEA0183Sentence
    let messageType: AISMessageType
    let mmsiNumber: MMSI
    
    let navStatus: NavigationStatus
    let rateOfTurn: RateOfTurn
    let speedOverGround: SpeedOverGround
    let positionAccuracy: PositionAccuracy
    let longitude: Longitude
    let latitude: Latitude
    let courseOverGround: CourseOverGround
    let trueHeading: TrueHeading
    let timestamp: TimeStamp
    let maneuverIndicator: ManeuverIndicator
    let spare: SpareData
    let raimFlag: RAIMFlag
    let radioStatus: RadioStatus
    
    init?(nmea: AISNMEA0183Sentence) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits
        
        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageTypeBits)) else { return nil }
        guard [1,2,3].contains(messageType.rawValue) else { return nil }
        self.messageType = messageType

        guard let mmsiBits: UInt32 = bits[8...37] else { return nil }
        guard let mmsi = MMSI(value: mmsiBits) else { return nil }
        self.mmsiNumber = mmsi

        guard let navStatusBits: UInt8 = bits[38...41] else { return nil }
        guard let navStatus = NavigationStatus(rawValue: navStatusBits) else { return nil }
        self.navStatus = navStatus

        guard let rotBits: UInt8 = bits[42...49] else { return nil }
        self.rateOfTurn = RateOfTurn(value: Int8(bitPattern: rotBits)) // 8-bit signed field (I3)

        guard let sogBits: UInt16 = bits[50...59] else { return nil }
        guard let speedOverGround = SpeedOverGround(rawValue: sogBits) else { return nil }
        self.speedOverGround = speedOverGround

        guard let accuracyBits: UInt8 = bits[60...60] else { return nil }
        guard let positionAccuracy = PositionAccuracy(rawValue: accuracyBits) else { return nil }
        self.positionAccuracy = positionAccuracy

        guard let lonBits: UInt32 = bits[61...88] else { return nil }
        self.longitude = Longitude(rawValue: lonBits) // 28-bit signed, sign-extended in init

        guard let latBits: UInt32 = bits[89...115] else { return nil }
        self.latitude = Latitude(rawValue: latBits) // 27-bit signed, sign-extended in init

        guard let courseBits: UInt16 = bits[116...127] else { return nil }
        self.courseOverGround = CourseOverGround(rawValue: courseBits)

        guard let headingBits: UInt16 = bits[128...136] else { return nil }
        self.trueHeading = TrueHeading(rawValue: headingBits)

        guard let secondBits: UInt8 = bits[137...142] else { return nil }
        self.timestamp = TimeStamp(rawValue: secondBits)

        guard let maneuverBits: UInt8 = bits[143...144] else { return nil }
        guard let maneuverIndicator = ManeuverIndicator(rawValue: maneuverBits) else { return nil }
        self.maneuverIndicator = maneuverIndicator

        guard let spareBits: UInt64 = bits[145...147] else { return nil }
        self.spare = SpareData(rawValue: spareBits)

        guard let raimBits: UInt8 = bits[148...148] else { return nil }
        guard let raimFlag = RAIMFlag(rawValue: raimBits) else { return nil }
        self.raimFlag = raimFlag

        guard let radioBits: UInt32 = bits[149...167] else { return nil }
        self.radioStatus = RadioStatus(rawValue: radioBits)
    }
    
    
    
    func description() -> String {
        return ([
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", mmsiNumber.description),
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
