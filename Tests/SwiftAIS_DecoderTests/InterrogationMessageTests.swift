//
//  InterrogationMessageTests.swift
//  SwiftAIS-Decoder
//
//  Tests for the InterrogationMessage parser (message type 15).
//

import Testing
@testable import SwiftAIS_Decoder

struct InterrogationMessageTests {

    // Type 15 interrogation. Expected values cross-checked against a known-good decoder.
    private static let interrogation = "!AIVDM,1,1,,A,?5OP=l00052HD00,2*5B"

    @Test func decodesInterrogation() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.interrogation),
                                    "The example sentence should parse as a valid AIS sentence")

        #expect(sentence.channel == .A)
        #expect(sentence.payloadBits.count == 88)

        let report = try #require(InterrogationMessage(nmea: sentence),
                                  "A Type 15 payload should initialize an InterrogationMessage")

        #expect(report.messageType.rawValue == 15)
        #expect(report.mmsiNumber.value == 368578000)
        #expect(report.interrogatedMMSI_1.value == 5158)
        #expect(report.requestedMessageType_1 == .staticAndVoyageRelatedData)
        #expect(report.slotOffset_1 == 0)
        #expect(report.spare_1 == 0)

        // The message ends at 88 bits, so no second request and no second station
        #expect(report.spare_2 == nil)
        #expect(report.requestedMessageType_2 == nil)
        #expect(report.slotOffset_2 == nil)
        #expect(report.spare_3 == nil)
        #expect(report.interrogatedMMSI_2 == nil)
        #expect(report.requestedMessageType_3 == nil)
        #expect(report.slotOffset_3 == nil)
        #expect(report.spare_4 == nil)

        print(report.description())
    }

    // Another 88-bit interrogation, this time of a station with an allocated MID.
    private static let secondInterrogation = "!AIVDM,1,1,,A,?5N29b18w<3PD00,2*6C"

    @Test func decodesSecondInterrogation() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.secondInterrogation),
                                    "The example sentence should parse as a valid AIS sentence")

        #expect(sentence.channel == .A)
        #expect(sentence.payloadBits.count == 88)

        let report = try #require(InterrogationMessage(nmea: sentence),
                                  "A Type 15 payload should initialize an InterrogationMessage")

        #expect(report.messageType.rawValue == 15)
        #expect(report.mmsiNumber.value == 367036840)
        #expect(report.interrogatedMMSI_1.value == 306131000)
        #expect(report.requestedMessageType_1 == .staticAndVoyageRelatedData)
        #expect(report.slotOffset_1 == 0)
        #expect(report.spare_1 == 0)

        // Ends at 88 bits, same as above
        #expect(report.requestedMessageType_2 == nil)
        #expect(report.slotOffset_2 == nil)
        #expect(report.interrogatedMMSI_2 == nil)
        #expect(report.requestedMessageType_3 == nil)
        #expect(report.slotOffset_3 == nil)

        print(report.description())
    }

    // A 112-bit interrogation on channel B asking one station for two message types.
    // The payload stops two bits into the second station's block, so there is no second
    // interrogated MMSI. Decoders that report "Destination ID #2 = 0" are inventing a station that
    // was never addressed; the parser leaves interrogatedMMSI_2 nil instead.
    private static let twoRequestsOneStation = "!AIVDM,1,1,,B,?h3Ovn1GP<K0<P@59a0,2*04"

    @Test func decodesTwoRequestsFromOneStation() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.twoRequestsOneStation),
                                    "The example sentence should parse as a valid AIS sentence")

        #expect(sentence.channel == .B)
        #expect(sentence.payloadBits.count == 112)

        let report = try #require(InterrogationMessage(nmea: sentence),
                                  "A Type 15 payload should initialize an InterrogationMessage")

        #expect(report.messageType.rawValue == 15)
        #expect(report.mmsiNumber.value == 3669720)

        // Both requests are addressed to the one interrogated station
        #expect(report.interrogatedMMSI_1.value == 367014320)
        #expect(report.requestedMessageType_1 == .positionReportClassAResponseToInterrogation)
        #expect(report.slotOffset_1 == 516)
        #expect(report.requestedMessageType_2 == .staticAndVoyageRelatedData)
        #expect(report.slotOffset_2 == 617)

        // No second station: the payload ends before the bit 110 MMSI field is complete
        #expect(report.interrogatedMMSI_2 == nil)
        #expect(report.requestedMessageType_3 == nil)
        #expect(report.slotOffset_3 == nil)

        print(report.description())
    }

    // A real type 15 whose first requested message type is 0, which is not a valid AIS message
    // type. Everything else decodes cleanly, but an interrogation that names no valid message type
    // carries no instruction, so it is malformed and the parser rejects the whole sentence rather
    // than reporting a partial result.
    private static let zeroRequestedMessageType = "!AIVDM,1,1,,A,?h3Owpi;Etq0000,2*1A"

    @Test func rejectsZeroRequestedMessageType() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.zeroRequestedMessageType),
                                    "The example sentence should parse as a valid AIS sentence")

        // The sentence itself is a well-formed type 15; only the requested type field is bad.
        let messageTypeBits: UInt8 = try #require(sentence.payloadBits[0...5])
        #expect(messageTypeBits == 15)
        let requestedMessageTypeBits: UInt8 = try #require(sentence.payloadBits[70...75])
        #expect(requestedMessageTypeBits == 0)

        #expect(InterrogationMessage(nmea: sentence) == nil)
    }
}
