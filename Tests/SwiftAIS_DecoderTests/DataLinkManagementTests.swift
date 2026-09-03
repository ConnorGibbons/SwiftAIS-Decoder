//
//  DataLinkManagementTests.swift
//  SwiftAIS-Decoder
//
//  Tests for the DataLinkManagement parser (message type 20).
//

import Testing
@testable import SwiftAIS_Decoder

struct DataLinkManagementTests {

    // A 72-bit type 20 carrying only the first reservation block. 
    private static let singleBlock = "!AIVDM,1,1,,B,Dh3OvjP7qN>4,0*3B"

    @Test func decodesSingleReservationBlock() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.singleBlock),
                                    "The example sentence should parse as a valid AIS sentence")

        #expect(sentence.channel == .B)
        #expect(sentence.payloadBits.count == 72)

        let report = try #require(DataLinkManagement(nmea: sentence),
                                  "A Type 20 payload should initialize a DataLinkManagement")

        #expect(report.messageType.rawValue == 20)
        #expect(report.mmsiNumber.value == 3669706)

        // The parser doesn't expose the repeat indicator, so it's checked straight off the payload
        let repeatIndicator: UInt8 = try #require(sentence.payloadBits[6...7])
        #expect(repeatIndicator == 3)

        #expect(report.offset1 == 126)
        #expect(report.reservedSlots1 == 5)
        #expect(report.timeout1 == 7)
        #expect(report.increment1 == 225)

        // The payload ends 2 bits into where a second block would start, so there is no second block
        #expect(report.offset2 == nil)
        #expect(report.reservedSlots2 == nil)
        #expect(report.timeout2 == nil)
        #expect(report.increment2 == nil)

        #expect(report.offset3 == nil)
        #expect(report.reservedSlots3 == nil)
        #expect(report.timeout3 == nil)
        #expect(report.increment3 == nil)

        #expect(report.offset4 == nil)
        #expect(report.reservedSlots4 == nil)
        #expect(report.timeout4 == nil)
        #expect(report.increment4 == nil)

        print(report.description())
    }
    
    private static let twoBlocks = "!AIVDM,1,1,,B,D02u=ThfmNfpMaN9H0,0*67"

    @Test func decodesTwoReservationBlocks() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.twoBlocks),
                                    "The example sentence should parse as a valid AIS sentence")

        #expect(sentence.channel == .B)
        #expect(sentence.payloadBits.count == 108)

        let report = try #require(DataLinkManagement(nmea: sentence),
                                  "A Type 20 payload should initialize a DataLinkManagement")

        #expect(report.messageType.rawValue == 20)
        #expect(report.mmsiNumber.value == 3100051)

        let repeatIndicator: UInt8 = try #require(sentence.payloadBits[6...7])
        #expect(repeatIndicator == 0)

        #expect(report.offset1 == 749)
        #expect(report.reservedSlots1 == 5)
        #expect(report.timeout1 == 7)
        #expect(report.increment1 == 750)

        #expect(report.offset2 == 474)
        #expect(report.reservedSlots2 == 5)
        #expect(report.timeout2 == 7)
        #expect(report.increment2 == 150)

        #expect(report.offset3 == nil)
        #expect(report.reservedSlots3 == nil)
        #expect(report.timeout3 == nil)
        #expect(report.increment3 == nil)

        #expect(report.offset4 == nil)
        #expect(report.reservedSlots4 == nil)
        #expect(report.timeout4 == nil)
        #expect(report.increment4 == nil)

        print(report.description())
    }

    private static let threeBlocks = "!AIVDM,1,1,,A,D030p81OpN?b<`O6EqAO6D0,2*5B"

    @Test func decodesThreeReservationBlocks() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.threeBlocks),
                                    "The example sentence should parse as a valid AIS sentence")

        #expect(sentence.channel == .A)
        #expect(sentence.payloadBits.count == 136)

        let report = try #require(DataLinkManagement(nmea: sentence),
                                  "A Type 20 payload should initialize a DataLinkManagement")

        #expect(report.messageType.rawValue == 20)
        #expect(report.mmsiNumber.value == 3160096)

        let repeatIndicator: UInt8 = try #require(sentence.payloadBits[6...7])
        #expect(repeatIndicator == 0)

        #expect(report.offset1 == 1534)
        #expect(report.reservedSlots1 == 1)
        #expect(report.timeout1 == 7)
        #expect(report.increment1 == 250)

        #expect(report.offset2 == 2250)
        #expect(report.reservedSlots2 == 1)
        #expect(report.timeout2 == 7)
        #expect(report.increment2 == 1125)

        #expect(report.offset3 == 1940)
        #expect(report.reservedSlots3 == 5)
        #expect(report.timeout3 == 7)
        #expect(report.increment3 == 1125)

        #expect(report.offset4 == nil)
        #expect(report.reservedSlots4 == nil)
        #expect(report.timeout4 == nil)
        #expect(report.increment4 == nil)

        print(report.description())
    }

    private static let dataLinkManagement = "!AIVDM,1,1,,A,D028rqP7mNfp000000000000000,2*3B"

    @Test func decodesDataLinkManagement() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.dataLinkManagement),
                                    "The example sentence should parse as a valid AIS sentence")

        #expect(sentence.channel == .A)
        #expect(sentence.payloadBits.count == 160)

        let report = try #require(DataLinkManagement(nmea: sentence),
                                  "A Type 20 payload should initialize a DataLinkManagement")

        #expect(report.messageType.rawValue == 20)
        #expect(report.mmsiNumber.value == 2243302)

        #expect(report.offset1 == 125)
        #expect(report.reservedSlots1 == 5)
        #expect(report.timeout1 == 7)
        #expect(report.increment1 == 750)

        // Blocks 2-4 are present in the payload but zeroed out, meaning they reserve nothing
        #expect(report.offset2 == 0)
        #expect(report.reservedSlots2 == 0)
        #expect(report.timeout2 == 0)
        #expect(report.increment2 == 0)

        #expect(report.offset3 == 0)
        #expect(report.reservedSlots3 == 0)
        #expect(report.timeout3 == 0)
        #expect(report.increment3 == 0)

        #expect(report.offset4 == 0)
        #expect(report.reservedSlots4 == 0)
        #expect(report.timeout4 == 0)
        #expect(report.increment4 == 0)

        print(report.description())
    }

    private static let fourBlocks = "!AIVDM,1,1,,A,D02VqLPjlJfq6DK6DrMJ>4sIK6E,2*34"

    @Test func decodesFourReservationBlocks() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.fourBlocks),
                                    "The example sentence should parse as a valid AIS sentence")

        #expect(sentence.channel == .A)
        #expect(sentence.payloadBits.count == 160)

        let report = try #require(DataLinkManagement(nmea: sentence),
                                  "A Type 20 payload should initialize a DataLinkManagement")

        #expect(report.messageType.rawValue == 20)
        #expect(report.mmsiNumber.value == 2734450)

        let repeatIndicator: UInt8 = try #require(sentence.payloadBits[6...7])
        #expect(repeatIndicator == 0)

        #expect(report.offset1 == 813)
        #expect(report.reservedSlots1 == 1)
        #expect(report.timeout1 == 5)
        #expect(report.increment1 == 750)

        #expect(report.offset2 == 1125)
        #expect(report.reservedSlots2 == 1)
        #expect(report.timeout2 == 5)
        #expect(report.increment2 == 1125)

        #expect(report.offset3 == 935)
        #expect(report.reservedSlots3 == 5)
        #expect(report.timeout3 == 5)
        #expect(report.increment3 == 225)

        #expect(report.offset4 == 950)
        #expect(report.reservedSlots4 == 5)
        #expect(report.timeout4 == 5)
        #expect(report.increment4 == 1125)

        print(report.description())
    }
}
