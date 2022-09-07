//
//  SettingsManager.swift
//  ToDue
//
//  Created by Niklas Kuder on 07.09.22.
//

import Foundation

class SettingsManager: ObservableObject {
    static let shared: SettingsManager = SettingsManager()
    static let defaultNotificationReminderTime: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 0, second: 0))!
    static let defaultNotificationDayDelta: Int = 1
    
    @Published var notificationReminderTime: Date = defaultNotificationReminderTime {
        willSet {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            print(components)
        }
    }
    @Published var notificationDayDelta: Int = defaultNotificationDayDelta {
        willSet {
            print(newValue)
        }
    }
    
    private init() {
        // TODO: Load current UserDefaults
    }
}
