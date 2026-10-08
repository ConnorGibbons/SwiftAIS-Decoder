//
//  AidToNavigationReport.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/3/26.
//
//  Type 21: Aid to Navigation Report (AtoN)
//  Payload Char: E

import SignalTools

public struct AidToNavigationReport: AISMessage {
    public let nmeaSentence: AISNMEA0183Sentence
    public let messageType: AISMessageType
    public let mmsiNumber: MMSI
    
    public let aidType: AtoNType
    public let name: AISText
    public let positionAccuracy: PositionAccuracy
    public let longitude: Longitude
    public let latitude: Latitude
    public let dimensionToBow: UInt16
    public let dimensionToStern: UInt16
    public let dimensionToPort: UInt8
    public let dimensionToStarboard: UInt8
    public let fixType: EPFDFixType
    public let timestamp: TimeStamp // UTC Second
    public let offPositionFlag: OffPositionFlag
    public let regionalReserved: UInt8 // Not sure what this is used for
    public let raimFlag: RAIMFlag
    public let virtualAidFlag: VirtualAidFlag
    public let assignedFlag: AssignedFlag
    public let spare: UInt8?
    public let nameExtension: AISText?
    
    public let additionalSentences: [AISNMEA0183Sentence]?
    
    public init(nmeaSentences: [AISNMEA0183Sentence]) throws(AISDecodingError) {
        guard nmeaSentences.count > 0 else { throw .payloadTooShort(field: "messageType", bits: 0..<6, available: 0) }
        self.nmeaSentence = nmeaSentences[0]
        
        var bits: BitBuffer = .init()
        if nmeaSentences.count > 1 {
            self.additionalSentences = Array(nmeaSentences.dropFirst())
        }
        else {
            self.additionalSentences = nil
        }
        for sentence in nmeaSentences {
            bits.append(contentsOf: sentence.payloadBits)
        }
        
        let messageType: AISMessageType = try bits.read(0...5, "messageType")
        guard messageType.rawValue == 21 else { throw .unexpectedMessageType(messageType.rawValue, expected: [21]) }
        self.messageType = messageType

        let mmsiBits: UInt32 = try bits.read(8...37, "mmsiNumber")
        guard let mmsi = MMSI(value: mmsiBits) else { throw .invalidValue(field: "mmsiNumber", rawValue: UInt64(mmsiBits)) }
        self.mmsiNumber = mmsi

        self.aidType = try bits.read(38...42, "aidType")

        let nameBits: BitBuffer = try bits.read(43...162, "name")
        guard let name = AISText(raw: nameBits) else { throw .invalidText(field: "name") }
        self.name = name

        self.positionAccuracy = try bits.read(163...163, "positionAccuracy")
        self.longitude = Longitude(rawValue: try bits.read(164...191, "longitude"))
        self.latitude = Latitude(rawValue: try bits.read(192...218, "latitude"))
        self.dimensionToBow = try bits.read(219...227, "dimensionToBow")
        self.dimensionToStern = try bits.read(228...236, "dimensionToStern")
        self.dimensionToPort = try bits.read(237...242, "dimensionToPort")
        self.dimensionToStarboard = try bits.read(243...248, "dimensionToStarboard")
        self.fixType = try bits.read(249...252, "fixType")
        self.timestamp = TimeStamp(rawValue: try bits.read(253...258, "timestamp"))
        self.offPositionFlag = OffPositionFlag(rawValue: try bits.read(259, "offPositionFlag"))
        self.regionalReserved = try bits.read(260...267, "regionalReserved")
        self.raimFlag = try bits.read(268...268, "raimFlag")
        self.virtualAidFlag = VirtualAidFlag(rawValue: try bits.read(269, "virtualAidFlag"))
        self.assignedFlag = AssignedFlag(rawValue: try bits.read(270, "assignedFlag"))
        
        if let spareBit: UInt8 = bits[271...271] {
            self.spare = spareBit
            if(bits.count > 272) {
                if let nameExtensionBits: BitBuffer = bits[272...(bits.count - 1)] {
                    if let nameExtension = AISText(raw: nameExtensionBits) {
                        self.nameExtension = nameExtension
                    } else {
                        self.nameExtension = nil
                    }
                } else {
                    self.nameExtension = nil
                }
            } else {
                self.nameExtension = nil
            }
        } else {
            self.spare = nil
            self.nameExtension = nil
        }
        
    }
    
    public func description() -> String {
        return ([
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Aid Type:", aidType.description),
            row("Name:", fullName),
            row("Position Accuracy:", positionAccuracy.description),
            row("Latitude:", latitude.description),
            row("Longitude:", longitude.description),
            row("Dimensions (m):", "Bow \(dimensionToBow), Stern \(dimensionToStern), Port \(dimensionToPort), Starboard \(dimensionToStarboard)"),
            row("EPFD Fix Type:", fixType.description),
            row("Timestamp:", timestamp.description),
            row("Off Position:", offPositionFlag.description),
            row("RAIM:", raimFlag.description),
            row("Virtual Aid:", virtualAidFlag.description),
            row("Assigned:", assignedFlag.description)
        ] as [String]).joined(separator: "\n")
    }

    private var fullName: String {
        guard let nameExtension = nameExtension, !nameExtension.text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return name.text
        }
        return name.text + nameExtension.text
    }
    
    
}
