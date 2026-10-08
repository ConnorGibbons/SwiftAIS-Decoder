//
//  VirtualAidFlag.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/3/26.
//

public enum VirtualAidFlag: RawRepresentable {
    public typealias RawValue = Bool
    
    case isVirtualAid
    case notVirtualAid
    
    public init(rawValue: Bool) {
        self = rawValue ? .isVirtualAid : .notVirtualAid
    }
    
    public var rawValue: Bool {
        switch self {
        case .isVirtualAid:
            return true
        case .notVirtualAid:
            return false
        }
    }
    
    public var description: String {
        if self.rawValue { return "Is a virtual AtoN" }
        else { return "Not a virtual AtoN" }
    }
    
}
