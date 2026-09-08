//
//  VHFChannel.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/8/26.
//

struct VHFChannel {
    let channel: Int
    
    var description: String {
        switch channel {
        case 2087:
            return "AIS 1: 87B, 161.975 MHz"
        case 2088:
            return "AIS 2: 88B, 162.000 MHz"
        default:
            return "VHF Channel \(channel)"
        }
        
    }
}
