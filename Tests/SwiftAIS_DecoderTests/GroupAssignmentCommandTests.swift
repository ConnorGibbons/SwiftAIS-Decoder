//
//  GroupAssignmentCommandTests.swift
//  SwiftAIS-Decoder
//
//  Tests for the GroupAssignmentCommand parser (message type 23).
//

import Testing
@testable import SwiftAIS_Decoder

struct GroupAssignmentCommandTests {

    private static let groupAssignmentCommand = "!AIVDM,1,1,,B,G02:Kn01R`sn@291nj600000900,2*12"

    @Test func decodesGroupAssignmentCommand() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.groupAssignmentCommand),
                                    "The example sentence should parse as a valid AIS sentence")

        #expect(sentence.channel == .B)
        #expect(sentence.payloadBits.count == 160)

        let report = try #require(GroupAssignmentCommand(nmea: sentence),
                                  "A Type 23 payload should initialize a GroupAssignmentCommand")

        #expect(report.messageType.rawValue == 23)
        #expect(report.mmsiNumber.value == 2268120)
        #expect(report.spare1 == 0)

        #expect(report.region.longitudeNE.degrees?.rounded(toPlaces: 6) == 2.63)
        #expect(report.region.latitudeNE.degrees?.rounded(toPlaces: 6) == 51.07)
        #expect(report.region.longitudeSW.degrees?.rounded(toPlaces: 6) == 1.826667)
        #expect(report.region.latitudeSW.degrees?.rounded(toPlaces: 6) == 50.68)

        #expect(report.stationType == .regionalUse)
        #expect(report.shipType == .notAvailable)
        #expect(report.spare2 == 0)

        #expect(report.txrx == .TxATxBRxARxB)
        // Value 9 is "next shorter reporting interval" per ITU-R M.1371. Decoders that report "2 s" here
        // are using the Class B reporting rate table instead of the type 23 interval table.
        #expect(report.reportInterval == .nextShorterReportingInterval)
        #expect(report.quietTime == 0)

        #expect(report.spare3 == 0)

        print(report.description())
    }
}
