//
//  BitBuffer.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/8/26.
//

import SignalTools

extension BitBuffer {

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

    func read(_ index: Int, _ field: String) throws(AISDecodingError) -> Bool {
        let bit: UInt8 = try read(index..<(index + 1), field)
        return bit == 1
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
