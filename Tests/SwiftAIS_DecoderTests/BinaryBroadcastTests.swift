//
//  BinaryBroadcastTests.swift
//  SwiftAIS-Decoder
//
//  Tests for the BinaryBroadcastMessage parser (message type 8).
//

import Testing
import SignalTools
@testable import SwiftAIS_Decoder

struct BinaryBroadcastTests {

    // Type 8 binary broadcast message on channel A. Expected values cross-checked against a
    // known-good decoder.
    private static let binaryBroadcast = "!AIVDM,1,1,,A,802R5Ph0BkEachFWA2GaOwwwwwwwwwwwwkBwwwwwwwwwwwwwwwwwwwwwwwu,2*57"

    // Known-good "Binary Data", one hex byte per element. This is the application data (everything
    // after the 56-bit header) as rendered by a decoder that keeps the 2 armoring fill bits and
    // then right-pads with 6 zero bits to land on a byte boundary — 38 bytes = 304 bits. The parser
    // strips the fill bits, so it exposes 296 real payload bits (the first 296 bits below).
    private static let expectedPayloadHex = [
        "35", "69", "AF", "05", "A7", "44", "25", "E9", "7F", "FF",
        "FF", "FF", "FF", "FF", "FF", "FF", "FF", "FF", "34", "BF",
        "FF", "FF", "FF", "FF", "FF", "FF", "FF", "FF", "FF", "FF",
        "FF", "FF", "FF", "FF", "FF", "FF", "FF", "40"
    ]

    @Test func decodesBinaryBroadcast() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.binaryBroadcast),
                                    "The example sentence should parse as a valid AIS sentence")

        #expect(sentence.channel == .A)

        let report = try #require(BinaryBroadcastMessage(nmeaSentences: [sentence]),
                                  "A Type 8 payload should initialize a BinaryBroadcastMessage")

        #expect(report.messageType.rawValue == 8)

        let repeatIndicator: UInt8? = sentence.payloadBits[6...7]
        #expect(repeatIndicator == 0)
        #expect(report.mmsiNumber.value == 2655619)
        #expect(report.spare == 0)

        // Application ID 75 = DAC (10 bits) << 6 | FI (6 bits): DAC 1, FI 11.
        #expect(report.areaCode == .international)
        #expect(report.areaCode?.rawValue == 1)
        #expect(report.functionalID == 11)
        let applicationID = (Int(report.areaCode?.rawValue ?? 0) << 6) | Int(report.functionalID)
        #expect(applicationID == 75)

        // Binary Data — convert the known-good hex to a bit sequence and compare.
        let expectedBits = Self.bits(fromHex: Self.expectedPayloadHex)
        #expect(expectedBits.count == 304)

        // The parser strips the 2 armoring fill bits, so it exposes 296 real payload bits.
        #expect(report.payload.count == 296)
        for i in 0..<report.payload.count {
            #expect(report.payload[i] == expectedBits[i],
                    "Payload bit \(i) should match the known-good binary data")
        }

        print(report.description())
    }

    /// Expands an array of two-character hex bytes into a flat array of bits (MSB first).
    private static func bits(fromHex hex: [String]) -> [Int] {
        var result: [Int] = []
        result.reserveCapacity(hex.count * 8)
        for byteString in hex {
            let byte = UInt8(byteString, radix: 16) ?? 0
            for shift in stride(from: 7, through: 0, by: -1) {
                result.append(Int((byte >> shift) & 1))
            }
        }
        return result
    }
}
