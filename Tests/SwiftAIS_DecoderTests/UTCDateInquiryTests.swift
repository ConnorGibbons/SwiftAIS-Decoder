//
//  UTCDateInquiryTests.swift
//  SwiftAIS-Decoder
//
//  Tests for the UTCDateInquiry parser (message type 10).
//

import Testing
@testable import SwiftAIS_Decoder

struct UTCDateInquiryTests {

    // Type 10 UTC/date inquiry. Expected values cross-checked against a known-good decoder:
    //   Source ID        538090168
    //   Destination ID   352324000
    private static let utcDateInquiry = "!AIVDM,1,1,,A,:81:Jf1D02J0,0*0E"

    @Test func decodesUTCDateInquiry() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.utcDateInquiry),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(UTCDateInquiry(nmea: sentence),
                                  "A Type 10 payload should initialize a UTCDateInquiry")

        // Message ID
        #expect(report.messageType.rawValue == 10)

        // Source ID (MMSI)
        #expect(report.mmsiNumber.value == 538090168)

        // Destination ID (MMSI)
        #expect(report.destinationMMSI.value == 352324000)

        // Spares
        #expect(report.spare1 == 0)
        #expect(report.spare2 == 0)

        print(report.description())
    }

    // Same source station inquiring of a different vessel.
    //   Source ID        538090168
    //   Destination ID   240897000
    private static let secondUTCDateInquiry = "!AIVDM,1,1,,A,:81:Jf0qKjvP,0*45"

    @Test func decodesSecondUTCDateInquiry() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.secondUTCDateInquiry),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(UTCDateInquiry(nmea: sentence),
                                  "A Type 10 payload should initialize a UTCDateInquiry")

        // Message ID
        #expect(report.messageType.rawValue == 10)

        // Source ID (MMSI)
        #expect(report.mmsiNumber.value == 538090168)

        // Destination ID (MMSI)
        #expect(report.destinationMMSI.value == 240897000)

        // Spares
        #expect(report.spare1 == 0)
        #expect(report.spare2 == 0)

        print(report.description())
    }

    // UTC/date inquiry on channel B.
    //   Source ID        538002009
    //   Destination ID   240132000
    private static let channelBUTCDateInquiry = "!AIVDM,1,1,,B,:8152F@q@7r0,0*53"

    @Test func decodesChannelBUTCDateInquiry() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.channelBUTCDateInquiry),
                                    "The example sentence should parse as a valid AIS sentence")
        #expect(sentence.channel == .B)

        let report = try #require(UTCDateInquiry(nmea: sentence),
                                  "A Type 10 payload should initialize a UTCDateInquiry")

        // Message ID
        #expect(report.messageType.rawValue == 10)

        // Source ID (MMSI)
        #expect(report.mmsiNumber.value == 538002009)

        // Destination ID (MMSI)
        #expect(report.destinationMMSI.value == 240132000)

        // Spares
        #expect(report.spare1 == 0)
        #expect(report.spare2 == 0)

        print(report.description())
    }
}
