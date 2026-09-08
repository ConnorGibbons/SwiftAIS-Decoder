//
//  AidToNavigationReportTests.swift
//  SwiftAIS-Decoder
//
//  Tests for the AidToNavigationReport parser (message type 21).
//

import Testing
@testable import SwiftAIS_Decoder

struct AidToNavigationReportTests {

    private static let aidToNavigationReport = "!AIVDM,1,1,,A,E0000ChcFstP000000000000000?iM91:RGuH00003RP10,4*3F"

    @Test func decodesAidToNavigationReport() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.aidToNavigationReport),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(AidToNavigationReport(nmeaSentences: [sentence]),
                                  "A Type 21 payload should initialize an AidToNavigationReport")

        #expect(report.messageType.rawValue == 21)
        #expect(report.mmsiNumber.value == 79)

        #expect(report.aidType == .referencePoint)
        #expect(report.name.text == "V-79@@@@@@@@@@@@@@@@")

        #expect(report.positionAccuracy == .lowAccuracy)

        let longitude = try #require(report.longitude.degrees)
        #expect(abs(longitude - (-6.35466333333333)) < 0.00001)

        let latitude = try #require(report.latitude.degrees)
        #expect(abs(latitude - 36.8298316666667) < 0.00001)

        #expect(report.dimensionToBow == 0)
        #expect(report.dimensionToStern == 0)
        #expect(report.dimensionToPort == 0)
        #expect(report.dimensionToStarboard == 0)

        #expect(report.fixType == .surveyed)
        #expect(report.timestamp.rawValue == 5)
        #expect(report.offPositionFlag == .onPosition)
        #expect(report.regionalReserved == 0)
        #expect(report.raimFlag == .notInUse)
        #expect(report.virtualAidFlag == .isVirtualAid)
        #expect(report.assignedFlag == .notAssignedMode)
        #expect(report.spare == 0)
        #expect(report.nameExtension == nil)
        #expect(report.additionalSentences == nil)

        print(report.description())
    }

    private static let aidToNavigationReportTwo = "!AIVDM,1,1,,A,E>j9dhiQ0a2Hh;TW230a6h72P00@=igf?TQA000003vP10,4*54"

    @Test func decodesSecondAidToNavigationReport() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.aidToNavigationReportTwo),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(AidToNavigationReport(nmeaSentences: [sentence]),
                                  "A Type 21 payload should initialize an AidToNavigationReport")

        #expect(report.messageType.rawValue == 21)
        #expect(report.mmsiNumber.value == 992111811)

        #expect(report.aidType == .fixedOffshoreStructure)
        #expect(report.name.text == "BARD1 WINDFARM NE@@@")

        #expect(report.positionAccuracy == .highAccuracy)

        let longitude = try #require(report.longitude.degrees)
        #expect(abs(longitude - 6.01938333333333) < 0.00001)

        let latitude = try #require(report.latitude.degrees)
        #expect(abs(latitude - 54.4232666666667) < 0.00001)

        #expect(report.dimensionToBow == 0)
        #expect(report.dimensionToStern == 0)
        #expect(report.dimensionToPort == 0)
        #expect(report.dimensionToStarboard == 0)

        #expect(report.fixType == .surveyed)
        #expect(report.timestamp.rawValue == 61)
        #expect(report.offPositionFlag == .onPosition)
        #expect(report.regionalReserved == 0)
        #expect(report.raimFlag == .notInUse)
        #expect(report.virtualAidFlag == .isVirtualAid)
        #expect(report.assignedFlag == .notAssignedMode)
        #expect(report.spare == 0)
        #expect(report.nameExtension == nil)
        #expect(report.additionalSentences == nil)

        print(report.description())
    }

    // Two-part Type 21 message — split across fragments despite fitting comfortably in one
    private static let multipartAidToNavigationReport1 = "!AIVDM,2,1,7,B,E4eHJhPR37q0000000000000000KUOSc=rq4h00000a,0*4A"
    private static let multipartAidToNavigationReport2 = "!AIVDM,2,2,7,B,@20,4*54"

    @Test func decodesMultipartAidToNavigationReport() throws {
        let sentence1 = try #require(AISNMEA0183Sentence(raw: Self.multipartAidToNavigationReport1),
                                     "The first fragment should parse as a valid AIS sentence")
        let sentence2 = try #require(AISNMEA0183Sentence(raw: Self.multipartAidToNavigationReport2),
                                     "The second fragment should parse as a valid AIS sentence")
        let report = try #require(AidToNavigationReport(nmeaSentences: [sentence1, sentence2]),
                                  "A Type 21 payload should initialize an AidToNavigationReport")

        #expect(report.messageType.rawValue == 21)
        #expect(report.mmsiNumber.value == 316021442)

        #expect(report.aidType == .referencePoint)
        #expect(report.name.text == "DFO2@@@@@@@@@@@@@@@@")

        #expect(report.positionAccuracy == .highAccuracy)

        let longitude = try #require(report.longitude.degrees)
        #expect(abs(longitude - (-123.429153333333)) < 0.00001)

        let latitude = try #require(report.latitude.degrees)
        #expect(abs(latitude - 48.65457) < 0.00001)

        #expect(report.dimensionToBow == 0)
        #expect(report.dimensionToStern == 0)
        #expect(report.dimensionToPort == 0)
        #expect(report.dimensionToStarboard == 0)

        #expect(report.fixType == .gps)
        #expect(report.timestamp.rawValue == 18)
        #expect(report.offPositionFlag == .offPosition)
        #expect(report.regionalReserved == 0)
        #expect(report.raimFlag == .inUse)

        #expect(report.additionalSentences?.count == 1)

        print(report.description())
    }

    // Two-part Type 21 message for a special mark buoy with non-zero dimensions.
    private static let secondMultipartAidToNavigationReport1 = "!AIVDM,2,1,8,B,E03l90w4Q1h3h1:WdPOwwwwwwwwlQdn`:e55020@@@gP0000000000000000,0*47"
    private static let secondMultipartAidToNavigationReport2 = "!AIVDM,2,2,8,B,00,4*19"

    @Test func decodesSecondMultipartAidToNavigationReport() throws {
        let sentence1 = try #require(AISNMEA0183Sentence(raw: Self.secondMultipartAidToNavigationReport1),
                                     "The first fragment should parse as a valid AIS sentence")
        let sentence2 = try #require(AISNMEA0183Sentence(raw: Self.secondMultipartAidToNavigationReport2),
                                     "The second fragment should parse as a valid AIS sentence")
        let report = try #require(AidToNavigationReport(nmeaSentences: [sentence1, sentence2]),
                                  "A Type 21 payload should initialize an AidToNavigationReport")

        #expect(report.messageType.rawValue == 21)
        #expect(report.mmsiNumber.value == 4000003)

        #expect(report.aidType == .specialMark)
        #expect(report.name.text == "IBC G BUOY@?????????")

        #expect(report.positionAccuracy == .highAccuracy)

        let longitude = try #require(report.longitude.degrees)
        #expect(abs(longitude - 126.572226666667) < 0.00001)

        let latitude = try #require(report.latitude.degrees)
        #expect(abs(latitude - 37.4144666666667) < 0.00001)

        #expect(report.dimensionToBow == 2)
        #expect(report.dimensionToStern == 2)
        #expect(report.dimensionToPort == 2)
        #expect(report.dimensionToStarboard == 2)

        #expect(report.fixType == .gps)
        #expect(report.timestamp.rawValue == 31)
        #expect(report.offPositionFlag == .onPosition)
        #expect(report.regionalReserved == 0)
        #expect(report.raimFlag == .notInUse)

        #expect(report.additionalSentences?.count == 1)

        print(report.description())
    }
}
