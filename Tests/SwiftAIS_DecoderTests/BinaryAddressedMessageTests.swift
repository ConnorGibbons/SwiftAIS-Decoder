//
//  BinaryAddressedMessageTests.swift
//  SwiftAIS-Decoder
//
//  Tests for the BinaryAddressedMessage parser (message type 6).
//

import Testing
@testable import SwiftAIS_Decoder

struct BinaryAddressedMessageTests {

    // Generic Type 6 binary addressed message. Expected values cross-checked against a known-good decoder.
    private static let binaryAddressedMessage = "!AIVDM,1,1,,A,6h2E:p66B2SR04<0@00000000000,0*4C"

    @Test func decodesBinaryAddressedMessage() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.binaryAddressedMessage),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(BinaryAddressedMessage(nmeaSentences: [sentence]),
                                  "A Type 6 payload should initialize a BinaryAddressedMessage")

        // Message ID
        #expect(report.messageType.rawValue == 6)

        // Source ID (MMSI)
        #expect(report.mmsiNumber.value == 2444000)

        // Destination ID (MMSI)
        #expect(report.destinationMMSI.value == 563219000)

        // Re-transmit flag — 1: retransmitted
        #expect(report.retransmit == true)

        // Spare — 0
        #expect(report.spare == false)

        // DAC — 1 (designates an international / ITU message)
        #expect(report.areaCode == .international)

        // FI (functional ID) — 3
        #expect(report.functionalID == 3)

        print(report.description())
        
        // This test doesn't actually compare to a known good decode of the payload. I'll have to add that eventually
    }
}
