//
//  DGNSSBroadcastBinaryMessageTests.swift
//  SwiftAIS-Decoder
//
//  Tests for the DGNSSBroadcastBinaryMessage parser (message type 17).
//

import Testing
import SignalTools
@testable import SwiftAIS_Decoder

struct DGNSSBroadcastBinaryMessageTests {

    // Type 17 DGNSS broadcast on channel A. Expected values cross-checked against a known-good decoder.
    private static let dgnssBroadcast = "!AIVDM,1,1,,A,A04757QAv0agH2JdGlLP7Oqa0@TGw9H170,4*5A"

    // Known-good "DGNSS Data", one hex byte per element. This is everything after the 40-bit RTCM 2.X
    // header, so it starts at bit 120 of the payload.
    private static let expectedDataHex = [
        "1D", "FE", "69", "01", "09", "17", "FC", "96", "01", "1C"
    ]

    @Test func decodesDGNSSBroadcast() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.dgnssBroadcast),
                                    "The example sentence should parse as a valid AIS sentence")

        #expect(sentence.channel == .A)

        // 34 armored characters minus the 4 fill bits
        #expect(sentence.payloadBits.count == 200)

        let report = try #require(DGNSSBroadcastBinaryMessage(nmeaSentences: [sentence]),
                                  "A Type 17 payload should initialize a DGNSSBroadcastBinaryMessage")

        #expect(report.messageType.rawValue == 17)

        // The parser doesn't expose the repeat indicator, so it's checked straight off the payload
        let repeatIndicator: UInt8 = try #require(sentence.payloadBits[6...7])
        #expect(repeatIndicator == 0)

        #expect(report.mmsiNumber.value == 4310302)
        #expect(report.spare1 == 0)
        #expect(report.spare2 == 0)
        #expect(report.additionalSentences == nil)

        // Longitude — 139°53.6'E, signed, 1/10 minutes
        #expect(report.longitude.rawValue == 83936)
        let longitude = try #require(report.longitude.degrees)
        #expect(abs(longitude - 139.893333) < 0.00001)

        // Latitude — 35°37.1'N, signed, 1/10 minutes
        #expect(report.latitude.rawValue == 21371)
        let latitude = try #require(report.latitude.degrees)
        #expect(abs(latitude - 35.618333) < 0.00001)

        // RTCM 2.X header — 40 bits, followed by the differential correction data
        #expect(report.messageTypeIdentifier == 9)
        #expect(report.stationID == 684)
        #expect(report.zCount == 3048)
        #expect(report.sequenceNumber == 7)
        #expect(report.length == 4)
        #expect(report.stationHealth == 0)

        // data covers the header too, so it's 40 header bits + 80 data bits
        #expect(report.data.count == 120)

        let expectedBits = Self.bits(fromHex: Self.expectedDataHex)
        #expect(expectedBits.count == 80)
        for i in 0..<expectedBits.count {
            #expect(report.data[40 + i] == expectedBits[i],
                    "DGNSS data bit \(i) should match the known-good binary data")
        }

        print(report.description())
    }

    // Two-part Type 17 broadcast on channel B carrying a much larger correction set.
    // Expected values cross-checked against a known-good decoder.
    private static let multipartDGNSSBroadcast1 = "!AIVDM,2,1,5,B,A02VqLPA4I6C07h5G`Qh>?k52kdgwT42>kOtfhls9gqW13daw?;w>jStig4s,0*78"
    private static let multipartDGNSSBroadcast2 = "!AIVDM,2,2,5,B,<?me6SdWwml0>rbb,0*47"

    // Known-good "DGNSS Data" for the two-part message — everything after the 40-bit RTCM 2.X header.
    // Neither fragment has fill bits, so this lands exactly on a byte boundary: 42 bytes, 336 bits.
    private static let expectedMultipartDataHex = [
        "38", "FC", "C5", "0B", "3B", "2F", "FE", "41", "02", "3B",
        "37", "FC", "BB", "0D", "3B", "26", "FE", "67", "04", "3B",
        "29", "FC", "F2", "FF", "3B", "28", "FC", "C6", "F1", "3B",
        "30", "FD", "6D", "1A", "3B", "27", "FF", "5D", "00", "3B",
        "AA", "AA"
    ]

    @Test func decodesMultipartDGNSSBroadcast() throws {
        let sentence1 = try #require(AISNMEA0183Sentence(raw: Self.multipartDGNSSBroadcast1),
                                     "The first fragment should parse as a valid AIS sentence")
        let sentence2 = try #require(AISNMEA0183Sentence(raw: Self.multipartDGNSSBroadcast2),
                                     "The second fragment should parse as a valid AIS sentence")

        #expect(sentence1.channel == .B)
        #expect(sentence2.channel == .B)
        #expect(sentence1.fillBits == 0)
        #expect(sentence2.fillBits == 0)

        // 60 characters in the first fragment, 16 in the second
        #expect(sentence1.payloadBits.count == 360)
        #expect(sentence2.payloadBits.count == 96)

        let report = try #require(DGNSSBroadcastBinaryMessage(nmeaSentences: [sentence1, sentence2]),
                                  "A Type 17 payload should initialize a DGNSSBroadcastBinaryMessage")

        #expect(report.messageType.rawValue == 17)

        let repeatIndicator: UInt8 = try #require(sentence1.payloadBits[6...7])
        #expect(repeatIndicator == 0)

        #expect(report.mmsiNumber.value == 2734450)
        #expect(report.spare1 == 0)
        #expect(report.spare2 == 0)

        // The trailing fragment should be kept alongside the first
        #expect(report.additionalSentences?.count == 1)

        // Longitude — 29°7.8'E, signed, 1/10 minutes
        #expect(report.longitude.rawValue == 17478)
        let longitude = try #require(report.longitude.degrees)
        #expect(abs(longitude - 29.13) < 0.00001)

        // Latitude — 59°59.2'N, signed, 1/10 minutes
        #expect(report.latitude.rawValue == 35992)
        let latitude = try #require(report.latitude.degrees)
        #expect(abs(latitude - 59.986667) < 0.00001)

        // RTCM 2.X header
        #expect(report.messageTypeIdentifier == 31)
        #expect(report.stationID == 5)
        #expect(report.zCount == 3025)
        #expect(report.sequenceNumber == 0)
        #expect(report.length == 14)
        #expect(report.stationHealth == 0)

        // 40 header bits + 336 data bits, assembled from both fragments
        #expect(report.data.count == 376)

        let expectedBits = Self.bits(fromHex: Self.expectedMultipartDataHex)
        #expect(expectedBits.count == 336)
        for i in 0..<expectedBits.count {
            #expect(report.data[40 + i] == expectedBits[i],
                    "DGNSS data bit \(i) should match the known-good binary data")
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
