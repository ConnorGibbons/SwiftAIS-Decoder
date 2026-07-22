//
//  UTCDateTime.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/14/26.
//

func dateStringFromUTCElements(year: UTCYear, month: UTCMonth, day: UTCDay, hour: UTCHour, minute: UTCMinute, second: TimeStamp) -> String {
    return "\(year.description)-\(month.description)-\(day.description) " + "\(hour.description):\(minute.description):\(second.description)"
}

struct UTCYear {
    let rawValue: UInt16
    let year: UInt16?
    
    init(rawValue: UInt16) {
        self.rawValue = rawValue
        if(rawValue > 0 && rawValue <= 9999) {
            self.year = rawValue
        }
        else {
            self.year = nil
        }
    }
    
    var description: String {
        if let year = year {
            return "\(year)"
        }
        else {
            return "Unavailable \(rawValue)"
        }
    }
    
}

struct UTCMonth {
    let rawValue: UInt8
    let month: UInt8?
    
    init(rawValue: UInt8) {
        self.rawValue = rawValue
        if(rawValue > 0 && rawValue <= 12) {
            self.month = rawValue
        }
        else {
            self.month = nil
        }
    }
    
    var description: String {
        if let month = month {
            return "\(month)"
        }
        else {
            return "Unavailable \(rawValue)"
        }
    }
    
}

struct UTCDay {
    let rawValue: UInt8
    let day: UInt8?
    
    init(rawValue: UInt8) {
        self.rawValue = rawValue
        if(rawValue > 0 && rawValue <= 31) {
            self.day = rawValue
        }
        else {
            self.day = nil
        }
    }
    
    var description: String {
        if let day = day {
            return "\(day)"
        }
        else {
            return "Unavailable \(rawValue)"
        }
    }
    
}

struct UTCHour {
    let rawValue: UInt8
    let hour: UInt8?
    
    init(rawValue: UInt8) {
        self.rawValue = rawValue
        if(rawValue > 0 && rawValue <= 23) {
            self.hour = rawValue
        }
        else {
            self.hour = nil
        }
    }
    
    var description: String {
        if let hour = hour {
            return "\(hour)"
        }
        else {
            return "Unavailable \(rawValue)"
        }
    }
    
}

struct UTCMinute {
    let rawValue: UInt8
    let minute: UInt8?
    
    init(rawValue: UInt8) {
        self.rawValue = rawValue
        if(rawValue > 0 && rawValue <= 59) {
            self.minute = rawValue
        }
        else {
            self.minute = nil
        }
    }
    
    var description: String {
        if let minute = minute {
            return "\(minute)"
        }
        else {
            return "Unavailable \(rawValue)"
        }
    }
    
}


// No need for UTCSecond -- it's in the exact same format as "TimeStamp"

