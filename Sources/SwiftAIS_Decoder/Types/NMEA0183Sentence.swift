//
//  NMEA0183Sentence.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/8/26.
//

import SignalTools

public class NMEA0183Sentence {
    public let raw: String
    
    public init(raw: String) throws(NMEASentenceError) {
        self.raw = raw
        try Self.verifyChecksum(raw)
    }

    public static func verifyChecksum(_ raw: String) throws(NMEASentenceError) {
        guard raw.first == "$" || raw.first == "!" else { throw .badTag(String(raw.prefix(while: { $0 != "," }))) }
        guard let starIndex = raw.firstIndex(of: "*") else { throw .invalidField(name: "checksum", value: "<missing>") } // Only '*' in sentence should be preceding checksum

        let checksumString = raw[raw.index(after: starIndex)...]
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard checksumString.count == 2,
              let expected = UInt8(checksumString, radix: 16) else { throw .invalidField(name: "checksum", value: checksumString) }

        let payload = raw[raw.index(after: raw.startIndex)..<starIndex]
        var calculated: UInt8 = 0
        for char in payload {
            guard let ascii = char.asciiValue else { throw .invalidPayloadCharacter(char) }
            calculated ^= ascii
        }
        guard calculated == expected else { throw .checksumMismatch(expected: expected, calculated: calculated) }
    }
}

public enum AISTalker: String {
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

    public var description: String {
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

public enum AISDataSource: String {
    case otherShip = "VDM"
    case ownShip = "VDO"
    
    public var description: String {
        switch self {
        case .ownShip: return "Own Ship"
        case .otherShip: return "Other Ship"
        }
    }
}

public enum AISChannel: String {
    case A = "A" // AIS A: VHF Channel 87B, 161.975MHz. "AIS 1"
    case _1 = "1" // Alias for A
    case B = "B" // AIS B: VHF Channel 88B, 162.025MHz  "AIS 2"
    case _2 = "2" // Alias for B
    case C = "C" // AIS C: VHF Channel 75, 165.775MHz   "AIS 3", used for long-range
    case _3 = "3" // Alias for C
    case D = "D" // AIS D: VHF Channel 76, 156.825MHz   "AIS 4", used for long-range
    case _4 = "4" // Alias for D
}


public class AISNMEA0183Sentence: NMEA0183Sentence {
    
    public let talker: AISTalker
    public let dataSource: AISDataSource
    public let fragmentCount: UInt8
    public let fragmentNumber: UInt8
    public let sequentialID: UInt8?
    public let channel: AISChannel
    public let payload: String
    public let payloadBits: BitBuffer
    public let fillBits: UInt8
    public let checksum: UInt8
    
    
    public override init(raw: String) throws(NMEASentenceError) {
        // Checked before the fields so a corrupted sentence reports a checksum mismatch rather than whichever field the corruption happened to break.
        try Self.verifyChecksum(raw)

        let fields = raw.split(separator: ",", maxSplits: Int.max, omittingEmptySubsequences: false).map(String.init)
        guard fields.count == 7 else { throw .wrongFieldCount(expected: 7, got: fields.count) }
        let longTag = fields[0]
        // Drop the leading "!"/"$" delimiter, leaving the 5-character talker + data-source tag (e.g. "AIVDM").
        guard longTag.first == "!" || longTag.first == "$" else { throw .badTag(longTag) }
        let tag = longTag.dropFirst()
        guard tag.count == 5 else { throw .badTag(longTag) }

        guard let talker = AISTalker(rawValue: String(tag.prefix(2))) else { throw .unknownTalker(String(tag.prefix(2))) }
        guard let dataSource = AISDataSource(rawValue: String(tag.suffix(3))) else { throw .unknownDataSource(String(tag.suffix(3))) }
        guard let fragmentCount = UInt8(fields[1]) else { throw .invalidField(name: "fragmentCount", value: fields[1]) }
        guard let fragmentNumber = UInt8(fields[2]) else { throw .invalidField(name: "fragmentNumber", value: fields[2]) }
        let sequentialID = UInt8(fields[3])
        guard let channel = AISChannel(rawValue: fields[4]) else { throw .invalidField(name: "channel", value: fields[4]) }
        let payload = fields[5]

        let lastFields = fields[6].split(separator: "*").map(String.init)
        guard lastFields.count > 1 else { throw .invalidField(name: "checksum", value: "<missing>") }
        guard let fillBits = UInt8(lastFields[0]), fillBits < 6 else { throw .invalidField(name: "fillBits", value: lastFields[0]) }
        guard let checksum = UInt8(lastFields[1], radix: 16) else { throw .invalidField(name: "checksum", value: lastFields[1]) }

        self.talker = talker
        self.dataSource = dataSource
        self.fragmentCount = fragmentCount
        self.fragmentNumber = fragmentNumber
        self.sequentialID = sequentialID
        self.channel = channel
        self.payload = payload
        self.payloadBits = try Self.getPayloadBits(payload: payload, fillBits: fillBits)
        self.fillBits = fillBits
        self.checksum = checksum
        try super.init(raw: raw)
    }

    private static func getPayloadBits(payload: String, fillBits: UInt8) throws(NMEASentenceError) -> BitBuffer {
        var bits = BitBuffer()
        var i = 0
        for char in payload {
            i += 1
            var trimCount = 0
            if(i == payload.count) { trimCount = Int(fillBits) }
            guard var byte = char.asciiValue,
                  (48...87).contains(byte) || (96...119).contains(byte) else { throw .invalidPayloadCharacter(char) } // 88-95 unused, invalid chars
            byte = byte - 48; if byte > 40 { byte = byte - 8 }
            let mask = UInt8(0b00100000)
            for _ in 0..<(6 - trimCount) {
                bits.append(byte & mask == 0 ? 0 : 1)
                byte = byte << 1
            }
        }
        return bits
    }

}
