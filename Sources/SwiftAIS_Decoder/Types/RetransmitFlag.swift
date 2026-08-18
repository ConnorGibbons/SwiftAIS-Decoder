//
//  RetransmitFlag.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 8/14/26.
//

enum RetransmitFlag: RawRepresentable {
    typealias RawValue = Bool
    
    case notRetransmitted
    case retransmitted
    
    init?(rawValue: Bool) {
        if rawValue {
            self = .retransmitted
        } else {
            self = .notRetransmitted
        }
    }
    
    // Must switch rather than compare: RawRepresentable's == is defined in terms of rawValue, so
    // comparing against a case here would recurse infinitely.
    var rawValue: Bool {
        switch self {
        case .retransmitted:
            return true
        case .notRetransmitted:
            return false
        }
    }

    var description: String {
        if(self.rawValue) {
            return "Retransmitted"
        }
        else {
            return "Not Retransmitted"
        }
    }
    
}
