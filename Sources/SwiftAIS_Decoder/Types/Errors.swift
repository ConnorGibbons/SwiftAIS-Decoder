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
}

/// Errors thrown while decoding the bit-level AIS payload into a message.
public enum AISDecodingError: Error, Equatable {
    case payloadTooShort(field: String, bits: Range<Int>, available: Int)
    case invalidValue(field: String, rawValue: UInt64)
    case unexpectedMessageType(Int, expected: [Int])
    case invalidText(field: String)
}
