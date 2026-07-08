//
//  MMSI.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/8/26.
//

struct MMSI {
    var value: UInt32
    
    init?(value: UInt32) {
        guard value <= 0b111011100110101100100111111111 else { return nil } // 999 999 999
        self.value = value
    }
    
    var description: String {
        return String(format: "%09u", value)
    }
}
