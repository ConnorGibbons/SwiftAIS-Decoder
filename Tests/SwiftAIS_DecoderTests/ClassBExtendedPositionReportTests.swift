//
//  ClassBExtendedPositionReportTests.swift
//  SwiftAIS-Decoder
//
//  Tests for the ClassBExtendedPositionReport parser (message type 19).
//

import Testing
@testable import SwiftAIS_Decoder

struct ClassBExtendedPositionReportTests {

    private static let classBExtendedPositionReport = "!AIVDM,1,1,,A,C6:Vo:00@R;51>TORgH2owc6@b30jb2M111111111110S0hS440P,0*0F"

    @Test func decodesClassBExtendedPositionReport() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.classBExtendedPositionReport),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(ClassBExtendedPositionReport(nmea: sentence),
                                  "A Type 19 payload should initialize a ClassBExtendedPositionReport")

        #expect(report.messageType.rawValue == 19)
        #expect(report.mmsiNumber.value == 413775656)
        #expect(report.regionalReserved1 == 0)

        #expect(report.speedOverGround.rawValue == 66)
        #expect(report.speedOverGround.speedOverGround == 6.6)

        #expect(report.positionAccuracy == .lowAccuracy)

        // Longitude — signed, 1/10000 minutes
        #expect(report.longitude.rawValue == 72917149)
        let longitude = try #require(report.longitude.degrees)
        #expect(abs(longitude - 121.528581666667) < 0.00001)

        // Latitude — signed, 1/10000 minutes
        #expect(report.latitude.rawValue == 18844406)
        let latitude = try #require(report.latitude.degrees)
        #expect(abs(latitude - 31.4073433333333) < 0.00001)

        #expect(report.courseOverGround.rawValue == 45)
        let courseOverGround = try #require(report.courseOverGround.value)
        #expect(abs(courseOverGround - 4.5) < 0.00001)

        #expect(report.trueHeading.rawValue == 511)
        #expect(report.trueHeading.value == nil)

        #expect(report.timeStamp.rawValue == 22)
        #expect(report.regionalReserved2 == 3)

        #expect(report.name.text.trimmingCharacters(in: [" "]) == "HUA YUAN")

        // Type of ship & cargo — 70: Cargo, all ships of this type
        #expect(report.shipType == .cargo)
        #expect(report.dimensionToBow == 12)
        #expect(report.dimensionToStern == 70)
        #expect(report.dimensionToPort == 8)
        #expect(report.dimensionToStarboard == 8)

        #expect(report.fixType == .undefined)
        #expect(report.raimFlag == .notInUse)

        // DTE — 1: not available
        #expect(report.dte == .notReady)
        #expect(report.assignedFlag == .notAssignedMode)
        #expect(report.spare == 0)

        print(report.description())
    }

    private static let classBExtendedPositionReportTwo = "!AIVDM,1,1,,A,C69@gi@00:8eJK4v0`fwcwh6Vb>2LjcQaUge11111110?1@51QP7,0*2C"

    @Test func decodesSecondClassBExtendedPositionReport() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.classBExtendedPositionReportTwo),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(ClassBExtendedPositionReport(nmea: sentence),
                                  "A Type 19 payload should initialize a ClassBExtendedPositionReport")

        #expect(report.messageType.rawValue == 19)
        #expect(report.mmsiNumber.value == 412364741)
        #expect(report.regionalReserved1 == 0)

        #expect(report.speedOverGround.rawValue == 0)
        #expect(report.speedOverGround.speedOverGround == 0.0)

        #expect(report.positionAccuracy == .highAccuracy)

        // Longitude — signed, 1/10000 minutes
        #expect(report.longitude.rawValue == 71675190)
        let longitude = try #require(report.longitude.degrees)
        #expect(abs(longitude - 119.45865) < 0.00001)

        // Latitude — signed, 1/10000 minutes
        #expect(report.latitude.rawValue == 20841099)
        let latitude = try #require(report.latitude.degrees)
        #expect(abs(latitude - 34.735165) < 0.00001)

        #expect(report.courseOverGround.rawValue == 3066)
        let courseOverGround = try #require(report.courseOverGround.value)
        #expect(abs(courseOverGround - 306.6) < 0.00001)

        #expect(report.trueHeading.rawValue == 511)
        #expect(report.trueHeading.value == nil)

        #expect(report.timeStamp.rawValue == 32)
        #expect(report.regionalReserved2 == 3)

        #expect(report.name.text.trimmingCharacters(in: [" "]) == "SUGANYU04276")

        // Type of ship & cargo — 30: Fishing
        #expect(report.shipType == .fishing)
        #expect(report.dimensionToBow == 20)
        #expect(report.dimensionToStern == 10)
        #expect(report.dimensionToPort == 3)
        #expect(report.dimensionToStarboard == 3)

        #expect(report.fixType == .undefined)
        #expect(report.raimFlag == .notInUse)

        // DTE — 0: available
        #expect(report.dte == .ready)
        #expect(report.assignedFlag == .notAssignedMode)
        #expect(report.spare == 7)

        print(report.description())
    }

    private static let classBExtendedPositionReportThree = "!AIVDM,1,1,,B,C5N3SRgPEnJGEBT>NhWAwwo862PaLELTBJ:V00000000S0D:R220,0*0B"

    @Test func decodesThirdClassBExtendedPositionReport() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.classBExtendedPositionReportThree),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(ClassBExtendedPositionReport(nmea: sentence),
                                  "A Type 19 payload should initialize a ClassBExtendedPositionReport")

        #expect(report.messageType.rawValue == 19)
        #expect(report.mmsiNumber.value == 367059850)
        #expect(report.regionalReserved1 == 248)

        #expect(report.speedOverGround.rawValue == 87)
        #expect(report.speedOverGround.speedOverGround == 8.7)

        #expect(report.positionAccuracy == .lowAccuracy)

        // Longitude — signed, 1/10000 minutes
        #expect(report.longitude.rawValue == -53286235)
        let longitude = try #require(report.longitude.degrees)
        #expect(abs(longitude - (-88.81039)) < 0.00001)

        // Latitude — signed, 1/10000 minutes
        #expect(report.latitude.rawValue == 17726217)
        let latitude = try #require(report.latitude.degrees)
        #expect(abs(latitude - 29.543695) < 0.00001)

        #expect(report.courseOverGround.rawValue == 3359)
        let courseOverGround = try #require(report.courseOverGround.value)
        #expect(abs(courseOverGround - 335.9) < 0.00001)

        #expect(report.trueHeading.rawValue == 511)
        #expect(report.trueHeading.value == nil)

        #expect(report.timeStamp.rawValue == 46)
        #expect(report.regionalReserved2 == 4)

        #expect(report.name.text == "CAPT.J.RIMES@@@@@@@@")

        // Type of ship & cargo — 70: Cargo, all ships of this type
        #expect(report.shipType == .cargo)
        #expect(report.dimensionToBow == 5)
        #expect(report.dimensionToStern == 21)
        #expect(report.dimensionToPort == 4)
        #expect(report.dimensionToStarboard == 4)

        #expect(report.fixType == .gps)
        #expect(report.raimFlag == .notInUse)

        // DTE — 0: available
        #expect(report.dte == .ready)
        #expect(report.assignedFlag == .notAssignedMode)
        #expect(report.spare == 0)

        print(report.description())
    }
}
