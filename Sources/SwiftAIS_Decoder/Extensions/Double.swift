//
//  Double.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/14/26.
//
import Foundation

extension Double {
    
    func rounded(toPlaces: Int) -> Double {
        let divisor = pow(10.0, Double(toPlaces))
        return (self * divisor).rounded() / divisor
    }
    
}
