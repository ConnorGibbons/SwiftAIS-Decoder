//
//  ChannelManagementTests.swift
//  SwiftAIS-Decoder
//
//  Tests for the ChannelManagement parser (message type 22).
//

import Testing
@testable import SwiftAIS_Decoder

struct ChannelManagementTests {

    private static let broadcast = "!AIVDM,1,1,,A,F030owj2N2P6Ubib@=4q35b10000,0*58"

    @Test func decodesBroadcastChannelManagement() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.broadcast),
                                    "The example sentence should parse as a valid AIS sentence")

        #expect(sentence.channel == .A)

        let report = try #require(ChannelManagement(nmea: sentence),
                                  "A Type 22 payload should initialize a ChannelManagement")

        #expect(report.messageType.rawValue == 22)

        #expect(report.mmsiNumber.value == 3160063)

        #expect(report.channelA.channel == 2087)
        #expect(report.channelB.channel == 2088)

        #expect(report.txrx == .TxATxBRxARxB)
        #expect(report.power == .lowPower)

        #expect(report.addressed == .broadcast)
        #expect(report.dest1 == nil)
        #expect(report.dest2 == nil)

        let region = try #require(report.region)
        // tested against https://www.aggsoft.com/ais-decoder.htm, but their raw longitudes seem to consistently be 1 off. I adjusted the comaparison values here to not use theirs
        #expect(region.longitudeNE.degrees?.rounded(toPlaces: 6) == -77.083333)
        #expect(region.latitudeNE.degrees?.rounded(toPlaces: 6) == 45.333333)
        #expect(region.longitudeSW.degrees?.rounded(toPlaces: 6) == -79.833333)
        #expect(region.latitudeSW.degrees?.rounded(toPlaces: 6) == 42.166667)

        #expect(report.channelABandwidth == .default)
        #expect(report.channelBBandwidth == .default)
        #expect(report.zoneSize == 3)

        print(report.description())
    }

    private static let broadcast2 = "!AIVDM,1,1,,B,F030pC22N2P73FiiNesU3FR10000,0*16"

    @Test func decodesSecondBroadcastChannelManagement() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.broadcast2),
                                    "The example sentence should parse as a valid AIS sentence")

        #expect(sentence.channel == .B)

        let report = try #require(ChannelManagement(nmea: sentence),
                                  "A Type 22 payload should initialize a ChannelManagement")

        #expect(report.messageType.rawValue == 22)

        #expect(report.mmsiNumber.value == 3160140)

        #expect(report.channelA.channel == 2087)
        #expect(report.channelB.channel == 2088)

        #expect(report.txrx == .TxATxBRxARxB)
        #expect(report.power == .lowPower)

        #expect(report.addressed == .broadcast)
        #expect(report.dest1 == nil)
        #expect(report.dest2 == nil)

        // Reference values were 1 off for latitude/zone size, same as the other test in this file.
        let region = try #require(report.region)
        #expect(region.longitudeNE.degrees?.rounded(toPlaces: 6) == -51.75)
        #expect(region.latitudeNE.degrees?.rounded(toPlaces: 6) == 48.416667)
        #expect(region.longitudeSW.degrees?.rounded(toPlaces: 6) == -56.5)
        #expect(region.latitudeSW.degrees?.rounded(toPlaces: 6) == 45.766667)

        #expect(report.channelABandwidth == .default)
        #expect(report.channelBBandwidth == .default)
        #expect(report.zoneSize == 3) // https://www.aiscatcher.org/tools/nmea-decoder says 2, but I think they didn't implement the +1 behavior from the spec

        print(report.description())
    }
}
