//
//  BandFlag.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/2/26.
//
//  Not entirely sure what this really means, seems to have to do with ability to change frequency at the request of a base station

enum BandFlag: RawRepresentable {
    typealias RawValue = Bool
    
    case canChangeFreq
    case cantChangeFreq
    
    init(rawValue: Bool) {
        self = rawValue ? .canChangeFreq : .cantChangeFreq
    }
    
    var rawValue: Bool {
        switch self {
        case .canChangeFreq:
            return true
        case .cantChangeFreq:
            return false
        }
    }

    var description: String {
        if self.rawValue { return "Can Change Frequency" }
        else { return "Can't Change Frequency" }
    }
    
}


