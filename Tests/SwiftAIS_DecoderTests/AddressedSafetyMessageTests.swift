//
//  AddressedSafetyMessageTests.swift
//  SwiftAIS-Decoder
//
//  Tests for the AddresedSafetyMessage parser (message type 12).
//

import Testing
@testable import SwiftAIS_Decoder

struct AddressedSafetyMessageTests {

    // Type 12 safety-related message from a base station to a vessel.
    // Expected values cross-checked against a known-good decoder
    private static let addressedSafetyMessage = "!AIVDM,1,1,,A,<02:oP0kKcv0@<51C5PB5@?BDPD?P:?2?EB7PDB16693P381>>5<PikP,0*37"

    @Test func decodesAddressedSafetyMessage() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.addressedSafetyMessage),
                                    "The example sentence should parse as a valid AIS sentence")
        let report = try #require(AddresedSafetyMessage(nmeaSentences: [sentence]),
                                  "A Type 12 payload should initialize an AddresedSafetyMessage")

        #expect(report.messageType.rawValue == 12)
        #expect(report.mmsiNumber.value == 2275200)
        #expect(report.sequenceNumber == 0)
        #expect(report.destinationMMSI.value == 215724000)
        #expect(report.retransmit == .notRetransmitted)
        #expect(report.spare == false)

        let text = try #require(report.text, "The payload should decode as 6-bit ASCII")
        #expect(text.text.trimmingCharacters(in: [" "]) == "PLEASE REPORT TO JOBOURG TRAFFIC CHANNEL 13")

        // Only one fragment, so there shouldn't be any additional sentences
        #expect(report.additionalSentences == nil)

        print(report.description())
    }

    // Short Type 12 message between two vessels, padded with 4 fill bits.
    // Expected values cross-checked against a known-good decoder
    private static let shortAddressedSafetyMessage = "!AIVDM,1,1,,A,<5?SIj5Cp;NPD81>H0,4*4C"

    @Test func decodesShortAddressedSafetyMessage() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.shortAddressedSafetyMessage),
                                    "The example sentence should parse as a valid AIS sentence")
        #expect(sentence.channel == .A)
        #expect(sentence.fillBits == 4)

        let report = try #require(AddresedSafetyMessage(nmeaSentences: [sentence]),
                                  "A Type 12 payload should initialize an AddresedSafetyMessage")

        #expect(report.messageType.rawValue == 12)
        #expect(report.mmsiNumber.value == 351853000)
        #expect(report.sequenceNumber == 1)
        #expect(report.destinationMMSI.value == 351809000)
        #expect(report.retransmit == .notRetransmitted)
        #expect(report.spare == false)

        // Safety-related text — the fill bits leave a partial trailing character that shouldn't be decoded
        let text = try #require(report.text, "The payload should decode as 6-bit ASCII")
        #expect(text.text == "THANX")

        print(report.description())
    }

    // Retransmitted Type 12 message between two vessels sharing a MID.
    // Expected values cross-checked against a known-good decoder
    private static let retransmittedAddressedSafetyMessage = "!AIVDM,1,1,,A,<42Lati0W:Ov=C7P6B?=Pjoihhjhqq0,2*2B"

    @Test func decodesRetransmittedAddressedSafetyMessage() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.retransmittedAddressedSafetyMessage),
                                    "The example sentence should parse as a valid AIS sentence")
        #expect(sentence.channel == .A)
        #expect(sentence.fillBits == 2)

        let report = try #require(AddresedSafetyMessage(nmeaSentences: [sentence]),
                                  "A Type 12 payload should initialize an AddresedSafetyMessage")

        #expect(report.messageType.rawValue == 12)
        #expect(report.mmsiNumber.value == 271002099)
        #expect(report.sequenceNumber == 0)
        #expect(report.destinationMMSI.value == 271002111)
        #expect(report.retransmit == .retransmitted)
        #expect(report.spare == false)

        // Safety-related text — 112 payload bits, so the trailing 4 bits are not a whole character
        let text = try #require(report.text, "The payload should decode as 6-bit ASCII")
        #expect(text.text == "MSG FROM 271002099")

        print(report.description())
    }

    // Two-part Type 12 message whose text spans both fragments.
    // Expected values cross-checked against a known-good decoder
    private static let multipartAddressedSafetyMessage1 = "!AIVDM,2,1,1,A,<39KdV8jIGtP7E4P@=PjEP>P81@9P>5GPI9BP?<P4P25CP6B=P1<P6E:19B1,0*02"
    private static let multipartAddressedSafetyMessage2 = "!AIVDM,2,2,1,A,80,4*1B"

    @Test func decodesMultipartAddressedSafetyMessage() throws {
        let sentence1 = try #require(AISNMEA0183Sentence(raw: Self.multipartAddressedSafetyMessage1),
                                     "The first fragment should parse as a valid AIS sentence")
        let sentence2 = try #require(AISNMEA0183Sentence(raw: Self.multipartAddressedSafetyMessage2),
                                     "The second fragment should parse as a valid AIS sentence")
        let report = try #require(AddresedSafetyMessage(nmeaSentences: [sentence1, sentence2]),
                                  "A Type 12 payload should initialize an AddresedSafetyMessage")

        #expect(report.messageType.rawValue == 12)
        #expect(report.mmsiNumber.value == 211217560)
        #expect(report.sequenceNumber == 2)
        #expect(report.destinationMMSI.value == 211378120)
        #expect(report.retransmit == .notRetransmitted)
        #expect(report.spare == false)

        // The trailing fragment should be kept alongside the first
        #expect(report.additionalSentences?.count == 1)

        let text = try #require(report.text, "The payload should decode as 6-bit ASCII")
        #expect(text.text == "GUD PM 2U N HAPI NEW YIR OL D BES FRM AL FUJAIRAH")

        print(report.description())
    }
}
