//
//  BinaryAddressedMessage.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/28/26.
//
//  Type 6
//  Probably won't see many of these.

import SignalTools

public struct BinaryAddressedMessage: AISMessage {
    public let messageType: AISMessageType
    public let mmsiNumber: MMSI
    
    public var destinationMMSI: MMSI
    public var retransmit: RetransmitFlag // 0 = no retransmit, 1 = retransmitted
    public var spare: Bool // Pretty much nothing, just here because it's in the spec.
    public var areaCode: DesignatedAreaCode
    public var functionalID: UInt8
    public var payload: BitBuffer
    public var text: AISText? // Almost every message will not properly decode AISText here. Most payloads are a mixture of data types, far too many to write individual parsers for.
    
    public init(bits: BitBuffer) throws(AISDecodingError) {
        guard bits.count >= 89 else { throw .payloadTooShort(field: "payload", bits: 88..<89, available: bits.count) } // Functional ID is bit 87, so this guard is to ensure there's at least 1 payload bit

        let messageType: AISMessageType = try bits.read(0...5, "messageType")
        guard messageType.rawValue == 6 else { throw .unexpectedMessageType(messageType.rawValue, expected: [6]) }
        self.messageType = messageType

        let mmsiBits: UInt32 = try bits.read(8...37, "mmsiNumber")
        self.mmsiNumber = MMSI(value: mmsiBits)

        let destinationMMSIBits: UInt32 = try bits.read(40...69, "destinationMMSI")
        self.destinationMMSI = MMSI(value: destinationMMSIBits)

        self.retransmit = RetransmitFlag(rawValue: try bits.read(70, "retransmit"))
        self.spare = try bits.read(71, "spare")
        self.areaCode = DesignatedAreaCode(rawValue: try bits.read(72...81, "areaCode"))
        self.functionalID = try bits.read(82...87, "functionalID")

        let payloadBits: BitBuffer = try bits.read(88..<bits.count, "payload")
        self.payload = payloadBits
        
        // Fill bits can leave a partial character at the end of the payload, so only whole characters are decoded.
        if let textBits: BitBuffer = payloadBits[0..<((payloadBits.count / 6) * 6)] {
            self.text = AISText(raw: textBits)
        }
        else {
            self.text = nil
        }
    }
    
    public func description() -> String {
        return ([
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", mmsiNumber.description),
            row("Destination MMSI:", destinationMMSI.description),
            row("Retransmit:", retransmit.description),
            row("Area Code (DAC):", "\(areaCode.description) (\(areaCode.rawValue))"),
            row("Functional ID:", "\(functionalID)"),
            row("Payload:", text?.text ?? "\(payload.count) bits")
        ] as [String]).joined(separator: "\n")
    }
    
    
}
