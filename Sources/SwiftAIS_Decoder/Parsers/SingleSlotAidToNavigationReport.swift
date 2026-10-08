//
//  SingleSlotAidToNavigationReport.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/23/26.
//
//  Type 28: Single Slot Aid to Navigation Report
//  Payload Character: L
//  AtoN report, like type 21, but small enough to occupy only one OTA slot, very recent message type

import SignalTools

public struct SingleSlotAidToNavigationReport: AISMessage {
    public let nmeaSentence: AISNMEA0183Sentence
    public let messageType: AISMessageType
    public let mmsiNumber: MMSI
    
    public let timeStamp: TimeStamp
    public let longitude: Longitude
    public let latitude: Latitude
    public let restrictedUseIndicator: RestrictedUseIndicator
    public let stationType: AtoNStationType
    public let aidType: AtoNType
    public let marineResourceName: UInt32 // 17-bit IALA identification number
    public let dimensions: AtoNDimensions
    public let chartedStatus: AtoNChartedStatus
    public let onStationStatus: AtoNOnStationStatus
    public let regionalReserved: UInt8 // This does actually have a meaning in the spec, as does the same field in type 21, but it seems to be region dependent
    public let spare: UInt8 // "Not uses" (lol) and should be 0
    public let authenticationFlag: AuthenticationFlag
    
    public init(nmea: AISNMEA0183Sentence) throws(AISDecodingError) {
        let bits = nmea.payloadBits
        self.nmeaSentence = nmea

        let messageType: AISMessageType = try bits.read(0...5, "messageType")
        guard messageType.rawValue == 28 else { throw .unexpectedMessageType(messageType.rawValue, expected: [28]) }
        self.messageType = messageType

        let mmsiBits: UInt32 = try bits.read(8...37, "mmsiNumber")
        guard let mmsi = MMSI(value: mmsiBits) else { throw .invalidValue(field: "mmsiNumber", rawValue: UInt64(mmsiBits)) }
        self.mmsiNumber = mmsi

        self.timeStamp = TimeStamp(rawValue: try bits.read(38...43, "timeStamp"))
        self.longitude = Longitude(rawValue: try bits.read(44...71, "longitude"))
        self.latitude = Latitude(rawValue: try bits.read(72...98, "latitude"))
        self.restrictedUseIndicator = try bits.read(99...100, "restrictedUseIndicator")
        self.stationType = try bits.read(101...103, "stationType")
        self.aidType = try bits.read(104...110, "aidType")
        self.marineResourceName = try bits.read(111...127, "marineResourceName")

        let dimensionType: AtoNDimensionType = try bits.read(128...131, "dimensionType")
        let dimensionABits: UInt16 = try bits.read(132...140, "dimensionA")
        let dimensionBBits: UInt16 = try bits.read(141...151, "dimensionB")
        let additionalDataFlag: Bool = try bits.read(152, "additionalDataFlag")
        guard let dimensions = AtoNDimensions(type: dimensionType, additionalDataFlag: additionalDataFlag, a: dimensionABits, b: dimensionBBits) else {
            throw .invalidValue(field: "dimensions", rawValue: (UInt64(dimensionABits) << 11) | UInt64(dimensionBBits)) // A and B are the only fields AtoNDimensions can reject
        }
        self.dimensions = dimensions

        self.chartedStatus = try bits.read(153...153, "chartedStatus")
        self.onStationStatus = try bits.read(154...157, "onStationStatus")
        self.regionalReserved = try bits.read(158...165, "regionalReserved")
        self.spare = try bits.read(166...166, "spare")
        self.authenticationFlag = AuthenticationFlag(rawValue: try bits.read(167, "authenticationFlag"))
    }
    
    public func description() -> String {
        return ([
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Timestamp:", timeStamp.description),
            row("Latitude:", latitude.description),
            row("Longitude:", longitude.description),
            row("Restricted Use:", restrictedUseIndicator.description),
            row("Station Type:", stationType.description),
            row("Aid Type:", aidType.description),
            row("Marine Resource Name:", "\(marineResourceName)"),
            row("Dimension Type:", dimensions.type.description),
            row("Dimensions:", dimensions.description),
            row("Charted Status:", chartedStatus.description),
            row("On-Station Status:", onStationStatus.description),
            row("Authentication:", authenticationFlag.description)
        ] as [String]).joined(separator: "\n")
    }
    
    
}
