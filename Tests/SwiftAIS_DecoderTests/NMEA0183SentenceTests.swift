//
//  NMEA0183SentenceTests.swift
//  SwiftAIS-Decoder
//

import Testing
@testable import SwiftAIS_Decoder

// The fixtures below are real AIVDM/AIVDO sentences. Their "*HH" checksums are
// standard NMEA 0183 checksums: the XOR of every character between the leading
// "!"/"$" delimiter and the "*", matching the current verifyChecksum() logic.

struct NMEA0183SentenceTests {

    // Real AIS sentences with valid standard checksums.
    private static let realVDM = "!AIVDM,1,1,,B,15M67FC000G?ufbE`FepT@000000,0*33"
    private static let realVDM2 = "!AIVDM,1,1,,A,13aEOK?P00PD2wVMdLDRhgvL289?,0*26"
    private static let realVDO = "!AIVDO,1,1,,A,B6CdCm0t3`tba35f@V9faHi7kP06,0*5A"

    // MARK: - NMEA0183Sentence checksum

    @Test func validChecksumSucceeds() throws {
        let sentence = try NMEA0183Sentence(raw: Self.realVDM)
        #expect(sentence.raw == Self.realVDM, "raw should be stored verbatim")
    }

    @Test func validChecksumTrailingWhitespaceTolerated() {
        // Checksums are trimmed of trailing whitespace/newlines before parsing.
        #expect(throws: Never.self, "A trailing CRLF after the checksum should be tolerated") {
            try NMEA0183Sentence(raw: Self.realVDM + "\r\n")
        }
    }

    @Test func invalidChecksumFails() {
        // Same body as realVDM but with a checksum that does not match.
        #expect(throws: NMEASentenceError.checksumMismatch(expected: 0x00, calculated: 0x33)) {
            try NMEA0183Sentence(raw: "!AIVDM,1,1,,B,15M67FC000G?ufbE`FepT@000000,0*00")
        }
    }

    @Test func missingDelimiterFails() {
        #expect(throws: NMEASentenceError.badTag("AIVDM")) {
            try NMEA0183Sentence(raw: "AIVDM,1,1,,B,15M67FC000G?ufbE`FepT@000000,0*33")
        }
    }

    @Test func missingChecksumFails() {
        #expect(throws: NMEASentenceError.invalidField(name: "checksum", value: "<missing>")) {
            try NMEA0183Sentence(raw: "!AIVDM,1,1,,B,15M67FC000G?ufbE`FepT@000000,0")
        }
    }

    @Test func wrongChecksumLengthFails() {
        #expect(throws: NMEASentenceError.invalidField(name: "checksum", value: "3")) {
            try NMEA0183Sentence(raw: "!AIVDM,1,1,,B,15M67FC000G?ufbE`FepT@000000,0*3")
        }
    }

    @Test func nonHexChecksumFails() {
        #expect(throws: NMEASentenceError.invalidField(name: "checksum", value: "ZZ")) {
            try NMEA0183Sentence(raw: "!AIVDM,1,1,,B,15M67FC000G?ufbE`FepT@000000,0*ZZ")
        }
    }

    // MARK: - AISNMEA0183Sentence parsing

    @Test func realVDMParsesTalkerAndDataSource() throws {
        let sentence = try AISNMEA0183Sentence(raw: Self.realVDM)
        #expect(sentence.talker == .mobileStation)
        #expect(sentence.dataSource == .otherShip)
        #expect(sentence.raw == Self.realVDM)
    }

    @Test func secondRealVDMParses() throws {
        let sentence = try AISNMEA0183Sentence(raw: Self.realVDM2)
        #expect(sentence.talker == .mobileStation)
        #expect(sentence.dataSource == .otherShip)
    }

    @Test func realVDOParsesOwnShip() throws {
        let sentence = try AISNMEA0183Sentence(raw: Self.realVDO)
        #expect(sentence.talker == .mobileStation)
        #expect(sentence.dataSource == .ownShip)
    }

    @Test func nonAISTalkerParses() throws {
        // A base-station talker ("AB") with a recomputed valid checksum.
        let raw = "!ABVDM,1,1,,B,16S`2cPP00a3UF6EKT@2:?vOr0S2,0*0B"
        let sentence = try AISNMEA0183Sentence(raw: raw)
        #expect(sentence.talker == .baseStation)
        #expect(sentence.dataSource == .otherShip)
    }

    @Test func missingDelimiterFailsAISParsing() {
        // The first field must begin with "!"/"$"; without it the tag can't be read.
        #expect(throws: NMEASentenceError.badTag("AIVDM")) {
            try AISNMEA0183Sentence(raw: "AIVDM,1,1,,B,15M67FC000G?ufbE`FepT@000000,0*33")
        }
    }

    @Test func unknownTalkerFails() {
        #expect(throws: NMEASentenceError.unknownTalker("ZZ")) {
            try AISNMEA0183Sentence(raw: "!ZZVDM,1,1,,B,15M67FC000G?ufbE`FepT@000000,0*3B")
        }
    }

    @Test func unknownDataSourceFails() {
        #expect(throws: NMEASentenceError.unknownDataSource("XXX")) {
            try AISNMEA0183Sentence(raw: "!AIXXX,1,1,,B,15M67FC000G?ufbE`FepT@000000,0*34")
        }
    }

    @Test func wrongTagLengthFails() {
        // "!AIVD" leaves a 4-character tag after dropping the delimiter.
        #expect(throws: NMEASentenceError.badTag("!AIVD")) {
            try AISNMEA0183Sentence(raw: "!AIVD,1,1,,B,15M67FC000G?ufbE`FepT@000000,0*7E")
        }
    }

    @Test func emptyRawFails() {
        #expect(throws: NMEASentenceError.badTag("")) {
            try AISNMEA0183Sentence(raw: "")
        }
    }

    @Test func validTagButBadChecksumFails() {
        // Talker/data source are valid, but the checksum is wrong, so the sentence is rejected before its fields are parsed.
        #expect(throws: NMEASentenceError.checksumMismatch(expected: 0x00, calculated: 0x33)) {
            try AISNMEA0183Sentence(raw: "!AIVDM,1,1,,B,15M67FC000G?ufbE`FepT@000000,0*00")
        }
    }

    @Test func bitstringsFromSentences() throws {
        let sentence1Raw = "!AIVDM,1,1,,B,177KQJ5000G?tO`K>RA1wUbN0TKH,0*5C"
        let sentence1Binary = "000001000111000111011011100001011010000101000000000000000000010111001111111100011111101000011011001110100010010001000001111111100101101010011110000000100100011011011000"
        let sentence1 = try AISNMEA0183Sentence(raw: sentence1Raw)
        #expect(sentence1Binary == sentence1.payloadBits.getBitstring())

        let sentence2Raw = "!AIVDM,1,1,,A,13u?etPv2;0n:dDPwUM1U1Cb069D,0*24"
        let sentence2Binary = "000001000011111101001111101101111100100000111110000010001011000000110110001010101100010100100000111111100101011101000001100101000001010011101010000000000110001001010100"
        let sentence2 = try AISNMEA0183Sentence(raw: sentence2Raw)
        #expect(sentence2Binary == sentence2.payloadBits.getBitstring())

        let sentence3Raw = "!AIVDM,1,1,,A,402;bFQv@kkLc00Dl4LE52100@J6,0*58"
        let sentence3Binary = "000100000000000010001011101010010110100001111110010000110011110011011100101011000000000000010100110100000100011100010101000101000010000001000000000000010000011010000110"
        let sentence3 = try AISNMEA0183Sentence(raw: sentence3Raw)
        #expect(sentence3Binary == sentence3.payloadBits.getBitstring())

        let sentence4Raw = "!AIVDM,1,1,,A,B6CdCm0t3`tba35f@V9faHi7kP06,0*58"
        let sentence4Binary = "010010000110010011101100010011110101000000111100000011101000111100101010101001000011000101101110010000100110001001101110101001011000110001000111110011100000000000000110"
        let sentence4 = try AISNMEA0183Sentence(raw: sentence4Raw)
        #expect(sentence4Binary == sentence4.payloadBits.getBitstring())

        let sentence5Raw = "!AIVDM,1,1,,A,H42O55i18tMET00000000000000,2*6D"
        let sentence5Binary = "0110000001000000100111110001010001011100010000010010001111000111010101011001000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        let sentence5 = try AISNMEA0183Sentence(raw: sentence5Raw)
        #expect(sentence5Binary == sentence5.payloadBits.getBitstring())
    }

    // MARK: - Enum descriptions

    @Test func talkerRawValuesAndDescriptions() {
        #expect(AISTalker(rawValue: "AI") == .mobileStation)
        #expect(AISTalker(rawValue: "ZZ") == nil, "Unknown codes should not map to a talker")
    }

    @Test func dataSourceRawValuesAndDescriptions() {
        #expect(AISDataSource(rawValue: "VDM") == .otherShip)
        #expect(AISDataSource(rawValue: "VDO") == .ownShip)
    }
}
