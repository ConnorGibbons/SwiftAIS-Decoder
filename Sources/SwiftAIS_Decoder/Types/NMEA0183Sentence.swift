//
//  NMEA0183Sentence.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/8/26.
//

import SignalTools

class NMEA0183Sentence {
    let raw: String
    
    init?(raw: String) {
        self.raw = raw
        guard verifyChecksum() else { return nil }
    }
    
    func verifyChecksum() -> Bool {
        guard raw.first == "$" || raw.first == "!",
              let starIndex = raw.firstIndex(of: "*") else { return false } // Only '*' in sentence should be preceding checksum

        let checksumString = raw[raw.index(after: starIndex)...]
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard checksumString.count == 2,
              let expected = UInt8(checksumString, radix: 16) else { return false } // Converts hex string to byte

        let payload = raw[raw.index(after: raw.startIndex)..<starIndex]
        var calculated: UInt8 = 0
        for char in payload {
            guard let ascii = char.asciiValue else { return false }
            calculated ^= ascii
        }
        return calculated == expected
    }
}

enum AISTalker: String {
    case baseStation = "AB"
    case dependentBaseStation = "AD"
    case mobileStation = "AI"
    case aidToNavigation = "AN"
    case receivingStation = "AR"
    case limitedBaseStation = "AS"
    case transmittingStation = "AT"
    case repeaterStation = "AX"
    case deprecatedBaseStation = "BS"
    case physicalShoreStation = "SA"

    var description: String {
        switch self {
        case .baseStation: return "NMEA 4.0 Base AIS station"
        case .dependentBaseStation: return "NMEA 4.0 Dependent AIS Base Station"
        case .mobileStation: return "Mobile AIS station"
        case .aidToNavigation: return "NMEA 4.0 Aid to Navigation AIS station"
        case .receivingStation: return "NMEA 4.0 AIS Receiving Station"
        case .limitedBaseStation: return "NMEA 4.0 Limited Base Station"
        case .transmittingStation: return "NMEA 4.0 AIS Transmitting Station"
        case .repeaterStation: return "NMEA 4.0 Repeater AIS station"
        case .deprecatedBaseStation: return "Base AIS station (deprecated in NMEA 4.0)"
        case .physicalShoreStation: return "NMEA 4.0 Physical Shore AIS Station"
        }
    }
}

enum AISDataSource: String {
    case otherShip = "VDM"
    case ownShip = "VDO"
    
    var description: String {
        switch self {
        case .ownShip: return "Own Ship"
        case .otherShip: return "Other Ship"
        }
    }
}

enum AISChannel: String {
    case A = "A"
    case B = "B"
}

class AISNMEA0183Sentence: NMEA0183Sentence {
    
    let talker: AISTalker
    let dataSource: AISDataSource
    let fragmentCount: UInt8
    let fragmentNumber: UInt8
    let sequentialID: UInt8?
    let channel: AISChannel
    let payload: String
    let payloadBits: BitBuffer
    let fillBits: UInt8
    let checksum: UInt8
    
    
    override init?(raw: String) {
        let fields = raw.split(separator: ",", maxSplits: Int.max, omittingEmptySubsequences: false).map(String.init)
        guard fields.count == 7 else { AISNMEA0183Sentence.printFailureReason("expected 7 comma-separated fields, got \(fields.count)"); return nil }
        guard let longTag = fields.first else { AISNMEA0183Sentence.printFailureReason("missing tag field"); return nil }
        // Drop the leading "!"/"$" delimiter, leaving the 5-character talker + data-source tag (e.g. "AIVDM").
        guard longTag.first == "!" || longTag.first == "$" else { AISNMEA0183Sentence.printFailureReason("tag does not start with '!' or '$': \(longTag)"); return nil }
        let tag = longTag.dropFirst()
        guard tag.count == 5 else { AISNMEA0183Sentence.printFailureReason("tag is not 5 characters: \(tag)"); return nil }
        
        guard let talker = AISTalker(rawValue: String(tag.prefix(2))) else { AISNMEA0183Sentence.printFailureReason("unknown talker: \(tag.prefix(2))"); return nil }
        guard let dataSource = AISDataSource(rawValue: String(tag.suffix(3))) else { AISNMEA0183Sentence.printFailureReason("unknown data source: \(tag.suffix(3))"); return nil }
        guard let fragmentCount = UInt8(fields[1]) else { AISNMEA0183Sentence.printFailureReason("invalid fragment count: \(fields[1])"); return nil }
        guard let fragmentNumber = UInt8(fields[2]) else { AISNMEA0183Sentence.printFailureReason("invalid fragment number: \(fields[2])"); return nil }
        let sequentialID = UInt8(fields[3])
        guard let channel = AISChannel(rawValue: fields[4]) else { AISNMEA0183Sentence.printFailureReason("invalid channel: \(fields[4])"); return nil }
        let payload = fields[5]
        
        let lastFields = fields.last!.split(separator: "*").map(String.init)
        guard let fillBits = UInt8(lastFields[0]) else { AISNMEA0183Sentence.printFailureReason("invalid fill bits: \(lastFields[0])"); return nil }
        guard fillBits < 6 else { AISNMEA0183Sentence.printFailureReason("fill bits out of range: \(fillBits)"); return nil }
        guard let checksum = UInt8(lastFields[1], radix: 16) else { AISNMEA0183Sentence.printFailureReason("invalid checksum: \(lastFields.count > 1 ? lastFields[1] : "<missing>")"); return nil }
        
        self.talker = talker
        self.dataSource = dataSource
        self.fragmentCount = fragmentCount
        self.fragmentNumber = fragmentNumber
        self.sequentialID = sequentialID
        self.channel = channel
        self.payload = payload
        guard let payloadBits = AISNMEA0183Sentence.getPayloadBits(payload: payload, fillBits: fillBits) else { AISNMEA0183Sentence.printFailureReason("could not decode payload bits from: \(payload)"); return nil }
        self.payloadBits = payloadBits
        self.fillBits = fillBits
        self.checksum = checksum
        super.init(raw: raw)
    }
    
    private static func getPayloadBits(payload: String, fillBits: UInt8) -> BitBuffer? {
        var bits = BitBuffer()
        var i = 0
        for char in payload {
            i += 1
            var trimCount = 0
            if(i == payload.count) { trimCount = Int(fillBits) }
            guard var byte = char.asciiValue else { return nil }
            guard byte >= 48 && ((48...87).contains(byte) || (96...119).contains(byte)) else { AISNMEA0183Sentence.printFailureReason("invalid payload character: \(char)"); return nil } // 88-95 unused, invalid chars
            byte = byte - 48; if byte > 40 { byte = byte - 8 }
            let mask = UInt8(0b00100000)
            for _ in 0..<(6 - trimCount) {
                bits.append(byte & mask == 0 ? 0 : 1)
                byte = byte << 1
            }
        }
        return bits
    }
    
    private static func printFailureReason(_ message: String) {
        print("AISNMEA0183Sentence init failed: \(message)")
    }
    
}
