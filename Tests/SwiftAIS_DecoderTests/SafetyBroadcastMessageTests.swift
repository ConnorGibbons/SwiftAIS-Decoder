//
//  SafetyBroadcastMessageTests.swift
//  SwiftAIS-Decoder
//
//  Tests for the SafetyBroadcastMessage parser (message type 14).
//

import Testing
@testable import SwiftAIS_Decoder

struct SafetyBroadcastMessageTests {

    // Type 14 safety-related broadcast from a vessel, padded with 2 fill bits.
    // Expected values cross-checked against a known-good decoder
    private static let safetyBroadcastMessage = "!AIVDM,1,1,,A,>5?Per18=HB1U:1@E=B0m<L,2*51"

    @Test func decodesSafetyBroadcastMessage() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.safetyBroadcastMessage),
                                    "The example sentence should parse as a valid AIS sentence")
        #expect(sentence.channel == .A)
        #expect(sentence.fillBits == 2)

        let report = try #require(SafetyBroadcastMessage(nmeaSentences: [sentence]),
                                  "A Type 14 payload should initialize a SafetyBroadcastMessage")

        #expect(report.messageType.rawValue == 14)
        #expect(report.mmsiNumber.value == 351809000)
        #expect(report.spare == 0)

        // Safety-related text — the fill bits leave a partial trailing character that shouldn't be decoded
        let text = try #require(report.text, "The payload should decode as 6-bit ASCII")
        #expect(text.text == "RCVD YR TEST MSG")

        // Only one fragment, so there shouldn't be any additional sentences
        #expect(report.additionalSentences == nil)

        print(report.description())
    }

    // Longer Type 14 broadcast, also padded with 2 fill bits.
    // Expected values cross-checked against a known-good decoder
    private static let longSafetyBroadcastMessage = "!AIVDM,1,1,,A,>3R1p10E3;;R0USCR0HO>0@gN10kGJp,2*7F"

    @Test func decodesLongSafetyBroadcastMessage() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.longSafetyBroadcastMessage),
                                    "The example sentence should parse as a valid AIS sentence")
        #expect(sentence.channel == .A)
        #expect(sentence.fillBits == 2)

        let report = try #require(SafetyBroadcastMessage(nmeaSentences: [sentence]),
                                  "A Type 14 payload should initialize a SafetyBroadcastMessage")

        #expect(report.messageType.rawValue == 14)
        #expect(report.mmsiNumber.value == 237008900)
        #expect(report.spare == 0)

        // Safety-related text — 24 whole characters, including punctuation
        let text = try #require(report.text, "The payload should decode as 6-bit ASCII")
        #expect(text.text == "EP228 IX48 FG3 DK7 PL56.")
        #expect(report.additionalSentences == nil)

        print(report.description())
    }

    // Two-part Type 14 broadcast whose text spans both fragments. The text is binary garbage rather
    // than anything readable, which makes it a useful check that arbitrary 6-bit values round-trip.
    // Expected values cross-checked against a known-good decoder
    private static let multipartSafetyBroadcastMessage1 = "!AIVDM,2,1,0,A,>MIv3elkWG;9M?vTgOao95OQgAva9qSSdfT2IkhFV5C,0*4F"
    private static let multipartSafetyBroadcastMessage2 = "!AIVDM,2,2,0,A,T,0*42"

    @Test func decodesMultipartSafetyBroadcastMessage() throws {
        let sentence1 = try #require(AISNMEA0183Sentence(raw: Self.multipartSafetyBroadcastMessage1),
                                     "The first fragment should parse as a valid AIS sentence")
        let sentence2 = try #require(AISNMEA0183Sentence(raw: Self.multipartSafetyBroadcastMessage2),
                                     "The second fragment should parse as a valid AIS sentence")
        let report = try #require(SafetyBroadcastMessage(nmeaSentences: [sentence1, sentence2]),
                                  "A Type 14 payload should initialize a SafetyBroadcastMessage")

        #expect(report.messageType.rawValue == 14)
        #expect(report.mmsiNumber.value == 899646391)

        // Spare — 1 for this message, unlike the single-fragment examples above
        #expect(report.spare == 1)

        // The trailing fragment should be kept alongside the first
        #expect(report.additionalSentences?.count == 1)

        // Safety-related text — assembled from both fragments. 264 payload bits total, so 224 bits
        // of text: 37 whole characters with 2 bits left over.
        let text = try #require(report.text, "The payload should decode as 6-bit ASCII")
        #expect(text.text == "L9522WS?)K7:]2QW8[4_*R^X8;K)@&\\<E)!T9")

        print(report.description())
    }

    // A Type 12 (AddresedSafetyMessage) sentence should be rejected on the message ID.
    private static let addressedSafetyMessage = "!AIVDM,1,1,,A,<5?SIj5Cp;NPD81>H0,4*4C"

    @Test func rejectsNonSafetyBroadcastMessage() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.addressedSafetyMessage),
                                    "The example sentence should parse as a valid AIS sentence")
        #expect(SafetyBroadcastMessage(nmeaSentences: [sentence]) == nil)
    }

    @Test func rejectsEmptySentenceList() {
        #expect(SafetyBroadcastMessage(nmeaSentences: []) == nil)
    }
}
