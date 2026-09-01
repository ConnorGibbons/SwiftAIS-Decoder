//
//  UTCDateInquiryResponseTests.swift
//  SwiftAIS-Decoder
//
//  Tests for the UTCDateInquiryResponse parser (message type 11).
//

import Testing
@testable import SwiftAIS_Decoder

struct UTCDateInquiryResponseTests {

    // Type 11 UTC/date response on channel B. Expected values cross-checked against a known-good decoder.
    private static let utcDateInquiryResponse = "!AIVDM,1,1,,B,;03tB91uho;NQ89:VJ=>H:i00000,0*7A"

    @Test func decodesUTCDateInquiryResponse() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.utcDateInquiryResponse),
                                    "The example sentence should parse as a valid AIS sentence")
        #expect(sentence.channel == .B)

        let report = try #require(UTCDateInquiryResponse(nmea: sentence),
                                  "A Type 11 payload should initialize a UTCDateInquiryResponse")

        #expect(report.messageType.rawValue == 11)
        #expect(report.mmsiNumber.value == 4133412)
        #expect(report.year.year == 2012)
        #expect(report.month.month == 3)
        #expect(report.day.day == 14)
        #expect(report.hour.hour == 11)
        #expect(report.minute.minute == 30)
        #expect(report.second.rawValue == 33)

        // Position accuracy — low (> 10m; unaugmented GNSS fix)
        #expect(report.positionAccuracy == .lowAccuracy)

        // Longitude — 113°51.0221'E, signed, 1/10000 minutes
        #expect(report.longitude.rawValue == 68310221)
        let longitude = try #require(report.longitude.degrees)
        #expect(abs(longitude - 113.850368333) < 0.00001)

        // Latitude — 23°6.7051'N, signed, 1/10000 minutes
        #expect(report.latitude.rawValue == 13867051)
        let latitude = try #require(report.latitude.degrees)
        #expect(abs(latitude - 23.111751667) < 0.00001)
        #expect(report.fixType == .gps)
        #expect(report.spareBits == 0)
        #expect(report.raimFlag == .notInUse)

        // Radio status — sync state 0, slot time-out 0, slot offset 0
        #expect(report.radioStatus.rawValue == 0)

        // Decoded SOTDMA communication state (ITU-R M.1371-5, Tables 18 & 19)
        #expect(report.radioStatus.syncState == .utcDirect)
        #expect(report.radioStatus.slotTimeout == 0)
        if case .slotOffset(let offset) = report.radioStatus.subMessage {
            #expect(offset == 0)
        } else {
            Issue.record("Expected sub message to be a slot offset for slot time-out 0")
        }

        print(report.description())
    }
}
