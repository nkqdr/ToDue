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
}
