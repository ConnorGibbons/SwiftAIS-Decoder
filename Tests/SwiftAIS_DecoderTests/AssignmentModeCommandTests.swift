//
//  AssignmentModeCommandTests.swift
//  SwiftAIS-Decoder
//
//  Tests for the AssignmentModeCommand parser (message type 16).
//

import Testing
@testable import SwiftAIS_Decoder

struct AssignmentModeCommandTests {

    // Type 16 assignment mode command. Expected values cross-checked against a known-good decoder.
    // The payload is 96 bits: one assigned station plus the four fill bits the spec inserts when a
    // single station is addressed. Decoders that report "Destination ID B = 0" are reading those fill
    // bits as a second station that was never addressed; the parser leaves destination2 nil instead.
    private static let assignmentModeCommand = "!AIVDM,1,1,,A,@01uEO@mMk7P<P00,0*18"

    @Test func decodesAssignmentModeCommand() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.assignmentModeCommand),
                                    "The example sentence should parse as a valid AIS sentence")

        #expect(sentence.channel == .A)
        #expect(sentence.payloadBits.count == 96)

        let report = try #require(AssignmentModeCommand(nmea: sentence),
                                  "A Type 16 payload should initialize an AssignmentModeCommand")

        #expect(report.messageType.rawValue == 16)
        #expect(report.mmsiNumber.value == 2053501)
        #expect(report.spare1 == 0)

        #expect(report.destination1.value == 224251000)
        #expect(report.offset1 == 200)
        #expect(report.increment1 == 0)

        // Only one station is assigned, so the second block is absent
        #expect(report.destination2 == nil)
        #expect(report.offset2 == nil)
        #expect(report.incrememt2 == nil)

        print(report.description())
    }

    // A full 144-bit command on channel B carrying both assignment blocks.
    // It's not really addressed at two stations however, they simply zeroed out the second destination.
    private static let twoAssignmentBlocks = "!AIVDM,1,1,,B,@h3OwhiGOl583h0000000500,0*30"

    @Test func decodesTwoAssignmentBlocks() throws {
        let sentence = try #require(AISNMEA0183Sentence(raw: Self.twoAssignmentBlocks),
                                    "The example sentence should parse as a valid AIS sentence")

        #expect(sentence.channel == .B)
        #expect(sentence.payloadBits.count == 144)

        let report = try #require(AssignmentModeCommand(nmea: sentence),
                                  "A Type 16 payload should initialize an AssignmentModeCommand")

        #expect(report.messageType.rawValue == 16)
        #expect(report.mmsiNumber.value == 3669955)
        #expect(report.spare1 == 0)

        // The parser doesn't expose the repeat indicator, so it's checked straight off the payload
        let repeatIndicator: UInt8 = try #require(sentence.payloadBits[6...7])
        #expect(repeatIndicator == 3)

        #expect(report.destination1.value == 366989394)
        #expect(report.offset1 == 60)
        #expect(report.increment1 == 0)

        // Second block: an all-zero MMSI, which is a valid MMSI value even though no station owns it
        #expect(report.destination2?.value == 0)
        #expect(report.offset2 == 20)
        #expect(report.incrememt2 == 0)

        print(report.description())
    }
    
    // I couldn't find an real world type 16 message that actually had two destination MMSIs. Probably just rarely used, if ever. If one ever comes up i'll put one in here.
    // If you're reading this and you have one, feel free to send it to me so i can test against it! connor@ccgibbons.com
}
