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

        // Call sign (6-bit ASCII, space-padded to 7 characters)
        #expect(report.callSign.text.trimmingCharacters(in: [" "]) == "LFNA")

        // Vessel name (6-bit ASCII, space-padded to 20 characters)
        #expect(report.vesselName.text.trimmingCharacters(in: [" "]) == "FALKVIK")

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

        // Max static draught — 3.8 m (raw 1/10 m field scaled to meters)
        #expect(abs(report.draught - 3.8) < 0.0001)

        // Destination (6-bit ASCII, space-padded to 20 characters)
        #expect(report.destination.text.trimmingCharacters(in: [" "]) == "FORUS")

        // DTE (data terminal equipment) — 0: available
        #expect(report.dte == .ready)

        print(report.description())
    }

    // Two-part Type 5 report for the vessel PRESTO (MMSI 205365700).
    // Expected values cross-checked against a known-good online decoder.
    private static let staticAndVoyage3 = "!AIVDM,2,1,1,B,533nQi400000uC?KGN118E=@v22222222222221S90;484ma06@CU5iDT1C`,0*15"
    private static let staticAndVoyage4 = "!AIVDM,2,2,1,B,88888888880,2*26"

    @Test func decodesStaticAndVoyageDataPresto() throws {
        let sentence1 = try #require(AISNMEA0183Sentence(raw: Self.staticAndVoyage3),
                                     "The first fragment should parse as a valid AIS sentence")
        let sentence2 = try #require(AISNMEA0183Sentence(raw: Self.staticAndVoyage4),
                                     "The second fragment should parse as a valid AIS sentence")
        let report = try #require(StaticAndVoyageData(nmea1: sentence1, nmea2: sentence2),
                                  "A Type 5 payload should initialize a StaticAndVoyageData")

        // Message ID
        #expect(report.messageType.rawValue == 5)

        // MMSI
        #expect(report.mmsiNumber.value == 205365700)

        // AIS version indicator — 1
        #expect(report.aisVersion == .future)

        // IMO number
        #expect(report.imoNumber == 0)

        // Call sign (6-bit ASCII, space-padded to 7 characters)
        #expect(report.callSign.text.trimmingCharacters(in: [" "]) == "OT3657")

        // Vessel name (6-bit ASCII, space-padded to 20 characters)
        #expect(report.vesselName.text.trimmingCharacters(in: [" "]) == "PRESTO")

        // Type of ship & cargo — 99: Other Type, No additional information
        #expect(report.shipType == .otherTypeNoAdditionalInfo)

        // Ship dimensions — A=72, B=11, C=4, D=8
        #expect(report.dimensionToBow == 72)
        #expect(report.dimensionToStern == 11)
        #expect(report.dimensionToPort == 4)
        #expect(report.dimensionToStarboard == 8)

        // EPFD type — 1: GPS
        #expect(report.fixType == .gps)

        // ETA — month 3, day 11, hour 9, minute 0
        #expect(report.month.month == 3)
        #expect(report.day.day == 11)
        #expect(report.hour.hour == 9)
        #expect(report.minute.minute == 0)

        // Max static draught — 2.5 m (raw 1/10 m field scaled to meters)
        #expect(abs(report.draught - 2.5) < 0.0001)

        // Destination (6-bit ASCII, space-padded to 20 characters)
        #expect(report.destination.text.trimmingCharacters(in: [" "]) == "ANTWERPEN")

        // DTE (data terminal equipment) — 0: available
        #expect(report.dte == .ready)

        print(report.description())
    }

    // Two-part Type 5 report for the vessel CORKY (MMSI 367006780).
    // This one is '@'-padded in its text fields, so the padding is asserted
    // verbatim to confirm the decoder preserves it.
    // Expected values cross-checked against a known-good online decoder.
    private static let staticAndVoyage5 = "!AIVDM,2,1,2,A,55N0D?000001L@???KH<u8eT000000000000000P0P>634<;?8CADQ@EF000,0*08"
    private static let staticAndVoyage6 = "!AIVDM,2,2,2,A,00000000000,2*26"

    @Test func decodesStaticAndVoyageDataCorky() throws {
        let sentence1 = try #require(AISNMEA0183Sentence(raw: Self.staticAndVoyage5),
                                     "The first fragment should parse as a valid AIS sentence")
        let sentence2 = try #require(AISNMEA0183Sentence(raw: Self.staticAndVoyage6),
                                     "The second fragment should parse as a valid AIS sentence")
        let report = try #require(StaticAndVoyageData(nmea1: sentence1, nmea2: sentence2),
                                  "A Type 5 payload should initialize a StaticAndVoyageData")

        // Message ID
        #expect(report.messageType.rawValue == 5)

        // MMSI
        #expect(report.mmsiNumber.value == 367006780)

        // AIS version indicator — 0 (station compliant with ITU-R M.1371-1)
        #expect(report.aisVersion == .standard)

        // IMO number
        #expect(report.imoNumber == 0)

        // Call sign — 7 characters, no padding needed
        #expect(report.callSign.text == "WDC3366")

        // Vessel name — "CORKY" '@'-padded to the full 20-character field.
        // Asserted verbatim (no stripping) to confirm the '@' padding is preserved.
        #expect(report.vesselName.text == "CORKY" + String(repeating: "@", count: 15))

        // Type of ship & cargo — 32: Towing (length > 200m or breadth > 25m)
        #expect(report.shipType == .towingLarge)

        // Ship dimensions — A=4, B=14, C=6, D=3
        #expect(report.dimensionToBow == 4)
        #expect(report.dimensionToStern == 14)
        #expect(report.dimensionToPort == 6)
        #expect(report.dimensionToStarboard == 3)

        // EPFD type — 1: GPS
        #expect(report.fixType == .gps)

        // ETA — month 0 (unavailable), day 24, hour 11, minute 15
        #expect(report.month.month == nil)
        #expect(report.day.day == 24)
        #expect(report.hour.hour == 11)
        #expect(report.minute.minute == 15)

        // Max static draught — 3.3 m (raw 1/10 m field scaled to meters)
        #expect(abs(report.draught - 3.3) < 0.0001)

        // Destination — "MEREAUX" '@'-padded to the full 20-character field.
        // Asserted verbatim (no stripping) to confirm the '@' padding is preserved.
        #expect(report.destination.text == "MEREAUX" + String(repeating: "@", count: 13))

        // DTE (data terminal equipment) — 0: available
        #expect(report.dte == .ready)

        print(report.description())
    }
}
