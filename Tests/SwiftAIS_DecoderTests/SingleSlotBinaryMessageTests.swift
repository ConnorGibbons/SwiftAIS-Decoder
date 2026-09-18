//
//  SingleSlotBinaryMessageTests.swift
//  SwiftAIS-Decoder
//

import Testing
import SignalTools
@testable import SwiftAIS_Decoder

struct SingleSlotBinaryMessageTests {


    private static let singleSlotAddressedUnstructuredBinaryMessage = "!AIVDM,1,1,,A,I6SWo?8P00a3PKpEKEVj0?vNP<65,0*73"

    // Known-good "Binary Data", one hex byte per element, from https://www.aggsoft.com/ais-decoder.htm
    // aggsoft reports 98 bits here, right-padded with 6 zero bits to land on a byte boundary — 13 bytes
    // = 104 bits. It reads the payload straight off the end of the destination MMSI, skipping the 2 spare
    // bits that ITU-R M.1371-5 Table 79 puts there when the destination ID is used, so its first 2 bits
    // are spare and the real 96-bit payload starts at index 2. See `spareBitOffset` below.
    private static let expectedPayloadHex = [
        "E0", "6F", "85", "5B", "56", "6C", "80", "3F", "E7", "A0",
        "30", "61", "40"
    ]

    @Test func decodesSingleSlotAddressedUnstructuredBinaryMessage() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.singleSlotAddressedUnstructuredBinaryMessage),
                                    "The example sentence should parse as a valid AIS sentence")

        #expect(sentence.channel == .A)
        #expect(sentence.fillBits == 0)
        #expect(sentence.payloadBits.count == 168)

        let report = try #require(SingleSlotBinaryMessage(nmea: sentence),
                                  "A Type 25 payload should initialize a SingleSlotBinaryMessage")

        #expect(report.messageType.rawValue == 25)

        #expect(report.mmsiNumber.value == 440006460)

        #expect(report.addressed == .addressed)
        #expect(report.structuredFlag == .unstructured)

        let destinationMMSI = try #require(report.destinationMMSI,
                                           "An addressed message should decode a destination MMSI")
        #expect(destinationMMSI.value == 134218384)

        #expect(report.appID == nil)
        #expect(report.dac == nil)
        #expect(report.fid == nil)

        // 168 bits minus the 40-bit header, the 30-bit destination MMSI, and the 2 spare bits
        #expect(report.payload.count == 96)

        // aggsoft's binary data includes the 2 spare bits at the front, so its bits are shifted by that
        // much relative to the payload this parser exposes.
        let spareBitOffset = 2
        let expectedBits = Self.bits(fromHex: Self.expectedPayloadHex)
        #expect(expectedBits.count == 104)
        for i in 0..<report.payload.count {
            #expect(report.payload[i] == expectedBits[i + spareBitOffset],
                    "Payload bit \(i) should match the known-good binary data")
        }

        // Not checking text here because it's garbage

        print(report.description())
    }

    private static let singleSlotBroadcastStructuredBinaryMessage = "!AIVDM,1,1,,A,I8IRGB40QPPa0:<HP::V=gwv0l48,0*0E"

    // Known-good "Binary Data", one hex byte per element. The message carries 112 payload bits, which
    // lands exactly on a byte boundary
    // This is from https://www.aggsoft.com/ais-decoder.htm
    private static let expectedStructuredPayloadHex = [
        "08", "29", "00", "A3", "18", "80", "A2", "A6", "36", "FF",
        "FE", "03", "41", "08"
    ]

    @Test func decodesSingleSlotBroadcastStructuredBinaryMessage() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.singleSlotBroadcastStructuredBinaryMessage),
                                    "The example sentence should parse as a valid AIS sentence")

        #expect(sentence.channel == .A)
        #expect(sentence.fillBits == 0)
        #expect(sentence.payloadBits.count == 168)

        let report = try #require(SingleSlotBinaryMessage(nmea: sentence),
                                  "A Type 25 payload should initialize a SingleSlotBinaryMessage")

        #expect(report.messageType.rawValue == 25)

        #expect(report.mmsiNumber.value == 563648328)

        #expect(report.addressed == .broadcast)
        #expect(report.structuredFlag == .structured)

        #expect(report.destinationMMSI == nil)

        #expect(report.appID == 134)
        #expect(report.dac?.rawValue == 2)
        #expect(report.dac?.isRegistered == false)
        #expect(report.dac?.description == "Unregistered")
        #expect(report.fid == 6)

        // 168 bits minus the 40-bit header and the 16-bit application ID
        #expect(report.payload.count == 112)

        let expectedBits = Self.bits(fromHex: Self.expectedStructuredPayloadHex)
        #expect(expectedBits.count == 112)
        for i in 0..<report.payload.count {
            #expect(report.payload[i] == expectedBits[i],
                    "Payload bit \(i) should match the known-good binary data")
        }

        // Not checking text here because it's garbage

        print(report.description())
    }

    private static let singleSlotBroadcastUnstructuredBinaryMessage = "!AIVDM,1,1,,A,I6SWVNP001a3P8FEKNf=Qb0@00S8,0*6B"

    // Known-good "Binary Data", one hex byte per element. The message carries 128 payload bits, which
    // lands exactly on a byte boundary
    // This is from https://www.aggsoft.com/ais-decoder.htm
    private static let expectedUnstructuredPayloadHex = [
        "00", "00", "1A", "43", "80", "85", "95", "6D", "EB", "8D",
        "86", "A0", "10", "00", "08", "C8"
    ]

    @Test func decodesSingleSlotBroadcastUnstructuredBinaryMessage() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.singleSlotBroadcastUnstructuredBinaryMessage),
                                    "The example sentence should parse as a valid AIS sentence")

        #expect(sentence.channel == .A)
        #expect(sentence.fillBits == 0)
        #expect(sentence.payloadBits.count == 168)

        let report = try #require(SingleSlotBinaryMessage(nmea: sentence),
                                  "A Type 25 payload should initialize a SingleSlotBinaryMessage")

        #expect(report.messageType.rawValue == 25)

        #expect(report.mmsiNumber.value == 440002170)

        #expect(report.addressed == .broadcast)
        #expect(report.structuredFlag == .unstructured)

        #expect(report.destinationMMSI == nil)

        #expect(report.appID == nil)
        #expect(report.dac == nil)
        #expect(report.fid == nil)

        // 168 bits minus the 40-bit header
        #expect(report.payload.count == 128)

        let expectedBits = Self.bits(fromHex: Self.expectedUnstructuredPayloadHex)
        #expect(expectedBits.count == 128)
        for i in 0..<report.payload.count {
            #expect(report.payload[i] == expectedBits[i],
                    "Payload bit \(i) should match the known-good binary data")
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
