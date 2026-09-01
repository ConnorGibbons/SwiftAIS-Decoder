//
//  BinaryAcknowledgeTests.swift
//  SwiftAIS-Decoder
//
//  Tests for the BinaryAcknowledge parser (message type 7).
//

import Testing
@testable import SwiftAIS_Decoder

struct BinaryAcknowledgeTests {

    // Type 7 binary acknowledge. Expected values cross-checked against a known-good decoder.
    private static let binaryAcknowledge = "!AIVDM,1,1,,A,7022QP00V206,0*42"

    @Test func decodesBinaryAcknowledge() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.binaryAcknowledge),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(BinaryAcknowledge(nmea: sentence),
                                  "A Type 7 payload should initialize a BinaryAcknowledge")

        #expect(report.messageType.rawValue == 7)
        #expect(report.mmsiNumber.value == 2138496)
        #expect(report.mmsis.count == 1)
        #expect(report.mmsis.first?.value == 2492417)

        print(report.description())
    }

    // Single-destination acknowledge (channel A).
    private static let singleDestination = "!AIVDM,1,1,,A,702R5`hwCjq8,0*6B"

    @Test func decodesSingleDestination() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.singleDestination),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(BinaryAcknowledge(nmea: sentence),
                                  "A Type 7 payload should initialize a BinaryAcknowledge")

        #expect(report.messageType.rawValue == 7)
        #expect(report.mmsiNumber.value == 2655651)
        #expect(report.mmsis.count == 1)
        #expect(report.mmsis.first?.value == 265538450)

        print(report.description())
    }

    // Multi-destination acknowledge (channel A), repeat indicator 1.
    // The payload is 128 bits = 40-bit header + two 32-bit destination blocks + 24 trailing bits.
    // A lenient decoder may right-pad those 24 leftover bits into a phantom third destination
    // (836359488); the parser only reads complete 30-bit fields, so it stops at two.
    private static let multiDestination = "!AIVDM,1,1,,A,7IiQ4T`UjA9lC;b:M<MWE@,4*01"

    @Test func decodesMultipleDestinations() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.multiDestination),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(BinaryAcknowledge(nmea: sentence),
                                  "A Type 7 payload should initialize a BinaryAcknowledge")

        #expect(report.messageType.rawValue == 7)
        #expect(report.mmsiNumber.value == 655901842)
        #expect(report.mmsis.count == 2)
        #expect(report.mmsis.map(\.value) == [158483613, 321823389])

        print(report.description())
    }

    // Two-destination acknowledge on channel B.
    // The payload is exactly 104 bits (40-bit header + two 32-bit destination blocks); there are
    // no bits left for a third destination, so the "Destination #3 = 0" some decoders report is a
    // phantom and the parser correctly yields two.
    private static let channelBAcknowledge = "!AIVDM,1,1,,B,7;UnTqiR>Wh0HSat1@,4*46"

    @Test func decodesChannelBAcknowledge() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.channelBAcknowledge),
                                    "The example sentence should parse as a valid AIS sentence")
        #expect(sentence.channel == .B)

        let report = try #require(BinaryAcknowledge(nmea: sentence),
                                  "A Type 7 payload should initialize a BinaryAcknowledge")

        #expect(report.messageType.rawValue == 7)
        #expect(report.mmsiNumber.value == 777888999)
        #expect(report.mmsis.count == 2)
        #expect(report.mmsis.map(\.value) == [412000000, 412000001])

        print(report.description())
    }
}
