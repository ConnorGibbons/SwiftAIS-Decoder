//
//  AISSatelliteMessageTests.swift
//  SwiftAIS-Decoder
//

import Testing
@testable import SwiftAIS_Decoder

struct AISSatelliteMessageTests {

    // Long range position report. Expected values cross-checked against an online decoder.
    private static let satelliteMessage = "!AIVDM,1,1,,B,K815>P8=5EikdUet,0*6B"
    private static let satelliteMessageTwo = "!AIVDM,1,1,,A,KrJN9vb@0?wl20RH,0*7A"

    @Test func decodesAISSatelliteMessage() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.satelliteMessage),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(AISSatelliteMessage(nmea: sentence),
                                  "A Type 27 payload should initialize an AISSatelliteMessage")

        #expect(sentence.channel == .B)
        #expect(report.messageType.rawValue == 27)
        #expect(report.mmsiNumber.value == 538005120)

        #expect(report.positionAccuracy == .highAccuracy)
        #expect(report.raimFlag == .notInUse)
        #expect(report.navigationStatus == .underWayUsingEngine)

        #expect(report.longitude.rawValue == -47785)
        let longitude = try #require(report.longitude.degrees)
        #expect(abs(longitude - -79.641667) < 0.00001)

        #expect(report.latitude.rawValue == 14809)
        let latitude = try #require(report.latitude.degrees)
        #expect(abs(latitude - 24.681667) < 0.00001)

        #expect(report.speedOverGround.rawValue == 11)
        #expect(report.speedOverGround.speedOverGround == 11)

        #expect(report.courseOverGround.rawValue == 223)
        let courseOverGround = try #require(report.courseOverGround.value)
        #expect(abs(courseOverGround - 223) < 0.00001)

        #expect(report.positionLatency == .under5Seconds)
        #expect(report.spare == 0)

        print(report.description())
    }

    @Test func decodesSecondAISSatelliteMessage() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.satelliteMessageTwo),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(AISSatelliteMessage(nmea: sentence),
                                  "A Type 27 payload should initialize an AISSatelliteMessage")

        #expect(sentence.channel == .A)
        #expect(report.messageType.rawValue == 27)
        #expect(report.mmsiNumber.value == 698845690)

        #expect(report.positionAccuracy == .highAccuracy)
        #expect(report.raimFlag == .notInUse)
        #expect(report.navigationStatus == .reservedForFutureHSC)

        #expect(report.longitude.rawValue == 63)
        let longitude = try #require(report.longitude.degrees)
        #expect(abs(longitude - 0.105) < 0.00001)

        // Negative latitude: the reference decoder reports -2.551667 (raw -1531), which is a one's
        // complement of the 17 bits. Two's complement gives -1532, which is what the spec calls for.
        #expect(report.latitude.rawValue == -1532)
        let latitude = try #require(report.latitude.degrees)
        #expect(abs(latitude - -2.553333) < 0.00001)

        #expect(report.speedOverGround.rawValue == 1)
        #expect(report.speedOverGround.speedOverGround == 1)

        #expect(report.courseOverGround.rawValue == 38)
        let courseOverGround = try #require(report.courseOverGround.value)
        #expect(abs(courseOverGround - 38) < 0.00001)

        #expect(report.positionLatency == .under5Seconds)
        #expect(report.spare == 0)

        print(report.description())
    }


}
