//
//  KBHDate.swift
//  KBHDatePicker
//
//  Created by Keith Hunter on 6/15/15.
//  Copyright © 2015 Keith Hunter. All rights reserved.
//

import Foundation

public let KBHDaysInAWeek = 7


extension NSDate {
    
    public var isWeekend: Bool { return self.oneLetterWeekday.uppercaseString == "S" }
    public var oneLetterWeekday: String { return self.weekdayWithNumberOfChars(1) }
    public var threeLetterWeekday: String { return self.weekdayWithNumberOfChars(3) }
    public var month: String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM"
        let monthNumber = formatter.stringFromDate(self) as NSString
        let months = formatter.standaloneMonthSymbols
        return months[monthNumber.intValue - 1]
    }
    public var day: Int {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd"
        let dayNumber = formatter.stringFromDate(self) as NSString
        return dayNumber.integerValue
    }
    
    
    // MARK: - Class Methods
    
    public class func dateWithOffset(offsetInDays: Int, fromDate date: NSDate) -> NSDate {
        return date.dateByAddingTimeInterval(NSTimeInterval(offsetInDays * 24 * 60 * 60))
    }
    
    
    // MARK: - Instance Methods
    
    public func weekdayWithNumberOfChars(numOfChars: Int) -> String {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .WeekOfMonth, .Weekday], fromDate: self)
        let dayNumber = components.weekday
        
        let formatter = NSDateFormatter()
        let weekdays = formatter.standaloneWeekdaySymbols
        let weekday = weekdays[dayNumber - 1]
        
        return weekday.substringToIndex(advance(weekday.startIndex, numOfChars))
    }
    
    public func withoutTime() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate: self)
        
        components.hour = 1
        components.minute = 0
        components.second = 0
        components.nanosecond = 0
        
        return calendar.dateFromComponents(components)!
    }
    
    public func earlierSunday() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .WeekOfMonth, .Weekday], fromDate: self)
        let weekday = components.weekday
        let daysToSunday = -((weekday - 1) % 7)
        return self.dateByAddingTimeInterval(NSTimeInterval(daysToSunday * 60 * 60 * 24))
    }
    
}
