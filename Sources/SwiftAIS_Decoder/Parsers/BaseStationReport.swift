//
//  BaseStationReport.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/14/26.
//

class BaseStationReport: AISMessage {
    let nmeaSentence: AISNMEA0183Sentence
    let messageType: AISMessageType
    let mmsiNumber: MMSI
    
    let year: UTCYear
    let month: UTCMonth
    let day: UTCDay
    let hour: UTCHour
    let minute: UTCMinute
    let second: TimeStamp
    let positionAccuracy: PositionAccuracy
    let longitude: Longitude
    let latitude: Latitude
    let fixType: EPFDFixType
    let spareBits: UInt64
    let raimFlag: RAIMFlag
    let radioStatus: RadioStatus
    
    
    init?(nmeaSentence: AISNMEA0183Sentence) {
        self.nmeaSentence = nmeaSentence
        let bits = nmeaSentence.payloadBits
        
        guard let messageTypeBits = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageTypeBits)) else { return nil }
        guard messageType.rawValue == 4 else { return nil }
        self.messageType = messageType
        
        guard let mmsiBits = bits[8...37] else { return nil }
        guard let mmsi = MMSI(value: UInt32(mmsiBits)) else { return nil }
        self.mmsiNumber = mmsi
        
        guard let yearBits = bits[38...51] else { return nil }
        self.year = UTCYear(rawValue: UInt16(yearBits))
        
        guard let monthBits = bits[52...55] else { return nil }
        self.month = UTCMonth(rawValue: UInt8(monthBits))
        
        guard let dayBits = bits[56...60] else { return nil }
        self.day = UTCDay(rawValue: UInt8(dayBits))
        
        guard let hourBits = bits[61...65] else { return nil }
        self.hour = UTCHour(rawValue: UInt8(hourBits))
        
        guard let minuteBits = bits[66...71] else { return nil }
        self.minute = UTCMinute(rawValue: UInt8(minuteBits))
        
        guard let secondBits = bits[72...77] else { return nil }
        self.second = TimeStamp(rawValue: UInt8(secondBits))
        
        guard let positionAccuracyBits = bits[78...78] else { return nil }
        guard let positionAccuracy = PositionAccuracy(rawValue: UInt8(positionAccuracyBits)) else { return nil }
        self.positionAccuracy = positionAccuracy
        
        guard let longitudeBits = bits[79...106] else { return nil }
        self.longitude = Longitude(rawValue: UInt32(longitudeBits))
        
        guard let latitudeBits = bits[107...133] else { return nil }
        self.latitude = Latitude(rawValue: UInt32(latitudeBits))
        
        guard let fixTypeBits = bits[134...137] else { return nil }
        guard let fixType = EPFDFixType(rawValue: UInt8(fixTypeBits)) else { return nil }
        self.fixType = fixType
        
        guard let spareBits = bits[138...147] else { return nil }
        self.spareBits = spareBits
        
        guard let raimBits = bits[148...148] else { return nil }
        guard let raimFlag = RAIMFlag(rawValue: UInt8(raimBits)) else { return nil }
        self.raimFlag = raimFlag
        
        guard let radioStatusBits = bits[149...167] else { return nil }
        self.radioStatus = RadioStatus(rawValue: UInt32(radioStatusBits))
    }
    
    func description() -> String {
        func row(_ label: String, _ value: String) -> String {
            let pad = String(repeating: " ", count: max(1, 20 - label.count))
            return "  \(label)\(pad)\(value)"
        }

        return ([
            "\(messageType.description) (Type \(messageType.rawValue))",
            row("MMSI:", mmsiNumber.description),
            row("Time (UTC):", dateStringFromUTCElements(year: self.year, month: self.month, day: self.day, hour: self.hour, minute: self.minute, second: self.second)),
            row("Latitude:", latitude.description),
            row("Longitude:", longitude.description),
            row("Position Accuracy:", positionAccuracy.description),
            row("EPFD Fix Type:", fixType.description),
            row("RAIM:", raimFlag.description),
            row("Radio Status:", radioStatus.description)
        ] as [String]).joined(separator: "\n")
    }
    
    
}
