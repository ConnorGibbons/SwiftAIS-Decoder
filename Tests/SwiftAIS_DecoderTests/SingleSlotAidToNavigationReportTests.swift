//
//  SingleSlotAidToNavigationReportTests.swift
//  SwiftAIS-Decoder
//

import Testing
@testable import SwiftAIS_Decoder

struct SingleSlotAidToNavigationReportTests {

    private static let singleSlotAidToNavigationReport = "!AIVDM,1,1,,A,L>k`@BC=MVsh<75N0303rA080D?8,0*1B"

    @Test func decodesSingleSlotAidToNavigationReport() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.singleSlotAidToNavigationReport),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(SingleSlotAidToNavigationReport(nmea: sentence),
                                  "A Type 28 payload should initialize a SingleSlotAidToNavigationReport")

        #expect(sentence.channel == .A)
        #expect(report.messageType.rawValue == 28)
        #expect(report.mmsiNumber.value == 993661001)

        #expect(report.timeStamp.rawValue == 12)

        let longitude = try #require(report.longitude.degrees)
        #expect(abs(longitude - (-70.949997)) < 0.00001)

        let latitude = try #require(report.latitude.degrees)
        #expect(abs(latitude - 42.329998) < 0.00001)

        #expect(report.restrictedUseIndicator == .notRestricted)
        #expect(report.stationType == .physicalFloating)
        #expect(report.aidType == .portHandMark)
        #expect(report.marineResourceName == 1001)

        #expect(report.dimensions.type == .heightAndStructuralArea)
        #expect(report.dimensions.a == 1)
        #expect(report.dimensions.b == 1)
        #expect(report.dimensions.additionalDataFlag == false)

        #expect(report.chartedStatus == .charted)
        #expect(report.onStationStatus == .onStation)
        // The reference decoder labels this field "AtoN status" (per IALA R0126)
        #expect(report.regionalReserved == 242)
        #expect(report.authenticationFlag == .notAuthenticated)

        print(report.description())
    }
}
