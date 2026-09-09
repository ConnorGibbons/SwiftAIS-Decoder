//
//  ReportInterval.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/8/26.
//

enum ReportInterval: UInt8 {
    case autonomous = 0
    case tenMinutes = 1
    case sixMinutes = 2
    case threeMinutes = 3
    case oneMinute = 4
    case thirtySeconds = 5
    case fifteenSeconds = 6
    case tenSeconds = 7
    case fiveSeconds = 8
    case nextShorterReportingInterval = 9
    case nextLongerReportingInterval = 10
    case reserved11 = 11
    case reserved12 = 12
    case reserved13 = 13
    case reserved14 = 14
    case reserved15 = 15
    
    var description: String {
        switch self {
        case .autonomous:
            return "As given by the autonomous mode"
        case .tenMinutes:
            return "10 Minutes"
        case .sixMinutes:
            return "6 Minutes"
        case .threeMinutes:
            return "3 Minutes"
        case .oneMinute:
            return "1 Minute"
        case .thirtySeconds:
            return "30 Seconds"
        case .fifteenSeconds:
            return "15 Seconds"
        case .tenSeconds:
            return "10 Seconds"
        case .fiveSeconds:
            return "5 Seconds"
        case .nextShorterReportingInterval:
            return "Next Shorter Reporting Interval"
        case .nextLongerReportingInterval:
            return "Next Longer Reporting Interval"
        case .reserved11, .reserved12, .reserved13, .reserved14, .reserved15:
            return "Reserved for future use"
        }
    }
}
