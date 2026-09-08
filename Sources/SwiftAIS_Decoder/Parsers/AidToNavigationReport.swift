//
//  AidToNavigationReport.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/3/26.
//
//  Type 21: Aid to Navigation Report (AtoN)
//  Payload Char: E

import SignalTools

struct AidToNavigationReport: AISMessage {
    let nmeaSentence: AISNMEA0183Sentence
    let messageType: AISMessageType
    let mmsiNumber: MMSI
    
    let aidType: NavaidType
    let name: AISText
    let positionAccuracy: PositionAccuracy
    let longitude: Longitude
    let latitude: Latitude
    let dimensionToBow: UInt16
    let dimensionToStern: UInt16
    let dimensionToPort: UInt8
    let dimensionToStarboard: UInt8
    let fixType: EPFDFixType
    let timestamp: TimeStamp // UTC Second
    let offPositionFlag: OffPositionFlag
    let regionalReserved: UInt8 // Not sure what this is used for
    let raimFlag: RAIMFlag
    let virtualAidFlag: VirtualAidFlag
    let assignedFlag: AssignedFlag
    let spare: UInt8?
    let nameExtension: AISText?
    
    let additionalSentences: [AISNMEA0183Sentence]?
    
    init?(nmeaSentences: [AISNMEA0183Sentence]) {
        guard nmeaSentences.count > 0 else { return nil }
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
        
        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageTypeBits)) else { return nil }
        guard messageType.rawValue == 21 else { return nil }
        self.messageType = messageType
        
        guard let mmsiBits: UInt32 = bits[8...37] else { return nil }
        guard let mmsi = MMSI(value: mmsiBits) else { return nil }
        self.mmsiNumber = mmsi
        
        guard let aidTypeBits: UInt8 = bits[38...42] else { return nil }
        guard let aidType = NavaidType(rawValue: aidTypeBits) else { return nil }
        self.aidType = aidType
        
        guard let nameBits: BitBuffer = bits[43...162] else { return nil }
        guard let name: AISText = .init(raw: nameBits) else { return nil }
        self.name = name
        
        guard let positionAccuracyBit: UInt8 = bits[163...163] else { return nil }
        guard let positionAccuracy = PositionAccuracy(rawValue: positionAccuracyBit) else { return nil }
        self.positionAccuracy = positionAccuracy
        
        guard let longitudeBits: UInt32 = bits[164...191] else { return nil }
        let longitude = Longitude(rawValue: longitudeBits)
        self.longitude = longitude
        
        guard let latitudeBits: UInt32 = bits[192...218] else { return nil }
        let latitude = Latitude(rawValue: latitudeBits)
        self.latitude = latitude
        
        guard let dimensionToBowBits: UInt16 = bits[219...227] else { return nil }
        self.dimensionToBow = dimensionToBowBits
        
        guard let dimensionToSternBits: UInt16 = bits[228...236] else { return nil }
        self.dimensionToStern = dimensionToSternBits
        
        guard let dimensionToPortBits: UInt8 = bits[237...242] else { return nil }
        self.dimensionToPort = dimensionToPortBits
        
        guard let dimensionToStarboardBits: UInt8 = bits[243...248] else { return nil }
        self.dimensionToStarboard = dimensionToStarboardBits
        
        guard let fixTypeBits: UInt8 = bits[249...252] else { return nil }
        guard let fixType = EPFDFixType(rawValue: fixTypeBits) else { return nil }
        self.fixType = fixType
        
        guard let timeStampBits: UInt8 = bits[253...258] else { return nil }
        let timeStamp = TimeStamp(rawValue: timeStampBits)
        self.timestamp = timeStamp
        
        guard let offPositionFlagBit: UInt8 = bits[259...259] else { return nil }
        let offPositionFlag = OffPositionFlag(rawValue: offPositionFlagBit == 1)
        self.offPositionFlag = offPositionFlag
        
        guard let regionalReservedBits: UInt8 = bits[260...267] else { return nil }
        self.regionalReserved = regionalReservedBits
        
        guard let raimFlagBit: UInt8 = bits[268...268] else { return nil }
        guard let raimFlag = RAIMFlag(rawValue: raimFlagBit) else { return nil }
        self.raimFlag = raimFlag
        
        guard let virtualAidFlagBit: UInt8 = bits[269...269] else { return nil }
        let virtualAidFlag = VirtualAidFlag(rawValue: virtualAidFlagBit == 1)
        self.virtualAidFlag = virtualAidFlag
        
        guard let assignedFlagBit: UInt8 = bits[270...270] else { return nil }
        let assignedFlag = AssignedFlag(rawValue: assignedFlagBit == 1)
        self.assignedFlag = assignedFlag
        
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
    
    func description() -> String {
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
