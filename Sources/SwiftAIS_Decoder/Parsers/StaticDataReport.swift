//
//  StaticDataReport.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/9/26.
//
//  Type 24: Static Data Report
//  Like a type 5 (Static and Voyage Data) message but for Class B equipment
//  Payload character: H

import SignalTools

struct StaticDataReport: AISMessage {
    let nmeaSentence: AISNMEA0183Sentence
    let messageType: AISMessageType
    let mmsiNumber: MMSI
    
    let part: StaticDataReportPart
    
    // Part A Contents
    let vesselName: AISText?
    let spare: UInt8?
    
    // Part B Contents
    let shipType: ShipType?
    let vendorID: AISText?
    let unitModelCode: UInt8?
    let serialNumber: UInt32?
    let callSign: AISText?
    let dimensionToBow: UInt16?
    let dimensionToStern: UInt16?
    let dimensionToPort: UInt8?
    let dimensionToStarboard: UInt8?
    let mothershipMMSI: MMSI?
    let spare2: UInt8?
    
    init?(nmea: AISNMEA0183Sentence) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits
        
        guard let messageTypeBits: UInt8 = bits[0...5] else { return nil }
        guard let messageType = AISMessageType(rawValue: Int(messageTypeBits)) else { return nil }
        guard messageType.rawValue == 24 else { return nil }
        self.messageType = messageType
        
        guard let mmsiBits: UInt32 = bits[8...37] else { return nil }
        guard let mmsi = MMSI(value: mmsiBits) else { return nil }
        self.mmsiNumber = mmsi
        
        guard let partBits: UInt8 = bits[38...39] else { return nil }
        guard let part = StaticDataReportPart(rawValue: partBits) else { return nil }
        self.part = part
        
        // The message can be sent containing one of two "parts", A or B, each contain different info.
        // The parts are expected to be broadcast one after the other.
        // Part A has the name and nothing else
        if(part == .a) {
            guard let nameBits: BitBuffer = bits[40...159] else { return nil }
            guard let name = AISText(raw: nameBits) else { return nil }
            self.vesselName = name
            if let spareBits: UInt8 = bits[160...167] { // Not going to guard on this becuase it's stated that these spare bits are commonly left out
                self.spare = spareBits
            } else {
                self.spare = nil
            }
            self.shipType = nil
            self.vendorID = nil
            self.unitModelCode = nil
            self.serialNumber = nil
            self.callSign = nil
            self.dimensionToBow = nil
            self.dimensionToStern = nil
            self.dimensionToPort = nil
            self.dimensionToStarboard = nil
            self.mothershipMMSI = nil
            self.spare2 = nil
        }
        // Part B has various ship & AIS module metadata
        else {
            guard let shipTypeBits: UInt8 = bits[40...47] else { return nil }
            guard let shipType = ShipType(rawValue: shipTypeBits) else { return nil }
            self.shipType = shipType
            
            // Explanation for this: Originally this field was 7 characters and was the AIS equipment vendor.
            // It was later changed to 3 letter vendor ID + unit model + serial number
            // Both are still used. The code here attempts to decode 7 characters, if all 7 are alphanumeric it treats it as the AIS equipment vendor.
            // Otherwise it'll treat it as vendorID + unit model + serial number
            guard let vendorIDBits: BitBuffer = bits[48...65] else { return nil }
            guard let vendorID = AISText(raw: vendorIDBits) else { return nil }
            guard let unitModelCodeBits: UInt8 = bits[66...69] else { return nil }
            guard let serialNumberBits: UInt32 = bits[70...89] else { return nil }
            guard let fullVendorIDBits: BitBuffer = bits[48...89] else { return nil }
            guard let fullVendorID = AISText(raw: fullVendorIDBits) else { return nil }
            let lastFour = fullVendorID.text.suffix(4)
            if(lastFour.allSatisfy({$0.isLetter || $0.isNumber})) {
                self.vendorID = fullVendorID
                self.unitModelCode = nil
                self.serialNumber = nil
            }
            else {
                self.vendorID = vendorID
                self.unitModelCode = unitModelCodeBits
                self.serialNumber = serialNumberBits
            }

            guard let callSignBits: BitBuffer = bits[90...131] else { return nil }
            guard let callSign = AISText(raw: callSignBits) else { return nil }
            self.callSign = callSign
            
            if(mmsiNumber.description.prefix(2) == "98") { // "98"-prefixed MMSI indicates an auxiliary craft, which sends its mothership MMSI in this slot
                guard let mothershipMMSIBits: UInt32 = bits[132...161] else { return nil }
                guard let mothershipMMSI = MMSI(value: mothershipMMSIBits) else { return nil }
                self.mothershipMMSI = mothershipMMSI
                
                self.dimensionToBow = nil
                self.dimensionToStern = nil
                self.dimensionToPort = nil
                self.dimensionToStarboard = nil
            }
            else {
                guard let dimensionToBowBits: UInt16 = bits[132...140] else { return nil }
                self.dimensionToBow = dimensionToBowBits
                
                guard let dimensionToSternBits: UInt16 = bits[141...149] else { return nil }
                self.dimensionToStern = dimensionToSternBits
                
                guard let dimensionToPortBits: UInt8 = bits[150...155] else { return nil }
                self.dimensionToPort = dimensionToPortBits
                
                guard let dimensionToStarboardBits: UInt8 = bits[156...161] else { return nil }
                self.dimensionToStarboard = dimensionToStarboardBits
                
                self.mothershipMMSI = nil
            }
            if let spare2Bits: UInt8 = bits[162...167] {
                self.spare2 = spare2Bits
            } else {
                self.spare2 = nil
            }
            self.vesselName = nil
            self.spare = nil
        }
    }
    
    
    func description() -> String {
        var rows: [String] = [
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Part:", part.description)
        ]

        // Each part carries a disjoint set of fields, so only report the ones this part actually contains.
        if(part == .a) {
            rows.append(row("Vessel Name:", vesselName?.text ?? "Unavailable"))
        }
        else {
            rows.append(row("Ship Type:", shipType?.description ?? "Unavailable"))

            // A nil unit model code & serial number means the vendor field was read as the original
            // 7-character equipment vendor rather than the newer vendor ID + model + serial split.
            if(unitModelCode == nil && serialNumber == nil) {
                rows.append(row("Equipment Vendor:", vendorID?.text ?? "Unavailable"))
            }
            else {
                rows.append(row("Vendor ID:", vendorID?.text ?? "Unavailable"))
                rows.append(row("Unit Model Code:", unitModelCode.map { "\($0)" } ?? "Unavailable"))
                rows.append(row("Serial Number:", serialNumber.map { "\($0)" } ?? "Unavailable"))
            }

            rows.append(row("Call Sign:", callSign?.text ?? "Unavailable"))

            // An auxiliary craft sends its mothership's MMSI in the slot the dimensions would otherwise occupy.
            if let mothershipMMSI {
                rows.append(row("Mothership MMSI:", "\(mothershipMMSI.country) - \(mothershipMMSI.description)"))
            }
            else {
                rows.append(row("Dimensions (m):", "Bow \(dimensionToBow ?? 0), Stern \(dimensionToStern ?? 0), Port \(dimensionToPort ?? 0), Starboard \(dimensionToStarboard ?? 0)"))
            }
        }

        return rows.joined(separator: "\n")
    }
    
    
}
