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
    @Published var saveButtonDisabled: Bool = true
    @Published var hasDeadline: Bool
    @Published var category: TaskCategory?
    
    init(task: Task?) {
        self.task = task
        self.taskTitle = task?.taskTitle ?? ""
        self.taskDescription = task?.taskDescription ?? ""
        self.category = task?.category
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
