//
//  BinaryAcknowledge.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/29/26.
//
//  Type 7

import SignalTools

public struct BinaryAcknowledge: AISMessage {
    public let messageType: AISMessageType
    public let mmsiNumber: MMSI
    
    public let mmsis: [MMSI]
    
    
    public init(bits: BitBuffer) throws(AISDecodingError) {
        let messageType: AISMessageType = try bits.read(0...5, "messageType")
        guard messageType.rawValue == 7 else { throw .unexpectedMessageType(messageType.rawValue, expected: [7]) }
        self.messageType = messageType

        let mmsiBits: UInt32 = try bits.read(8...37, "mmsiNumber")
        self.mmsiNumber = MMSI(value: mmsiBits)
        
        var mmsis: [MMSI] = []
        var bitIndex: Int = 40
        while(bitIndex + 29 < bits.count) {
            if let mmsi: UInt32 = bits[bitIndex...bitIndex + 29] {
                mmsis.append(MMSI(value: mmsi))
            }
            bitIndex += 32
        }
        self.mmsis = mmsis
    }
    
    
    
    public func description() -> String {
        let acknowledged: String
        if mmsis.isEmpty {
            acknowledged = "None"
        } else {
            acknowledged = mmsis.map { "\($0.country) - \($0.description)" }.joined(separator: "\n" + row("", ""))
        }
        return ([
            "*** \(messageType.description) (Type \(messageType.rawValue)) ***",
            row("MMSI:", "\(mmsiNumber.country) - \(mmsiNumber.description)"),
            row("Acknowledged MMSIs:", acknowledged)
        ] as [String]).joined(separator: "\n")
    }
    
    
}
