//
//  Addressed.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/8/26.
//

enum Addressed: UInt8 {
    case addressed = 1
    case broadcast = 0

    var description: String {
        switch self {
        case .addressed:
            return "Addressed"
        case .broadcast:
            return "Broadcast Geographical Area Message"
        }
    }
}
