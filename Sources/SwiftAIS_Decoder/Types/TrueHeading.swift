//
//  TrueHeading.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/14/26.
//

struct TrueHeading {
    let rawValue: UInt16
    let value: Double?
    
    init(rawValue: UInt16) {
        self.rawValue = rawValue
        if(rawValue >= 0 && rawValue <= 360) { self.value = Double(rawValue) }
        else { value = nil }
    }
    
    var description: String {
        if let heading = value {
            return "\(heading) degrees"
        }
        else {
            return "Unavailable (\(rawValue))"
        }
    }
}
