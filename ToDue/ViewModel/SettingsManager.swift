//
//  SettingsManager.swift
//  ToDue
//
//  Created by Niklas Kuder on 07.09.22.
//

import Foundation
import UserNotifications
import Combine

class SettingsManager: ObservableObject {
    static let shared: SettingsManager = SettingsManager()
    private var incompleteTasks: [Task] = []
    private var taskCancellable: AnyCancellable?
    
    private init(taskPublisher: AnyPublisher<[Task], Never> = TaskStorage.shared.tasks.eraseToAnyPublisher()) {
        taskCancellable = taskPublisher.sink { tasks in
            print("Updating tasks in SettingsManager...")
            self.incompleteTasks = tasks.filter { !$0.isCompleted }
        }
    }
    
    func refreshNotifications() {
        print("Executing refresh on \(incompleteTasks.count) tasks")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        for task in incompleteTasks {
            Utils.scheduleNewNotification(for: task)
        }
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { notifications in
            print(notifications.count)
        })
    }
}
