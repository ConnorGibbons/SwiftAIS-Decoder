//
//  StaticDataReportPart.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 9/9/26.
//
//  Static Data Report Part

enum StaticDataReportPart: UInt8 {
    case a = 0
    case b = 1

    var description: String {
        switch self {
        case .a:
            return "A"
        case .b:
            return "B"
        }
    }
}
