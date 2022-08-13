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
}
