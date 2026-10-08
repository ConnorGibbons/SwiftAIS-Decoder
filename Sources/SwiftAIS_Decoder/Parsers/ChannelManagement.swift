//
//  ChannelManagement.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/8/26.
//
//  Type 22: Channel Management
//  Broadcast by a control base station to set radio Tx/Rx parameters for a particular region.
//  Payload Character: F

public struct ChannelManagement: AISMessage {
    public let nmeaSentence: AISNMEA0183Sentence
    public let messageType: AISMessageType
    public let mmsiNumber: MMSI
    
    public let spare1: UInt8
    public let channelA: VHFChannel
    public let channelB: VHFChannel
    public let txrx: TxRxModes
    public let power: TransmitPower
    public let region: LatLongRegion? // Whether or not this is used or MMSI1/2 depends on the "Addressed" bit
    public let dest1: MMSI?
    public let dest2: MMSI?
    public let addressed: Addressed
    public let channelABandwidth: Bandwidth
    public let channelBBandwidth: Bandwidth
    public let zoneSize: UInt8 // "The Transitional Zone Size in nautical miles should be calcu-lated by adding 1 to this parameter value. The default parameter value should be 4, which translates to 5
    // nautical miles" - https://web.archive.org/web/20111110211252/https://www.ialathree.org/iala/pages/AIS/IALATech1.5.pdf
    public let spare2: UInt32?
    
    public init(nmea: AISNMEA0183Sentence) throws(AISDecodingError) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits

        let messageType: AISMessageType = try bits.read(0...5, "messageType")
        guard messageType.rawValue == 22 else { throw .unexpectedMessageType(messageType.rawValue, expected: [22]) }
        self.messageType = messageType

        let mmsiBits: UInt32 = try bits.read(8...37, "mmsiNumber")
        guard let mmsi = MMSI(value: mmsiBits) else { throw .invalidValue(field: "mmsiNumber", rawValue: UInt64(mmsiBits)) }
        self.mmsiNumber = mmsi

        self.spare1 = try bits.read(38...39, "spare1")

        let channelABits: UInt16 = try bits.read(40...51, "channelA")
        self.channelA = VHFChannel(channel: Int(channelABits))

        let channelBBits: UInt16 = try bits.read(52...63, "channelB")
        self.channelB = VHFChannel(channel: Int(channelBBits))

        self.txrx = try bits.read(64...67, "txrx")
        self.power = try bits.read(68...68, "power")

        let addressed: Addressed = try bits.read(139...139, "addressed")
        self.addressed = addressed

        if addressed == .addressed { // Format of the message is gated based on addressed bit, which for some reason comes *after* the fields it dictates.
            let dest1Bits: UInt32 = try bits.read(69...98, "dest1")
            guard let dest1 = MMSI(value: dest1Bits) else { throw .invalidValue(field: "dest1", rawValue: UInt64(dest1Bits)) }
            self.dest1 = dest1

            let dest2Bits: UInt32 = try bits.read(104...133, "dest2")
            guard let dest2 = MMSI(value: dest2Bits) else { throw .invalidValue(field: "dest2", rawValue: UInt64(dest2Bits)) }
            self.dest2 = dest2

            self.region = nil
        }
        else {
            let neLongitudeBits: UInt32 = try bits.read(69...86, "neLongitude")
            let neLatitudeBits: UInt32 = try bits.read(87...103, "neLatitude")
            let swLongitudeBits: UInt32 = try bits.read(104...121, "swLongitude")
            let swLatitudeBits: UInt32 = try bits.read(122...138, "swLatitude")
            self.region = LatLongRegion(longitudeNEMins: neLongitudeBits, latitudeNEMins: neLatitudeBits, longitudeSWMins: swLongitudeBits, latitudeSWMins: swLatitudeBits)

            self.dest1 = nil
            self.dest2 = nil
        }

        self.channelABandwidth = try bits.read(140...140, "channelABandwidth")
        self.channelBBandwidth = try bits.read(141...141, "channelBBandwidth")

        let zoneSizeBits: UInt8 = try bits.read(142...144, "zoneSize")
        self.zoneSize = zoneSizeBits + 1 // See comment on property definition
        
        if let spare2Bits: UInt32 = bits[145...167] {
            self.spare2 = spare2Bits
        } else {
            self.spare2 = nil
        }
    }
    
    public func description() -> String {
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
