//
//  ChannelManagement.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/8/26.
//
//  Type 22: Channel Management
//  Broadcast by a control base station to set radio Tx/Rx parameters for a particular region.
//  Payload Character: F

struct ChannelManagement: AISMessage {
    let nmeaSentence: AISNMEA0183Sentence
    let messageType: AISMessageType
    let mmsiNumber: MMSI
    
    let spare1: UInt8
    let channelA: VHFChannel
    let channelB: VHFChannel
    let txrx: TxRxModes
    let power: TransmitPower
    let region: LatLongRegion? // Whether or not this is used or MMSI1/2 depends on the "Addressed" bit
    let dest1: MMSI?
    let dest2: MMSI?
    let addressed: Addressed
    let channelABandwidth: Bandwidth
    let channelBBandwidth: Bandwidth
    let zoneSize: UInt8 // "The Transitional Zone Size in nautical miles should be calcu-lated by adding 1 to this parameter value. The default parameter value should be 4, which translates to 5
    // nautical miles" - https://web.archive.org/web/20111110211252/https://www.ialathree.org/iala/pages/AIS/IALATech1.5.pdf
    let spare2: UInt32?
    
    init?(nmea: AISNMEA0183Sentence) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits
        
        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageTypeBits)) else { return nil }
        guard messageType.rawValue == 22 else { return nil }
        self.messageType = messageType
        
        guard let mmsiBits: UInt32 = bits[8...37] else { return nil }
        guard let mmsi = MMSI(value: mmsiBits) else { return nil }
        self.mmsiNumber = mmsi
        
        guard let spare1Bits: UInt8 = bits[38...39] else { return nil }
        self.spare1 = spare1Bits
        
        guard let channelABits: UInt16 = bits[40...51] else { return nil }
        let channelA = VHFChannel(channel: Int(channelABits))
        self.channelA = channelA
        
        guard let channelBBits: UInt16 = bits[52...63] else { return nil }
        let channelB = VHFChannel(channel: Int(channelBBits))
        self.channelB = channelB
        
        guard let txrxBits: UInt8 = bits[64...67] else { return nil }
        guard let txrx = TxRxModes(rawValue: txrxBits) else { return nil }
        self.txrx = txrx
        
        guard let powerBit: UInt8 = bits[68...68] else { return nil }
        guard let power = TransmitPower(rawValue: powerBit) else { return nil }
        self.power = power
        
        guard let addressedBit: UInt8 = bits[139...139] else { return nil }
        guard let addressed = Addressed(rawValue: addressedBit) else { return nil }
        self.addressed = addressed
        
        if addressed == .addressed { // Format of the message is gated based on addressed bit, which for some reason comes *after* the fields it dictates.
            guard let dest1Bits: UInt32 = bits[69...98] else { return nil }
            guard let dest1 = MMSI(value: dest1Bits) else { return nil }
            self.dest1 = dest1
            
            guard let dest2Bits: UInt32 = bits[104...133] else { return nil }
            guard let dest2 = MMSI(value: dest2Bits) else { return nil }
            self.dest2 = dest2
            
            self.region = nil
        }
        else {
            guard let neLongitudeBits: UInt32 = bits[69...86] else { return nil }
            guard let neLatitudeBits: UInt32 = bits[87...103] else { return nil }
            guard let swLongitudeBits: UInt32 = bits[104...121] else { return nil }
            guard let swLatitudeBits: UInt32 = bits[122...138] else { return nil }
            let region = LatLongRegion(longitudeNEMins: neLongitudeBits, latitudeNEMins: neLatitudeBits, longitudeSWMins: swLongitudeBits, latitudeSWMins: swLatitudeBits)
            self.region = region
            
            self.dest1 = nil
            self.dest2 = nil
        }
        
        guard let channelABandwidthBit: UInt8 = bits[140...140] else { return nil }
        guard let channelABandwidth = Bandwidth(rawValue: channelABandwidthBit) else { return nil }
        self.channelABandwidth = channelABandwidth
        
        guard let channelBBandwidthBit: UInt8 = bits[141...141] else { return nil }
        guard let channelBBandwidth = Bandwidth(rawValue: channelBBandwidthBit) else { return nil }
        self.channelBBandwidth = channelBBandwidth
        
        guard let zoneSizeBits: UInt8 = bits[142...144] else { return nil }
        self.zoneSize = zoneSizeBits + 1 // See comment on property definition
        
        if let spare2Bits: UInt32 = bits[145...167] {
            self.spare2 = spare2Bits
        } else {
            self.spare2 = nil
        }
    }
    
    func description() -> String {
        var rows: [String] = [
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Channel A:", channelA.description),
            row("Channel B:", channelB.description),
            row("TX/RX Mode:", txrx.description),
            row("Power:", power.description),
            row("Addressed:", addressed.description)
        ]

        // Whether destination MMSIs or a lat/long region follow is gated on the addressed flag.
        if addressed == .addressed {
            if let dest1 = dest1 {
                rows.append(row("Destination 1:", "\(dest1.country) - \(dest1.description)"))
            }
            if let dest2 = dest2 {
                rows.append(row("Destination 2:", "\(dest2.country) - \(dest2.description)"))
            }
        } else if let region = region {
            rows.append(row("Region:", region.description))
        }

        rows.append(row("Channel A Bandwidth:", channelABandwidth.description))
        rows.append(row("Channel B Bandwidth:", channelBBandwidth.description))
        rows.append(row("Transitional Zone Size:", "\(zoneSize) nautical miles"))

        return rows.joined(separator: "\n")
    }


}
