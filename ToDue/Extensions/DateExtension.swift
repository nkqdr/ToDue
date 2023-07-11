//
//  DateExtension.swift
//  ToDue
//
//  Created by Niklas Kuder on 06.03.22.
//

import SwiftUI

extension DateComponents {
    public var wrappedMonth: Int {
        get {
            return self.month ?? Calendar.current.component(.month, from: Date())
        }
        set {
            self.month = newValue
        }
    }
    
    public var wrappedYear: Int {
        get {
            return self.year ?? Calendar.current.component(.year, from: Date())
        }
        set {
            self.year = newValue
        }
    }
    
    public var toDate: Date {
        Calendar.current.date(from: self) ?? Date()
    }
}

extension Date {
    public var removeTimeStamp : Date? {
        // Maybe a better solution? To be tested...
        // return Calendar.current.startOfDay(for: self)
        
       guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
        return nil
       }
       return date
    }
    
    public func isSameDayAs(_ otherDate: Date) -> Bool {
        return Calendar.current.compare(self, to: otherDate, toGranularity: .day) == .orderedSame
    }
    
    public static var rangeFromToday: PartialRangeFrom<Date> {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        return calendar.date(from: startComponents)!...
    }
    
    public var startOfThisMonth: Date {
        let myComps: DateComponents = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: DateComponents(year: myComps.wrappedYear, month: myComps.wrappedMonth, day: 1)) ?? Date()
    }
}

extension Date: RawRepresentable {
    public var rawValue: String {
        self.timeIntervalSinceReferenceDate.description
    }
    
    public init?(rawValue: String) {
        self = Date(timeIntervalSinceReferenceDate: Double(rawValue) ?? 0.0)
    }
}
