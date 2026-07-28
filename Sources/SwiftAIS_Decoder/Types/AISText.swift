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

struct AISText {
    let raw: BitBuffer
    let text: String

    init?(raw: BitBuffer) {
        guard raw.count % 6 == 0 else {
            print("ERROR: AISText bit count (\(raw.count)) must be a multiple of 6.")
            return nil
        }
        self.raw = raw
        let charCount = raw.count / 6
        var chars: [Character] = .init(repeating: " ", count: charCount)
        for i in 0..<charCount {
            let lowerBound = i * 6
            let upperBound = lowerBound + 6
            guard let sixBits: UInt8 = raw[lowerBound..<upperBound] else { return nil }
            chars[i] = bitsToCharacter[sixBits] ?? "?"
        }
        self.text = String(chars)
    }

}
