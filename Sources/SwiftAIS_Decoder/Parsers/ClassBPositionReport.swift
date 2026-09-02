//
//  ClassBPositionReport.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/2/26.
//
//  Type 18: Standard Class B Position Report
//  Payload character: "B"

class ClassBPositionReport: AISMessage {
    let nmeaSentence: AISNMEA0183Sentence
    let messageType: AISMessageType
    let mmsiNumber: MMSI
    
    let regionalReserved1: UInt8 // I'm not sure what this field is actually used for but it's here
    let speedOverGround: SpeedOverGround
    let positonAccuracy: PositionAccuracy
    let longitude: Longitude
    let latitude: Latitude
    let courseOverGround: CourseOverGround
    let heading: TrueHeading
    let timestamp: TimeStamp
    let regionalReserved2: UInt8
    let csUnit: CSUnit
    let visualDisplay: VisualDisplay
    let dscFlag: DSCFlag
    let bandFlag: BandFlag
    let type22Flag: Type22Flag
    let assignedFlag: AssignedFlag
    let raimFlag: RAIMFlag
    let radioStatus: RadioStatus
    
    init?(nmea: AISNMEA0183Sentence) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits
        
        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageTypeBits)) else { return nil }
        guard messageType.rawValue == 18 else { return nil }
        self.messageType = messageType
        
        guard let mmsiBits: UInt32 = bits[8...37] else { return nil }
        guard let mmsi = MMSI(value: mmsiBits) else { return nil }
        self.mmsiNumber = mmsi
        
        guard let regionalReserved1Bits: UInt8 = bits[38...45] else { return nil }
        self.regionalReserved1 = regionalReserved1Bits
        
        guard let speedOverGroundBits: UInt16 = bits[46...55] else { return nil }
        guard let speedOverGround = SpeedOverGround(rawValue: speedOverGroundBits) else { return nil }
        self.speedOverGround = speedOverGround
        
        guard let positionAccuracyBit: UInt8 = bits[56...56] else { return nil }
        guard let positionAccuracy = PositionAccuracy(rawValue: positionAccuracyBit) else { return nil }
        self.positonAccuracy = positionAccuracy
        
        guard let longitudeBits: UInt32 = bits[57...84] else { return nil }
        let longitude = Longitude(rawValue: longitudeBits)
        self.longitude = longitude
        
        guard let latitudeBits: UInt32 = bits[85...111] else { return nil }
        let latitude = Latitude(rawValue: latitudeBits)
        self.latitude = latitude
        
        guard let courseOverGroundBits: UInt16 = bits[112...123] else { return nil }
        let courseOverGround = CourseOverGround(rawValue: courseOverGroundBits)
        self.courseOverGround = courseOverGround
        
        guard let trueHeadingBits: UInt16 = bits[124...132] else { return nil }
        let trueHeading = TrueHeading(rawValue: trueHeadingBits)
        self.heading = trueHeading
        
        guard let timeStampBits: UInt8 = bits[133...138] else { return nil }
        let timeStamp = TimeStamp(rawValue: timeStampBits)
        self.timestamp = timeStamp
        
        guard let regionalReserved2Bits: UInt8 = bits[139...140] else { return nil }
        self.regionalReserved2 = regionalReserved2Bits
        
        guard let csUnitBit: UInt8 = bits[141...141] else { return nil }
        guard let csUnit = CSUnit(rawValue: csUnitBit) else { return nil }
        self.csUnit = csUnit
        
        guard let displayBit: UInt8 = bits[142...142] else { return nil }
        let visualDisplay = VisualDisplay(rawValue: displayBit == 1)
        self.visualDisplay = visualDisplay
        
        guard let dscBit: UInt8 = bits[143...143] else { return nil }
        let dscFlag = DSCFlag(rawValue: dscBit == 1)
        self.dscFlag = dscFlag
        
        guard let bandBit: UInt8 = bits[144...144] else { return nil }
        let bandFlag = BandFlag(rawValue: bandBit == 1)
        self.bandFlag = bandFlag
        
        guard let message22Bit: UInt8 = bits[145...145] else { return nil }
        let type22Flag = Type22Flag(rawValue: message22Bit == 1)
        self.type22Flag = type22Flag
        
        guard let assignedBit: UInt8 = bits[146...146] else { return nil }
        let assignedFlag = AssignedFlag(rawValue: assignedBit == 1)
        self.assignedFlag = assignedFlag
        
        guard let raimBit: UInt8 = bits[147...147] else { return nil }
        guard let raimFlag = RAIMFlag(rawValue: raimBit) else { return nil }
        self.raimFlag = raimFlag
        
        // For now, the radio status might not be right. There is a bit here being skipped that determines whether it's SOTDMA or ITDMA state.
        // My decoder currently only handles SOTDMA
        guard let radioStatusTypeBit: UInt8 = bits[148...148] else { return nil }
        guard let radioStatusType = RadioStatusType(rawValue: radioStatusTypeBit) else { return nil }
        guard let radioStatusBits: UInt32 = bits[149...167] else { return nil }
        let radioStatus = RadioStatus(rawValue: radioStatusBits, statusType: radioStatusType)
        self.radioStatus = radioStatus
    }
    
    func description() -> String {
        return ([
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Speed Over Ground:", speedOverGround.description),
            row("Position Accuracy:", positonAccuracy.description),
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
