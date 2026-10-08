//
//  StaticAndVoyageData.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/23/26.
//
//  Type 5

import SignalTools

public struct StaticAndVoyageData: AISMessage {
    public let nmeaSentence: AISNMEA0183Sentence
    public let messageType: AISMessageType
    public let mmsiNumber: MMSI
    
    public let nmeaSentence2: AISNMEA0183Sentence
    public let aisVersion: AISVersion
    public let imoNumber: UInt32
    public let callSign: AISText
    public let vesselName: AISText
    public let shipType: ShipType
    public let dimensionToBow: UInt16
    public let dimensionToStern: UInt16
    public let dimensionToPort: UInt8
    public let dimensionToStarboard: UInt8
    public let fixType: EPFDFixType
    public let month: UTCMonth
    public let day: UTCDay
    public let hour: UTCHour
    public let minute: UTCMinute
    public let draught: Double
    public let destination: AISText
    public let dte: DTE?
    public let spare: Bool? // Just 1 bit
    
    public init(nmea1: AISNMEA0183Sentence, nmea2: AISNMEA0183Sentence) throws(AISDecodingError) {
        self.nmeaSentence = nmea1
        self.nmeaSentence2 = nmea2

        var bits = nmea1.payloadBits
        bits.append(contentsOf: nmea2.payloadBits)

        let messageType: AISMessageType = try bits.read(0...5, "messageType")
        guard messageType.rawValue == 5 else { throw .unexpectedMessageType(messageType.rawValue, expected: [5]) }
        self.messageType = messageType

        let mmsiBits: UInt32 = try bits.read(8...37, "mmsiNumber")
        guard let mmsi = MMSI(value: mmsiBits) else { throw .invalidValue(field: "mmsiNumber", rawValue: UInt64(mmsiBits)) }
        self.mmsiNumber = mmsi

        self.aisVersion = try bits.read(38...39, "aisVersion")
        self.imoNumber = try bits.read(40...69, "imoNumber")

        let callSignBits: BitBuffer = try bits.read(70...111, "callSign")
        guard let callSign = AISText(raw: callSignBits) else { throw .invalidText(field: "callSign") }
        self.callSign = callSign

        let vesselNameBits: BitBuffer = try bits.read(112...231, "vesselName")
        guard let vesselName = AISText(raw: vesselNameBits) else { throw .invalidText(field: "vesselName") }
        self.vesselName = vesselName

        self.shipType = try bits.read(232...239, "shipType")
        self.dimensionToBow = try bits.read(240...248, "dimensionToBow")
        self.dimensionToStern = try bits.read(249...257, "dimensionToStern")
        self.dimensionToPort = try bits.read(258...263, "dimensionToPort")
        self.dimensionToStarboard = try bits.read(264...269, "dimensionToStarboard")
        self.fixType = try bits.read(270...273, "fixType")
        self.month = UTCMonth(rawValue: try bits.read(274...277, "month"))
        self.day = UTCDay(rawValue: try bits.read(278...282, "day"))
        self.hour = UTCHour(rawValue: try bits.read(283...287, "hour"))
        self.minute = UTCMinute(rawValue: try bits.read(288...293, "minute"))

        let draughtBits: UInt8 = try bits.read(294...301, "draught")
        self.draught = Double(UInt16(draughtBits)) / 10

        let destinationBits: BitBuffer = try bits.read(302...421, "destination")
        guard let destination = AISText(raw: destinationBits) else { throw .invalidText(field: "destination") }
        self.destination = destination
        
        if(bits.count > 422) {
            let DTEBit = bits[422]
            self.dte = DTE(rawValue: DTEBit == 1)
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
    
    public func description() -> String {
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

