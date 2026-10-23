//
//  AISText.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/23/26.
//
//  Structure described here: https://gpsd.gitlab.io/gpsd/AIVDM.html

import SignalTools

let bitsToCharacter: [UInt8: Character] = {
    var charMap: [UInt8: Character] = [:]
    for value: UInt8 in 0..<64 {
        if(value < 32) {
            charMap[value] = Character(UnicodeScalar(value + 64))
        }
        else {
            charMap[value] = Character(UnicodeScalar(value))
        }
    }
    return charMap
}()

public struct AISText {
    public let raw: BitBuffer
    public let text: String?

    public init(raw: BitBuffer) {
        self.raw = raw
        self.text = AISText.decode(raw)
    }

    public var isValid: Bool {
        return raw.count % 6 == 0
    }

    public var description: String {
        return text ?? "\(raw.count) bits [bad data]"
    }

    private static func decode(_ raw: BitBuffer) -> String? {
        guard raw.count % 6 == 0 else { return nil }
        let charCount = raw.count / 6
        var chars: [Character] = .init(repeating: " ", count: charCount)
        for i in 0..<charCount {
            let lowerBound = i * 6
            let upperBound = lowerBound + 6
            guard let sixBits: UInt8 = raw[lowerBound..<upperBound] else { return nil }
            chars[i] = bitsToCharacter[sixBits] ?? "?"
        }
        return String(chars)
    }

}
