//
//  VisualDisplay.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/2/26.
//

enum VisualDisplay: RawRepresentable {
    typealias RawValue = Bool
    
    case hasVisualDisplay
    case noVisualDisplay
    
    init(rawValue: Bool) {
        self = rawValue ? .hasVisualDisplay : .noVisualDisplay
    }
    
    var rawValue: Bool {
        switch self {
        case .hasVisualDisplay:
            return true
        case .noVisualDisplay:
            return false
        }
    }

    var description: String {
        if self.rawValue { return "Has Visual Display" }
        else { return "Does Not Have Visual Display" }
    }
    
}
