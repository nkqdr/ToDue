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
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return dateFormatter
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
    
    // MARK: - Notifications
    
    private static func getTaskNotificationContent(for task: Task) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = task.taskTitle ?? "Unknown Task"
        content.subtitle = "Task is almost due!"
        content.sound = UNNotificationSound.default
        return content
    }
    
    /// This function is only used for debugging
    static func scheduleTestNotification(for task: Task) {
        let content = getTaskNotificationContent(for: task)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        if let uuid = task.id {
            print("Scheduling")
            let request = UNNotificationRequest(identifier: uuid.uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    static func scheduleNewNotification(for task: Task, on date: Date, withTime: DateComponents = DateComponents(hour: 8, minute: 0, second: 0)) {
        let content = getTaskNotificationContent(for: task)
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        dateComponents.hour = withTime.hour
        dateComponents.minute = withTime.minute
        dateComponents.second = withTime.second
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        if let uuid = task.id,
            let scheduleDate = Calendar.current.date(from: dateComponents),
            scheduleDate > Date.now {
            let request = UNNotificationRequest(identifier: uuid.uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    static func cancelNotification(for task: Task) {
        if let uuid = task.id {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [uuid.uuidString])
        }
    }
}
