//
//  AISSatelliteMessage.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/18/26.
//
//  Type 27: AIS Satellite Message
//  Payload Character: J
//
//  Short message that occupies less than a full slot, intended to be compact for long range reception.

struct AISSatelliteMessage: AISMessage {
    let nmeaSentence: AISNMEA0183Sentence
    let messageType: AISMessageType
    let mmsiNumber: MMSI
    
    let positionAccuracy: PositionAccuracy
    let raimFlag: RAIMFlag
    let navigationStatus: NavigationStatus
    let longitude: Longitude
    let latitude: Latitude
    let speedOverGround: SpeedOverGroundCompact
    let courseOverGround: CourseOverGroundCompact
    let positionLatency: PositionLatency
    let spare: UInt8?
    
    init?(nmea: AISNMEA0183Sentence) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits
        
        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageTypeBits)) else { return nil }
        guard messageType.rawValue == 27 else { return nil }
        self.messageType = messageType
        
        guard let mmsiBits: UInt32 = bits[8...37] else { return nil }
        guard let mmsi = MMSI(value: mmsiBits) else { return nil }
        self.mmsiNumber = mmsi
        
        guard let positionAccuracyBit: UInt8 = bits[38...38] else { return nil }
        guard let positionAccuracy = PositionAccuracy(rawValue: positionAccuracyBit) else { return nil }
        self.positionAccuracy = positionAccuracy
        
        guard let raimFlagBit: UInt8 = bits[39...39] else { return nil }
        guard let raimFlag = RAIMFlag(rawValue: raimFlagBit) else { return nil }
        self.raimFlag = raimFlag
        
        guard let navigationStatusBits: UInt8 = bits[40...43] else { return nil }
        guard let navigationStatus = NavigationStatus(rawValue: navigationStatusBits) else { return nil }
        self.navigationStatus = navigationStatus
        
        guard let longitudeBits: UInt32 = bits[44...61] else { return nil }
        let longitude = Longitude(rawValue: longitudeBits, isTenths: true)
        self.longitude = longitude
        
        guard let latitudeBits: UInt32 = bits[62...78] else { return nil }
        let latitude = Latitude(rawValue: latitudeBits, isTenths: true)
        self.latitude = latitude
        
        guard let speedOverGroundBits: UInt8 = bits[79...84] else { return nil }
        guard let speedOverGround = SpeedOverGroundCompact(rawValue: speedOverGroundBits) else { return nil }
        self.speedOverGround = speedOverGround
        
        guard let courseOverGroundBits: UInt16 = bits[85...93] else { return nil }
        guard let courseOverGround = CourseOverGroundCompact(rawValue: courseOverGroundBits) else { return nil }
        self.courseOverGround = courseOverGround
        
        guard let positionLatencyBit: UInt8 = bits[94...94] else { return nil }
        guard let positionLatency = PositionLatency(rawValue: positionLatencyBit) else { return nil }
        self.positionLatency = positionLatency
        
        if let spareBit: UInt8 = bits[95...95] {
            self.spare = spareBit
        } else {
            self.spare = nil
        }
    }
    
    func description() -> String {
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
