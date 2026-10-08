//
//  CourseOverGround.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/14/26.
//

public struct CourseOverGround {
    public let rawValue: UInt16
    public let value: Double?
    
    public init?(rawValue: UInt16) {
        self.rawValue = rawValue
        guard rawValue <= 0b111111111111 else { return nil } // Max val is 4095, field is 12 bits
        if(rawValue < 3600) { self.value = Double(rawValue) / 10 }
        else { self.value = nil }
    }
    
    public var description: String {
        if let degree = value {
            return "\(degree) degrees"
        }
        else if rawValue == 3600 {
            return "Not available"
        }
        else {
            return "Not available (\(rawValue)) [bad data]"
        }
    }
    
}

public struct CourseOverGroundCompact {
    public let rawValue: UInt16
    public let value: Double?
    
    public init?(rawValue: UInt16) {
        self.rawValue = rawValue
        guard rawValue <= 0b111111111 else { return nil } // Max val is 511, field is 9 bits
        if(rawValue < 360) { self.value = Double(rawValue) }
        else { self.value = nil }
    }
    
    public var description: String {
        if let degree = value {
            return "\(degree) degrees"
        }
        else if rawValue == 511 {
            return "Not available"
        }
        else {
            return "Not available (\(rawValue)) [bad data]"
        }
    }
}
