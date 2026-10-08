//
//  SpareData.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/14/26.
//

public struct SpareData {
    public let rawValue: UInt64
    
    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }
    
    public var description: String {
        "\(rawValue)"
    }
}
