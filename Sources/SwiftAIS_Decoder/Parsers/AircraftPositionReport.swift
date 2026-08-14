//
//  AircraftPositionReport.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 8/6/26.
//
//  Type 9: Standard SAR Aircraft Position Report
//  SAR: "Search and Rescue"


class AircraftPositionReport: AISMessage {
    let nmeaSentence: AISNMEA0183Sentence
    let messageType: AISMessageType
    let mmsiNumber: MMSI
    
    let altitude: UInt16 // given in meters
    let speedOverGround: UInt16
    let positionAccuracy: PositionAccuracy
    let longitude: Longitude
    let latitude: Latitude
    let courseOverGround: CourseOverGround
    let timestamp: TimeStamp
    let regionalReserved: UInt8 // No idea what this is used for
    let dte: DTE
    let spare: UInt8
    let assigned: Assigned
    let raimFlag: RAIMFlag
    let radioStatus: RadioStatus
    
    init?(nmea: AISNMEA0183Sentence) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits
        
        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageTypeBits)) else { return nil }
        guard messageType.rawValue == 9 else { return nil }
        self.messageType = messageType
        
        guard let mmsiBits: UInt32 = bits[8...37] else { return nil }
        guard let mmsi = MMSI(value: mmsiBits) else { return nil }
        self.mmsiNumber = mmsi
        
        guard let altitudeBits: UInt16 = bits[38...49] else { return nil }
        self.altitude = altitudeBits
        
        guard let sogBits: UInt16 = bits[50...59] else { return nil }
        self.speedOverGround = sogBits // Unlike in position report, it's given in knots, so can use value directly
        
        guard let accuracyBit: UInt8 = bits[60...60] else { return nil }
        guard let positionAccuracy = PositionAccuracy(rawValue: accuracyBit) else { return nil }
        self.positionAccuracy = positionAccuracy
        
        guard let longitudeBits: UInt32 = bits[61...88] else { return nil }
        self.longitude = Longitude(rawValue: longitudeBits)
        
        guard let latitudeBits: UInt32 = bits[89...115] else { return nil }
        self.latitude = Latitude(rawValue: latitudeBits)
        
        guard let cogBits: UInt16 = bits[116...127] else { return nil }
        self.courseOverGround = CourseOverGround(rawValue: cogBits)
        
        guard let timestampBits: UInt8 = bits[128...133] else { return nil }
        self.timestamp = TimeStamp(rawValue: timestampBits)
        
        guard let regionalReservedBits: UInt8 = bits[134...141] else { return nil }
        self.regionalReserved = regionalReservedBits
        
        guard let dteBit: UInt8 = bits[142...142] else { return nil }
        self.dte = DTE(rawValue: dteBit != 0)
        
        guard let spareBits: UInt8 = bits[143...145] else { return nil }
        self.spare = spareBits
        
        guard let assignedBit: UInt8 = bits[146...146] else { return nil }
        self.assigned = Assigned(rawValue: assignedBit != 0)
        
        guard let raimBit: UInt8 = bits[147...147] else { return nil }
        guard let raim = RAIMFlag(rawValue: raimBit) else { return nil }
        self.raimFlag = raim
        
        guard let radioStatusBits: UInt32 = bits[148...167] else { return nil }
        self.radioStatus = RadioStatus(rawValue: radioStatusBits)
    }
    
    
    func description() -> String {
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
