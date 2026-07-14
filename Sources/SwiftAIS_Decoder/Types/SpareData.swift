//
//  SpareData.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/14/26.
//

struct SpareData {
    let rawValue: UInt64
    
    init(rawValue: UInt64) {
        self.rawValue = rawValue
    }
    
    var description: String {
        "\(rawValue)"
    }
}
