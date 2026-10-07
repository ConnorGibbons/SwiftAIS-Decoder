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

struct SingleSlotAidToNavigationReport: AISMessage {
    let nmeaSentence: AISNMEA0183Sentence
    let messageType: AISMessageType
    let mmsiNumber: MMSI
    
    let timeStamp: TimeStamp
    let longitude: Longitude
    let latitude: Latitude
    let restrictedUseIndicator: RestrictedUseIndicator
    let stationType: AtoNStationType
    let aidType: AtoNType
    let marineResourceName: UInt32 // 17-bit IALA identification number
    let dimensions: AtoNDimensions
    let chartedStatus: AtoNChartedStatus
    let onStationStatus: AtoNOnStationStatus
    let regionalReserved: UInt8 // This does actually have a meaning in the spec, as does the same field in type 21, but it seems to be region dependent
    let spare: UInt8 // "Not uses" (lol) and should be 0
    let authenticationFlag: AuthenticationFlag
    
    init?(nmea: AISNMEA0183Sentence) {
        let bits = nmea.payloadBits
        self.nmeaSentence = nmea
        
        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageTypeBits)) else { return nil }
        guard messageType.rawValue == 28 else { return nil }
        self.messageType = messageType
        
        guard let mmsiBits: UInt32 = bits[8...37] else { return nil }
        guard let mmsi = MMSI(value: mmsiBits) else { return nil }
        self.mmsiNumber = mmsi
        
        guard let timeStampBits: UInt8 = bits[38...43] else { return nil }
        let timeStamp = TimeStamp(rawValue: timeStampBits)
        self.timeStamp = timeStamp
        
        guard let longitudeBits: UInt32 = bits[44...71] else { return nil }
        let longitude = Longitude(rawValue: longitudeBits)
        self.longitude = longitude
        
        guard let latitudeBits: UInt32 = bits[72...98] else { return nil }
        let latitude = Latitude(rawValue: latitudeBits)
        self.latitude = latitude
        
        guard let restrictedUseBits: UInt8 = bits[99...100] else { return nil }
        guard let restrictedUseIndicator = RestrictedUseIndicator(rawValue: restrictedUseBits) else { return nil }
        self.restrictedUseIndicator = restrictedUseIndicator
        
        guard let stationTypeBits: UInt8 = bits[101...103] else { return nil }
        guard let stationType = AtoNStationType(rawValue: stationTypeBits) else { return nil }
        self.stationType = stationType
        
        guard let aidTypeBits: UInt8 = bits[104...110] else { return nil }
        guard let aidType = AtoNType(rawValue: aidTypeBits) else { return nil }
        self.aidType = aidType
        
        guard let marineResourceNameBits: UInt32 = bits[111...127] else { return nil }
        self.marineResourceName = marineResourceNameBits
        
        guard let dimensionTypeBits: UInt8 = bits[128...131] else { return nil }
        guard let dimensionType = AtoNDimensionType(rawValue: dimensionTypeBits) else { return nil }
        guard let dimensionABits: UInt16 = bits[132...140] else { return nil }
        guard let dimensionBBits: UInt16 = bits[141...151] else { return nil }
        guard let additionalDataFlagBit: UInt8 = bits[152...152] else { return nil }
        guard let dimensions = AtoNDimensions(type: dimensionType, additionalDataFlag: additionalDataFlagBit > 0, a: dimensionABits, b: dimensionBBits) else { return nil }
        self.dimensions = dimensions
        
        guard let chartedStatusBit: UInt8 = bits[153...153] else { return nil }
        guard let chartedStatus = AtoNChartedStatus(rawValue: chartedStatusBit) else { return nil }
        self.chartedStatus = chartedStatus
        
        guard let onStationStatusBits: UInt8 = bits[154...157] else { return nil }
        guard let onStationStatus = AtoNOnStationStatus(rawValue: onStationStatusBits) else { return nil }
        self.onStationStatus = onStationStatus

        guard let regionalReservedBits: UInt8 = bits[158...165] else { return nil }
        self.regionalReserved = regionalReservedBits
        
        guard let spareBit: UInt8 = bits[166...166] else { return nil }
        self.spare = spareBit
        
        guard let authenticationFlagBit: UInt8 = bits[167...167] else { return nil }
        self.authenticationFlag = AuthenticationFlag(rawValue: authenticationFlagBit > 0)
    }
    
    func description() -> String {
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
