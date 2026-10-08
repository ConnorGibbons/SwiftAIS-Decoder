//
//  GroupAssignmentCommand.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/8/26.
//
//  Type 23: Group Assignment Command
//  Broadcast by a control station to set operational parameters for AIS stations in a particular region
//  Payload character: G

public struct GroupAssignmentCommand: AISMessage {
    public let nmeaSentence: AISNMEA0183Sentence
    public let messageType: AISMessageType
    public let mmsiNumber: MMSI
    
    public let spare1: UInt8
    public let region: LatLongRegion
    public let stationType: StationType
    public let shipType: ShipType
    public let spare2: UInt32
    public let txrx: TxRxModes
    public let reportInterval: ReportInterval
    public let quietTime: UInt8 // Minutes affected stations should remain silent
    public let spare3: UInt8?
    
    public init(nmea: AISNMEA0183Sentence) throws(AISDecodingError) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits

        let messageType: AISMessageType = try bits.read(0...5, "messageType")
        guard messageType.rawValue == 23 else { throw .unexpectedMessageType(messageType.rawValue, expected: [23]) }
        self.messageType = messageType

        let mmsiBits: UInt32 = try bits.read(8...37, "mmsiNumber")
        guard let mmsi = MMSI(value: mmsiBits) else { throw .invalidValue(field: "mmsiNumber", rawValue: UInt64(mmsiBits)) }
        self.mmsiNumber = mmsi

        self.spare1 = try bits.read(38...39, "spare1")

        let neLongitudeBits: UInt32 = try bits.read(40...57, "neLongitude")
        let neLatitudeBits: UInt32 = try bits.read(58...74, "neLatitude")
        let swLongitudeBits: UInt32 = try bits.read(75...92, "swLongitude")
        let swLatitudeBits: UInt32 = try bits.read(93...109, "swLatitude")
        self.region = LatLongRegion(longitudeNEMins: neLongitudeBits, latitudeNEMins: neLatitudeBits, longitudeSWMins: swLongitudeBits, latitudeSWMins: swLatitudeBits)

        self.stationType = try bits.read(110...113, "stationType")
        self.shipType = try bits.read(114...121, "shipType")
        self.spare2 = try bits.read(122...143, "spare2")
        self.txrx = try bits.read(144...145, "txrx")
        self.reportInterval = try bits.read(146...149, "reportInterval")
        self.quietTime = try bits.read(150...153, "quietTime")

        if let spare3Bits: UInt8 = bits[154...159] {
            self.spare3 = spare3Bits
        } else {
            self.spare3 = nil
        }
    }
    
    public func description() -> String {
        var rows: [String] = [
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Region:", region.description),
            row("Station Type:", stationType.description)
        ]

        rows.append(row("Ship Type:", shipType.description))

        rows.append(row("TX/RX Mode:", txrx.description))
        rows.append(row("Report Interval:", reportInterval.description))
        // A quiet time of 0 means no silent period was commanded.
        rows.append(row("Quiet Time:", quietTime == 0 ? "None" : "\(quietTime) Minutes"))

        return rows.joined(separator: "\n")
    }
    
    
}
