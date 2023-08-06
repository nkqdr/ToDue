//
//  ReminderManager.swift
//  ToDue
//
//  Created by Niklas Kuder on 30.07.23.
//

import Foundation
import Combine

class ReminderManager: ObservableObject {
    @Published var reminders: [Reminder] = [] {
        didSet {
            self.pastReminders = reminders.filter { $0.dateTime ?? Date() < Date() }
            self.openReminders = reminders.filter { $0.dateTime ?? Date() >= Date() }
        }
    }
    @Published var pastReminders: [Reminder] = []
    @Published var openReminders: [Reminder] = []
    
    private var reminderCancellable: AnyCancellable?
    private var fetchController: ReminderFetchController
    
    init(task: Task) {
        self.fetchController = ReminderFetchController(task: task)
        let publisher = self.fetchController.reminders.eraseToAnyPublisher()
        
        self.reminderCancellable = publisher.sink { reminders in
            self.reminders = reminders
        }
    }
}
