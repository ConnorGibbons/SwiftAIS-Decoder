//
//  GroupAssignmentCommand.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/8/26.
//
//  Type 23: Group Assignment Command
//  Broadcast by a control station to set operational parameters for AIS stations in a particular region
//  Payload character: G

struct GroupAssignmentCommand: AISMessage {
    let nmeaSentence: AISNMEA0183Sentence
    let messageType: AISMessageType
    let mmsiNumber: MMSI
    
    let spare1: UInt8
    let region: LatLongRegion
    let stationType: StationType
    let shipType: ShipType
    let spare2: UInt32
    let txrx: TxRxModes
    let reportInterval: ReportInterval
    let quietTime: UInt8 // Minutes affected stations should remain silent
    let spare3: UInt8?
    
    init?(nmea: AISNMEA0183Sentence) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits
        
        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageTypeBits)) else { return nil }
        guard messageType.rawValue == 23 else { return nil }
        self.messageType = messageType
        
        guard let mmsiBits: UInt32 = bits[8...37] else { return nil }
        guard let mmsi = MMSI(value: mmsiBits) else { return nil }
        self.mmsiNumber = mmsi
        
        guard let spare1Bits: UInt8 = bits[38...39] else { return nil }
        self.spare1 = spare1Bits
        
        guard let neLongitudeBits: UInt32 = bits[40...57] else { return nil }
        guard let neLatitudeBits: UInt32 = bits[58...74] else { return nil }
        guard let swLongitudeBits: UInt32 = bits[75...92] else { return nil }
        guard let swLatitudeBits: UInt32 = bits[93...109] else { return nil }
        let region = LatLongRegion(longitudeNEMins: neLongitudeBits, latitudeNEMins: neLatitudeBits, longitudeSWMins: swLongitudeBits, latitudeSWMins: swLatitudeBits)
        self.region = region
        
        guard let stationTypeBits: UInt8 = bits[110...113] else { return nil }
        guard let stationType = StationType(rawValue: stationTypeBits) else { return nil }
        self.stationType = stationType
        
        guard let shipTypeBits: UInt8 = bits[114...121] else { return nil }
        guard let shipType = ShipType(rawValue: shipTypeBits) else { return nil }
        self.shipType = shipType
        
        guard let spare2Bits: UInt32 = bits[122...143] else { return nil }
        self.spare2 = spare2Bits
        
        guard let txrxBits: UInt8 = bits[144...145] else { return nil }
        guard let txrx = TxRxModes(rawValue: txrxBits) else { return nil }
        self.txrx = txrx
        
        guard let reportIntervalBits: UInt8 = bits[146...149] else { return nil }
        guard let reportInterval = ReportInterval(rawValue: reportIntervalBits) else { return nil }
        self.reportInterval = reportInterval
        
        guard let quietTimeBits: UInt8 = bits[150...153] else { return nil }
        self.quietTime = quietTimeBits
        
        if let spare3Bits: UInt8 = bits[154...159] {
            self.spare3 = spare3Bits
        } else {
            self.spare3 = nil
        }
    }
    
    func description() -> String {
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
