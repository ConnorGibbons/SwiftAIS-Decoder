//
//  VirtualAidFlag.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/3/26.
//

enum VirtualAidFlag: RawRepresentable {
    typealias RawValue = Bool
    
    case isVirtualAid
    case notVirtualAid
    
    init(rawValue: Bool) {
        self = rawValue ? .isVirtualAid : .notVirtualAid
    }
    
    var rawValue: Bool {
        switch self {
        case .isVirtualAid:
            return true
        case .notVirtualAid:
            return false
        }
    }
    
    var description: String {
        if self.rawValue { return "Is a virtual AtoN" }
        else { return "Not a virtual AtoN" }
    }
    
}
