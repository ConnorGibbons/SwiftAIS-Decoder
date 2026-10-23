//
//  Errors.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 10/8/26.
//

/// Errors thrown while parsing the NMEA 0183 sentence wrapper around an AIS payload.
public enum NMEASentenceError: Error, Equatable {
    case wrongFieldCount(expected: Int, got: Int)
    case badTag(String)
    case unknownTalker(String)
    case unknownDataSource(String)
    case invalidField(name: String, value: String)
    case invalidPayloadCharacter(Character)
    case checksumMismatch(expected: UInt8, calculated: UInt8)
    
    public var kind: String {
        switch self {
        case .wrongFieldCount:         return "NMEA wrong field count"
        case .badTag:                  return "NMEA bad tag"
        case .unknownTalker:           return "NMEA unknown talker"
        case .unknownDataSource:       return "NMEA unknown data source"
        case .invalidField:            return "NMEA invalid field"
        case .invalidPayloadCharacter: return "NMEA invalid payload character"
        case .checksumMismatch:        return "NMEA checksum mismatch"
        }
    }

    public var description: String {
        switch self {
        case let .wrongFieldCount(expected, got):
            return "\(kind): expected \(expected), got \(got)"
        case let .badTag(tag):
            return "\(kind): '\(tag)'"
        case let .unknownTalker(talker):
            return "\(kind): '\(talker)'"
        case let .unknownDataSource(source):
            return "\(kind): '\(source)'"
        case let .invalidField(name, value):
            return "\(kind): \(name) = '\(value)'"
        case let .invalidPayloadCharacter(char):
            let scalars = char.unicodeScalars
                .map { String(format: "U+%04X", $0.value) }
                .joined(separator: " ")
            return "\(kind): '\(char)' (\(scalars))"
        case let .checksumMismatch(expected, calculated):
            return "\(kind): " + String(format: "expected 0x%02X, calculated 0x%02X",
                                         UInt32(expected), UInt32(calculated))
        }
    }
    
}

/// Errors thrown while decoding the bit-level AIS payload into a message.
public enum AISDecodingError: Error, Equatable {
    case payloadTooShort(field: String, bits: Range<Int>, available: Int)
    case invalidValue(field: String, rawValue: UInt64)
    case unexpectedMessageType(Int, expected: [Int])
    case invalidText(field: String)
    case tooManyNMEASentences(count: Int, expected: Int)
    
    public var kind: String {
        switch self {
        case .payloadTooShort:       return "AIS payload too short"
        case .invalidValue:          return "AIS invalid value"
        case .unexpectedMessageType: return "AIS unexpected message type"
        case .invalidText:           return "AIS invalid text"
        case .tooManyNMEASentences:  return "AIS too many NMEA sentences"
        }
    }

    public var description: String {
        switch self {
        case let .payloadTooShort(field, bits, available):
            return "\(kind): '\(field)' needs bits \(bits.lowerBound)..<\(bits.upperBound), only \(available) available"
        case let .invalidValue(field, rawValue):
            return "\(kind): '\(field)' raw \(rawValue) (0x\(String(rawValue, radix: 16, uppercase: true)))"
        case let .unexpectedMessageType(got, expected):
            let list = expected.map(String.init).joined(separator: ", ")
            return "\(kind): got \(got), expected one of [\(list)]"
        case let .invalidText(field):
            return "\(kind): field '\(field)'"
        case let .tooManyNMEASentences(count, expected):
            return "\(kind): got \(count), expected \(expected)"
        }
    }
}
