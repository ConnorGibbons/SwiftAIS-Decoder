//
//  BaseStationReportTests.swift
//  SwiftAIS-Decoder
//
//  Tests for the BaseStationReport parser (message type 4).
//

import Testing
@testable import SwiftAIS_Decoder

struct BaseStationReportTests {

    // Base station report. Expected values cross-checked against an online decoder.
    private static let baseStationReport = "!AIVDM,1,1,,B,4020ssAuho;N?PeNwjOAp<70089A,0*09"

    @Test func decodesBaseStationReport() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.baseStationReport),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(BaseStationReport(nmeaSentence: sentence),
                                  "A Type 4 payload should initialize a BaseStationReport")

        // Message ID
        #expect(report.messageType.rawValue == 4)

        // MMSI
        #expect(report.mmsiNumber.value == 2112493)

        // UTC date/time
        #expect(report.year.year == 2012)
        #expect(report.month.month == 3)
        #expect(report.day.day == 14)
        #expect(report.hour.hour == 11)
        #expect(report.minute.minute == 30)
        #expect(report.second.rawValue == 15)

        // Position accuracy — high (< 10m; differential mode)
        #expect(report.positionAccuracy == .highAccuracy)

        // Longitude — 9°56.1721'E, signed, 1/10000 minutes
        #expect(report.longitude.rawValue == 5961721)
        let longitude = try #require(report.longitude.degrees)
        #expect(abs(longitude - 9.936201667) < 0.00001)

        // Latitude — 54°39.8768'N, signed, 1/10000 minutes
        #expect(report.latitude.rawValue == 32798768)
        let latitude = try #require(report.latitude.degrees)
        #expect(abs(latitude - 54.664613333) < 0.00001)

        // EPFD type — surveyed
        #expect(report.fixType == .surveyed)

        // Spare
        #expect(report.spareBits == 0)

        // RAIM flag
        #expect(report.raimFlag == .notInUse)

        // Radio status — sync state 0, slot time-out 2, slot number 593
        // (0 << 17) | (2 << 14) | 593 = 33361
        #expect(report.radioStatus.rawValue == 33361)

        // Decoded SOTDMA communication state (ITU-R M.1371-5, Tables 18 & 19)
//        #expect(report.radioStatus.syncState == .utcDirect)
//        #expect(report.radioStatus.slotTimeout == 2)
//        if case .slotNumber(let slot) = report.radioStatus.subMessage {
//            #expect(slot == 593)
//        } else {
//            Issue.record("Expected sub message to be a slot number for slot time-out 2")
//        }
        
        print(report.description())
    }
}
