//
//  Helpers.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/23/26.
//

func row(_ label: String, _ value: String) -> String {
    let pad = String(repeating: " ", count: max(1, 20 - label.count))
    return "  \(label)\(pad)\(value)"
}
