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
    
    
    init?(nmea: AISNMEA0183Sentence) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits
        
        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageTypeBits)) else { return nil }
        guard messageType.rawValue == 4 else { return nil }
        self.messageType = messageType
        
        guard let mmsiBits: UInt32 = bits[8...37] else { return nil }
        guard let mmsi = MMSI(value: mmsiBits) else { return nil }
        self.mmsiNumber = mmsi

        guard let yearBits: UInt16 = bits[38...51] else { return nil }
        self.year = UTCYear(rawValue: yearBits)

        guard let monthBits: UInt8 = bits[52...55] else { return nil }
        self.month = UTCMonth(rawValue: monthBits)

        guard let dayBits: UInt8 = bits[56...60] else { return nil }
        self.day = UTCDay(rawValue: dayBits)

        guard let hourBits: UInt8 = bits[61...65] else { return nil }
        self.hour = UTCHour(rawValue: hourBits)

        guard let minuteBits: UInt8 = bits[66...71] else { return nil }
        self.minute = UTCMinute(rawValue: minuteBits)

        guard let secondBits: UInt8 = bits[72...77] else { return nil }
        self.second = TimeStamp(rawValue: secondBits)

        guard let positionAccuracyBits: UInt8 = bits[78...78] else { return nil }
        guard let positionAccuracy = PositionAccuracy(rawValue: positionAccuracyBits) else { return nil }
        self.positionAccuracy = positionAccuracy

        guard let longitudeBits: UInt32 = bits[79...106] else { return nil }
        self.longitude = Longitude(rawValue: longitudeBits)

        guard let latitudeBits: UInt32 = bits[107...133] else { return nil }
        self.latitude = Latitude(rawValue: latitudeBits)

        guard let fixTypeBits: UInt8 = bits[134...137] else { return nil }
        guard let fixType = EPFDFixType(rawValue: fixTypeBits) else { return nil }
        self.fixType = fixType

        guard let spareBits: UInt64 = bits[138...147] else { return nil }
        self.spareBits = spareBits

        guard let raimBits: UInt8 = bits[148...148] else { return nil }
        guard let raimFlag = RAIMFlag(rawValue: raimBits) else { return nil }
        self.raimFlag = raimFlag

        guard let radioStatusBits: UInt32 = bits[149...167] else { return nil }
        self.radioStatus = RadioStatus(rawValue: radioStatusBits)
    }
    
    func description() -> String {
        return ([
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
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
