//
//  ParserTests.swift
//  SwiftAIS-Decoder
//
//  Tests for the message parsers (ClassA_PositionReport, etc.).
//

import Testing
@testable import SwiftAIS_Decoder

struct ClassA_ParserTests {

    // vessel (MMSI 477553000) moored in Puget Sound.
    // Source: https://gpsd.gitlab.io/gpsd/AIVDM.html
    private static let classAPositionReport = "!AIVDM,1,1,,B,177KQJ5000G?tO`K>RA1wUbN0TKH,0*5C"
    private static let classAPositionReport_2 = "!AIVDM,1,1,,A,15MrVH0000KH<:V:NtBLoqFP2H9:,0*2F"

    @Test func decodesCommonNavigationBlock_1() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.classAPositionReport),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(ClassA_PositionReport(nmea: sentence),
                                  "A Type 1 payload should initialize a ClassA_PositionReport")

        // MMSI
        #expect(report.mmsiNumber.value == 477553000)

        // Navigation status
        #expect(report.navStatus == .moored)

        // Rate of turn — 0 means "not turning"
        #expect(report.rateOfTurn.rawValue == 0)
        #expect(report.rateOfTurn.rot == 0)

        // Speed over ground — stationary
        #expect(report.speedOverGround.rawValue == 0)
        #expect(report.speedOverGround.speedOverGround == 0.0)

        // Position accuracy — low (> 10m)
        #expect(report.positionAccuracy == .lowAccuracy)

        // Longitude — signed, 1/10000 minutes
        #expect(report.longitude.rawValue == -73407500)
        let longitude = try #require(report.longitude.degrees)
        #expect(abs(longitude - -122.345833) < 0.00001)

        // Latitude — signed, 1/10000 minutes
        #expect(report.latitude.rawValue == 28549700)
        let latitude = try #require(report.latitude.degrees)
        #expect(abs(latitude - 47.582833) < 0.00001)

        // Course over ground — 0.1 degree units
        #expect(report.courseOverGround.rawValue == 510)
        #expect(report.courseOverGround.value == 51.0)

        // True heading — whole degrees
        #expect(report.trueHeading.rawValue == 181)
        #expect(report.trueHeading.value == 181.0)

        // Timestamp — second of UTC minute
        #expect(report.timestamp.rawValue == 15)

        // Maneuver indicator
        #expect(report.maneuverIndicator == .notAvailable)

        // Spare
        #expect(report.spare.rawValue == 0)

        // RAIM flag
        #expect(report.raimFlag == .notInUse)

        // Radio status
        #expect(report.radioStatus.rawValue == 149208)
        
        print(report.description())
    }
    
    @Test func decodesCommonNavigationBlock_2() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.classAPositionReport_2),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(ClassA_PositionReport(nmea: sentence),
                                  "A Type 1 payload should initialize a ClassA_PositionReport")


        // MMSI
        #expect(report.mmsiNumber.value == 366913120)

        // Navigation status
        #expect(report.navStatus == .underWayUsingEngine)

        // Rate of turn — 0 means "not turning"
        #expect(report.rateOfTurn.rawValue == 0)
        #expect(report.rateOfTurn.rot == 0)

        // Speed over ground — stationary
        #expect(report.speedOverGround.rawValue == 0)
        #expect(report.speedOverGround.speedOverGround == 0.0)

        // Position accuracy — low (> 10m)
        #expect(report.positionAccuracy == .lowAccuracy)

        // Longitude — signed, 1/10000 minutes (-64.62066° West)
        #expect(report.longitude.rawValue == -38772397)
        let longitude = try #require(report.longitude.degrees)
        #expect(abs(longitude - -64.62066) < 0.00001)

        // Latitude — signed, 1/10000 minutes (18.3211883° North)
        #expect(report.latitude.rawValue == 10992713)
        let latitude = try #require(report.latitude.degrees)
        #expect(abs(latitude - 18.3211883333333) < 0.00001)

        // Course over ground — 0.1 degree units
        #expect(report.courseOverGround.rawValue == 3295)
        #expect(report.courseOverGround.value == 329.5)

        // True heading — whole degrees
        #expect(report.trueHeading.rawValue == 299)
        #expect(report.trueHeading.value == 299.0)

        // Timestamp — second of UTC minute
        #expect(report.timestamp.rawValue == 16)

        // Maneuver indicator
        #expect(report.maneuverIndicator == .notAvailable)

        // Spare (reserved for regional use)
        #expect(report.spare.rawValue == 0)

        // RAIM flag — in use
        #expect(report.raimFlag == .inUse)

        // Radio status
        #expect(report.radioStatus.rawValue == 98890)
        
        print(report.description())
    }
}
