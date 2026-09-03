//
//  ParserTests.swift
//  SwiftAIS-Decoder
//
//  Tests for the message parsers (ClassA_PositionReport, etc.).
//

import Testing
@testable import SwiftAIS_Decoder

struct ClassAParserTests {

    // vessel (MMSI 477553000) moored in Puget Sound.
    // Source: https://gpsd.gitlab.io/gpsd/AIVDM.html
    private static let classAPositionReport = "!AIVDM,1,1,,B,177KQJ5000G?tO`K>RA1wUbN0TKH,0*5C"
    private static let classAPositionReport_2 = "!AIVDM,1,1,,A,15MrVH0000KH<:V:NtBLoqFP2H9:,0*2F"

    @Test func decodesCommonNavigationBlock_1() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.classAPositionReport),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(ClassAPositionReport(nmea: sentence),
                                  "A Type 1 payload should initialize a ClassA_PositionReport")

        #expect(report.mmsiNumber.value == 477553000)
        #expect(report.navStatus == .moored)

        #expect(report.rateOfTurn.rawValue == 0)
        #expect(report.rateOfTurn.rot == 0)

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

        #expect(report.courseOverGround.rawValue == 510)
        #expect(report.courseOverGround.value == 51.0)

        #expect(report.trueHeading.rawValue == 181)
        #expect(report.trueHeading.value == 181.0)

        // Timestamp — second of UTC minute
        #expect(report.timestamp.rawValue == 15)
        #expect(report.maneuverIndicator == .notAvailable)
        #expect(report.spare.rawValue == 0)
        #expect(report.raimFlag == .notInUse)
        #expect(report.radioStatus.rawValue == 149208)
        
        print(report.description())
    }
    
    @Test func decodesCommonNavigationBlock_2() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.classAPositionReport_2),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(ClassAPositionReport(nmea: sentence),
                                  "A Type 1 payload should initialize a ClassA_PositionReport")

        #expect(report.mmsiNumber.value == 366913120)
        #expect(report.navStatus == .underWayUsingEngine)

        #expect(report.rateOfTurn.rawValue == 0)
        #expect(report.rateOfTurn.rot == 0)

        #expect(report.speedOverGround.rawValue == 0)
        #expect(report.speedOverGround.speedOverGround == 0.0)

        // Position accuracy — low (> 10m)
        #expect(report.positionAccuracy == .lowAccuracy)

        // Longitude — signed, 1/10000 minutes
        #expect(report.longitude.rawValue == -38772397)
        let longitude = try #require(report.longitude.degrees)
        #expect(abs(longitude - -64.62066) < 0.00001)

        // Latitude — signed, 1/10000 minutes
        #expect(report.latitude.rawValue == 10992713)
        let latitude = try #require(report.latitude.degrees)
        #expect(abs(latitude - 18.3211883333333) < 0.00001)

        #expect(report.courseOverGround.rawValue == 3295)
        #expect(report.courseOverGround.value == 329.5)

        #expect(report.trueHeading.rawValue == 299)
        #expect(report.trueHeading.value == 299.0)

        // Timestamp — second of UTC minute
        #expect(report.timestamp.rawValue == 16)
        #expect(report.maneuverIndicator == .notAvailable)
        #expect(report.spare.rawValue == 0)
        #expect(report.raimFlag == .inUse)
        #expect(report.radioStatus.rawValue == 98890)
        
        print(report.description())
    }
}
