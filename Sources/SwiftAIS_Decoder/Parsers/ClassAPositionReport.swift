//
//  ClassAPositionReport.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/14/26.
//

class ClassA_PositionReport: AISMessage {
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
        
        guard let messageType = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageType)) else { return nil }
        guard [1,2,3].contains(messageType.rawValue) else { return nil }
        self.messageType = messageType
        
        guard let mmsiBits = bits[8...37] else { return nil }
        guard let mmsi = MMSI(value: UInt32(mmsiBits)) else { return nil }
        self.mmsiNumber = mmsi
        
        guard let navStatusBits = bits[38...41] else { return nil }
        guard let navStatus = NavigationStatus(rawValue: UInt8(navStatusBits)) else { return nil }
        self.navStatus = navStatus

        guard let rotBits = bits[42...49] else { return nil }
        self.rateOfTurn = RateOfTurn(value: Int8(bitPattern: UInt8(rotBits))) // 8-bit signed field (I3)

        guard let sogBits = bits[50...59] else { return nil }
        guard let speedOverGround = SpeedOverGround(rawValue: UInt16(sogBits)) else { return nil }
        self.speedOverGround = speedOverGround

        guard let accuracyBits = bits[60...60] else { return nil }
        guard let positionAccuracy = PositionAccuracy(rawValue: UInt8(accuracyBits)) else { return nil }
        self.positionAccuracy = positionAccuracy

        guard let lonBits = bits[61...88] else { return nil }
        self.longitude = Longitude(rawValue: UInt32(lonBits)) // 28-bit signed, sign-extended in init

        guard let latBits = bits[89...115] else { return nil }
        self.latitude = Latitude(rawValue: UInt32(latBits)) // 27-bit signed, sign-extended in init

        guard let courseBits = bits[116...127] else { return nil }
        self.courseOverGround = CourseOverGround(rawValue: UInt16(courseBits))

        guard let headingBits = bits[128...136] else { return nil }
        self.trueHeading = TrueHeading(rawValue: UInt16(headingBits))

        guard let secondBits = bits[137...142] else { return nil }
        self.timestamp = TimeStamp(rawValue: UInt8(secondBits))

        guard let maneuverBits = bits[143...144] else { return nil }
        guard let maneuverIndicator = ManeuverIndicator(rawValue: UInt8(maneuverBits)) else { return nil }
        self.maneuverIndicator = maneuverIndicator

        guard let spareBits = bits[145...147] else { return nil }
        self.spare = SpareData(rawValue: spareBits)

        guard let raimBits = bits[148...148] else { return nil }
        guard let raimFlag = RAIMFlag(rawValue: UInt8(raimBits)) else { return nil }
        self.raimFlag = raimFlag

        guard let radioBits = bits[149...167] else { return nil }
        self.radioStatus = RadioStatus(rawValue: UInt32(radioBits))
    }
    
    
    
    func description() -> String {
        func row(_ label: String, _ value: String) -> String {
            let pad = String(repeating: " ", count: max(1, 20 - label.count))
            return "  \(label)\(pad)\(value)"
        }

        return ([
            "\(messageType.description) (Type \(messageType.rawValue))",
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
