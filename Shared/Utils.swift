//
//  Utils.swift
//  ToDue
//
//  Created by Niklas Kuder on 24.08.22.
//

import Foundation
import SwiftUI

class Utils {
    static func _remainingTime(_ givenTask: Task?, granularity: Set<Calendar.Component> = [.month, .day]) -> DateComponents {
        if let task = givenTask, let date = task.date, date < Date.distantFuture {
            let diff = Calendar.current.dateComponents(granularity, from: Date().removeTimeStamp, to: date)
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
    
    static func shortRemainingTimeLabel(task: Task?) -> LocalizedStringKey {
        let remainingTime = _remainingTime(task)
        if let months = remainingTime.month,
            let days = remainingTime.day {
            if months > 0 {
                return "\(months) M, \(days) D"
            } else if days >= 0 {
                return "\(days) days_short"
            } else {
                return "Overdue"
            }
        } else {
            return "-"
        }
    }
    
    // MARK: - Notifications
    
    private static func getTaskNotificationContent(for task: Task) -> UNMutableNotificationContent {
        let messagePrefix = NSString.localizedUserNotificationString(forKey: "due_in", arguments: nil)
        let remainingTime = _remainingTime(task, granularity: [.day])
        let days: Int = remainingTime.day ?? 0
        let remainingTimeSuffix = days == 1 ? NSString.localizedUserNotificationString(forKey: "day_singular", arguments: nil) : NSString.localizedUserNotificationString(forKey: "days_plural", arguments: nil)
        
        
        let content = UNMutableNotificationContent()
        content.title = task.taskTitle ?? "Unknown Task"
        content.body = messagePrefix + " \(days) " + remainingTimeSuffix
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
    
    static func scheduleNewNotification(for task: Task) {
        if let date = task.date, date < Date.distantFuture {
            let newDayDelta = UserDefaults.standard.integer(forKey: "notificationDayDelta")
            let newReminderTime = Date(rawValue: UserDefaults.standard.string(forKey: "notificationReminderTime") ?? "")
            if let time = newReminderTime {
                let reminderComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: time)
                scheduleNewNotification(for: task, on: Calendar.current.date(byAdding: .day, value: newDayDelta * -1, to: date)!, withTime: reminderComponents)
            } else {
                scheduleNewNotification(for: task, on: Calendar.current.date(byAdding: .day, value: newDayDelta * -1, to: date)!)
            }
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
            scheduleDate > Date() {
            let request = UNNotificationRequest(identifier: uuid.uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
            print("Scheduled notification for \(task.taskTitle ?? "Unknown") on \(dateComponents.description)")
        }
    }
    
    static func scheduleReminderNotification(reminder: Reminder) {
        guard let task = reminder.task, let date = reminder.dateTime, date > Date() else {
            return
        }
        guard let uuidStr = reminder.id?.uuidString else {
            return
        }
        let content = getTaskNotificationContent(for: task)
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: uuidStr, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    static func cancelNotification(for reminder: Reminder) {
        guard let uuid = reminder.id else {
            return
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [uuid.uuidString])
    }
    
    static func cancelNotification(for task: Task) {
        if let uuid = task.id {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [uuid.uuidString])
        }
    }
}
