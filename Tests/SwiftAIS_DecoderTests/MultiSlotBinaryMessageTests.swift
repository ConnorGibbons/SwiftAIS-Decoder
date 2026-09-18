//
//  MultiSlotBinaryMessageTests.swift
//  SwiftAIS-Decoder
//

import Testing
import SignalTools
@testable import SwiftAIS_Decoder

struct MultiSlotBinaryMessageTests {


    private static let multiSlotAddressedStructuredBinaryMessage = "!AIVDM,1,1,,A,JB3R0GO7p>vQL8tjw0b5hqpd0706kh9d3lR2vbl0400,2*40"

    // Known-good "data" field from the reference decoder, one hex byte per element. The reference reports
    // this as 168 bits running from the end of the 16-bit application ID to the end of the message, so the
    // trailing 20 bits are the communication state that this parser peels off into `radioStatus`. Only the
    // leading 148 bits are compared against `payload` for that reason.
    private static let expectedPayloadHex = [
        "32", "FC", "0A", "85", "C3", "9E", "2C", "00", "70", "06",
        "CF", "02", "6C", "0F", "48", "82", "FA", "AD", "00", "10",
        "00"
    ]

    @Test func decodesMultiSlotAddressedStructuredBinaryMessage() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.multiSlotAddressedStructuredBinaryMessage),
                                    "The example sentence should parse as a valid AIS sentence")

        #expect(sentence.channel == .A)
        #expect(sentence.fillBits == 2)
        #expect(sentence.payloadBits.count == 256)

        let report = try #require(MultiSlotBinaryMessage(nmea: sentence),
                                  "A Type 26 payload should initialize a MultiSlotBinaryMessage")

        #expect(report.messageType.rawValue == 26)

        #expect(report.mmsiNumber.value == 137920605)

        #expect(report.addressed == .addressed)
        #expect(report.structuredFlag == .structured)

        let destinationMMSI = try #require(report.destinationMMSI,
                                           "An addressed message should decode a destination MMSI")
        #expect(destinationMMSI.value == 838351848)

        #expect(report.appID == 28815)
        #expect(report.dac?.rawValue == 450)
        #expect(report.fid == 15)

        // 256 bits minus the 40-bit header, the 30-bit destination MMSI, the 2 spare bits,
        // the 16-bit application ID, and the 20-bit communication state
        #expect(report.payload.count == 148)

        let expectedBits = Self.bits(fromHex: Self.expectedPayloadHex)
        #expect(expectedBits.count == 168)
        for i in 0..<report.payload.count {
            #expect(report.payload[i] == expectedBits[i],
                    "Payload bit \(i) should match the known-good binary data")
        }

        #expect(report.radioStatus.statusType == .sotdma)
        #expect(report.radioStatus.rawValue == 4096)
        #expect(report.radioStatus.syncState == .utcDirect)
        #expect(report.radioStatus.slotTimeout == 0)
        if case .slotOffset(let offset) = report.radioStatus.subMessage {
            #expect(offset == 4096)
        } else {
            Issue.record("Expected sub message to be a slot offset for slot time-out 0")
        }

        // Not checking text here because it's garbage

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
