//
//  AISText.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/23/26.
//
//  Structure described here: https://gpsd.gitlab.io/gpsd/AIVDM.html

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

    /// Assumes left-to-right, and residual zeroes in the last UInt64 as being on the left hand side.
    init?(raw: BitBuffer) {
        
    }

}
