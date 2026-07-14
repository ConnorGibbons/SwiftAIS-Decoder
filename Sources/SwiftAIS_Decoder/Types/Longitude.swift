//
//  Longitude.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/14/26.
//

struct Longitude: Equatable {
    let rawValue: Int32
    let degrees: Double?

    init(rawValue: UInt32) {
        let rawValueSigned = Int32(signextend: rawValue, bits: 28) // This will properly interpret the 28 bits as a 28-bit signed int
        self.rawValue = rawValueSigned
        let computedDegrees = Double(rawValueSigned) / 600000 // Provided in 1/10000 minutes
        if(computedDegrees >= -180 && computedDegrees <= 180) { self.degrees = computedDegrees }
        else { self.degrees = nil }
    }

    var description: String {
        if let degrees = degrees {
            return "\(degrees.rounded(toPlaces: 6)) degrees"
        }
        else {
            return "Longitude unavailable (\(rawValue))"
        }
    }

}
