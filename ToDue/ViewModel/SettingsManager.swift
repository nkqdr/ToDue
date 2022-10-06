//
//  SettingsManager.swift
//  ToDue
//
//  Created by Niklas Kuder on 07.09.22.
//

import Foundation
import UserNotifications
import Combine
import CloudKit

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
    
    private func printNotificationCount() {
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { notifications in
            print(notifications.count)
        })
    }
    
    // MARK: - Intents
    
    func handleIcloudSyncToggle(_ newValue: Bool) {
        // set the use_icloud_sync key to be true/false depending on the toggle state
        NSUbiquitousKeyValueStore.default.set(newValue, forKey: "use_icloud_sync")
        
        // delete the zone in iCloud if user switch off iCloud sync
        if !newValue {
            let container = CKContainer(identifier: "iCloud.com.niklaskuder.ToDue")
            let database = container.privateCloudDatabase
            // instruct iCloud to delete the whole zone (and all of its records)
            database.delete(withRecordZoneID: .init(zoneName: "com.apple.coredata.cloudkit.zone"), completionHandler: { (zoneID, error) in
                if let error = error {
                    print("deleting zone error \(error.localizedDescription)")
                }
            })
        }
    }
    
    func removeAllReminderNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        printNotificationCount()
    }
    
    func setAllReminderNotifications() {
        for task in incompleteTasks {
            Utils.scheduleNewNotification(for: task)
        }
        printNotificationCount()
    }
    
    func refreshNotifications() {
        print("Executing refresh on \(incompleteTasks.count) tasks")
        removeAllReminderNotifications()
        setAllReminderNotifications()
    }
}
