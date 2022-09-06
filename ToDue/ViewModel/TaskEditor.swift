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
    
    init(task: Task?) {
        self.task = task
        self.taskTitle = task?.taskTitle ?? ""
        self.taskDescription = task?.taskDescription ?? ""
        self.taskDueDate = task?.date ?? Date()
    }
    
    init() {
        self.taskTitle = ""
        self.taskDescription = ""
        self.taskDueDate = Date()
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
