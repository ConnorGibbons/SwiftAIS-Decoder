//
//  VisualDisplay.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/2/26.
//

public enum VisualDisplay: RawRepresentable {
    public typealias RawValue = Bool
    
    case hasVisualDisplay
    case noVisualDisplay
    
    public init(rawValue: Bool) {
        self = rawValue ? .hasVisualDisplay : .noVisualDisplay
    }
    
    public var rawValue: Bool {
        switch self {
        case .hasVisualDisplay:
            return true
        case .noVisualDisplay:
            return false
        }
    }

    public var description: String {
        if self.rawValue { return "Has Visual Display" }
        else { return "Does Not Have Visual Display" }
    }
    
}
