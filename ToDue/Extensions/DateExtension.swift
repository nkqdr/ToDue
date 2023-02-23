//
//  DateExtension.swift
//  ToDue
//
//  Created by Niklas Kuder on 06.03.22.
//

import SwiftUI

extension Date {
    public var removeTimeStamp : Date? {
       guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
        return nil
       }
       return date
    }
    
    private func isSameXAs(_ otherDate: Date, comps: Set<Calendar.Component>) -> Bool {
        let myComps: DateComponents = Calendar.current.dateComponents(comps, from: self)
        let otherComps: DateComponents = Calendar.current.dateComponents(comps, from: otherDate)
        return Calendar.current.date(from: myComps) == Calendar.current.date(from: otherComps)
    }
    
    public func isSameDayAs(_ otherDate: Date) -> Bool {
        return isSameXAs(otherDate, comps: [.year, .month, .day])
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
