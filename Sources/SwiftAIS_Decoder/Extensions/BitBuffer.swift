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
        return self[indexes.lowerBound..<(indexes.upperBound+1)]
    }
    
    subscript(indexes: Range<Int>) -> BitBuffer? {
        guard indexes.lowerBound >= 0, indexes.upperBound <= count else { return nil }
        var newBitBuffer = BitBuffer()
        for i in indexes {
            newBitBuffer.append(UInt8(self[i]))
        }
        return newBitBuffer
    }
    
    subscript(indexes: ClosedRange<Int>) -> BitBuffer? {
        return self[indexes.lowerBound..<(indexes.upperBound+1)]
    }
    
    mutating func append(intArray: [Int]) {
        for i in intArray {
            self.append(UInt8(i))
        }
    }
    
    /// 'Padding' allows to prevent the appending of zero-fill bits, which are assumed to be on the left side.
    mutating func append<T: FixedWidthInteger>(bits: T, padding: Int = 0) {
        var bits = bits << padding
        let mask: T = 1 << (T.bitWidth - 1)
        for _ in 0..<(bits.bitWidth - padding) {
            self.append((bits & mask) == 0 ? 0 : 1)
            bits = bits << 1
        }
    }
    
    mutating func append(contentsOf: BitBuffer) {
        for i in 0..<contentsOf.count {
            self.append(UInt8(contentsOf[i]))
        }
    }

    // Throwing readers used by the message parsers. `field` names the field being read so errors carry context.

    func read<T: FixedWidthInteger>(_ range: Range<Int>, _ field: String) throws(AISDecodingError) -> T {
        guard range.lowerBound >= 0, range.upperBound <= count else {
            throw .payloadTooShort(field: field, bits: range, available: count)
        }
        // Bounds are already checked, so a nil here means the range is wider than T: a programmer error, not bad data.
        guard let value: T = self[range] else { preconditionFailure("\(field): \(range.count) bits don't fit in \(T.self)") }
        return value
    }

    func read<T: FixedWidthInteger>(_ range: ClosedRange<Int>, _ field: String) throws(AISDecodingError) -> T {
        try read(range.lowerBound..<(range.upperBound + 1), field)
    }

    func read<E: RawRepresentable>(_ range: ClosedRange<Int>, _ field: String) throws(AISDecodingError) -> E
        where E.RawValue: FixedWidthInteger {
        let raw: E.RawValue = try read(range, field)
        guard let value = E(rawValue: raw) else {
            throw .invalidValue(field: field, rawValue: UInt64(truncatingIfNeeded: raw))
        }
        return value
    }

    func read(_ range: Range<Int>, _ field: String) throws(AISDecodingError) -> BitBuffer {
        guard let value: BitBuffer = self[range] else {
            throw .payloadTooShort(field: field, bits: range, available: count)
        }
        return value
    }

    func read(_ range: ClosedRange<Int>, _ field: String) throws(AISDecodingError) -> BitBuffer {
        try read(range.lowerBound..<(range.upperBound + 1), field)
    }

}
