//
//  StaticDataReportTests.swift
//  SwiftAIS-Decoder
//

import Testing
@testable import SwiftAIS_Decoder

struct StaticDataReportTests {

    private static let staticDataReportPartA = "!AIVDM,1,1,,B,H0HN<8QLTdTpN22222222222223,2*1B"

    @Test func decodesPartAStaticDataReport() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.staticDataReportPartA),
                                    "The example sentence should parse as a valid AIS sentence")

        #expect(sentence.channel == .B)
        #expect(sentence.payloadBits.count == 160)

        let report = try #require(StaticDataReport(nmea: sentence),
                                  "A Type 24 payload should initialize a StaticDataReport")

        #expect(report.messageType.rawValue == 24)
        #expect(report.mmsiNumber.value == 25660450)
        #expect(report.part == .a)

        #expect(report.vesselName?.text == "WIKING              ")
        #expect(report.vesselName?.text.trimmingCharacters(in: [" "]) == "WIKING")
        #expect(report.spare == nil)

        #expect(report.shipType == nil)
        #expect(report.vendorID == nil)
        #expect(report.unitModelCode == nil)
        #expect(report.serialNumber == nil)
        #expect(report.callSign == nil)
        #expect(report.dimensionToBow == nil)
        #expect(report.dimensionToStern == nil)
        #expect(report.dimensionToPort == nil)
        #expect(report.dimensionToStarboard == nil)
        #expect(report.mothershipMMSI == nil)
        #expect(report.spare2 == nil)

        print(report.description())
    }

    private static let staticDataReportPartB = "!AIVDM,1,1,,B,H>DQ@04N6DeihhlPPPPPPP000000,0*0E"

    @Test func decodesPartBStaticDataReport() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.staticDataReportPartB),
                                    "The example sentence should parse as a valid AIS sentence")

        #expect(sentence.channel == .B)
        #expect(sentence.payloadBits.count == 168)

        let report = try #require(StaticDataReport(nmea: sentence),
                                  "A Type 24 payload should initialize a StaticDataReport")

        #expect(report.messageType.rawValue == 24)
        #expect(report.mmsiNumber.value == 961040384)
        #expect(report.part == .b)

        #expect(report.shipType == .fishing)

        #expect(report.vendorID?.text == "FT-1004")
        #expect(report.unitModelCode == nil)
        #expect(report.serialNumber == nil)
        
        #expect(report.callSign?.text == "       ")
        #expect(report.callSign?.text.trimmingCharacters(in: [" "]) == "")

        #expect(report.mothershipMMSI == nil)
        #expect(report.dimensionToBow == 0)
        #expect(report.dimensionToStern == 0)
        #expect(report.dimensionToPort == 0)
        #expect(report.dimensionToStarboard == 0)

        #expect(report.spare2 == 0)

        #expect(report.vesselName == nil)
        #expect(report.spare == nil)

        print(report.description())
    }

    private static let staticDataReportPairPartA = "!AIVDM,1,1,,A,H42O55i18tMET00000000000000,2*6D"
    private static let staticDataReportPairPartB = "!AIVDM,1,1,,A,H42O55lti4hhhilD3nink000?050,0*40"

    @Test func decodesStaticDataReportPair() throws {
        let sentenceA = try #require(AISNMEA0183Sentence(raw: Self.staticDataReportPairPartA),
                                     "The Part A sentence should parse as a valid AIS sentence")
        let sentenceB = try #require(AISNMEA0183Sentence(raw: Self.staticDataReportPairPartB),
                                     "The Part B sentence should parse as a valid AIS sentence")

        #expect(sentenceA.channel == .A)
        #expect(sentenceB.channel == .A)
        #expect(sentenceA.payloadBits.count == 160)
        #expect(sentenceB.payloadBits.count == 168)

        let partA = try #require(StaticDataReport(nmea: sentenceA),
                                 "A Type 24 payload should initialize a StaticDataReport")
        let partB = try #require(StaticDataReport(nmea: sentenceB),
                                 "A Type 24 payload should initialize a StaticDataReport")

        #expect(partA.mmsiNumber.value == 271041815)
        #expect(partB.mmsiNumber.value == 271041815)
        #expect(partA.mmsiNumber.country == "Republic of Turkiye")

        #expect(partA.messageType.rawValue == 24)
        #expect(partB.messageType.rawValue == 24)
        #expect(partA.part == .a)
        #expect(partB.part == .b)

        #expect(partA.vesselName?.text == "PROGUY@@@@@@@@@@@@@@")
        #expect(partA.vesselName?.text.trimmingCharacters(in: ["@"]) == "PROGUY")
        #expect(partA.spare == nil)
        #expect(partA.shipType == nil)
        #expect(partA.vendorID == nil)
        #expect(partA.callSign == nil)

        #expect(partB.shipType == .passenger)

        #expect(partB.vendorID?.text == "1D00014")
        #expect(partB.unitModelCode == nil)
        #expect(partB.serialNumber == nil)

        #expect(partB.callSign?.text == "TC6163@")
        #expect(partB.callSign?.text.trimmingCharacters(in: ["@"]) == "TC6163")

        #expect(partB.mothershipMMSI == nil)
        #expect(partB.dimensionToBow == 0)
        #expect(partB.dimensionToStern == 15)
        #expect(partB.dimensionToPort == 0)
        #expect(partB.dimensionToStarboard == 5)
        #expect((partB.dimensionToBow ?? 0) + (partB.dimensionToStern ?? 0) == 15)
        #expect((partB.dimensionToPort ?? 0) + (partB.dimensionToStarboard ?? 0) == 5)

        #expect(partB.spare2 == 0)
        #expect(partB.vesselName == nil)

        print(partA.description())
        print(partB.description())
    }

    private static let staticDataReportMothership = "!AIVDO,1,1,,A,H>W@vFTe6??406t2??21J0Wg8Jb0,0*6F"
    // Note: This is a synthetic message designed to trigger the mothership's MMSI path. I couldn't find a real one
    @Test func decodesMothershipStaticDataReport() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.staticDataReportMothership),
                                    "The example sentence should parse as a valid AIS sentence")

        #expect(sentence.dataSource == .ownShip)
        #expect(sentence.channel == .A)
        #expect(sentence.payloadBits.count == 168)

        let report = try #require(StaticDataReport(nmea: sentence),
                                  "A Type 24 payload should initialize a StaticDataReport")

        #expect(report.messageType.rawValue == 24)
        #expect(report.mmsiNumber.value == 980696666)
        #expect(report.part == .b)

        #expect(report.shipType == .highSpeedCraftReserved45)

        #expect(report.vendorID?.text == "FOO")
        #expect(report.unitModelCode == 1)
        #expect(report.serialNumber == 444)

        #expect(report.callSign?.text == "BOOBAZ@")
        #expect(report.callSign?.text.trimmingCharacters(in: ["@"]) == "BOOBAZ")

        // "98"-prefixed MMSI marks an auxiliary craft, so this slot holds the mothership's MMSI
        // Online decoders get this wrong, however https://www.aiscatcher.org/tools/nmea-decoder does it properly, and I used that to generate the ground truth.
        let mothershipMMSI = try #require(report.mothershipMMSI,
                                          "A \"98\"-prefixed MMSI should decode a mothership MMSI")
        #expect(mothershipMMSI.value == 666666666)
        #expect(report.dimensionToBow == nil)
        #expect(report.dimensionToStern == nil)
        #expect(report.dimensionToPort == nil)
        #expect(report.dimensionToStarboard == nil)

        #expect(report.spare2 == 0)
        
        #expect(report.vesselName == nil)
        #expect(report.spare == nil)

        print(report.description())
    }
}
