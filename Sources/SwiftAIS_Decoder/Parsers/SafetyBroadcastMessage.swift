//
//  SafetyBroadcastMessage.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 8/18/26.
//
//  Type 14: Safety-Related Broadcast Message
//  Payload character: >

import SignalTools

public struct SafetyBroadcastMessage: AISMessage {
    public let messageType: AISMessageType
    public let mmsiNumber: MMSI

    public let spare: UInt8
    public let payload: BitBuffer
    public let text: AISText?
    
    public init(bits: BitBuffer) throws(AISDecodingError) {
        guard bits.count > 40 else { throw .payloadTooShort(field: "payload", bits: 40..<41, available: bits.count) } // Spare ends at 40th bit, so this ensures there's at least one payload bit

        let messageType: AISMessageType = try bits.read(0...5, "messageType")
        guard messageType.rawValue == 14 else { throw .unexpectedMessageType(messageType.rawValue, expected: [14]) }
        self.messageType = messageType

        let mmsiBits: UInt32 = try bits.read(8...37, "mmsiNumber")
        self.mmsiNumber = MMSI(value: mmsiBits)

        self.spare = try bits.read(38...39, "spare")

        let payloadBits: BitBuffer = try bits.read(40..<bits.count, "payload")
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
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Payload:", text?.text ?? "\(payload.count) bits")
        ] as [String]).joined(separator: "\n")
    }
    
    
}
