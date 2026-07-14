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
    let raimFlag: RaimFlag
    let radioStatus: RadioStatus
    
    init?(nmea: AISNMEA0183Sentence) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits
        
        guard let messageType = bits[0..<6] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageType)) else { return nil }
        guard [1,2,3].contains(messageType.rawValue) else { return nil }
        self.messageType = messageType
        
        guard let mmsiBits = bits[8..<38] else { return nil }
        guard let mmsi = MMSI(value: UInt32(mmsiBits)) else { return nil }
        self.mmsiNumber = mmsi
        
        guard let navStatusBits = bits[38..<42] else { return nil }
        guard let navStatus = NavigationStatus(rawValue: UInt8(navStatusBits)) else { return nil }
        self.navStatus = navStatus

        guard let rotBits = bits[42..<50] else { return nil }
        self.rateOfTurn = RateOfTurn(value: Int8(bitPattern: UInt8(rotBits))) // 8-bit signed field (I3)

        guard let sogBits = bits[50..<60] else { return nil }
        guard let speedOverGround = SpeedOverGround(rawValue: UInt16(sogBits)) else { return nil }
        self.speedOverGround = speedOverGround

        guard let accuracyBits = bits[60..<61] else { return nil }
        guard let positionAccuracy = PositionAccuracy(rawValue: UInt8(accuracyBits)) else { return nil }
        self.positionAccuracy = positionAccuracy

        guard let lonBits = bits[61..<89] else { return nil }
        self.longitude = Longitude(rawValue: UInt32(lonBits)) // 28-bit signed, sign-extended in init

        guard let latBits = bits[89..<116] else { return nil }
        self.latitude = Latitude(rawValue: UInt32(latBits)) // 27-bit signed, sign-extended in init

        guard let courseBits = bits[116..<128] else { return nil }
        self.courseOverGround = CourseOverGround(rawValue: UInt16(courseBits))

        guard let headingBits = bits[128..<137] else { return nil }
        self.trueHeading = TrueHeading(rawValue: UInt16(headingBits))

        guard let secondBits = bits[137..<143] else { return nil }
        self.timestamp = TimeStamp(rawValue: UInt8(secondBits))

        guard let maneuverBits = bits[143..<145] else { return nil }
        guard let maneuverIndicator = ManeuverIndicator(rawValue: UInt8(maneuverBits)) else { return nil }
        self.maneuverIndicator = maneuverIndicator

        guard let spareBits = bits[145..<148] else { return nil }
        self.spare = SpareData(rawValue: spareBits)

        guard let raimBits = bits[148..<149] else { return nil }
        guard let raimFlag = RaimFlag(rawValue: UInt8(raimBits)) else { return nil }
        self.raimFlag = raimFlag

        guard let radioBits = bits[149..<168] else { return nil }
        self.radioStatus = RadioStatus(rawValue: UInt32(radioBits))
    }
    
    
    
    func description() -> String {
        return "ClassA Position Report"
    }
    
    
}
