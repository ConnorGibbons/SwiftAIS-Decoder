//
//  ClassBPositionReportTests.swift
//  SwiftAIS-Decoder
//
//  Tests for the ClassBPositionReport parser (message type 18).
//

import Testing
@testable import SwiftAIS_Decoder

struct ClassBPositionReportTests {

    private static let classBPositionReport = "!AIVDM,1,1,,B,B0001300D:6rrT5Ta?PuOw`RP<00,0*35"
    private static let classBPositionReportTwo = "!AIVDM,1,1,,A,B3mKm@00>@=jDW9P>IlGgw`UoP06,0*4F"
    private static let classBPositionReportThree = "!AIVDM,1,1,,A,B3`hBuh00052goWE0b<03wcUkP06,0*3C"

    @Test func decodesClassBPositionReport() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.classBPositionReport),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(ClassBPositionReport(nmea: sentence),
                                  "A Type 18 payload should initialize a ClassBPositionReport")

        #expect(report.messageType.rawValue == 18)
        #expect(report.mmsiNumber.value == 268)
        #expect(report.regionalReserved1 == 0)

        #expect(report.speedOverGround.rawValue == 80)
        #expect(report.speedOverGround.speedOverGround == 8.0)

        #expect(report.positonAccuracy == .highAccuracy)

        // Longitude — signed, 1/10000 minutes
        #expect(report.longitude.rawValue == 70737224)
        let longitude = try #require(report.longitude.degrees)
        #expect(abs(longitude - 117.895373333333) < 0.00001)

        // Latitude — signed, 1/10000 minutes
        #expect(report.latitude.rawValue == 23373048)
        let latitude = try #require(report.latitude.degrees)
        #expect(abs(latitude - 38.95508) < 0.00001)

        #expect(report.courseOverGround.rawValue == 983)
        let courseOverGround = try #require(report.courseOverGround.value)
        #expect(abs(courseOverGround - 98.3) < 0.00001)

        #expect(report.heading.rawValue == 511)
        #expect(report.heading.value == nil)

        #expect(report.timestamp.rawValue == 17)
        #expect(report.regionalReserved2 == 0)

        #expect(report.csUnit == .sotdma)
        #expect(report.visualDisplay == .hasVisualDisplay)
        #expect(report.dscFlag == .noDSC)
        #expect(report.bandFlag == .canChangeFreq)
        #expect(report.type22Flag == .unsupported)
        #expect(report.assignedFlag == .notAssignedMode)
        #expect(report.raimFlag == .notInUse)

        // Radio status — sync state 0, slot time-out 3, received stations 0
        // (0 << 17) | (3 << 14) | 0 = 49152
        #expect(report.radioStatus.rawValue == 49152)
        #expect(report.radioStatus.syncState == .utcDirect)
        #expect(report.radioStatus.slotTimeout == 3)
        if case .receivedStations(let stations) = report.radioStatus.subMessage {
            #expect(stations == 0)
        } else {
            Issue.record("Expected sub message to be a received station count for slot time-out 3")
        }

        print(report.description())
    }

    @Test func decodesSecondClassBPositionReport() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.classBPositionReportTwo),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(ClassBPositionReport(nmea: sentence),
                                  "A Type 18 payload should initialize a ClassBPositionReport")

        #expect(report.messageType.rawValue == 18)
        #expect(report.mmsiNumber.value == 257357120)
        #expect(report.regionalReserved1 == 0)

        #expect(report.speedOverGround.rawValue == 57)
        #expect(report.speedOverGround.speedOverGround == 5.7)

        #expect(report.positonAccuracy == .lowAccuracy)

        // Longitude — signed, 1/10000 minutes
        #expect(report.longitude.rawValue == 7227982)
        let longitude = try #require(report.longitude.degrees)
        #expect(abs(longitude - 12.0466366666667) < 0.00001)

        // Latitude — signed, 1/10000 minutes
        #expect(report.latitude.rawValue == 39860637)
        let latitude = try #require(report.latitude.degrees)
        #expect(abs(latitude - 66.434395) < 0.00001)

        #expect(report.courseOverGround.rawValue == 379)
        let courseOverGround = try #require(report.courseOverGround.value)
        #expect(abs(courseOverGround - 37.9) < 0.00001)

        #expect(report.heading.rawValue == 511)
        #expect(report.heading.value == nil)

        #expect(report.timestamp.rawValue == 17)
        #expect(report.regionalReserved2 == 0)

        #expect(report.csUnit == .carrierSense)
        #expect(report.visualDisplay == .noVisualDisplay)
        #expect(report.dscFlag == .hasDSC)
        #expect(report.bandFlag == .canChangeFreq)
        #expect(report.type22Flag == .supported)
        #expect(report.assignedFlag == .notAssignedMode)
        #expect(report.raimFlag == .inUse)

        // Comm state selector is 1 (ITDMA), whose fields RadioStatus doesn't model, so only the raw field is checked here.
        #expect(report.radioStatus.statusType == .itdma)
        #expect(report.radioStatus.rawValue == 393222)

        print(report.description())
    }

    @Test func decodesThirdClassBPositionReport() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.classBPositionReportThree),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(ClassBPositionReport(nmea: sentence),
                                  "A Type 18 payload should initialize a ClassBPositionReport")

        #expect(report.messageType.rawValue == 18)
        #expect(report.mmsiNumber.value == 244060919)
        #expect(report.regionalReserved1 == 0)

        #expect(report.speedOverGround.rawValue == 0)
        #expect(report.speedOverGround.speedOverGround == 0.0)

        #expect(report.positonAccuracy == .lowAccuracy)

        // Longitude — signed, 1/10000 minutes
        #expect(report.longitude.rawValue == 2643951)
        let longitude = try #require(report.longitude.degrees)
        #expect(abs(longitude - 4.406585) < 0.00001)

        // Latitude — signed, 1/10000 minutes
        #expect(report.latitude.rawValue == 30737059)
        let latitude = try #require(report.latitude.degrees)
        #expect(abs(latitude - 51.2284316666667) < 0.00001)

        #expect(report.courseOverGround.rawValue == 0)
        #expect(report.courseOverGround.value == 0.0)

        #expect(report.heading.rawValue == 511)
        #expect(report.heading.value == nil)

        #expect(report.timestamp.rawValue == 23)
        #expect(report.regionalReserved2 == 0)

        #expect(report.csUnit == .carrierSense)
        #expect(report.visualDisplay == .noVisualDisplay)
        #expect(report.dscFlag == .hasDSC)
        #expect(report.bandFlag == .canChangeFreq)
        #expect(report.type22Flag == .supported)
        #expect(report.assignedFlag == .notAssignedMode)
        #expect(report.raimFlag == .notInUse)

        #expect(report.radioStatus.statusType == .itdma)
        #expect(report.radioStatus.rawValue == 393222)

        print(report.description())
    }
}
