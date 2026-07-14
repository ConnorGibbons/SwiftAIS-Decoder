//
//  Int32.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/14/26.
//

extension Int32 {
    init(signextend: UInt32, bits: Int) {
        let shiftBy = 32 - bits
        // Reinterpret as signed *before* the right shift so it's an arithmetic
        // (sign-extending) shift rather than a logical one.
        self = Int32(bitPattern: signextend << shiftBy) >> shiftBy
    }
}
