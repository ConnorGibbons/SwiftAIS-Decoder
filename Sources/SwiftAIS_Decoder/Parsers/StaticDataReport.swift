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

public struct StaticDataReport: AISMessage {
    public let nmeaSentence: AISNMEA0183Sentence
    public let messageType: AISMessageType
    public let mmsiNumber: MMSI
    
    public let part: StaticDataReportPart
    
    // Part A Contents
    public let vesselName: AISText?
    public let spare: UInt8?
    
    // Part B Contents
    public let shipType: ShipType?
    public let vendorID: AISText?
    public let unitModelCode: UInt8?
    public let serialNumber: UInt32?
    public let callSign: AISText?
    public let dimensionToBow: UInt16?
    public let dimensionToStern: UInt16?
    public let dimensionToPort: UInt8?
    public let dimensionToStarboard: UInt8?
    public let mothershipMMSI: MMSI?
    public let spare2: UInt8?
    
    public init(nmea: AISNMEA0183Sentence) throws(AISDecodingError) {
        self.nmeaSentence = nmea
        let bits = nmea.payloadBits

        let messageType: AISMessageType = try bits.read(0...5, "messageType")
        guard messageType.rawValue == 24 else { throw .unexpectedMessageType(messageType.rawValue, expected: [24]) }
        self.messageType = messageType

        let mmsiBits: UInt32 = try bits.read(8...37, "mmsiNumber")
        guard let mmsi = MMSI(value: mmsiBits) else { throw .invalidValue(field: "mmsiNumber", rawValue: UInt64(mmsiBits)) }
        self.mmsiNumber = mmsi

        let part: StaticDataReportPart = try bits.read(38...39, "part")
        self.part = part
        
        // The message can be sent containing one of two "parts", A or B, each contain different info.
        // The parts are expected to be broadcast one after the other.
        // Part A has the name and nothing else
        if(part == .a) {
            let nameBits: BitBuffer = try bits.read(40...159, "vesselName")
            guard let name = AISText(raw: nameBits) else { throw .invalidText(field: "vesselName") }
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
            let shipType: ShipType = try bits.read(40...47, "shipType")
            self.shipType = shipType
            
            // Explanation for this: Originally this field was 7 characters and was the AIS equipment vendor.
            // It was later changed to 3 letter vendor ID + unit model + serial number
            // Both are still used. The code here attempts to decode 7 characters, if all 7 are alphanumeric it treats it as the AIS equipment vendor.
            // Otherwise it'll treat it as vendorID + unit model + serial number
            let vendorIDBits: BitBuffer = try bits.read(48...65, "vendorID")
            guard let vendorID = AISText(raw: vendorIDBits) else { throw .invalidText(field: "vendorID") }
            let unitModelCodeBits: UInt8 = try bits.read(66...69, "unitModelCode")
            let serialNumberBits: UInt32 = try bits.read(70...89, "serialNumber")
            let fullVendorIDBits: BitBuffer = try bits.read(48...89, "vendorID")
            guard let fullVendorID = AISText(raw: fullVendorIDBits) else { throw .invalidText(field: "vendorID") }
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

            let callSignBits: BitBuffer = try bits.read(90...131, "callSign")
            guard let callSign = AISText(raw: callSignBits) else { throw .invalidText(field: "callSign") }
            self.callSign = callSign

            if(mmsiNumber.description.prefix(2) == "98") { // "98"-prefixed MMSI indicates an auxiliary craft, which sends its mothership MMSI in this slot
                let mothershipMMSIBits: UInt32 = try bits.read(132...161, "mothershipMMSI")
                guard let mothershipMMSI = MMSI(value: mothershipMMSIBits) else { throw .invalidValue(field: "mothershipMMSI", rawValue: UInt64(mothershipMMSIBits)) }
                self.mothershipMMSI = mothershipMMSI
                
                self.dimensionToBow = nil
                self.dimensionToStern = nil
                self.dimensionToPort = nil
                self.dimensionToStarboard = nil
            }
            else {
                let dimensionToBow: UInt16 = try bits.read(132...140, "dimensionToBow")
                self.dimensionToBow = dimensionToBow
                let dimensionToStern: UInt16 = try bits.read(141...149, "dimensionToStern")
                self.dimensionToStern = dimensionToStern
                let dimensionToPort: UInt8 = try bits.read(150...155, "dimensionToPort")
                self.dimensionToPort = dimensionToPort
                let dimensionToStarboard: UInt8 = try bits.read(156...161, "dimensionToStarboard")
                self.dimensionToStarboard = dimensionToStarboard

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
    
    
    public func description() -> String {
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
