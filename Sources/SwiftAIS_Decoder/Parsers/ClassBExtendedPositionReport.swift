//
//  ClassBExtendedPositionReport.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/2/26.
//
//  Type 19: Extended Class B Positon Report
//  Payload Character: C

import SignalTools

class ClassBExtendedPositionReport: AISMessage {
    let nmeaSentence: AISNMEA0183Sentence
    let messageType: AISMessageType
    let mmsiNumber: MMSI
    
    let regionalReserved1: UInt8 // As with non-extended (type 18), not sure what this is used for
    let speedOverGround: SpeedOverGround
    let positionAccuracy: PositionAccuracy
    let longitude: Longitude
    let latitude: Latitude
    let courseOverGround: CourseOverGround
    let trueHeading: TrueHeading
    let timeStamp: TimeStamp
    let regionalReserved2: UInt8
    let name: AISText
    let shipType: ShipType
    let dimensionToBow: UInt16
    let dimensionToStern: UInt16
    let dimensionToPort: UInt8
    let dimensionToStarboard: UInt8
    let fixType: EPFDFixType
    let raimFlag: RAIMFlag
    let dte: DTE
    let assignedFlag: AssignedFlag
    let spare: UInt8
    
    init?(nmea: AISNMEA0183Sentence) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits
        
        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageTypeBits)) else { return nil }
        guard messageType.rawValue == 19 else { return nil }
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
        self.positionAccuracy = positionAccuracy
        
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
        self.trueHeading = trueHeading
        
        guard let timeStampBits: UInt8 = bits[133...138] else { return nil }
        let timeStamp = TimeStamp(rawValue: timeStampBits)
        self.timeStamp = timeStamp
        
        guard let regionalReserved2Bits: UInt8 = bits[139...142] else { return nil }
        self.regionalReserved2 = regionalReserved2Bits
        
        guard let nameBits: BitBuffer = bits[143...262] else { return nil }
        guard let name = AISText(raw: nameBits) else { return nil }
        self.name = name
        
        guard let shipTypeBits: UInt8 = bits[263...270] else { return nil }
        guard let typeOfShip = ShipType(rawValue: shipTypeBits) else { return nil }
        self.shipType = typeOfShip
        
        guard let dimensionToBowBits: UInt16 = bits[271...279] else { return nil }
        self.dimensionToBow = dimensionToBowBits
        
        guard let dimensionToSternBits: UInt16 = bits[280...288] else { return nil }
        self.dimensionToStern = dimensionToSternBits
        
        guard let dimensionToPortBits: UInt8 = bits[289...294] else { return nil }
        self.dimensionToPort = dimensionToPortBits
        
        guard let dimensionToStarboard: UInt8 = bits[295...300] else { return nil }
        self.dimensionToStarboard = dimensionToStarboard
        
        guard let fixTypeBits: UInt8 = bits[301...304] else { return nil }
        guard let fixType = EPFDFixType(rawValue: fixTypeBits) else { return nil }
        self.fixType = fixType
        
        guard let raimFlagBit: UInt8 = bits[305...305] else { return nil }
        guard let raimFlag = RAIMFlag(rawValue: raimFlagBit) else { return nil }
        self.raimFlag = raimFlag
        
        guard let dteBit: UInt8 = bits[306...306] else { return nil }
        let dte = DTE(rawValue: dteBit == 1)
        self.dte = dte
        
        guard let assignedFlagBit: UInt8 = bits[307...307] else { return nil }
        let assignedFlag = AssignedFlag(rawValue: assignedFlagBit == 1)
        self.assignedFlag = assignedFlag
        
        guard let spareBits: UInt8 = bits[308...311] else { return nil }
        self.spare = spareBits
    }
    
    func description() -> String {
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
