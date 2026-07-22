//
//  BitBuffer.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/8/26.
//

import SignalTools

public extension BitBuffer {
    
    /// Extracts the value of the bits in this range of the BitBuffer.
    subscript (indexes: Range<Int>) -> UInt64? {
        guard self.count >= indexes.upperBound && indexes.lowerBound >= 0 else { return nil }
        var value: UInt64 = 0
        for index in indexes {
            value <<= 1
            value |= UInt64(self[index])
        }
        return value
    }
    
    subscript (indexes: ClosedRange<Int>) -> UInt64? {
        guard self.count >= indexes.upperBound && indexes.lowerBound >= 0 else { return nil }
        let range: Range<Int> = indexes.lowerBound..<(indexes.upperBound + 1)
        return self[range]
    }
    
}
