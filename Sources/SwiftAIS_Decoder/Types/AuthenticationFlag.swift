//
//  AuthenticationFlag.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 10/7/26.
//
//  Only used on message type 28, describes whether the message is authenticated per IALA G1192

enum AuthenticationFlag: RawRepresentable {
    typealias RawValue = Bool
    
    case authenticated
    case notAuthenticated
    
    init(rawValue: Bool) {
        self = rawValue ? .authenticated : .notAuthenticated
    }
    
    var rawValue: Bool {
        switch self {
        case .authenticated:
            return true
        case .notAuthenticated:
            return false
        }
    }

    var description: String {
        if self.rawValue { return "Message authenticated per IALA G1192" }
        else { return "Message not authenticated (default)" }
    }
    
}

