//
//  Array.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 10/12/26.
//

import SignalTools

extension Array where Element == AISNMEA0183Sentence {
    /// The payload bits of every sentence, concatenated in order, ready to hand to a message parser.
    public var payloadBits: BitBuffer {
        var bits: BitBuffer = .init()
        for sentence in self {
            bits.append(contentsOf: sentence.payloadBits)
        }
        return bits
    }
}
