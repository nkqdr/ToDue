//
//  Utils.swift
//  ToDue
//
//  Created by Niklas Kuder on 24.08.22.
//

import Foundation
import SwiftUI

class Utils {
    static func _remainingTime(_ givenTask: Task?) -> DateComponents {
        if let task = givenTask {
            let diff = Calendar.current.dateComponents([.month, .day], from: Date.now.removeTimeStamp!, to: task.date!)
            return diff
        } else {
            return Calendar.current.dateComponents([], from: Date.distantPast)
        }
    }

    static func remainingTimeLabel(task: Task?) -> LocalizedStringKey {
        let remainingTime = _remainingTime(task)
        if let months = remainingTime.month,
            let days = remainingTime.day {
            if months > 0 {
                return "\(months) Months, \(days) Days"
            } else if days >= 0 {
                return "\(days) Days"
            } else {
                return "Task is past due!"
            }
        } else {
            return "No tasks!"
        }
    }
}
