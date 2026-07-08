//
//  RateOfTurn.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/8/26.
//

struct RateOfTurn {
    var rawValue: Int8
    var rot: Double? {
        if(rawValue == -128) { return nil }
        if(rawValue == 127) { return 10 }
        if(rawValue == -127) { return -10 }
        if(rawValue == 0) { return 0 }
        else { return calcROT(val: self.rawValue) }
    }
    
    init(value: Int8) {
        self.rawValue = value
    }
    
    var description: String {
        switch rawValue {
        case -128: return "No information available"
        case 0:    return "Not turning"
        case 127:  return "Turning right at more than 10°/min"
        case -127: return "Turning left at more than 10°/min"
        default:
            let rate = calcROT(val: rawValue)
            let direction = rawValue > 0 ? "right" : "left"
            return "Turning \(direction) at \(String(format: "%.1f", abs(rate)))°/min"
        }
    }
    
    /// Returns rate of turn in degrees/minute
    /// Field is provided as 4.733xSQRT(ROT), so this inverts that
    private func calcROT(val: Int8) -> Double {
        let mult: Double = val < 0 ? -1 : 1
        let valAsDouble = Double(val)
        return (valAsDouble / 4.733) * (valAsDouble / 4.733) * mult
    }
}
