//
//  AircraftPositionReportTests.swift
//  SwiftAIS-Decoder
//
//  Tests for the AircraftPositionReport parser (message type 9).
//

import Testing
@testable import SwiftAIS_Decoder

struct AircraftPositionReportTests {

    // Standard SAR aircraft position reports. Expected values cross-checked against an online decoder.
    private static let aircraftPositionReport = "!AIVDM,1,1,,A,91b55vRAQwOnDE<M05ICOp0208CM,0*6A"
    private static let aircraftPositionReportTwo = "!AIVDM,1,1,,A,91b55vRB23OnO7>M0<Ujik020@7r,0*07"

    @Test func decodesAircraftPositionReport() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.aircraftPositionReport),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(AircraftPositionReport(nmea: sentence),
                                  "A Type 9 payload should initialize an AircraftPositionReport")

        // Message ID
        #expect(report.messageType.rawValue == 9)

        // MMSI
        #expect(report.mmsiNumber.value == 111232506)

        // Altitude — meters
        #expect(report.altitude == 582)

        // Speed over ground — whole knots
        #expect(report.speedOverGround == 127)

        // Position accuracy — low
        #expect(report.positionAccuracy == .lowAccuracy)

        // Longitude — 2°6.9082'W, signed, 1/10000 minutes
        #expect(report.longitude.rawValue == -1269082)
        let longitude = try #require(report.longitude.degrees)
        #expect(abs(longitude - -2.115135) < 0.00001)

        // Latitude — 50°41.0084'N, signed, 1/10000 minutes
        #expect(report.latitude.rawValue == 30410085)
        let latitude = try #require(report.latitude.degrees)
        #expect(abs(latitude - 50.683475) < 0.00001)

        // Course over ground — 1/10 degree
        #expect(report.courseOverGround.rawValue == 895)
        let courseOverGround = try #require(report.courseOverGround.value)
        #expect(abs(courseOverGround - 89.5) < 0.00001)

        // Second of UTC timestamp
        #expect(report.timestamp.rawValue == 32)

        // Reserved for regional use
        #expect(report.regionalReserved == 0)

        // DTE — the bit is set, which the spec defines as "DTE not available"
        #expect(report.dte.rawValue == true)

        // Spare
        #expect(report.spare == 0)

        // Assigned mode flag — autonomous and continuous mode (default)
        #expect(report.assigned == .notAssignedMode)

        // RAIM flag
        #expect(report.raimFlag == .notInUse)

        // Radio status — comm state selector 0 (SOTDMA), sync state 0, slot time-out 2, slot number 1245
        // (0 << 17) | (2 << 14) | 1245 = 34013
        #expect(report.radioStatus.rawValue == 34013)

        // Decoded SOTDMA communication state (ITU-R M.1371-5, Tables 18 & 19)
        #expect(report.radioStatus.syncState == .utcDirect)
        #expect(report.radioStatus.slotTimeout == 2)
        if case .slotNumber(let slot) = report.radioStatus.subMessage {
            #expect(slot == 1245)
        } else {
            Issue.record("Expected sub message to be a slot number for slot time-out 2")
        }

        print(report.description())
    }

    @Test func decodesSecondAircraftPositionReport() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.aircraftPositionReportTwo),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(AircraftPositionReport(nmea: sentence),
                                  "A Type 9 payload should initialize an AircraftPositionReport")

        // Message ID
        #expect(report.messageType.rawValue == 9)

        // MMSI — same aircraft as the first example
        #expect(report.mmsiNumber.value == 111232506)

        // Altitude — meters; 4095 would mean "not available"
        #expect(report.altitude == 584)

        // Speed over ground — whole knots for type 9; 1023 would mean "not available"
        #expect(report.speedOverGround == 131)

        // Position accuracy — low (> 10m; unaugmented GNSS fix)
        #expect(report.positionAccuracy == .lowAccuracy)

        // Longitude — 2°4.7000'W, signed, 1/10000 minutes
        #expect(report.longitude.rawValue == -1247001)
        let longitude = try #require(report.longitude.degrees)
        #expect(abs(longitude - -2.078333) < 0.00001)

        // Latitude — 50°41.1927'N, signed, 1/10000 minutes
        #expect(report.latitude.rawValue == 30411927)
        let latitude = try #require(report.latitude.degrees)
        #expect(abs(latitude - 50.686545) < 0.00001)

        // Course over ground — 1/10 degree
        #expect(report.courseOverGround.rawValue == 711)
        let courseOverGround = try #require(report.courseOverGround.value)
        #expect(abs(courseOverGround - 71.1) < 0.00001)

        // Second of UTC timestamp
        #expect(report.timestamp.rawValue == 12)

        // Reserved for regional use
        #expect(report.regionalReserved == 0)

        // DTE — the bit is set, which the spec defines as "DTE not available"
        #expect(report.dte.rawValue == true)

        // Spare
        #expect(report.spare == 0)

        // Assigned mode flag — autonomous and continuous mode (default)
        #expect(report.assigned == .notAssignedMode)

        // RAIM flag
        #expect(report.raimFlag == .notInUse)

        // Radio status — comm state selector 0 (SOTDMA), sync state 0, slot time-out 4, slot number 506
        // (0 << 17) | (4 << 14) | 506 = 66042
        #expect(report.radioStatus.rawValue == 66042)

        // Decoded SOTDMA communication state (ITU-R M.1371-5, Tables 18 & 19)
        #expect(report.radioStatus.syncState == .utcDirect)
        #expect(report.radioStatus.slotTimeout == 4)
        if case .slotNumber(let slot) = report.radioStatus.subMessage {
            #expect(slot == 506)
        } else {
            Issue.record("Expected sub message to be a slot number for slot time-out 4")
        }

        print(report.description())
    }
}
