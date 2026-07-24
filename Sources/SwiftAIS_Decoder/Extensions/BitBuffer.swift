//
//  BitBuffer.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/8/26.
//

import SignalTools

public extension BitBuffer {
    
    /// Extracts the value of the bits in this range of the BitBuffer.
    /// Any residual will be on the left-hand side.
    subscript<T: FixedWidthInteger>(indexes: Range<Int>) -> T? {
        guard self.count >= indexes.upperBound && indexes.lowerBound >= 0 else { return nil }
        if indexes.count > T.bitWidth {
            print("ERROR: Attempted to extract more bits (\(indexes.count)) than the type can hold (\(T.bitWidth)).")
            return nil
        }
        var value: T = 0
        for index in indexes {
            value <<= 1
            value |= T(self[index])
        }
        return value
    }
    
    subscript<T: FixedWidthInteger>(indexes: ClosedRange<Int>) -> T? {
        guard self.count >= indexes.upperBound && indexes.lowerBound >= 0 else { return nil }
        let range: Range<Int> = indexes.lowerBound..<(indexes.upperBound + 1)
        return self[range]
    }
    
    subscript(indexes: Range<Int>) -> BitBuffer? {
        var newBitBuffer: BitBuffer = .init()
        guard indexes.count <= 64 && indexes.count > 0 else { return nil }
        var values: [UInt64?] = {
            let bucketCount =  (63 + indexes.count) / 64
            
        }
        guard values != nil else { return nil }
        values = values! << (64 - indexes.count)
        let mask = UInt64(1 << 63)
        for i in 0..<indexes.count {
            newBitBuffer.append((values! & mask) != 0 ? 1 : 0)
            values! = values! << 1
        }
        return newBitBuffer
    }
    
    mutating func append(contentsOf: BitBuffer) {
        for i in 0..<contentsOf.count {
            self.append(UInt8(contentsOf[i]))
        }
    }
    
}
