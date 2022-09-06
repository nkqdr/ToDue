//
//  SubtaskEditor.swift
//  ToDue
//
//  Created by Niklas Kuder on 31.08.22.
//

import Foundation

/// This class is used as a controller for editing and creating subtasks
class SubtaskEditor: ObservableObject {
    private(set) var subtask: SubTask?
    private(set) var task: Task
    
    @Published var subtaskTitle: String
    @Published var saveButtonDisabled: Bool = true
    
    init(_ subtask: SubTask?, on task: Task) {
        self.subtask = subtask
        self.subtaskTitle = subtask?.title ?? ""
        self.task = task
    }
    
    init(on task: Task) {
        self.subtaskTitle = ""
        self.task = task
    }
    
    // MARK: - Intents
    
    func changeTitleValue(newValue: String) {
        if (newValue.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
            saveButtonDisabled = false
        } else {
            saveButtonDisabled = true
        }
    }
}
