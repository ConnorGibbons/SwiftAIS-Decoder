//
//  StaticAndVoyageData.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/23/26.
//
//  Type 5

import SignalTools

class StaticAndVoyageData: AISMessage {
    let nmeaSentence: AISNMEA0183Sentence
    let messageType: AISMessageType
    let mmsiNumber: MMSI
    
    let nmeaSentence2: AISNMEA0183Sentence
    let aisVersion: AISVersion
    let imoNumber: UInt32
    let callSign: AISText
    let vesselName: AISText
    let shipType: ShipType
    let dimensionToBow: UInt16
    let dimensionToStern: UInt16
    let dimensionToPort: UInt8
    let dimensionToStarboard: UInt8
    let fixType: EPFDFixType
    let month: UTCMonth
    let day: UTCDay
    let hour: UTCHour
    let minute: UTCMinute
    let draught: Double
    let destination: AISText
    let dte: DTE?
    let spare: Bool? // Just 1 bit
    
    init?(nmea1: AISNMEA0183Sentence, nmea2: AISNMEA0183Sentence) {
        self.nmeaSentence = nmea1
        self.nmeaSentence2 = nmea2
        
        var bits = nmea1.payloadBits
        bits.append(contentsOf: nmea2.payloadBits)
        
        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageTypeBits)) else { return nil }
        guard messageType.rawValue == 5 else { return nil }
        self.messageType = messageType

        guard let mmsiBits: UInt32 = bits[8...37] else { return nil }
        guard let mmsi = MMSI(value: mmsiBits) else { return nil }
        self.mmsiNumber = mmsi
        
        guard let aisVersionBits: UInt8 = bits[38...39] else { return nil }
        guard let aisVersion = AISVersion(rawValue: aisVersionBits) else { return nil }
        self.aisVersion = aisVersion
        
        guard let imoNumberBits: UInt32 = bits[40...69] else { return nil }
        self.imoNumber = imoNumberBits
        
        guard let callSignBits: BitBuffer = bits[70...111] else { return nil }
        guard let callSign = AISText(raw: callSignBits) else { return nil }
        self.callSign = callSign
        
        guard let vesselNameBits: BitBuffer = bits[112...231] else { return nil }
        guard let vesselName = AISText(raw: vesselNameBits) else { return nil }
        self.vesselName = vesselName
        
        guard let shipTypeBits: UInt8 = bits[232...239] else { return nil }
        guard let shipType = ShipType(rawValue: shipTypeBits) else { return nil }
        self.shipType = shipType
        
        guard let dimensionToBow: UInt16 = bits[240...248] else { return nil }
        self.dimensionToBow = dimensionToBow
        
        guard let dimensionToStern: UInt16 = bits[249...257] else { return nil }
        self.dimensionToStern = dimensionToStern
        
        guard let dimensionToPort: UInt8 = bits[258...263] else { return nil }
        self.dimensionToPort = dimensionToPort
        
        guard let dimensionToStarboard: UInt8 = bits[264...269] else { return nil }
        self.dimensionToStarboard = dimensionToStarboard
        
        guard let fixTypeBits: UInt8 = bits[270...273] else { return nil }
        guard let fixType = EPFDFixType(rawValue: fixTypeBits) else { return nil }
        self.fixType = fixType
        
        guard let monthBits: UInt8 = bits[274...277] else { return nil }
        self.month = UTCMonth(rawValue: monthBits)
        
        guard let dayBits: UInt8 = bits[278...282] else { return nil }
        self.day = UTCDay(rawValue: dayBits)
        
        guard let hourBits: UInt8 = bits[283...287] else { return nil }
        self.hour = UTCHour(rawValue: hourBits)
        
        guard let minuteBits: UInt8 = bits[288...293] else { return nil }
        self.minute = UTCMinute(rawValue: minuteBits)
        
        guard let draughtBits: UInt8 = bits[294...301] else { return nil }
        self.draught = Double(UInt16(draughtBits)) / 10
        
        guard let destinationBits: BitBuffer = bits[302...421] else { return nil }
        guard let destination = AISText(raw: destinationBits) else { return nil }
        self.destination = destination
        
        if(bits.count > 422) {
            let DTEBit = bits[422]
            self.dte = DTE(rawValue: DTEBit == 0)
            if(bits.count > 423) {
                let spareBit = bits[423]
                self.spare = spareBit != 0
            }
            else {
                self.spare = nil
            }
        }
        else {
            self.dte = nil
            self.spare = nil
        }
    }
    
    func description() -> String {
        return ([
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("AIS Version:", "\(aisVersion)"),
            row("IMO Number:", "\(imoNumber)"),
            row("Call Sign:", callSign.text),
            row("Vessel Name:", vesselName.text),
            row("Ship Type:", shipType.description),
            row("Dimensions (m):", "Bow \(dimensionToBow), Stern \(dimensionToStern), Port \(dimensionToPort), Starboard \(dimensionToStarboard)"),
            row("EPFD Fix Type:", fixType.description),
            row("ETA (UTC):", "\(month.description)-\(day.description) \(hour.description):\(minute.description)"),
            row("Draught (m):", "\(draught)"),
            row("Destination:", destination.text),
            row("DTE:", dte?.description ?? "Unavailable")
        ] as [String]).joined(separator: "\n")
    }
    
    
}

