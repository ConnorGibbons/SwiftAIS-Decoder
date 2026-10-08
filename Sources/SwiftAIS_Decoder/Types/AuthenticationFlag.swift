//
//  AuthenticationFlag.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 10/7/26.
//
//  Only used on message type 28, describes whether the message is authenticated per IALA G1192

public enum AuthenticationFlag: RawRepresentable {
    public typealias RawValue = Bool
    
    case authenticated
    case notAuthenticated
    
    public init(rawValue: Bool) {
        self = rawValue ? .authenticated : .notAuthenticated
    }
    
    public var rawValue: Bool {
        switch self {
        case .authenticated:
            return true
        case .notAuthenticated:
            return false
        }
    }

    public var description: String {
        if self.rawValue { return "Message authenticated per IALA G1192" }
        else { return "Message not authenticated (default)" }
    }
    
}

