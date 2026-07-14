//
//  CourseOverGround.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/14/26.
//

struct CourseOverGround {
    let rawValue: UInt16
    let value: Double?
    
    init(rawValue: UInt16) {
        self.rawValue = rawValue
        if(rawValue < 3600 && rawValue >= 0) { self.value = Double(rawValue) / 10 }
        else { self.value = nil }
    }
    
    var description: String {
        if let degree = value {
            return "\(degree) degrees"
        }
        else {
            return "Not available (\(rawValue))"
        }
    }
    
}
