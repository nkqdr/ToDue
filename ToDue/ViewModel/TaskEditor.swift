//
//  TaskEditor.swift
//  ToDue
//
//  Created by Niklas Kuder on 31.08.22.
//

import Foundation

/// This class is used as a controller for editing and creating tasks
class TaskEditor: ObservableObject {
    private(set) var task: Task?
    
    @Published var taskTitle: String
    @Published var taskDescription: String
    @Published var taskDueDate: Date
    @Published var scheduledDate: Date
    @Published var saveButtonDisabled: Bool = true
    @Published var hasDeadline: Bool
    @Published var category: TaskCategory?
    @Published var isScheduled: Bool
    
    init(task: Task?) {
        self.task = task
        self.taskTitle = task?.taskTitle ?? ""
        self.taskDescription = task?.taskDescription ?? ""
        self.category = task?.category
        self.scheduledDate = task?.scheduledDate ?? Date()
        self.isScheduled = task?.scheduledDate != nil
        if let task = task, let date = task.date {
            self.taskDueDate = date == Date.distantFuture ? Date() : date
            self.hasDeadline = date != Date.distantFuture
        } else {
            self.taskDueDate = Date()
            self.hasDeadline = true
        }
    }
    
    init() {
        self.taskTitle = ""
        self.taskDescription = ""
        self.taskDueDate = Date()
        self.hasDeadline = true
        self.scheduledDate = Date()
        self.isScheduled = false
    }
    
    // MARK: - Intents
    
    func changeTitle(newValue: String) {
        if (newValue.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
            saveButtonDisabled = false
        } else {
            saveButtonDisabled = true
        }
    }
}
