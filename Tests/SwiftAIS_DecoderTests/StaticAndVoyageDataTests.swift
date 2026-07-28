//
//  StaticAndVoyageDataTests.swift
//  SwiftAIS-Decoder
//
//  Tests for the StaticAndVoyageData parser (message type 5).
//

import Testing
@testable import SwiftAIS_Decoder

struct StaticAndVoyageDataTests {

    // Two-part Type 5 report for the cargo vessel FALKVIK (MMSI 258315000).
    // Expected values cross-checked against a known-good online decoder.
    private static let staticAndVoyage1 = "!AIVDM,2,1,9,B,53nFBv01SJ<thHp6220H4heHTf2222222222221?50:454o<`9QSlUDp,0*09"
    private static let staticAndVoyage2 = "!AIVDM,2,2,9,B,888888888888880,2*2E"

    @Test func decodesStaticAndVoyageData() throws {
        let sentence1 = try #require(AISNMEA0183Sentence(raw: Self.staticAndVoyage1),
                                     "The first fragment should parse as a valid AIS sentence")
        let sentence2 = try #require(AISNMEA0183Sentence(raw: Self.staticAndVoyage2),
                                     "The second fragment should parse as a valid AIS sentence")
        let report = try #require(StaticAndVoyageData(nmea1: sentence1, nmea2: sentence2),
                                  "A Type 5 payload should initialize a StaticAndVoyageData")

        // Message ID
        #expect(report.messageType.rawValue == 5)

        // MMSI
        #expect(report.mmsiNumber.value == 258315000)

        // AIS version indicator — 0 (station compliant with ITU-R M.1371-1)
        #expect(report.aisVersion == .standard)

        // IMO number
        #expect(report.imoNumber == 6514895)

        // Call sign (6-bit ASCII, '@'-padded to 7 characters)
        #expect(report.callSign.text.trimmingCharacters(in: ["@", " "]) == "LFNA")

        // Vessel name (6-bit ASCII, '@'-padded to 20 characters)
        #expect(report.vesselName.text.trimmingCharacters(in: ["@", " "]) == "FALKVIK")

        // Type of ship & cargo — 79: Cargo, No additional information
        #expect(report.shipType == .cargoNoAdditionalInfo)

        // Ship dimensions — A=40, B=10, C=4, D=5
        #expect(report.dimensionToBow == 40)
        #expect(report.dimensionToStern == 10)
        #expect(report.dimensionToPort == 4)
        #expect(report.dimensionToStarboard == 5)

        // EPFD type — 1: GPS
        #expect(report.fixType == .gps)

        // ETA — month 3, day 14, hour 12, minute 40
        #expect(report.month.month == 3)
        #expect(report.day.day == 14)
        #expect(report.hour.hour == 12)
        #expect(report.minute.minute == 40)

        // Max static draught — 3.8 m. Raw field is in 1/10 m units (38);
        // the parser scales it by 10 on storage.
        #expect(report.draught == 380)

        // Destination (6-bit ASCII, '@'-padded to 20 characters)
        #expect(report.destination.text.trimmingCharacters(in: ["@", " "]) == "FORUS")

        // DTE (data terminal equipment) — 0: available
        #expect(report.dte == .ready)

        print(report.description())
    }
}
