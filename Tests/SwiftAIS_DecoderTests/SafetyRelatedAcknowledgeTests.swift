//
//  SafetyRelatedAcknowledgeTests.swift
//  SwiftAIS-Decoder
//
//  Tests for the SafetyRelatedAcknowledge parser (message type 13).
//

import Testing
@testable import SwiftAIS_Decoder

struct SafetyRelatedAcknowledgeTests {

    // Type 13 safety related acknowledge. Expected values cross-checked against a known-good decoder:
    //   Source ID        211378120
    //   Destination #1   211217560 (sequence number 2)
    private static let safetyRelatedAcknowledge = "!AIVDM,1,1,,A,=39UOj0jFs9R,0*65"

    @Test func decodesSafetyRelatedAcknowledge() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.safetyRelatedAcknowledge),
                                    "The example sentence should parse as a valid AIS sentence")
        #expect(sentence.channel == .A)

        let report = try #require(SafetyRelatedAcknowledge(nmea: sentence),
                                  "A Type 13 payload should initialize a SafetyRelatedAcknowledge")

        // Message ID
        #expect(report.messageType.rawValue == 13)

        // Source ID (MMSI)
        #expect(report.mmsiNumber.value == 211378120)

        // Acknowledged destinations. The payload is exactly 72 bits (40-bit header + one 30-bit
        // MMSI + a 2-bit sequence number), so there is room for only one destination.
        #expect(report.mmsis.count == 1)
        #expect(report.mmsis.first?.value == 211217560)

        print(report.description())
    }

    // A Type 7 (BinaryAcknowledge) sentence shares the type 13 field layout, but the parser should
    // still reject it on the message ID.
    private static let binaryAcknowledge = "!AIVDM,1,1,,A,7022QP00V206,0*42"

    @Test func rejectsNonSafetyRelatedAcknowledge() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.binaryAcknowledge),
                                    "The example sentence should parse as a valid AIS sentence")
        #expect(SafetyRelatedAcknowledge(nmea: sentence) == nil)
    }
}
