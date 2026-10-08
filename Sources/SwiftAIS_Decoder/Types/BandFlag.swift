//
//  BandFlag.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/2/26.
//
//  Not entirely sure what this really means, seems to have to do with ability to change frequency at the request of a base station

public enum BandFlag: RawRepresentable {
    public typealias RawValue = Bool
    
    case canChangeFreq
    case cantChangeFreq
    
    public init(rawValue: Bool) {
        self = rawValue ? .canChangeFreq : .cantChangeFreq
    }
    
    public var rawValue: Bool {
        switch self {
        case .canChangeFreq:
            return true
        case .cantChangeFreq:
            return false
        }
    }

    public var description: String {
        if self.rawValue { return "Can Change Frequency" }
        else { return "Can't Change Frequency" }
    }
    
}


