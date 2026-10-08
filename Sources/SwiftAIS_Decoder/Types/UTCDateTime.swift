//
//  UTCDateTime.swift
//  SwiftAIS-Decoder
//
//  Created by Connor Gibbons on 7/14/26.
//

func dateStringFromUTCElements(year: UTCYear, month: UTCMonth, day: UTCDay, hour: UTCHour, minute: UTCMinute, second: TimeStamp) -> String {
    return "\(year.description)-\(month.description)-\(day.description) " + "\(hour.description):\(minute.description):\(second.description)"
}

public struct UTCYear {
    public let rawValue: UInt16
    public let year: UInt16?
    
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
        if(rawValue > 0 && rawValue <= 9999) {
            self.year = rawValue
        }
        else {
            self.year = nil
        }
    }
    
    public var description: String {
        if let year = year {
            return "\(year)"
        }
        else {
            return "Unavailable \(rawValue)"
        }
    }
    
}

public struct UTCMonth {
    public let rawValue: UInt8
    public let month: UInt8?
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
        if(rawValue > 0 && rawValue <= 12) {
            self.month = rawValue
        }
        else {
            self.month = nil
        }
    }
    
    public var description: String {
        if let month = month {
            return "\(month)"
        }
        else {
            return "Unavailable \(rawValue)"
        }
    }
    
}

public struct UTCDay {
    public let rawValue: UInt8
    public let day: UInt8?
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
        if(rawValue > 0 && rawValue <= 31) {
            self.day = rawValue
        }
        else {
            self.day = nil
        }
    }
    
    public var description: String {
        if let day = day {
            return "\(day)"
        }
        else {
            return "Unavailable \(rawValue)"
        }
    }
    
}

public struct UTCHour {
    public let rawValue: UInt8
    public let hour: UInt8?
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
        if(rawValue <= 23) {
            self.hour = rawValue
        }
        else {
            self.hour = nil
        }
    }
    
    public var description: String {
        if let hour = hour {
            return "\(hour)"
        }
        else {
            return "Unavailable \(rawValue)"
        }
    }
    
}

public struct UTCMinute {
    public let rawValue: UInt8
    public let minute: UInt8?
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
        if(rawValue <= 59) {
            self.minute = rawValue
        }
        else {
            self.minute = nil
        }
    }
    
    public var description: String {
        if let minute = minute {
            return "\(minute)"
        }
        else {
            return "Unavailable \(rawValue)"
        }
    }
    
}


// No need for UTCSecond -- it's in the exact same format as "TimeStamp"

